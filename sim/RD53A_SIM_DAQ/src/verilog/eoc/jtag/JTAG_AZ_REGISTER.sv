
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_AZ_REGISTER.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Mar 17, 2016
// [Modified]       Mar 17, 2017
// [Description]    Dedicated 27-bit JTAG Data Register (DR) for autozeroing. Load PWM generator defaults
//                  when a CAPTURE_DR flag is generated from TAP controller. Shift-right TDI serial data
//                  when a SHIFT_DR flag is generated from TAP controller. Transfers data from DR
//                  shift-register into DR shadow-register when an UPDATE_DR flag is generated from TAP
//                  controller.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef JTAG_AZ_REGISTER__SV
`define JTAG_AZ_REGISTER__SV


`timescale  1ns / 1ps
//`include "timescale.v"


module JTAG_AZ_REGISTER (

   input  wire RESET,                         // reset signal (asynchronous, active-low)
   input  wire CLOCK_DR,                      // **NOTE: gated clock CLOCK_DR no more adopted (IEEE Std. 1149.1-2001 broken). At top level TCK is propagated to all JTAG clock pins instead
   input  wire SHIFT_DR,                      // shift-enable, from TAP controller
   input  wire UPDATE_DR,                     // transfer payload data into shadow register

   input  wire TDI,

   input  wire CAPTURE_DR,                    // load-enable, from TAP controller

   output wire TDO,
   output wire [26:0] SHADOW                  // shadow-register outputs

   ) ;

   `ifndef ABSTRACT


   // data shift register

   logic [26:0] shift_reg ;

   wire [ 4:0] Ndelay_default = 5'b00000 ;                // zero-delay
   wire [ 7:0] Nhigh_default  = 8'b0001_0100 ;            // 0.5us high, 20 x 25ns
   wire [13:0] Nlow_default   = 14'b0011111_0001100 ;     // 99.5us low, 3980 x 25ns


   always_ff @(negedge RESET or posedge CLOCK_DR) begin

      if( RESET == 1'b0 )
         shift_reg <= 'b0 ;

      else begin

         if(  CAPTURE_DR == 1'b1 )                                            
            shift_reg <= { Nlow_default , Nhigh_default,  Ndelay_default } ;   // load defaults

         else if( SHIFT_DR == 1'b1 )
            shift_reg <= { TDI , shift_reg[26:1] } ;                 // shift-right using concatenation

      end  // else
   end  // always_ff


   // shift-register serial output
   assign TDO = shift_reg[0] ;




   // shadow register

   logic [26:0] shadow_reg ;

   always_ff @(negedge RESET or negedge CLOCK_DR) begin   // the data transfer occurs at NEGATIVE edge of clock signal

      if( RESET == 1'b0 )
         shadow_reg <= 'b0 ;

      else if( UPDATE_DR == 1'b1 )           // **NOTE: according to IEEE Std. 1149.1-2001, UPDATE_DR should be the clock signal
         shadow_reg <= shift_reg ;           //         driving DFF clock pins. Here UPDATE_IR is used as a MUX control instead

   end  // always_ff

   assign SHADOW = shadow_reg ;


   `endif  // ABSTRACT

endmodule : JTAG_AZ_REGISTER

`endif

