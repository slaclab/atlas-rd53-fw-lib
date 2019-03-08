
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_DAC_PRAGUE.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Mar 14, 2017
// [Modified]       Apr  4, 2017
// [Description]    Simple RNM behavioural description for the Prague 12-bit voltage DAC.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef RD53_DAC_PRAGUE__SV
`define RD53_DAC_PRAGUE__SV


`timescale 1ns / 1ps
//`include "timescale.v"


module RD53_DAC_PRAGUE (

   // 12-bit binary input word
   input wire [11:0] BIN,               // 8-bit R/2R ladder + 4-bit binary weighted ladder 

   // reference voltages
   input real VREF_P,                   // 1.2 V (default)
   input real VREF_N,                   // 0.0 V (default)

   // output voltage
   output real DACOUT, 

   // power/ground pins, unused in this behavioral description
   inout wire VDDA,
   inout wire GNDA,
   inout wire VSUB

   ) ;


   // check the input word, "X" is replaced by 'b0

   wire [11:0] Ndac ;
   assign Ndac = ( ^BIN === 1'bx ) ? 12'b0 : BIN ; 


   // LSB voltage ( ~0.3 mV for rail-to-rail reference voltages)
   real VREF_DAC ;
   assign VREF_DAC = (VREF_P - VREF_N)/4096.0 ;

   assign DACOUT   = Ndac * VREF_DAC ;


endmodule : RD53_DAC_PRAGUE

`endif

