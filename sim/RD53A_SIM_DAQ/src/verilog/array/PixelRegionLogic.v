
`define MEM 8

`include "array/PixelRegionLatencyMem.v"

`ifndef  PIXEL_REGION_LOGIC__V
`define  PIXEL_REGION_LOGIC__V

module PixelRegionLogic (Clk, Reset, L1Trig, TrigId, TrigIdReq, Read, DataToCore, Hit,
                    TokIn, TokOut, LatCnt, LatCntReq, PwrDwn
                    );

// pixel positon
// 1  3 
// 0  2 

input [3:0] Hit;

input wire Clk, Reset, L1Trig, Read;

input wire TokIn;
output wire TokOut;

output [15:0] DataToCore; // Data Bus "fast" OR
//input [15:0] DataFromTop;
//output [15:0] DataToBot;

input wire [4:0] TrigId, TrigIdReq;

input wire [8:0] LatCnt, LatCntReq;

input [3:0] PwrDwn;
                     
wire [15:0] data;
wire [3:0] write_le_int;

wire [`MEM-1:0] le_addr; 
wire [`MEM-1:0] read_int;

wire le;
assign le = |write_le_int ;

wire [3:0] data_tot [3:0];

wire pix_off_cnfg;

wire [15:0] ham_data;
assign ham_data = {data_tot[3], data_tot[2], data_tot[1], data_tot[0]};

wire en_out;
wire en_out_pre;
assign en_out = en_out_pre & ~pix_off_cnfg;

assign data = en_out ? ham_data : 0;
assign DataToCore = data; // Data Bus "fast" OR
//assign DataToBot = DataFromTop | data;

wire clk_off;
assign clk_off = Clk & ~pix_off_cnfg;


generate
    genvar p;
        for (p=0; p < 4; p=p+1)  begin:  pixels_in_gen
            PixelLogic in (
                .Disc(Hit[p]), 
                .WriteLe(write_le_int[p]), 
                .LeAddr(le_addr),
                .LE(le),
                .Read(read_int),
                .Data(data_tot[p]),
                .Clk(clk_off),
                .Reset(Reset)
            );
        end // pixels_in_gen
endgenerate

PixelRegionLatencyMem  quad_core( 
    .LE(le),
    .L1(L1Trig), 
    .Reset(Reset),
    .Clk(clk_off), 
    .TokIn(TokIn),
    .TokOut(TokOut), 
    .ReadData(Read), 
    .L1In(TrigId),
    .L1Req(TrigIdReq),
    .EnOut(en_out_pre),
    .LeAddr(le_addr),
    .Read(read_int),
    .LatCnfg(LatCnt),
    .LatCnfg2(LatCntReq),
    .PixOffCnfg(pix_off_cnfg)
);

assign pix_off_cnfg = &PwrDwn; 

endmodule //PixelRegionLogic

`endif