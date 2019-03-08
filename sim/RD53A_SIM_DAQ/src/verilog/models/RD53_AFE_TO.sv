`include "array/interfaces/RD53_AFE_TO_inf.sv"

`define FASTCLK_PERIOD 5e-9

module RD53_AFE_TO(

 // input stimulus from the simulation environment, but also a physical 
   // pin connected to the bump pad in the full-custom OA layout
   input  PIXEL_IN_TO,
   input  POWER_DOWN_TO,

   	// ~~~~ Analog Bias IF ~~~~~~~~
   // CSA bias lines
   input  IBIASP1_TO,
   input  IBIASP2_TO,
   input  VCASN_TO,
   input  VCASP1_TO,
   input  IBIAS_SF_TO,

   // Krummenacher feedback bias lines
   input  VREF_KRUM_TO,
   input  VCAS_KRUM_TO,
   input  IBIAS_FEED_TO,
//   input  GNDA_KRUM_TO,


   // DISC preamp bias lines
   input  IBIAS_DISC_TO,
   input  VCASN_DISC_TO,
   input  VBL_DISC_TO,
   input  VTH_DISC_TO,


   // calibration circuit DC levels and charge-injection test-pulse
   input  CAL_HI,
   input  CAL_MI,
   input  ICTRL_TOT_TO,

   // ~~~~ end Analog Bias IF ~~~~~~~~
	// ~~~~ Digital IF ~~~~~~~~
   input  S0,
   input  S1,
   output  VOUT_PREAMP,
   
      // DISC digital control signals
   input  PHI_AZ_TO,
   input  STROBE_TO,

   // configuration bits
   input  SEL_C2F_TO,
   input  SEL_C4F_TO,

   // delay line
   input  DELAY_IN_TO,
   output DELAY_OUT_TO,

   // latch differential outputs
   output logic VOUTP_TO,
   output logic VOUTN_TO
   // ~~~~ end Digital IF ~~~~~~~~
	); 
    
    // **NOTE - module time unit in seconds! (use SI units for all calculations) --- check that does not make troubles.
	 timeunit 1s;
	 timeprecision 100ps;

    // non-synthesizable behavioural code
    // synopsys translate_off

      // internal hit, assigned either to the external digital pulse provided by the verifiction environment
      // or to the pulse generated during analog injection 
      logic hit_int ;
      logic analog_hit ;


      // hit pulse from charge-injection
	  logic hit_inj_S0 = 1'b0 ;
      logic hit_inj_S1 = 1'b0 ;



      // analogue front-end parameters
      parameter      Cinj =   8.0e-15 ;                 // 8 fF calibration circuit injection capacitance
      parameter  Cfeed_2F =   2.0e-15 ;                 // selectable 2 fF feedback capacitance
      parameter  Cfeed_4F =   4.0e-15 ;                 // selectable 4 fF feedback capacitance
      parameter    cal_hi = 500.0e-3  ;                 // sample CAL_HI value
      parameter    cal_mi =  50.0e-3  ;                 // nominal 50 mV CAL_LO value
      parameter	   Idisch =  20.0e-9  ;	                // feedback discharge current
      //parameter    Idisch =  400.0e-9  ;              // feedback discharge current


      real  Cfeed ;                                     // effective feedback capacitance depending on SEL_C2F and SEL_C4F configuration bits
	  real  Qinj_S0 ;						            // injected charge depending on (CAL_HI - CAL_MI) voltage difference
	  real  ToT_S0 ;						            // analogue time-over-threshold
	  real  Qinj_S1 ;						            // injected charge depending on (CAL_MI - GND) voltage difference
	  real  ToT_S1 ;					                // analogue time-over-threshold


      // CSA configuration (only for debug purposes, in fact Cfeed does not contribute to ToT in this simple model)
      always @(*) begin

         case( {SEL_C4F_TO , SEL_C2F_TO} )

            2'b01   : Cfeed = Cfeed_2F ;
            2'b10   : Cfeed = Cfeed_4F ;
            2'b11   : Cfeed = Cfeed_2F + Cfeed_4F ;

         endcase

      end

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
	  always @( analog_hit, hit_inj_S0, hit_inj_S1 ) begin 

		  if (analog_hit || hit_inj_S0 || hit_inj_S1) 
              // simple OR model of external hit and two injection signals (S0 and S1) with different amplitude 
              hit_int = analog_hit | hit_inj_S0 | hit_inj_S1 ; // simple OR model
          else
              hit_int = 1'b0;
      end

      // switch between external hit and test hit (use variables instead of wires)
      //assign hit_int = #20ns PIXEL_IN_TO ;
      assign analog_hit = PIXEL_IN_TO;

      // latch reset and decision, including the strobe-to-VoutP(VoutN)
      // transition delays (~ 500 ps from SPICE simulations). The resulting
      // internal hit is synchronized with the strobe activity

      initial begin 
            VOUTP_TO <= #(500.0e-12) 1'b1 ;
            VOUTN_TO <= #(500.0e-12) 1'b1 ;
      end
      
      always @( STROBE_TO ) begin

         if(STROBE_TO == 1'b0) begin
            VOUTP_TO <= #(500.0e-12)  1'b1 ;
            VOUTN_TO <= #(500.0e-12)  1'b1 ;
         end
         else begin

            case ( hit_int )
               1'b0    : begin
                            VOUTP_TO <= #(500.0e-12)  1'b1 ;
                            VOUTN_TO <= #(500.0e-12)  1'b0 ;
                         end

               1'b1    : begin
                            VOUTP_TO <= #(500.0e-12)  1'b0 ;  //  **NOTE - remind that VoutP and VoutN are active-low!
                            VOUTN_TO <= #(500.0e-12)  1'b1 ;
                         end

               default : begin
                            VOUTP_TO <= #(500.0e-12)  1'b1 ;
                            VOUTN_TO <= #(500.0e-12)  1'b1 ;
                         end
            endcase

         end //if
      end  //always


      // INVERTING delay line (behavioral)
      assign #(0.5*`FASTCLK_PERIOD) DELAY_OUT_TO = ~ DELAY_IN_TO ; 
      //assign #(500.0e-12) delay_out = ~ delay_in ;
      
// synopsys translate_on

endmodule : RD53_AFE_TO



