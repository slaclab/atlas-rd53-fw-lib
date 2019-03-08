

module FeControl_LBNL(
    
    input wire DefConf,
    input wire DefCalEn,
    input wire Wr, 
    input wire [7:0] DataIn,
    output reg [7:0] DataOut,
    input wire S0,
    input wire S1,
    input wire CalEdge,
    input wire EnDigHit,
     
    RD53_AFE_LBNL_dig_if.fe_control	AnaToDigInf,
    output wire PowerDownToRegion,
    output wire HitOut, HitOr
);

logic hit_en;
logic hit_or_en;
logic cal_en;
logic [3:0] t_dac;
logic sign;
// Latched configuration
logic hit_en_latch;
logic hit_or_en_latch;
logic cal_en_latch;
logic [3:0] t_dac_latch;
logic sign_latch;

`ifdef INIT_PIXEL_CONF
    initial begin
        sign_latch = 0;
        t_dac_latch = 4'b1111;
        hit_or_en_latch = `INIT_PIXEL_CONF;
        cal_en_latch = 0;
        hit_en_latch = `INIT_PIXEL_CONF;
     end
 `endif
 
always@(*)
    if(Wr)
        {sign_latch, t_dac_latch, hit_or_en_latch, cal_en_latch, hit_en_latch} = DataIn;

always@(*)
    if(DefConf)
        {sign, t_dac, hit_or_en, cal_en, hit_en} = {1'b0, 4'b1111, 1'b1, DefCalEn, 1'b1}; 
    else 
        {sign, t_dac, hit_or_en, cal_en, hit_en} = {sign_latch, t_dac_latch, hit_or_en_latch, cal_en_latch, hit_en_latch} ;


assign DataOut = {sign, t_dac, hit_or_en, cal_en, hit_en};

// Defaults

// S0 and S1 to AFE locally gated based on cal_en configuration bit
// inversion based on pixel position should happen in Core
assign AnaToDigInf.S0 = cal_en? S0 : 1'b1;
assign AnaToDigInf.S1 = cal_en? S1 : 1'b1; 

wire pix_d; 
assign pix_d = 1'b0; // Hard wire to zero (Dario).
assign AnaToDigInf.DTH1 = sign ? {4{pix_d}} : t_dac;
assign AnaToDigInf.DTH2 = sign ? t_dac : {4{pix_d}};

wire hit;
// LBNL FE - low driving capabilities - force a buffer in the layout (add if needed).
wire DiscBuffered;
//BUFFD0 disc_buff_dont_touch (.Z(DiscBuffered), .I(AnaToDigInf.outdis));
//assign hit = ~DiscBuffered;
assign hit = ~AnaToDigInf.outdis; // Negative polarity --> INVERTER.

// Outputs
assign hit_t = EnDigHit ? (CalEdge & cal_en) : hit ;
assign HitOut = hit_t & hit_en;
assign HitOr = hit_t & hit_or_en & hit_en; 
assign PowerDownToRegion = ~hit_en;



endmodule  //FeControl_LBNL
