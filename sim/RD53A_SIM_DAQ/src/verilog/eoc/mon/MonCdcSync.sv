//
// CDC Sync circuit [MUX recirculation synchronizer]
//
module MonCDCSync #(parameter DSIZE = 34)
    (
    output      logic [DSIZE-1:0] OutData,
    output      logic             WriteDone,
    input  wire logic [DSIZE-1:0] InData,
    input  wire logic             WrRst,
    input  wire logic             Write,    
    input  wire logic             RdClk, 
    input  wire logic             WrClk, 
    input  wire logic             RdRst
    );
        
//
// Strech Write signal and keep it high until WriteDone is generated
// Uses 160MHz clock
//
logic WriteStr;
//
always_ff @(posedge WrClk) begin : Strech_AFF
    if (WrRst == 1'b1) WriteStr <= 1'b0;
    else begin
        if (Write == 1'b1) WriteStr <= 1'b1;
        else               WriteStr <= (WriteDone == 1'b1) ? 1'b0 : WriteStr;
    end
end

//
// Synchronize InData
logic WriteDly, WrSync;
//
always_ff @(posedge RdClk) begin : Sync_AFF
    {WrSync,WriteDly} <= {WriteDly,WriteStr};
end : Sync_AFF

//
// Detect rising edge of WrSync
logic WrSyncEdge, WrSyncDly;
always_ff @(posedge RdClk) begin : WrSyncEdge_AFF
    WrSyncDly <= WrSync;
    if ({WrSyncDly,WrSync} == 2'b01) WrSyncEdge <= 1'b1;
    else                             WrSyncEdge <= 1'b0;
end : WrSyncEdge_AFF

//
// Write output data
always_ff @(posedge RdClk) begin : OutData_AFF
    if(RdRst == 1'b1) begin
        OutData <= 'b0;
    end else begin
        if (WrSyncEdge == 1'b1) OutData <= InData;
        else                    OutData <= OutData;
    end
end : OutData_AFF

//
// In addition we have to generate a sygnal to be used with 160MHz clock to know when data has been copied
//
logic WrSyncEdgeDly;
//
always_ff @(posedge WrClk) begin : WriteDone_AFF
    {WriteDone,WrSyncEdgeDly} <= {WrSyncEdgeDly,WrSyncEdge};
end : WriteDone_AFF



endmodule // MonCDCSync
