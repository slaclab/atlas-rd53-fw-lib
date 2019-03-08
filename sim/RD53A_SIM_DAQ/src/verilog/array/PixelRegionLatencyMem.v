`include "array/PixelLogic.v"
`include "array/LatencyMemCell.v"

`ifndef  PIXEL_REGION_LATENCY_MEM__V
`define  PIXEL_REGION_LATENCY_MEM__V

module PixelRegionLatencyMem(LE, L1, Reset ,Clk, TokIn, TokOut, ReadData, L1In, L1Req, EnOut,
LeAddr, Read, LatCnfg, LatCnfg2, PixOffCnfg); 

input wire LE, L1, Reset, Clk, ReadData;


input PixOffCnfg;

input wire TokIn;
output wire TokOut;

output wire EnOut;

input wire [4:0] L1In;
input wire [4:0] L1Req;
input wire [8:0] LatCnfg, LatCnfg2;

output wire [`MEM-1:0] LeAddr;
output wire [`MEM-1:0] Read;

// pixel positon
// 0  2 
// 1  3

wire [`MEM-1:0] ready_to_read;
wire [`MEM-1:0] full;

wire [`MEM-1:0] demux_le;

wire [3:0] data [`MEM-1:0];        
wire [`MEM-1:0] read_lat_mem;

generate
    genvar k;
    for (k=0; k<`MEM; k=k+1)
    begin: latency_mem
      LatencyMemCell mem( 
                    .Clk(Clk), 
                    .Reset(Reset), 
                    .WriteLe(demux_le[k]), 
                    .L1(L1), 
                    .Full(full[k]), 
                    .ReadyToRead(ready_to_read[k]), 
                    .Read(read_lat_mem[k]),
                    .L1In(L1In), 
                    .L1Req(L1Req),
                    .LatCntIn(LatCnfg),
                    .LatCntReq(LatCnfg2)
                    );
     end 
endgenerate        


// -------------  TE  storeage  &  adress calc---------------------

wire [`MEM-1:0] free_le_addr;

generate
    genvar m;
    for (m=0; m<`MEM; m=m+1)
    begin : addr_dec    
        if( m==0 )
            assign free_le_addr[m] = (full[m]==0);
        else
            assign free_le_addr[m] = (full[m]==0 & ( &full[m-1:0] ));
    end 
endgenerate 

assign demux_le = {`MEM{LE}} & free_le_addr;

assign LeAddr = free_le_addr;

// -------------Read and Output  ---------------------
logic is_triggered_to_read;
assign is_triggered_to_read = (ready_to_read != 0);

wire token_rise; //synopsys keep_signal_name "token_rise"
assign token_rise = (is_triggered_to_read & ~PixOffCnfg); 

assign TokOut = token_rise | TokIn;

assign EnOut = (TokIn == 0 && is_triggered_to_read );

/*
wire [`MEM-1:0] trigger_read;

generate
    genvar t;
    for (t=0; t<`MEM; t=t+1)
    begin: read_dec    
        if( t==0 )
            assign trigger_read[t] = (ready_to_read[t]==1);
        else
            assign trigger_read[t] = (ready_to_read[t]==1 & !( |ready_to_read[t-1:0] ));
    end 
endgenerate */

assign Read = EnOut ? ready_to_read : 0 ;

assign read_lat_mem = (EnOut & ReadData) ? ready_to_read : 0 ;

// -------------END Read and Output  ---------------------

endmodule //PixelRegionLatencyMem

`endif