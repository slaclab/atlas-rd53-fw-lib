
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_TX_REGISTER.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 16, 2016
// [Modified]       Jan 16, 2016
// [Description]    Generic configurable-width JTAG output Data Register (DR). Shifts-right TDI serial
//                  test data when a SHIFT_DR flag is generated from TAP controller. Loads parallel 
//                  input data when a CAPTURE_DR flag is generated from TAP controller.
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


`ifndef JTAG_TX_REGISTER__SV
`define JTAG_TX_REGISTER__SV


`timescale  1ns / 1ps
//`include "timescale.v"


module JTAG_TX_REGISTER  #(parameter DATA_WIDTH = 16) (

   input  wire RESET,                         // reset signal (asynchronous, active-low)
   input  wire CLOCK_DR,                      // **NOTE: gated clock CLOCK_DR no more adopted (IEEE Std. 1149.1-2001 broken). At top level TCK is propagated to all JTAG clock pins instead
   input  wire SHIFT_DR,                      // shift-enable, from TAP controller
   input  wire CAPTURE_DR,                    // load payload data into the shift register
   input  wire [DATA_WIDTH-1:0] PDATA,        // parallel input data 

   input  wire TDI,
   output wire TDO

   ) ;

   `ifndef ABSTRACT


   // shift register with optional parallel-input

   logic [DATA_WIDTH-1:0] shift_reg ;

   always_ff @(negedge RESET or posedge CLOCK_DR) begin

      if( RESET == 1'b0 )
         shift_reg <= 'b0 ;

      else begin

         if( CAPTURE_DR == 1'b1 )                                    // load parallel input data
            shift_reg <= PDATA ;

         else if( SHIFT_DR == 1'b1 )
            shift_reg <= { TDI , shift_reg[DATA_WIDTH-1:1] } ;       // shift-right using concatenation

      end  // else
   end  // always_ff


   // shift-register serial output
   assign TDO = shift_reg[0] ;

   `endif  // ABSTRACT

endmodule : JTAG_TX_REGISTER

`endif

