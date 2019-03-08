
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_BSC.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 18002012]
// [Created]        Jul 14, 2016
// [Modified]       Apr  9, 2017
// [Description]    Single-bit JTAG Boundary Scan Cell (BSC) supporting both sample/preload operations
//
// [Notes]          Gated clocks CLOCK_DR and UPDATE_DR generated from TAP controller not adopted
//                  (IEEE Std. 1149.1-2001 broken). At top level TCK is propagated to all JTAG clock
//                  pins instead. Additional asynchronous active-low reset for scan and capture DFF.
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef JTAG_BSC__SV
`define JTAG_BSC__SV


`timescale  1ns / 1ps
//`include "timescale.v"

module JTAG_BSC (

   input  wire  RESET,                // reset signal (asynchronous, active-low)
   input  wire  CLOCK_DR,             // scan-FF clock
   input  wire  SHIFT_DR,             // input MUX select signal
   input  wire  SHIFT_EN,             // additional MUX control since gated-clocks are not adopted
   input  wire  NDI,                  // normal data-in
   input  wire  TDI,                  // scan input data
   input  wire  UPDATE_DR,            // update-FF clock
   input  wire  MODE,                 // output MUX select signal
   output wire  NDO,                  // normal data-out
   output wire  TDO                   // scan output data

   ) ;


   `ifndef ABSTRACT

   // input multiplexer
   wire d0 ;
   assign d0 = (SHIFT_DR == 1'b0) ? NDI : TDI ;


   // scan/update FF outputs
   logic q0, q1 ;


   // scan (capture) FF
   always_ff @(negedge RESET or posedge CLOCK_DR) begin
   //always_ff @(posedge CLOCK_DR) begin

      if( RESET == 1'b0 )
         q0 <= 1'b0 ;
      else if( SHIFT_EN == 1'b1 )            // additional MUX control
         q0 <= d0 ;

   end // always_ff


   // update FF
   //always_ff @(posedge UPDATE_DR or negedge RESET) begin
   //always_ff @(posedge UPDATE_DR) begin

   always_ff @(negedge RESET or negedge CLOCK_DR) begin   // data transfer occurs at the NEGATIVE edge of clock signal

      if( RESET == 1'b0 )
         q1 <= 1'b0 ;
      else if( UPDATE_DR == 1'b1 )           // **NOTE: according to IEEE Std. 1149.1-2001, UPDATE_DR should be the clock signal
         q1 <= q0 ;                          //         driving DFF clock pins. Here UPDATE_IR is used as a MUX control instead

   end // always_ff



   // output multiplexer
   assign NDO = (MODE == 1'b1) ? q1 : NDI ;


   // serial output
   assign TDO = q0 ;


   `endif   // ABSTRACT

endmodule : JTAG_BSC

`endif

