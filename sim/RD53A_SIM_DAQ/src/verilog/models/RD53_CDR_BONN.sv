
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_CDR_BONN.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Mar 22, 2017
// [Modified]       Apr 25, 2017
// [Description]    Simple behavioural description for the CDR/PLL block. Simulation defaults assumes
//                  50 ps jitter on nominal 1.28 GHz PLL clock.
//
// [Notes]          Use the ADD_PLL_JITTER macro in $RTL_DIR/top/RD53A_defines.sv to enable
//                  random jitter simulation.
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/top/RD53A_defines.sv


`ifndef RD53_CDR_BONN__SV
`define RD53_CDR_BONN__SV

//`include "timescale.v"


`include "top/RD53A_defines.sv"


module RD53_CDR_BONN (

   input wire CMD,                      // serial input stream
   input wire [1:0] CDR_PD_SEL,         // phase-detector configuration, 2'b00 = CDR mode n.1, 2'b01 = CDR mode n.2, 2'b10 = CDR mode n.3, 2'b11 = PLL-mode
   input wire [2:0] CDR_PD_DEL,         // phase-detector configuration
   input wire [2:0] CDR_VCO_GAIN,       // VCO configuration

   input wire CDR_EN_GCK2,

   input wire CDR_SEL_DEL_CLK,          // MUX control
   input wire [2:0] CDR_SEL_SER_CLK,    // MUX control

   input wire BYPASS_CDR,
   input wire EXT_CMD_CLK,               // external 160 MHz clock, from SLVS RX
   input wire EXT_SER_CLK,               // external SER clock, from SLVS RX

   output wire CMD_CLK,                  // recovered 160 MHz clock or 
   output wire DEL_CLK,                  // 640 MHz PLL clock or EXT_SER_CLK for fine-delay

   output logic SER_CLK,                 // TX clock for serializers
   output logic CMD_DATA,                // serial output stream

   output wire GWT_320_CLK,              // dedicated 320 MHz clock for GWT driver


   // charge-pump and VCO bias currents, not used in this model
   input real CDR_CP_BIAS,
   input real CDR_VCO_BIAS,
   input real CDR_VCO_BUFF_BIAS,

   // power/ground, used to model power down
   inout wire VDD_PLL,
   inout wire VSS_PLL

   ) ;
   
   timeunit 1ps ;
   timeprecision 1ps ;


   // nominal 1.28 GHz PLL clock

   logic pll_clk_sim = 1'b0 ;

   parameter period = 782 ;         // ps
   parameter jitter =  50 ;         // ps

   integer seed = 10 ;


   `ifdef ADD_PLL_JITTER

   always #( 0.5*period + $dist_uniform(seed,-jitter,jitter) ) pll_clk_sim = ~pll_clk_sim ;

   `else

   always #( 0.5*period ) pll_clk_sim = ~ pll_clk_sim ;

   `endif


   // check PLL power/ground connectivity

   logic pll_clk ;

   always_comb begin

      case( { VDD_PLL , VSS_PLL } )

          2'b10   : pll_clk = pll_clk_sim ;        // power/ground OK
          2'b00   : pll_clk = 1'b0 ;               // no power

          default : pll_clk = 1'bx ;               // not allowed

      endcase
   end



   // clock divider to generate 640 MHz, 320 MHz and 160 MHz clocks
   logic [2:0] clk_div = 3'b000 ;
 
   always @(posedge pll_clk )
     clk_div <= clk_div + 1 ;


   wire pll_clk_640MHz ;
   wire pll_clk_320MHz ;
   wire pll_clk_160MHz ;

   assign pll_clk_640MHz = clk_div[0] ;      // 640 MHz, pll_clk/2
   assign pll_clk_320MHz = clk_div[1] ;      // 320 MHz, pll_clk/4
   assign pll_clk_160MHz = clk_div[2] ;      // 160 MHz, pll_clk/8


   // SER_CLK clock MUX
   always_comb begin

       case( CDR_SEL_SER_CLK[2:0] )

         3'b000 , 3'b100  : SER_CLK = pll_clk ;
         3'b001 , 3'b101  : SER_CLK = pll_clk_640MHz ;
         3'b010 , 3'b110  : SER_CLK = pll_clk_320MHz ;
         3'b011           : SER_CLK = pll_clk_160MHz ;
         3'b111           : SER_CLK = EXT_SER_CLK ;

      endcase
   end  // always_comb



   assign DEL_CLK = ( CDR_SEL_DEL_CLK == 1'b0 ) ? pll_clk_640MHz : EXT_SER_CLK ;


   // effective 160 MHz clock fed to core logic, either from PLL or from external pad, used to synchronize CMD_DATA

   wire cmd_clk_mux ;

   assign cmd_clk_mux = ( BYPASS_CDR == 1'b1 ) ? EXT_CMD_CLK : pll_clk_160MHz ;


   // data stream fed to core logic

   always_ff @(posedge cmd_clk_mux )
      CMD_DATA <= CMD ;


   assign CMD_CLK = cmd_clk_mux ;


endmodule : RD53_CDR_BONN

`endif

