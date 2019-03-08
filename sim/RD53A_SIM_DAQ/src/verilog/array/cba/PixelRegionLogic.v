
`include "top/RD53A_defines.sv"
`include "array/cba/PixelRegionLatencyMem.v"
`include "array/cba/StagingBuffer.v"
`include "array/interfaces/CoreCBAIf.sv"

`define PIPE_WIDTH 4

module PixelRegionLogic_CBA (Clk, Reset, L1Trig, TrigId, TrigIdReq, Read, DataToCore, Readys, ToTs,
					TokIn, TokOut, LatCnt, LatCntReq, PwrDwn, WriteSyncTime
					);

input [`CBA_REG_PIXELS-1:0] Readys;
input [`CBA_REG_PIXELS*`CBA_TOT_BITS-1:0] ToTs;

input wire Clk, Reset, L1Trig, Read;

input wire TokIn;
output wire TokOut;

output [`CBA_DATA_BITS-1:0] DataToCore;

input wire [4:0] TrigId, TrigIdReq;

input wire [8:0] LatCnt, LatCntReq;

input [`CBA_REG_PIXELS-1:0] PwrDwn;

input [`CBA_SG_LATENCY_BITS-1:0] WriteSyncTime;

/*
* Now the logic
*/

wire [`CBA_DATA_BITS-1:0] data;

wire le;

wire pix_off_cnfg;

wire [`CBA_DATA_BITS-1:0] triggered_data;

wire en_out;
wire en_out_pre;
assign en_out = en_out_pre & ~pix_off_cnfg;

assign data = en_out ? triggered_data : 0;
assign DataToCore = data;

wire clk_off;
assign clk_off = Clk & ~pix_off_cnfg;


wire clk_le;
assign clk_le = (~Clk & le);

wire [`CBA_TOT_SLOTS*`CBA_TOT_BITS-1:0] writer_tots;
wire [`CBA_REG_PIXELS-1:0] rdwHitMap;

/*
* Staging buffer
*/

wire sta_clk, sta_write;
assign sta_clk = Clk;

StagingBuffer sg (
	.clk(sta_clk),
	.reset(Reset),
	.WriteSyncTime(WriteSyncTime),
	.imap(Readys),
	.omap(rdwHitMap),
    .write(sta_write)
);

/*
* Remapping
*/

localparam int order [`CBA_REG_PIXELS] = `CBA_PIX_ORDER;
wire [`CBA_REG_PIXELS*`CBA_TOT_BITS-1:0] remapped_tots;
wire [`CBA_REG_PIXELS-1:0] remapped_hitmap;

generate
genvar pix;
for(pix=0;pix<`CBA_REG_PIXELS;pix++) begin
    assign remapped_tots[(pix+1)*`CBA_TOT_BITS-1-:`CBA_TOT_BITS] = ToTs[(order[pix]+1)*`CBA_TOT_BITS-1-:`CBA_TOT_BITS];
    assign remapped_hitmap[pix] = rdwHitMap[order[pix]];
end
endgenerate

/*
* ToT Compression
*/

RegionDigitalWriter #(
		.TOT_BITS(`CBA_TOT_BITS),
		.WIDTH(`CBA_TOT_SLOTS)
	) rdw (
		.totValues(remapped_tots),
		.hitReady(remapped_hitmap),
		.memoryDataTotValues(writer_tots)
	);

assign le = sta_write;

PixelRegionLatencyMem_CBA  quad_core(
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
	.LatCnfg(LatCnt),
	.LatCnfg2(LatCntReq),
	.PixOffCnfg(pix_off_cnfg),
	.WriterData({remapped_hitmap, writer_tots}),
	.TriggeredData(triggered_data)
);

assign pix_off_cnfg = &PwrDwn;

endmodule //PixelRegionLogic

