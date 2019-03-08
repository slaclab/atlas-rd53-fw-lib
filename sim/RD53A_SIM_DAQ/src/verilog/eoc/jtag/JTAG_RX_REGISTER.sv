
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_RX_REGISTER.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jul 14, 2016
// [Modified]       Jan 16, 2017
// [Description]    Generic configurable-width JTAG Data Register (DR). Shift-right TDI serial data 
//                  when a SHIFT_DR flag is generated from TAP controller. Transfers data from DR
//                  shift-register into DR shadow-register when an UPDATE_DR flag is generated 
//                  from TAP controller.
//
// [Notes]          Use the DATA_WIDTH Verilog parameter to specify the register size (default is set
//                  to 16-bits).
//
// [Version]        1.0
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef JTAG_RX_REGISTER__SV
`define JTAG_RX_REGISTER__SV


`timescale  1ns / 1ps
//`include "timescale.v"


module JTAG_RX_REGISTER  #(parameter DATA_WIDTH = 16) (

   input  wire RESET,                         // reset signal (asynchronous, active-low)
   input  wire CLOCK_DR,                      // **NOTE: gated clock CLOCK_DR no more adopted (IEEE Std. 1149.1-2001 broken). At top level TCK is propagated to all JTAG clock pins instead
   input  wire SHIFT_DR,                      // shift-enable, from TAP controller
   input  wire UPDATE_DR,                     // transfer payload data into shadow register

   input  wire TDI,

   output wire TDO,
   output wire [DATA_WIDTH-1:0] SHADOW        // shadow-register outputs

   ) ;

   `ifndef ABSTRACT


   // data shift register (optional parallel-input NOT implemented)

   logic [DATA_WIDTH-1:0] shift_reg ;

   always_ff @(negedge RESET or posedge CLOCK_DR) begin

      if( RESET == 1'b0 )
         shift_reg <= 'b0 ;

      else if( SHIFT_DR == 1'b1 )
         shift_reg <= { TDI , shift_reg[DATA_WIDTH-1:1] } ;            // shift-right using concatenation

   end  // always_ff


   // shift-register serial output
   assign TDO = shift_reg[0] ;




   // shadow register

   logic [DATA_WIDTH-1:0] shadow_reg ;

   always_ff @(negedge RESET or negedge CLOCK_DR) begin   // the data transfer occurs at NEGATIVE edge of clock signal

      if( RESET == 1'b0 )
         shadow_reg <= 'b0 ;

      else if( UPDATE_DR == 1'b1 )           // **NOTE: according to IEEE Std. 1149.1-2001, UPDATE_DR should be the clock signal
         shadow_reg <= shift_reg ;           //         driving DFF clock pins. Here UPDATE_IR is used as a MUX control instead

   end  // always_ff

   assign SHADOW = shadow_reg ;


   `endif  // ABSTRACT

endmodule : JTAG_RX_REGISTER

`endif

