`include "array/CgWrapper.v"
`include "array/cba/components/DoublePulse.v"

`include "array/interfaces/CoreCBAIf.sv"

//timescale 1ns/10ps
`ifndef T_ff_SN_TO
module T_ff_SN_TO(q, clk, set); 

output reg q;
input wire clk, set;

always @ (negedge clk or posedge set)
    if(set)
        q <= 1;
    else
        q <= !q;

endmodule
`endif

module FeControl_CBA_TO(
    input Clk,
	input ClkDig,
    output ClkPixel,
    input DefConf,
    input DefCalEn,
    input Reset, // active high
    input Wr, 
    input [2:0] DataIn,
    output reg [2:0] DataOut,
    input FastEn,
    input wire CalEdge,
    input wire EnDigHit,

    input wire Mask,
    input wire S0,
    input wire S1,

    RD53_AFE_TO_dig_if.fe_control    AnaToDigInf,
    output wire PresentPulse, HitOr, TotSavePulse,
    output reg [`CBA_TOT_BITS-1:0] ToT
);

logic hit_en;
logic hit_or_en;
logic cal_en;
wire [`CBA_TOT_BITS-1:0] tot_cnt;
reg present;
reg cready, cpresent;
wire HitOut;

/*
* Combinatorial
*/

// Config
reg hit_or_en_latch, cal_en_latch, hit_en_latch;
always@(*)
    if(Wr)
        {hit_or_en_latch, cal_en_latch, hit_en_latch} =  DataIn;
   
always@(*)
    if(DefConf)
        {hit_or_en, cal_en, hit_en} = {1'b1, DefCalEn, 1'b1};
    else 
        {hit_or_en, cal_en, hit_en} = {hit_or_en_latch, cal_en_latch, hit_en_latch};
        
assign DataOut = {hit_or_en, cal_en, hit_en};

// S0 and S1 to AFE locally gated based on cal_en configuration bit
// inversion based on pixel position should happen in Core
assign AnaToDigInf.S0 = cal_en ? S0 : 1'b1;
assign AnaToDigInf.S1 = cal_en ? S1 : 1'b1; 

assign AnaToDigInf.POWER_DOWN_TO = ~hit_en;

// Hit flag generation, function of VoutP and VoutN
wire hit;
wire n1; // internal signal
wire n2; // internal signal
assign n1 = !(AnaToDigInf.VOUTN_TO & hit); // loop to produce hit
assign n2 = AnaToDigInf.VOUTP_TO & n1;
assign hit = !(n2) & !Reset; // | DefConf) ; // 


// Closing Delay line in FAST MODE (if hit present) 
reg valid; // used in CHIPIX65 to force latch in AFE to only latch on clock edge (power)
wire valid_delayed;

assign valid = ~(AnaToDigInf.VOUTP_TO & AnaToDigInf.VOUTN_TO) & cpresent;

assign AnaToDigInf.DELAY_IN_TO = FastEn ? valid : 1'b0;
assign valid_delayed = AnaToDigInf.DELAY_OUT_TO;
 
// Providing Strobe to AFE 
reg strobe;
assign strobe = (FastEn && cpresent) ? valid_delayed : Clk;
assign ClkPixel = strobe & ~Mask & hit_en;

/*
*  Outputs
*/

// If digital injection, emulate latch
reg dighit;
always @(posedge ClkDig or posedge Reset) begin
	if(Reset)
		dighit = 1'b0;
	else
		dighit = CalEdge & cal_en;
end

assign hit_t = EnDigHit ? dighit : hit ;
assign HitOut = hit_t & hit_en & ~Mask;        // TODO: Masking valid for both digital and analog inj?
assign HitOr = hit_t & hit_or_en & hit_en & ~Mask;

/*
* Detach from HitOut
*/
	
wire totOverflow;
wire npulse, ppulse, ppulsew;

always @(posedge HitOut, posedge ppulse)
    if(ppulse == 1'b1)
        cpresent = 1'b0;
    else
        cpresent = 1'b1;

assign cready = (cpresent & ~HitOut) | totOverflow;

/*
* Slow Clock domain
*/
wire clk_pix_en = cpresent | Reset | ppulsew;
wire clk_pix;

// clk_gated is the clock for everything in the pixel
CG_MOD CG_clk_gated(.ClkIn(Clk), .Enable(clk_pix_en), .ClkOut(clk_pix));

// present
always @(posedge clk_pix or posedge Reset)
	if(Reset)
		present = 1'b0;
	else
	    present = cpresent;

assign PresentPulse = cpresent & ~present;

DoublePulse pulses_gen (
    .clk(clk_pix),
    .reset(Reset),
    .enable(cready),
    .p1(npulse),
    .p2(ppulse),
    .pw(ppulsew)
);

/*
* Fast Clock domain
*/
assign totOverflow = (tot_cnt == 2**`CBA_TOT_BITS-2);
wire clk_tot_en = HitOut & cpresent & ~(totOverflow | ppulsew); // cpresent ensure clk_tot_en rises after valid is on
wire clk_tot; 
wire tot_rst;

// clk_tot is the clock for the TOT counter
CG_MOD CG_clk_tot(.ClkIn(~valid), .Enable(clk_tot_en), .ClkOut(clk_tot));
//assign clk_tot = ~valid & clk_tot_en;

assign tot_rst = Reset | ppulse;

// ToT Counter
T_ff_SN_TO fftb0(.q(tot_cnt[0]), .clk(~clk_tot), .set(tot_rst)); 
generate
    genvar tb;

    for(tb=1;tb<`CBA_TOT_BITS;tb++)
        T_ff_SN_TO fftb(.q(tot_cnt[tb]), .clk(tot_cnt[tb-1]), .set(tot_rst));
endgenerate

// Latch the TOT output, avoid useless switching
assign ToT = tot_cnt;
assign TotSavePulse = npulse;

endmodule //PixelLogic

