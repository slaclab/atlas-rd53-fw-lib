
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_BYPASS_REGISTER.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jul 14, 2016
// [Modified]       Jan 30, 2017
// [Description]    JTAG BYPASS register (when selected through a BYPASS instruction, it provides 
//                  a single-bit scan path between TDI and TDO)
//
// [Notes]          A logic 1'b0 is loaded into the BYPASS register when a CAPTURE_DR is generated
//                  from TAP controller
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef JTAG_BYPASS_REGISTER__SV
`define JTAG_BYPASS_REGISTER__SV


`timescale  1ns / 1ps
//`include "timescale.v"


module JTAG_BYPASS_REGISTER (

   //input  wire RESET,            // (TBC, according to IEEE Std. 1149.1-2001 no reset signal is required for the BYPASS register)
   input  wire  CLOCK_DR,          // **NOTE: gated clock CLOCK_DR no more adopted (IEEE Std. 1149.1-2001 broken). At top level TCK is propagated to all JTAG clock pins instead
   input  wire  SHIFT_DR,
   input  wire  CAPTURE_DR,        // a logic 1'b0 is loaded into the BYPASS register when a CAPTURE_DR flag is generated from TAP controller
   input  wire  TDI,
   output logic TDO

   ) ;


   `ifndef  ABSTRACT

   // just a simple DFF with input AND

   always_ff @(posedge CLOCK_DR) begin

      //if( RESET == 1'b0 )
      //   TDO <= 1'b0 ;

      if( CAPTURE_DR == 1'b1 )
         TDO <= 1'b0 ;

      else
         TDO <= TDI & SHIFT_DR ;

   end  // always_ff


   `endif  // ABSTRACT

endmodule : JTAG_BYPASS_REGISTER

`endif

