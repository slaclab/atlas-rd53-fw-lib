`ifndef  RD53_AFE_LBNL_IF__SV
`define  RD53_AFE_LBNL_IF__SV

interface RD53_AFE_LBNL_dig_if  ;
    
    wire S0, S1 ;
    wire [3:0] DTH1, DTH2	;
    
    wire outdis; // discriminator output (negative polarity)

    
	modport afe (
        input  S0, S1,	
        input  DTH1, DTH2,
        output outdis
	);
	modport fe_control (
        output  S0, S1,	 
        output  DTH1, DTH2,
        input outdis	
	);
	
endinterface: RD53_AFE_LBNL_dig_if

interface RD53_AFE_LBNL_analog_if  ;
    
    wire [7:0]  CAL_HI, CAL_MI;
    wire [7:0] PrmpVbnFol, PrmpVbp, VctrCF0, VctrLCC, compVbn, preCompVbn, vbnLcc, vff, vthin1, vthin2 ;

modport afe(
    input CAL_HI, CAL_MI,
    input PrmpVbnFol, PrmpVbp, VctrCF0, VctrLCC, compVbn, preCompVbn, vbnLcc, vff, vthin1, vthin2 
);
	
endinterface: RD53_AFE_LBNL_analog_if

`endif