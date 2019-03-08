
module FeControl_BGPV(

    input DefConf,
    input DefCalEn,
    input Wr, 
    input [7:0] DataIn,
    output reg [7:0] DataOut,
    input S0,
    input S1,
    input  CalEdge,
    input  EnDigHit,
    
    RD53_AFE_BGPV_dig_if.fe_control	AnaToDigInf,

    output wire HitOut, HitOr
);

logic hit_en;
logic hit_or_en;
logic cal_en;
logic [3:0] t_dac;
logic gain_sel;
// Latched configuration
logic hit_en_latch;
logic hit_or_en_latch;
logic cal_en_latch;
logic [3:0] t_dac_latch;
logic gain_sel_latch;

`ifdef INIT_PIXEL_CONF
    initial begin
        #500ns gain_sel_latch = 1;
        t_dac_latch = 1000;
        hit_or_en_latch = `INIT_PIXEL_CONF;
        cal_en_latch = 0; // CAL_EN is active high
        hit_en_latch = `INIT_PIXEL_CONF;
    end
`endif

always@(*)
    if(Wr)
        {gain_sel_latch, t_dac_latch, hit_or_en_latch, cal_en_latch, hit_en_latch} = DataIn;
   
always@(*)
    if(DefConf)
        {gain_sel, t_dac, hit_or_en, cal_en, hit_en} = {1'b1,4'b1000, 1'b1, DefCalEn, 1'b1};
    else 
        {gain_sel, t_dac, hit_or_en, cal_en, hit_en} = {gain_sel_latch, t_dac_latch, hit_or_en_latch, cal_en_latch, hit_en_latch} ;
      
assign DataOut = {gain_sel, t_dac, hit_or_en, cal_en, hit_en};

// Defaults

// S0 and S1 to AFE locally gated based on cal_en configuration bit
// inversion based on pixel position should happen in Core
assign AnaToDigInf.S0 = cal_en? S0 : 1'b1;
assign AnaToDigInf.S1 = cal_en? S1 : 1'b1; 

assign AnaToDigInf.TH_DAC   = t_dac;
assign AnaToDigInf.GAIN_SEL = gain_sel;

wire hit;
assign hit = AnaToDigInf.HIT; // Positive polarity.

// Outputs

assign hit_t = EnDigHit ? (CalEdge & cal_en) : hit ;
assign HitOut = hit_t & hit_en;
assign HitOr = hit_t & hit_or_en & hit_en; // Mask hit-or if AFE is powered-down 
assign AnaToDigInf.POWER_DOWN = ~hit_en;

endmodule: FeControl_BGPV
