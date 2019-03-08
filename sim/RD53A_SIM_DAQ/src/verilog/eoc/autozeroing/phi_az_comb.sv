
//-----------------------------------------------------------------------------------------------------
// [Filename]       phi_az_comb.sv
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Apr 4, 2017
// [Modified]       Apr 4, 2017
// [Description]    Torino-only startup circuit for autozeroing. At startup perform autozeroing
//                  in synchronous pixels.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef PHI_AZ_COMB__SV
`define PHI_AZ_COMB__SV


`timescale 1ns / 1ps


module phi_az_comb (

   input wire reset_b,
   input wire clk,
   input wire pulse,

   output wire phi_az_comb

   ) ;


   parameter idle = 1'b0, ready = 1'b1 ;

   logic state ;

   always_ff @(posedge clk or negedge reset_b ) begin

      if( reset_b == 1'b0 )
         state <= idle ;

      else

         case ( state )

            idle    : if( pulse == 1'b1 ) state <= ready ; else state <= idle ;
            ready   : state <= ready ;

            default : state <= idle ;

         endcase

   end // always_ff

   wire   phi_az_idle ;
   assign phi_az_idle = ( state == idle ) ? 1'b1 : 1'b0 ; 

   assign phi_az_comb = phi_az_idle | pulse ;

endmodule

`endif

