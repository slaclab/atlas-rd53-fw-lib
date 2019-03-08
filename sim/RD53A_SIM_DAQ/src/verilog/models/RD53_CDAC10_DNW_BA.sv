
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_CDAC10_DNW_BA.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Mar 5, 2017
// [Modified]       Apr 4, 2017
// [Description]    Simple RNM behavioural description for the Bari INFN 10-bit current-steering
//                  biasing DAC.
//
// [Notes]          Input and output currents in this model are just real numbers. Only for basic 
//                  connectivity checks. Use Verilog-AMS model to drive transistor-level bias cells.
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef RD53_CDAC10_DNW_BA__SV
`define RD53_CDAC10_DNW_BA__SV


`timescale 1ns / 1ps
//`include "timescale.v"


module RD53_CDAC10_DNW_BA (

   // 10-bit binary input word
   input wire [9:0] BIN,

   // 4 uA nominal reference current from BGR
   input real IREF,

   // output currents
   output real IOUT_P,
   output real IOUT_N, 

   // power/ground pins, unused in this behavioral description
   inout wire VDDA,
   inout wire GNDA,
   inout wire VSUB

   ) ;


   // check the input word, "X" is replaced by 'b0

   wire [9:0] Ndac ;
   assign Ndac = ( ^BIN === 1'bx ) ? 10'b0 : BIN ;

   // internal divided current
   real IREF_DAC ;

   assign IREF_DAC = IREF/40.0 ;

   assign IOUT_P = Ndac * IREF_DAC ;
   assign IOUT_N = (1023 - Ndac) * IREF_DAC ;


endmodule : RD53_CDAC10_DNW_BA

`endif

