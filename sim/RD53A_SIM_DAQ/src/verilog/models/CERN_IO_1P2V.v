
//-----------------------------------------------------------------------------------------------------
// [Filename]       CERN_IO_1P2V.v
// [Project]        CHIPIX65/RD53 pixel array demonstrators
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       Verilog 2005 [IEEE Std. 1364-2005]
// [Created]        Jan 15, 2016
// [Modified]       Mar  6, 2017
// [Description]    Verilog description for custom CERN I/O cells 
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`timescale 1ns / 1ps


`celldefine
module CERN_IO_PAD (

   inout  wire IO,             // pad

   input  wire PEN,            // pull-up/down enable (configuration bit)
   input  wire \UD* ,          // pull-up/down select (configuration bit)    **WARN: active-low!
   output wire Z,              // **TO** core

   input  wire OUT_EN,         // output-enable (configuration bit)
   input  wire DS,             // drive-strength select (configuration bit)
   input  wire A,              // **FROM** core

   inout  wire VDD,
   inout  wire VSS,
   inout  wire VDDPST,
   inout  wire VSSPST

   ) ;


   //--------------------   PAD => core pin (Z)   --------------------//

   // gate-level schematic, only for reference
   //
   //nand      (pullup_en_b,  PEN, \UD* ) ;       // control logic
   //nor       (pulldown_en, ~PEN, \UD* ) ;
   //pullup    (Ru) ;                             // 40 kohm pullup-resistor
   //pulldown  (Rd) ;                             // 40 khom pull-down resistor
   //pmos      (Internal, Ru, pullup_en_b) ;        // pmos(D,S,G)
   //nmos      (Internal, Rd, pulldown_en ) ;     // nmos(D,S,G)
   //

   wire  pullup_en_b ;
   wire  pulldown_en ;

   assign pullup_en_b = ~( PEN & \UD* ) ;
   assign pulldown_en = ~( ~PEN | \UD* ) ;

   wire Internal ;

   bufif0 (weak0, weak1) (Internal, 1'b1, pullup_en_b) ; 
   bufif1 (weak0, weak1) (Internal, 1'b0, pulldown_en) ;

   rtran (Internal, IO) ;    // resistive bidirectional path between IO and Internal (SF_1V2_CDM)

   buf (Z, Internal) ;
   //buf #(1.038, 1.241) (Z, Internal) ;   // 1.038 ns tpLH and 1.241 tpHL delays from SPICE simulation (TT, 30 fF internal load capacitance)





   //--------------------   core pin (A) => PAD   --------------------//

   // delay table (maybe not required)
   //
   //   DS     PEN   UP     tpLH (ps)   tpHL (ps)
   //  1'b0   1'b0  1'b0       -          -
   //  1'b0   1'b1  1'b0
   //  1'b0   1'b1  1'b1
   //  1'b1   1'b0  1'b0
   //  1'b1   1'b1  1'b0
   //  1'b1   1'b1  1'b1
   //


   reg A_reg ;    // to take into account drive-strength

   always @(A or DS) begin

      case ( DS )

         1'b0    : A_reg = A ;        // no delays 
         1'b1    : A_reg = A ;
         default : A_reg = A ;

         //1'b0    : A_reg = #(,) A ;
         //1'b1    : A_reg = #(,) A ;
         //default : A_reg = #(,) A ;

      endcase
   end

   bufif1  (IO, A_reg, OUT_EN ) ;


endmodule
`endcelldefine




`celldefine
module SF_1V2_FULL_LOCAL (

   inout wire IO,
   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST 

   ) ;

   `ifndef ABSTRACT
      tran (IO, IO);
   `endif

endmodule
`endcelldefine





`celldefine
module SF_1V2_CDM (

   inout wire Internal,
   inout wire IO,
   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST 

   ) ;

   `ifndef ABSTRACT
      tran (Internal, IO);
   `endif

endmodule
`endcelldefine





`celldefine
module SF_1V2_POWER_CLAMP_CORE_SUPPLY (

   inout wire VDD,
   inout wire VSS,
   inout wire VSSPST 

   ) ;

   `ifndef ABSTRACT
      tran(VSS, VSSPST) ;
   `endif

endmodule
`endcelldefine






`celldefine
module SF_1V2_POWER_CLAMP_CORE_GROUND (

   inout wire VDD,
   inout wire VSS,
   inout wire VSSPST

   ) ;

   `ifndef ABSTRACT
      tran(VSS, VSSPST) ;
   `endif

endmodule
`endcelldefine





`celldefine
module SF_1V2_POWER_CLAMP_IO_SUPPLY (

   inout wire VDDPST,
   inout wire VSSPST,
   inout wire VSS 

   ) ;

   `ifndef ABSTRACT
      tran(VSS, VSSPST) ;
   `endif

endmodule
`endcelldefine




`celldefine
module SF_1V2_POWER_CLAMP_IO_GROUND (

   inout wire VDDPST,
   inout wire VSSPST,
   inout wire VSS

   ) ;

   `ifndef ABSTRACT
      tran(VSS, VSSPST) ;
   `endif

endmodule
`endcelldefine

