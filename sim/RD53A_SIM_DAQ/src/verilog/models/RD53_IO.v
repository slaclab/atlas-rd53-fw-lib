
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_IO.v
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       Verilog 2005 [IEEE Std. 1364-2005]
// [Created]        Mar 20, 2016
// [Modified]       Apr 25, 2017
// [Description]    Verilog wrappers and behavioral models for CERN I/O cells, SLVS TX/RX and GTX
//                  according to OA schematic views.
//
// [Notes]          For RTL simulations use $RTL_DIR/models/Serializer_TapDelayX4.v. For post-PNR
//                  simulations use $RTL_DIR/models/Serializer_TapDelayX4_pwr.v
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/models/CERN_IO_1P2V.v
// $RTL_DIR/models/Serializer_TapDelayX4.v (RTL) or Serializer_TapDelayX4_pwr.v (post-PNR)


`timescale 1ns / 1ps
//`include "timescale.v"
`default_nettype wire

`include "models/CERN_IO_1P2V.v"

//`ifdef RTL_SIM
   `include "models/Serializer_TapDelayX4.v"
//`else
//   `include "models/Serializer_TapDelayX4_pwr.v"
//`endif


`celldefine
module PASSIVE_pad (

   inout wire PAD,            // pad

   inout wire O ,             // to/from core using SF_1V2_CDM
   inout wire I,              // to/from core directly to PAD, just a cds_thru as in OA schematic

   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST

   ) ;


   SF_1V2_CDM  analog_pad ( 

      .IO        (    PAD ),
      .Internal  (      O ),
      .VDD       (    VDD ),
      .VSS       (    VSS ),
      .VDDPST    ( VDDPST ),
      .VSSPST    ( VSSPST )

      ) ;


   assign I = PAD ;

endmodule
`endcelldefine


`celldefine
module PASSIVE_noESD_pad (

   inout wire PAD,
   inout wire IO,

   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST

   ) ;

   assign IO = PAD ;   // just a cds_thru as in OA schematic

endmodule
`endcelldefine


`celldefine
module PASSIVE_OVT_PD_pad (

   inout wire PAD,
   inout wire IO,

   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST

   ) ;

   assign IO = PAD ;

endmodule
`endcelldefine


`celldefine
module CMOS_pad (

   inout  wire PAD,           // pad

   input  wire PEN,           // pull-up/down enable (configuration bit)
   input  wire UD_B ,         // pull-up/down select (configuration bit)    **WARN: active-low!
   output wire Z,             // **TO** core

   input  wire OUT_EN,        // output-enable (configuration bit)
   input  wire DS,            // drive-strength select (configuration bit)
   input  wire A,             // **FROM** core

   inout  wire VDD,
   inout  wire VSS,
   inout  wire VDDPST,
   inout  wire VSSPST

   ) ;


   CERN_IO_PAD  cmos_pad (

      .IO     (    PAD ),
      .PEN    (    PEN ),
      .\UD*   (   UD_B ),
      .Z      (      Z ),
      .OUT_EN ( OUT_EN ),
      .DS     (     DS ),
      .A      (      A ),
      .VDD    (    VDD ),
      .VSS    (    VSS ),
      .VDDPST ( VDDPST ),
      .VSSPST ( VSSPST )

      ) ;

endmodule
`endcelldefine


`celldefine
module LVDS_RX_pad (

   input wire PAD_P,
   input wire PAD_N,

   input wire EN_B,

   output wire O,

   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST

   ) ;


   // simple behavioral modelling for differential RX
   reg rx_data ;

   always @(*) begin

      if( EN_B == 1'b0 ) begin

         case( { PAD_P , PAD_N } )

            2'b01   : rx_data = 1'b0 ; 
            2'b10   : rx_data = 1'b1 ;

            default : rx_data = 1'bx ;

         endcase
      end
      else
         rx_data = 1'bx ;

   end   // always

   assign O = rx_data ;

endmodule
`endcelldefine


`celldefine
module LVDS_TX_pad (

   input wire I,
   input wire EN_B,
   input wire [2:0] B,

   output wire PAD_P,
   output wire PAD_N,

   inout wire VDD,
   inout wire VSS, 
   inout wire VDDPST,
   inout wire VSSPST

   ) ;


   // simple behavioral modelling for differential RX
   reg tx_data ;

   always @(*) begin

      if( EN_B == 1'b0 )

         /*
         case( B )

            3'b000  : tx_data = I ;        // **NOTE: drive-strength not modeled for the moment
            3'b001  : tx_data = I ;
            3'b010  : tx_data = I ;
            3'b011  : tx_data = I ;
            3'b100  : tx_data = I ;
            3'b101  : tx_data = I ;
            3'b110  : tx_data = I ;
            3'b111  : tx_data = I ;

            default : tx_data = I ;

         endcase */

         tx_data = I ;

      else
         tx_data = 1'bx ;

   end   // always

   assign PAD_P =  tx_data ;
   assign PAD_N = ~tx_data ;

endmodule
`endcelldefine


