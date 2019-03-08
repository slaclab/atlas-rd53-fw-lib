`include "array/interfaces/RD53_AFE_LBNL_inf.sv"

module RD53_AFE_LBNL(
    
    // Analog injection signals
    input wire S0,
    input wire S1,
    // Threshold adjust configuration
    input wire [3:0] DTH1,
    input wire [3:0] DTH2,
    
    input wire in, // analog input 
    output wire outdis, // discriminator output (negative polarity)

    // Biases
    input CAL_HI,
    input CAL_MI,
    input PrmpVbnFol,
    input PrmpVbp,
    input VctrCF0,
    input VctrLCC,
    input compVbn,
    input preCompVbn,
    input vbnLcc,
    input vff,
    input vthin1,
    input vthin2,
    // Pins for Top-padframe
    output out1,
    output out2,
    output out2b,    
    
    // Floating pins (testing).
    input ncas,
    input InjPix,
    input intCF0,
    input outlcc,
    input vbcas
    //inout out1i

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
	parameter	 cal_hi = 500.0e-3  ;	// sample CAL_HI value
	parameter	 cal_mi =  50.0e-3  ;	// nominal 50 mV CAL_MI value
	parameter	 Idisch =  20.0e-9  ;	// feedback discharge current

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
	always @( in, hit_inj_S0, hit_inj_S1 ) begin // to ADD: S0 and S1 injection 

		if (in || hit_inj_S0 || hit_inj_S1) 
            // simple OR model of external hit and two injection signals (S0 and S1) with different amplitude 
            hit_int = in | hit_inj_S0 | hit_inj_S1 ;
        else
            hit_int = 1'b0;
    end
    
    // Negative polarity of discriminator output.
    assign outdis = ~hit_int ; 

//wire g_or; // to propagate X
//assign g_or = PrmpVbnFol | PrmpVbp | VctrCF0 | VctrLCC | compVbn | preCompVbn | vbnLcc | vff | vthin1 | vthin2 | CAL_HI | CAL_MI;

//reg int_inj;
//assign outdis = ~( (in | int_inj) ) ;

///initial begin
//int_inj = 0;
  // TODO: correct analog injection modeling 
  /*forever begin
    @(posedge S0) // just dummy for the first injection
        int_inj = g_or;
        #(25*DTH1) int_inj = 1;
  end
 */
//end

// synopsys translate_on

endmodule //RD53_AFE_LBNL
