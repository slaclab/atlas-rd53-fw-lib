
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_POR_EXTERNAL_CAP_SEVILLA.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         -
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Mar  2, 2017
// [Modified]       Mar 19, 2017
// [Description]    Pure digital or RNM behavioural description for the Power-On reset (POR).
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef RD53_POR_EXTERNAL_CAP_SEVILLA__SV
`define RD53_POR_EXTERNAL_CAP_SEVILLA__SV


`timescale 1ns / 1ps
//`include "timescale.v"


`define POR_STARTUP        540ns// 550ns  // TBD, just some random numbers for the moment
`define EXT_RESET_WIDTH    540ns//550ns


module RD53_POR_EXTERNAL_CAP_SEVILLA (

   input  wire POR_EXT_CAP,                          // POR external-cap pin, can also trigger a POR signal in case POR stucks
   output wire POR_OUT_B,                            // monitor POR output signal or force it, also fed to core logic
   inout  wire VDD,
   inout  wire GND

   ) ;



   // POR output signal
   logic por_sim ;

   initial begin
      #0               por_sim = 1'b0 ;       // active-low !
      #(`POR_STARTUP)  por_sim = 1'b1 ;
      //#(`POR_WIDTH)    por_sim = 1'b1 ;
   end

   // trigger the POR if a POR_EXT_CAP switching signal is fed to the chip
   always @( negedge POR_EXT_CAP ) begin

      por_sim = 1'b0 ;
      #(`EXT_RESET_WIDTH) por_sim = 1'b1 ;

   end

   // for the moment, just drive POR_OUT_B (no POR-override modelling)
   assign POR_OUT_B = por_sim ;


   // **TODO: RNM model

endmodule : RD53_POR_EXTERNAL_CAP_SEVILLA

`endif