`celldefine
module POWERCUT ( inout wire VSS ) ;
endmodule
`endcelldefine



`celldefine
module CML_TX_RD53A (

   input wire CML_EN,

   input wire SER_OUT_TAP1,
   input wire SER_OUT_TAP2,
   input wire SER_OUT_TAP3,

   output wire DOP,
   output wire DON,

   inout wire IBIAS1,
   inout wire IBIAS2,
   inout wire IBIAS3,

   // power/ground, used to model CML power-off
   inout wire VDD,
   inout wire VSS

   ) ;


   // pre-driver signals
   wire TAP1_P, TAP1_N ;
   wire TAP2_P, TAP2_N ;
   wire TAP3_P, TAP4_N ;

   assign TAP1_P = SER_OUT_TAP1 ; assign TAP1_N = ~ SER_OUT_TAP1 ;
   assign TAP2_P = SER_OUT_TAP2 ; assign TAP2_N = ~ SER_OUT_TAP2 ;
   assign TAP3_P = SER_OUT_TAP2 ; assign TAP3_N = ~ SER_OUT_TAP3 ;

   wire tx_data_p, tx_data_n ;

   assign tx_data_p = ( CML_EN == 1'b1 ) ? TAP1_P : 1'bx ;
   assign tx_data_n = (	CML_EN == 1'b1 ) ? TAP1_N : 1'bx ;

   assign DOP = ( VDD == 1'b1 && VSS == 1'b0 ) ? tx_data_p : ( VDD == 1'b0 && VSS == 1'b0 ) ? 1'b0 : 1'bx ; 
   assign DON = ( VDD == 1'b1 && VSS == 1'b0 ) ? tx_data_n : ( VDD == 1'b0 && VSS == 1'b0 ) ? 1'b0 : 1'bx ;

endmodule
`endcelldefine





