//
// Global Configuration FIFO with Syncronous reset
//
module MonFifo #(// Parameters
                parameter DataWidth = 27,
                parameter AddrWidth = 3)    // FifoDepth is (1 << AddrWidth)
               (// Inputs
                input  wire logic [DataWidth-1:0] InData,
                input  wire logic                 clk,       // 160 MHz clock
                input  wire logic                 reset,     // Syncronous reset active high
                input  wire logic                 Write,
                input  wire logic                 Read,
                // Outputs
                output logic [DataWidth-1:0] OutData,
                output logic                 Full,
                output logic                 Empty);
                 
// Parameters
parameter FifoDepth = (1 << AddrWidth);

logic [AddrWidth-1:0] WrPtr;
logic [AddrWidth-1:0] RdPtr;
logic [AddrWidth  :0] WordCnt;
logic [DataWidth-1:0] MemOutData;

//
// Determine FifoFull condition
//assign Full  = (WordCnt == FifoDepth);
always_ff @(posedge clk) begin : Full_AFF
    Full <= (WordCnt == FifoDepth);
end : Full_AFF

//
// Determine Fifo Empty condition
//assign Empty = (WordCnt == 0);
always_ff @(posedge clk) begin : Empty_AFF
    Empty <= (WordCnt == 0);
end : Empty_AFF

// 
// Set write pointer
always_ff @(posedge clk) begin : WrPtr_AFF
    if (reset == 1'b1) begin
        WrPtr    <= 0;
    end
    else 
        if (Write & ~Full) WrPtr <= WrPtr + 1;
        else               WrPtr <= WrPtr;
    end : WrPtr_AFF

//
// Set read pointer
always @(posedge clk) begin : RdPtr_AFF
    if (reset == 1'b1)
        RdPtr <= 0;
    else
        if (Read & ~Empty) RdPtr <= RdPtr + 1;
        else               RdPtr <= RdPtr;
    end : RdPtr_AFF

//
// Calculate how many words are in the Fifo
always_ff @(posedge clk) begin : WordCnt_AFF
    if (reset == 1'b1)
        WordCnt <= 0;
    else
        if (Write && !Read && (Full != 1'b1))
            WordCnt <= WordCnt + 1;
        else if (Read && !Write && (Empty != 1'b1))
            WordCnt <= WordCnt - 1;
        else
            WordCnt <= WordCnt;
    end : WordCnt_AFF

//
// always @(posedge clk)
//     if(Read & ~Empty)
//         OutData <= MemOutData;
assign OutData = MemOutData;
   
//
// Instance of the Memory
MonMem #(.DataWidth(DataWidth), .AddrWidth(AddrWidth)) Mem (.WrAddr(WrPtr),
                                                            .RdAddr(RdPtr),
                                                            .InData(InData),
                                                            .OutData(MemOutData),
                                                            .Write( Write & ~Full ),
                                                            .clk(clk));

endmodule : MonFifo
