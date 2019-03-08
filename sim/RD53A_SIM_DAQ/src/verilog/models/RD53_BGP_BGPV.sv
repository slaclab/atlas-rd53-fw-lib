
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_BGP_BGPV.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Mar 19, 2017
// [Modified]       Apr  4, 2017
// [Description]    Simple RNM behavioural description for the Bergamo/Pavia INFN bandgap voltage
//                  reference. The look-up table for voltage values was derived from transistor-level
//                  simulations.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef RD53_BGP_BGPV__SV
`define RD53_BGP_BGPV__SV


`timescale 1ns / 1ps
//`include "timescale.v"


module RD53_BGP_BGPV (

   // 5-bit binary input word for trimming
   input wire B0,
   input wire B1,
   input wire B2,
   input wire B3,
   input wire B4, 

   // additional floating pins
   input wire POR,

   // output reference voltage
   output real VREF, 

   // power/ground pins, unused in this behavioral description
   inout wire VDDA,
   inout wire GNDA,
   inout wire VSUB

   ) ;

   wire [4:0] code ;
   assign code = { B4 , B3 , B2 , B1 , B0 } ;

   logic [4:0] Ntrim ;

   always @( code ) begin

      // check the input word, "X" is replaced by 'b0
      if( ^code === 1'bx )                                     // **NOTE: use "case equality" operator!
         Ntrim = 5'b00000 ;
      else
         Ntrim = code ; 


      // look-up table according to transistor-level simulations (TT, 27C)
      case( Ntrim )

          0 : VREF = 427.0e-3 ;
          1 : VREF = 429.6e-3 ;
          2 : VREF = 433.0e-3 ;
          3 : VREF = 435.6e-3 ;
          4 : VREF = 440.2e-3 ;
          5 : VREF = 443.1e-3 ;
          6 : VREF = 446.9e-3 ; 
          7 : VREF = 449.9e-3 ;
          8 : VREF = 456.4e-3 ;
          9 : VREF = 459.6e-3 ;
         10 : VREF = 463.9e-3 ;
         11 : VREF = 467.4e-3 ;
         12 : VREF = 473.3e-3 ;
         13 : VREF = 477.0e-3 ;
         14 : VREF = 482.0e-3 ;
         15 : VREF = 485.9e-3 ;
         16 : VREF = 496.5e-3 ;
         17 : VREF = 500.8e-3 ;
         18 : VREF = 506.6e-3 ;
         19 : VREF = 511.2e-3 ;
         20 : VREF = 519.4e-3 ;
         21 : VREF = 524.4e-3 ;
         22 : VREF = 531.2e-3 ;
         23 : VREF = 536.6e-3 ;
         24 : VREF = 548.9e-3 ;
         25 : VREF = 554.8e-3 ;
         26 : VREF = 563.0e-3 ;
         27 : VREF = 569.3e-3 ;
         28 : VREF = 581.0e-3 ;
         29 : VREF = 588.0e-3 ;
         30 : VREF = 597.7e-3 ;
         31 : VREF = 605.3e-3 ;

      endcase

   end

endmodule : RD53_BGP_BGPV

`endif

