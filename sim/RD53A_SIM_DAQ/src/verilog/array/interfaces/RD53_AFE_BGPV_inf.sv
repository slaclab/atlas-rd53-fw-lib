`ifndef  RD53_AFE_BGPV_IF__SV
`define  RD53_AFE_BGPV_IF__SV

interface RD53_AFE_BGPV_dig_if  ;
	
	// Pulses driving injection circuit
	wire  S0, S1; 
	// configuration bits
	wire  GAIN_SEL;
	wire  POWER_DOWN;
	wire  [3:0] TH_DAC;
	 // single-ended discriminator asynchronous output
	wire HIT; // name changed based on AFE doc.
	
	modport afe(
	    input   S0,
        input   S1,
	    input  GAIN_SEL,
	    input  POWER_DOWN,
	    input  TH_DAC,
	    output HIT
	);
	modport fe_control (
	    output  S0,
        output  S1,
	    output GAIN_SEL,
	    output POWER_DOWN,
	    output TH_DAC,
	    input   HIT

	);
	
endinterface: RD53_AFE_BGPV_dig_if




interface RD53_AFE_BGPV_analog_if (  
    input [7:0] COMP_BIAS_BG,
    input [7:0] IHU_KRUM_BG,
    input [7:0] IHD_KRUM_BG,
    input [7:0] IFC_BIAS_BG,
    input [7:0] IPA_IN_BIAS_BG, 
    input [7:0] VRIF_KRUM_BG,
    input [7:0] VTH_BG, 
    input [7:0] ILDAC_MIR1_BG, 
    input [7:0] ILDAC_MIR2_BG, 
    input [7:0] CAL_HI, 
    input [7:0] CAL_MI  
 );
	
endinterface: RD53_AFE_BGPV_analog_if

`endif