module GTX_pad (

   input  wire SER_RST_B,
   input  wire SER_TX_CLK,

   input  wire [3:0] SER_EN_LANE,
   input  wire [2:1] SER_INV_TAP,
   input  wire [2:1] SER_EN_TAP,

   input  wire [1:0] SER_SEL_OUT0,
   input  wire [1:0] SER_SEL_OUT1,
   input  wire [1:0] SER_SEL_OUT2,
   input  wire [1:0] SER_SEL_OUT3,

   input  wire [19:0] SER_WORD0,
   input  wire [19:0] SER_WORD1,
   input  wire [19:0] SER_WORD2,
   input  wire [19:0] SER_WORD3,

   output wire SER_WORD_CLK,

   output wire GTX0_PAD_P,
   output wire GTX0_PAD_N,
   output wire GTX1_PAD_P,
   output wire GTX1_PAD_N,
   output wire GTX2_PAD_P,
   output wire GTX2_PAD_N,
   output wire GTX3_PAD_P,
   output wire GTX3_PAD_N,

   inout  wire CML_TAP_BIAS1,
   inout  wire CML_TAP_BIAS2,
   inout  wire CML_TAP_BIAS3,

   inout wire VDDD,
   inout wire GNDD,

   inout wire VDD_CML,
   inout wire GND_CML,

   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST

   ) ;


   /*   **LEGACY BEHAVIORAL**   */

   /*

   // clock divider for Aurora/CDC FIFO and data load
   wire ser_tx_clk ;
   assign ser_tx_clk = SER_TX_CLK ;

   reg [4:0] cnt = 5'b00000 ;

   always @( posedge ser_tx_clk ) begin
      if( cnt == 19 )
         cnt <= 0 ;
      else
         cnt <= cnt + 1 ;
   end

   wire data_clk = cnt[3] ;
   assign SER_WORD_CLK = data_clk ;     // SER_TX_CLK/20

   reg load ;

   always @( posedge ser_tx_clk )
      load <= ( cnt == 2 ) ;

   // data synchronization

   reg [19:0] data_0 ;
   reg [19:0] data_1 ;
   reg [19:0] data_2 ;
   reg [19:0] data_3 ;

   always @( posedge data_clk ) begin
      data_0 <= SER_WORD0 ;
      data_1 <= SER_WORD1 ;
      data_2 <= SER_WORD2 ;
      data_3 <= SER_WORD3 ;
   end


   // serializers (just simple PISO shift registers)

   reg [19:0] shift_reg_0 ;
   reg [19:0] shift_reg_1 ;
   reg [19:0] shift_reg_2 ;
   reg [19:0] shift_reg_3 ;

   always @( posedge ser_tx_clk ) begin

      if( load ) begin
         shift_reg_0 <= data_0 ;
         shift_reg_1 <= data_1 ;
         shift_reg_2 <= data_2 ;
         shift_reg_3 <= data_3 ;
      end
      else begin
         shift_reg_0 <= { 1'b0 , shift_reg_0[19:1] } ;    // shift-right using concatenation
         shift_reg_1 <= { 1'b0 , shift_reg_1[19:1] } ;
         shift_reg_2 <= { 1'b0 , shift_reg_2[19:1] } ;
         shift_reg_3 <= { 1'b0 , shift_reg_3[19:1] } ;
      end  // else
   end // always

   assign GTX0_PAD_P = shift_reg_0[0] ; assign GTX0_PAD_N = ~ shift_reg_0[0] ;
   assign GTX1_PAD_P = shift_reg_1[0] ; assign GTX1_PAD_N = ~ shift_reg_1[0] ;
   assign GTX2_PAD_P = shift_reg_2[0] ; assign GTX2_PAD_N = ~ shift_reg_2[0] ;
   assign GTX3_PAD_P = shift_reg_3[0] ; assign GTX3_PAD_N = ~ shift_reg_3[0] ;

   */

    

   // NC-Verilog gate-level netlist from OA schematic view

   // **NOTE: use deposit to force some initial value on net018 or net07, otherwise the clock-divider cannot work!

   wire [3:0] SER_TAP1 ;
   wire [3:0] SER_TAP2 ;
   wire [3:0] SER_TAP3 ;


   Serializer_TapDelayX4  SER_CML (

      // inputs
      .EXT_RST_B         (    SER_RST_B ), 
      .SER_CLK           (   SER_TX_CLK ),

      .DATA_SER0         (    SER_WORD0 ),
      .DATA_SER1         (    SER_WORD1 ),
      .DATA_SER2         (    SER_WORD2 ),
      .DATA_SER3         (    SER_WORD3 ),

      .SER_EN_TAP_SER0   (   SER_EN_TAP ),
      .SER_EN_TAP_SER1   (   SER_EN_TAP ),
      .SER_EN_TAP_SER2   (   SER_EN_TAP ),
      .SER_EN_TAP_SER3   (   SER_EN_TAP ),

      .SER_INV_TAP_SER0  (  SER_INV_TAP ),
      .SER_INV_TAP_SER1  (  SER_INV_TAP ),
      .SER_INV_TAP_SER2  (  SER_INV_TAP ),
      .SER_INV_TAP_SER3  (  SER_INV_TAP ),

      .SER_SEL_OUT_SER0  ( SER_SEL_OUT0 ),
      .SER_SEL_OUT_SER1  ( SER_SEL_OUT1 ),
      .SER_SEL_OUT_SER2  ( SER_SEL_OUT2 ),
      .SER_SEL_OUT_SER3  ( SER_SEL_OUT3 ),

      // outputs
      .TAP0              (     SER_TAP1 ),
      .TAP1              (     SER_TAP2 ),
      .TAP2              (     SER_TAP3 ),

      .WORD_CLK            ( SER_WORD_CLK ),
      //.CLK_640_INT       (              ),            //   **UNCONNECTED
      .LOAD_INT_B        (              ),            //   **UNCONNECTED
      .EN_LANE           (SER_EN_LANE   ),

      // power/ground
      .VDD               (         VDDD ),
      .VSS               (         GNDD )

      ) ;

   wire [3:0] CML_TAP1 ; assign CML_TAP1 = SER_TAP1 ;  // as in OA schematic view
   wire [3:0] CML_TAP2 ; assign CML_TAP2 = SER_TAP2 ;
   wire [3:0] CML_TAP3 ; assign CML_TAP3 = SER_TAP3 ;

   wire [3:0] DOP ;
   wire [3:0] DON ;

   generate

      genvar k ;

      for( k = 0; k < 4; k = k+1 )

         CML_TX_RD53A   CML_TX (

            .CML_EN       ( SER_EN_LANE[k] ),
            .SER_OUT_TAP1 (    CML_TAP1[k] ), 
            .SER_OUT_TAP2 (    CML_TAP2[k] ), 
            .SER_OUT_TAP3 (    CML_TAP3[k] ), 
            .DOP          (         DOP[k] ),
            .DON          (         DON[k] ),
            .IBIAS1       (  CML_TAP_BIAS1 ),
            .IBIAS2       (  CML_TAP_BIAS2 ),
            .IBIAS3       (  CML_TAP_BIAS3 ),
            .VDD          (        VDD_CML ),
            .VSS          (        GND_CML )

            ) ;

   endgenerate


   assign GTX0_PAD_P = DOP[0] ; assign GTX0_PAD_N = DON[0] ;
   assign GTX1_PAD_P = DOP[1] ; assign GTX1_PAD_N = DON[1] ;
   assign GTX2_PAD_P = DOP[2] ; assign GTX2_PAD_N = DON[2] ;
   assign GTX3_PAD_P = DOP[3] ; assign GTX3_PAD_N = DON[3] ;
    
endmodule



`celldefine
module POWER_pad (

   inout wire PAD,

   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST 

   ) ;

endmodule
`endcelldefine


`celldefine
module GROUND_pad (

   inout wire PAD,

   inout wire VDD,
   inout wire VSS,
   inout wire VDDPST,
   inout wire VSSPST 

   ) ;

endmodule
`endcelldefine

