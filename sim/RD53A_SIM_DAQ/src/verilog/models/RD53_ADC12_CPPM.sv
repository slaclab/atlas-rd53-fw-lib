
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_ADC12_CPPM.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Apr 4, 2017
// [Modified]       Apr 4, 2017
// [Description]    Simple RNM behavioural description for the CPPM 12-bit monitoring. Model derived
//                  from Mohsine Verilog-AMS code in OA views.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// RTL_DIR/models/ADC_CLK_SOC_gen.v(ams)


`ifndef RD53_ADC12_CPPM__SV
`define RD53_ADC12_CPPM__SV


`timescale 1ns / 1ps
//`include "timescale.v"


`include "models/ADC_CLK_SOC_gen.v"


module RD53_ADC12_CPPM (

   // digital control signals
   input  wire CLOCK,
   input  wire RESET_B,
   input  wire ADC_SOC,
   output wire ADC_EOC_B,
   output wire [11:0] ADC_OUT,

   input wire [6:1] ADC_TRIM,

   // analog input voltages
   input real adc_vin,
   input real adc_vref,

   // comparator bias current 
   inout wire Ibias_comp,

   // power/ground pins, unused in this behavioral description
   inout wire AVDD,
   inout wire AGND,
   inout wire VSUB,
   inout wire DVDD,
   inout wire DGND

   ) ;




   // signal generator (as in OA schematic)

   wire phi1 ;
   wire phi2 ;
   wire phi3 ;
   wire phi4 ;

   wire ADC_SOC_LF ;

   ADC_CLK_SOC_gen  ADC_CLK_SOC_gen (

      .CLOCK   (       CLOCK ),
      .RESETB  (     RESET_B ),
      .SOC     (     ADC_SOC ),
      .SOC_LF  (  ADC_SOC_LF ),
      .PHI1    (        phi1 ),
      .PHI2    (        phi2 ),
      .PHI3    (        phi3 ),
      .PHI4    (        phi4 ),
      .VDDD    (             ),    
      .GNDD    (             )

      ) ;



   // internal wires (as in OA schematic)

   wire Reset = RESET_B ;
   wire din = ADC_SOC_LF ;
   wire clk_phi1 = phi1 ;
   wire clk_phi2 = phi2 ;
   wire clk_phi3 = phi3 ;
   wire clk_phi4 = phi4 ;

   wire [6:1] trim = ADC_TRIM[6:1] ;

   reg data_valid ;
   assign ADC_EOC_B = data_valid ;

   reg [11:0] adc_out ;
   assign ADC_OUT = adc_out ;


   //---------------------   SAR ADC real-numbers model   ---------------------//

   // internal variables

   reg [2:0] adc_state ;
   reg [9:0] div_count ;

   real vref, thres, sample ;

   integer bit_n ;

   parameter integer td = 5 ;

   parameter RESET = 0, IDLE = 1, STARTCONV = 2, CONV = 3, ENDCONV = 4 ;

   //assign CLOCK_LF = div_count[9] ;

   initial begin
      #0 adc_out = 12'b0 ;              // **WARN: use #0 to guarantee proper simulation initialization across the hierarchy using real values !
         data_valid = 1 ; 
         sample = adc_vin ;
         vref = adc_vref ;
         thres = vref/2.0 ;
         bit_n=11 ;
   end


   // SAR ADC model
   always @(adc_state or bit_n) begin

      case (adc_state)

         RESET :
            begin
               adc_out = 0 ;
               data_valid =1 ;
            end

         IDLE :
            begin
               adc_out = adc_out ;
               data_valid = data_valid ;
            end

         STARTCONV :
            begin
               sample = adc_vin ;
               thres =  vref/2.0 ;
               bit_n=11 ;
               adc_out = 0;
               data_valid=1 ;
            end

         CONV :
            begin
               if(sample > thres) 
                  begin
                     adc_out[bit_n] <= #(td) 1 ;
                     thres = thres + vref/(2*2**(12-bit_n)) ;
                  end
               else 
                  begin
                     adc_out[bit_n] <= #(td) 0 ;
                     thres = thres - vref/(2*2**(12-bit_n)) ;
                  end
               end

         ENDCONV :
            begin
               adc_out[bit_n] <= #(td) adc_out[bit_n] ;
               data_valid =0 ;
            end

      endcase
   end


   always @(posedge clk_phi1 or negedge Reset) begin

      if(!Reset)
         adc_state = RESET ;

      else
         case (adc_state)

            RESET : 
               if(din==1)
                  adc_state = STARTCONV ;
               else
                  adc_state = RESET ;	

            IDLE :
               if(din==1)
                  adc_state = STARTCONV ;
               else
                  adc_state = IDLE ;
						
            STARTCONV :
               if(din==0)
                  adc_state = CONV ;
               else
                  adc_state = STARTCONV ;

            CONV :
               if(bit_n>=0) begin
                  bit_n=bit_n-1 ;
                  adc_state = CONV ;
               end
               else
                  adc_state =ENDCONV;

            ENDCONV :
               adc_state = IDLE;		

         endcase
   end

endmodule : RD53_ADC12_CPPM

`endif

