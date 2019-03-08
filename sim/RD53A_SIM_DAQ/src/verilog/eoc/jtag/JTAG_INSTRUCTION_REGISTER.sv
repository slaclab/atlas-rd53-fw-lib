
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_INSTRUCTION_REGISTER.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jul 14, 2016
// [Modified]       Jan 30, 2017
// [Description]    Generic configurable-width JTAG Instruction Register (IR). Shift-right TDI serial
//                  data when a SHIFT_IR flag is generated from TAP controller. Transfers data from
//                  shift-register into shadow-register when an UPDATE_IR flag is generated from TAP
//                  controller.
//
// [Notes]          Use the DATA_WIDTH Verilog parameter to specify the register size (default is set
//                  to 5-bits).
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/eoc/jtag/JTAG_INSTRUCTION_REGISTER_codes_pkg.sv    **NOTE: package source file included at top-level


`ifndef JTAG_INSTRUCTION_REGISTER__SV
`define JTAG_INSTRUCTION_REGISTER__SV


`timescale  1ns / 1ps
//`include "timescale.v"


module JTAG_INSTRUCTION_REGISTER  #(parameter DATA_WIDTH = 5) (

   input  wire RESET,
   input  wire CLOCK_IR,                      // **NOTE: gated clock CLOCK_IR no more adopted (IEEE Std. 1149.1-2001 broken). At top level TCK is propagated to all JTAG clock pins instead

   input  wire SHIFT_IR,                      // shift-enable, from TAP controller
   input  wire CAPTURE_IR,                    // load parallel-input data into IR (for easier fault detection)
   input  wire UPDATE_IR,                     // load IR data into shadow register

   input  wire TDI,                           // serial-in
   output wire TDO,                           // serial-out
   output wire [DATA_WIDTH-1:0] OPCODE        // shadow-register output code

   ) ;


   `ifndef ABSTRACT


   import JTAG_IR_codes_pkg::* ;

   // instruction shift-register (including optional parallel-input for easier faults detection)
   logic [DATA_WIDTH-1:0] shift_reg ;

   always_ff @(negedge RESET or posedge CLOCK_IR) begin

      if( RESET == 1'b0 )                                        // asynchronous reset, active-low (TBC)
         shift_reg <= 'b0 ;

      else begin

         if( CAPTURE_IR == 1'b1 )                                // **NOTE: according to IEEE Std. 1149.1-2001, if an optional parallel-input is adopted for the IR, then the two LSBs **MUST**
            shift_reg <= RESERVED ;                              //         be loaded with 2'b01 for easier faults detection in the serial path between the chip and the test PCB. It is also 
                                                                 //         recommended to fill all remaining MSBs with constant values, e.g. all 1's or all 0's. This OPCODE corresponds to RESERVED 
         else if( SHIFT_IR == 1'b1 )
            shift_reg <= { TDI , shift_reg[DATA_WIDTH-1:1] } ;   // shift-right using concatenation
      end

   end  // always_ff


   // shift-register output
   assign TDO = shift_reg[0] ;



   // IR shadow-register

   logic [DATA_WIDTH-1:0] shadow_reg ;

   always_ff @(negedge RESET or negedge CLOCK_IR) begin         // data transfer occurs at the NEGATIVE edge of clock signal

      if( RESET == 1'b0 )
         shadow_reg <= BYPASS ;                                 // according to IEEE Std. 1149.1-2001, by default enter to BYPASS mode when reset is asserted (or load the IDCODE if available)

      else if( UPDATE_IR == 1'b1 )                              // **NOTE: according to IEEE Std. 1149.1-2001, UPDATE_IR is a clock signal
         shadow_reg <= shift_reg ;                              //         driving DFF clock pins. Here UPDATE_IR is used as a MUX control instead

   end // always_ff

   assign OPCODE = shadow_reg ;

   `endif  // ABSTRACT

endmodule : JTAG_INSTRUCTION_REGISTER

`endif

