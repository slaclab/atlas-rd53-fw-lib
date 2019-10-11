`include "array/interfaces/RD53_AFE_BGPV_inf.sv"

`ifndef  RD53_AFE_BGPV__SV
`define  RD53_AFE_BGPV__SV

module RD53_AFE_BGPV(

	// input stimulus from the simulation environment, but also a physical
	// pin connected to the bump pad in the full-custom layout
	input PIXEL_IN_BG,
	// ~~~~ Analog Bias IF ~~~~~~~~
	// CSA bias lines
	input  IFC_BIAS_BG,
	input  IPA_IN_BIAS_BG,
	// Krummenacher feedback bias lines
	//input VDD_KRUM_BG,
    input  VRIF_KRUM_BG,
	input  IHU_KRUM_BG,
	input  IHD_KRUM_BG,
	input  COMP_BIAS_BG,
	// global/local DAC bias
	input  VTH_BG,
	input  ILDAC_MIR1_BG,
	input  ILDAC_MIR2_BG,
	// calibration circuit DC levels and charge-injection test-pulse
	input  CAL_HI,
	input  CAL_MI,
    // Top padframe PIN
    output PA_OUT_BG, // pre-amplifier output 
    
	// analog power/ground
	//input  VDDA,
	//input  GNDA,
	// digital power/ground for DISC components
	//input  VDDD,
	//input  GNDD,
	// substrate
	//input  VSUB,.
	// ~~~~ end Analog Bias IF ~~~~~~~~
	// ~~~~ Digital IF ~~~~~~~~
	input  S0, S1,
	// configuration bits
	input  GAIN_SEL,
	input  POWER_DOWN,
	input  [3:0] TH_DAC,
	 // single-ended discriminator asynchronous output
	 output HIT
	// ~~~~ end Digital IF ~~~~~~~~
	);
    
    // **NOTE - module time unit in seconds! (use SI units for all calculations) --- check that does not make troubles.
	timeunit 1s;
	timeprecision 100ps;

// synopsys translate_off

	// internal hit, assigned either to the external digital pulse provided by the verifiction environment
	// or to the pulse generated during analog injection 
	logic hit_int ;


	// hit pulse from charge-injection
    logic hit_inj_S0 = 1'b0 ;
    logic hit_inj_S1 = 1'b0 ;

	// analogue front-end parameters
    parameter    Cinj   =	8.0e-15 ;   // 8 fF calibration circuit injection capacitance
	parameter    cal_hi = 500.0e-3  ;	// sample CAL_HI value
	parameter    cal_mi =  50.0e-3  ;	// nominal 50 mV CAL_MI value
	parameter    Idisch =  20.0e-9  ;	// feedback discharge current

	real  Qinj_S0 ;						// injected charge depending on (CAL_HI - CAL_MI) voltage difference
	real  ToT_S0 ;						// analogue time-over-threshold
	real  Qinj_S1 ;						// injected charge depending on (CAL_MI - GND) voltage difference
	real  ToT_S1 ;					    // analogue time-over-threshold



	// simple behavioural modelling for triangular pulse shaping after analog injection on S0 or S1
    
    initial begin 
        hit_inj_S0 = 1'b0 ;
        hit_inj_S1 = 1'b0 ;
    end
    
    always @(posedge S0) begin
	    hit_inj_S0 = 1'b1 ;
	    Qinj_S0 = (cal_hi - cal_mi)*Cinj ;
	    ToT_S0 = Qinj_S0/Idisch ;
	    hit_inj_S0 = #(ToT_S0) 1'b0 ;       
	end // always 
    
    always @(posedge S1) begin
        hit_inj_S1 = 1'b1 ;
	    Qinj_S1 = (cal_mi)*Cinj ;
	    ToT_S1 = Qinj_S1/Idisch ;
	    hit_inj_S1 = #(ToT_S1) 1'b0 ;       
	end // always 


	// switch between external hit and test hit (use variables instead of wires)
	always @( PIXEL_IN_BG, hit_inj_S0, hit_inj_S1, POWER_DOWN ) begin 
        if (POWER_DOWN) // when AFE is powered-down, discriminator output is fixed to 1 (maskign needed in FeControl)!
            hit_int = 1'b1; 
		else if (PIXEL_IN_BG || hit_inj_S0 || hit_inj_S1) 
            // simple OR model of external hit and two injection signals (S0 and S1) with different amplitude 
            hit_int = PIXEL_IN_BG | hit_inj_S0 | hit_inj_S1 ;   
        else
            hit_int = 1'b0;
    end
       
    assign HIT = hit_int ;

// synopsys translate_on

endmodule : RD53_AFE_BGPV

`endif


