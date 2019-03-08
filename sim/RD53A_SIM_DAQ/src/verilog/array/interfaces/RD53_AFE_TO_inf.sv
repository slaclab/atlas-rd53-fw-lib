`ifndef  RD53_AFE_TO_IF__SV
`define  RD53_AFE_TO_IF__SV

interface RD53_AFE_TO_dig_if  ;

    //wire  TESTP; (global)
    // configuration bits
	wire POWER_DOWN_TO;
    
   // delay line signals (fast mode)
    wire DELAY_IN_TO;
    wire DELAY_OUT_TO;
    
    // hit output (latch differential) 
    wire VOUTP_TO;
    wire VOUTN_TO;

	wire S0, S1;
    
	modport afe (
		input S0,
		input S1,
	    input POWER_DOWN_TO,
        input DELAY_IN_TO,
        output DELAY_OUT_TO,
	    output VOUTP_TO,
        output VOUTN_TO
	);
	modport fe_control (
		output S0,
		output S1,
        output POWER_DOWN_TO,
	    output DELAY_IN_TO,
        input DELAY_OUT_TO,
        input VOUTP_TO,
        input VOUTN_TO
	);
	
endinterface: RD53_AFE_TO_dig_if

interface RD53_AFE_TO_analog_if  ;

   wire  [7:0] IBIASP1_TO; 
   wire  [7:0] IBIASP2_TO;
   wire  [7:0] VCASN_TO;
   wire  [7:0] VCASP1_TO;
   wire [7:0] IBIAS_SF_TO;

   // Krummenacher feedback bias lines
   wire [7:0]   VREF_KRUM_TO;
   wire [7:0]   VCAS_KRUM_TO;
   wire [7:0]   IBIAS_FEED_TO;
//   wire [7:0]   GNDA_KRUM_TO;


   // DISC preamp bias lines
   wire [7:0]   IBIAS_DISC_TO;
   wire [7:0]   VCASN_DISC_TO;
   wire [7:0]   VBL_DISC_TO;
   wire [7:0]   VTH_DISC_TO;

   // calibration circuit DC levels and charge-injection test-pulse
   wire [7:0]   CAL_HI;
   wire [7:0]   CAL_MI;
   wire [7:0]   ICTRL_TOT_TO;

modport afe(
	input IBIASP1_TO,  IBIASP2_TO, VCASN_TO, VCASP1_TO, IBIAS_SF_TO, VREF_KRUM_TO, VCAS_KRUM_TO,// GNDA_KRUM_TO,
    IBIAS_FEED_TO, IBIAS_DISC_TO, VCASN_DISC_TO, VBL_DISC_TO, VTH_DISC_TO, CAL_HI, CAL_MI, ICTRL_TOT_TO
);
	
endinterface: RD53_AFE_TO_analog_if

`endif