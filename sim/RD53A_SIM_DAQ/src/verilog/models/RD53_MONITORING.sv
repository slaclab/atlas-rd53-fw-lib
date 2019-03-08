
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_MONITORING.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Mar 19, 2017
// [Modified]       Apr  4, 2017
// [Description]    RNM behavioral description for the monitoring-block
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/models/RD53_BGP_BGPV.sv
// $RTL_DIR/models/AnalogMux_40to1.sv
// $RTL_DIR/models/RD53_ADC12_CPPM.sv


`ifndef RD53_MONITORING__SV
`define RD53_MONITORING__SV

`timescale 1ns / 1ps
//`include "timescale.v"


`include "models/RD53_BGP_BGPV.sv"
`include "models/AnalogMux_40to1.sv"
`include "models/RD53_ADC12_CPPM.sv"


module RD53_MONITORING (

   input  wire MON_ENABLE,                         // **WARN: FLOATING, no more used !

   // bandgap trimming and additional POR
   input  wire POR_BGP, 
   input  wire [4:0] MON_BG_TRIM,

   // analog MUX
   input  wire [39:0] MON_VIN_SEL,
   input  real MON_INPUT[39:1],

   // ADC
   output real adc_vin,          // **NOTE: this is supposed to just monitor ADC input voltage, not to override it externally !
   input  real vref_in,
   output real vref_out,  
   input  wire ADC_SOC,
   input  wire [5:0] ADC_TRIM,
   input  wire CLK40,
   input  wire RST_B,
   output wire ADC_EOC_B,
   output wire [11:0] ADC_OUT,

   // bias lines
   inout wire Ibias_comp,
   inout wire Ibias_opamp,

   // power/ground, not used in this model
   inout wire AVDD,
   inout wire AGND,
   inout wire DVDD,
   inout wire DGND,
   inout wire VSUB

   ) ;



   //----------------   bandgap voltage reference   -----------------//

   real vbg ;

   RD53_BGP_BGPV  BGP_ADC (

      .B0     ( MON_BG_TRIM[0] ),
      .B1     ( MON_BG_TRIM[1] ),
      .B2     ( MON_BG_TRIM[2] ),
      .B3     ( MON_BG_TRIM[3] ),
      .B4     ( MON_BG_TRIM[4] ),
      .POR    (        POR_BGP ),
      .VREF   (            vbg ),
      .VDDA   (                ),
      .GNDA   (                ),
      .VSUB   (                )

      ) ;
 

   // 2x buffer
   
   always @(*)
      vref_out = 2*vbg ;


   //---------------   40:1 analog MUX for voltages   ---------------//

   real Vmux_in[39:0] ;

   always @(*) begin
      Vmux_in[0] = vbg ;
      Vmux_in[39:1] = MON_INPUT[39:1] ;
   end


   real Vmux_out ;

   AnalogMux_40to1  AnalogMux (

      .Input      (     Vmux_in[39:0] ),
      .Select     ( MON_VIN_SEL[39:0] ),
      .AnalogOut  (          Vmux_out ),
      .AVDD       (                   ),
      .AGND       (                   ),
      .VSS        (                   )

      ) ;

   always @(*)
      adc_vin = Vmux_out ; 



   //---------------------   monitoring ADC   -----------------------//

   RD53_ADC12_CPPM  ADC (

      .CLOCK      (         CLK40 ),   
      .RESET_B    (         RST_B ),
      .ADC_SOC    (       ADC_SOC ),
      .ADC_EOC_B  (     ADC_EOC_B ),
      .ADC_OUT    ( ADC_OUT[11:0] ),
      .ADC_TRIM   ( ADC_TRIM[5:0] ),
      .adc_vin    (      Vmux_out ),
      .adc_vref   (       vref_in ),
      .Ibias_comp (               ),
      .AVDD       (               ),
      .AGND       (               ),
      .VSUB       (               ),
      .DVDD       (               ),
      .DGND       (               )

   ) ;


endmodule : RD53_MONITORING

`endif


