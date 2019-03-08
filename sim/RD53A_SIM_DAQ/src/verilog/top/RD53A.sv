
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53A.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         -
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 21, 2017
// [Modified]       Jul  6, 2017
// [Description]    Top-level wrapper for the entire chip
//
// [Notes]          Ref. to https://twiki.cern.ch/twiki/bin/view/RD53/IoPadFrame for
//                  the latest I/O pinout assignment
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/top/RD53A_defines.sv
// $RTL_DIR/top/DigitalChipBottom.sv
// $RTL_DIR/top/PixelArray.sv
// $RTL_DIR/eoc/jtag/JTAG_MACRO.sv
// $RTL_DIR/eoc/jtag/JTAG_BOUNDARYSCAN_REGISTER.sv
// $RTL_DIR/models/RD53_PADFRAME_TOP.sv
// $RTL_DIR/models/RD53_PADFRAME_BOTTOM.sv
// $RTL_DIR/models/RD53_ANALOG_CHIP_BOTTOM.sv


`ifndef RD53A__SV
`define RD53A__SV


`default_nettype wire

`timescale  1ns / 1ps
//`include "timescale.v"


`include "top/RD53A_defines.sv"
`include "top/DigitalChipBottom.sv"
`include "top/PixelArray.sv"
`include "eoc/jtag/JTAG_MACRO.sv"
`include "eoc/jtag/JTAG_BOUNDARYSCAN_REGISTER.sv"
`include "models/RD53_PADFRAME_BOTTOM.sv"
`include "models/RD53_ANALOG_CHIP_BOTTOM.sv"
`include "models/RD53_TOP_BLOCKS.v"

module RD53A (


   //------------------------------   DIGITAL INTERFACE   ------------------------------//

   //
   // Power-on Resets (POR)
   //
   input  wire  POR_EXT_CAP_PAD,                            // POR external-cap pin, also used to trigger POR signal
   output wire  POR_OUT_B_PAD,                              // sense/override POR output signal, bidirectional
   input  wire  POR_SLDO_BGP_PAD,                           // **BACKUP: POR signal for Shunt-LDO bandgap voltage reference
   input  wire  PLL_RST_B_PAD,
   inout  wire  PLL_VCTRL_PAD,
   //
   // Clock Data Recovery (CDR) input command/data stream [SLVS]
   //
   input  wire  CMD_P_PAD,
   input  wire  CMD_N_PAD,

   //
   // 4x general-purpose SLVS outputs, including Hit-ORs
   //
   output wire GPLVDS0_P_PAD,
   output wire GPLVDS0_N_PAD,

   output wire GPLVDS1_P_PAD,
   output wire GPLVDS1_N_PAD,

   output wire GPLVDS2_P_PAD,
   output wire GPLVDS2_N_PAD,

   output wire GPLVDS3_P_PAD,
   output wire GPLVDS3_N_PAD,

   //
   // general purpose monitor output [CMOS]
   //
   output wire STATUS_PAD,          

   //
   // 4x serial output data links @ 1.28 Gb/s [CML]
   //
   output wire GTX0_P_PAD,             
   output wire GTX0_N_PAD,

   output wire GTX1_P_PAD,
   output wire GTX1_N_PAD,

   output wire GTX2_P_PAD,
   output wire GTX2_N_PAD,

   output wire GTX3_P_PAD,
   output wire GTX3_N_PAD,

   //
   // single serial output data link @ 5 Gb/s [GWT]
   //
   //output wire GWTX_P_PAD,
   //output wire GWTX_N_PAD,

   //
   // external 3-bit hard-wired local chip address [CMOS]
   //
   input  wire CHIPID0_PAD,
   input  wire CHIPID1_PAD,
   input  wire CHIPID2_PAD,

   //
   // **BACKUP: single 1.28 Gb/s output line [SLVS]
   //
   output wire GTX0LVDS_P_PAD,
   output wire GTX0LVDS_N_PAD,

   //
   // **BACKUP: bypass/debug MUX controls [CMOS]
   //
   input  wire BYPASS_CMD_PAD,                              // bypass command-decoder and use JTAG
   input  wire BYPASS_CDR_PAD,                              // bypass CDR and enable external CMD clock and data
   input  wire DEBUG_EN_PAD,                                // global debug-enable

   //
   // **BACKUP: external clocks [SLVS]
   //
   input  wire EXT_CMD_CLK_P_PAD,                           // external 160 MHz clock for CDR bypass mode 
   input  wire EXT_CMD_CLK_N_PAD,

   input  wire EXT_SER_CLK_P_PAD,                           // external user-defined SER clock
   input  wire EXT_SER_CLK_N_PAD,

   //
   // **BACKUP: JTAG [CMOS]
   //
   input  wire JTAG_TRST_B_PAD,                             // JTAG test-reset, active-low   [PD]
   input  wire JTAG_TCK_PAD,                                // JTAG test clock               [PD]
   input  wire JTAG_TMS_PAD,                                // JTAG test mode select         [PU]
   input  wire JTAG_TDI_PAD,                                // JTAG test data input          [PU]
   output wire JTAG_TDO_PAD,                                // JTAG test data output

   //
   // **BACKUP: external trigger [CMOS]
   //
   input  wire EXT_TRIGGER_PAD,

   //
   // **BACKUP: auxiliary external CalEdge/CalDly injection signals [CMOS]
   //
   input  wire INJ_STRB0_PAD,
   input  wire INJ_STRB1_PAD,


   //------------------------------   ANALOG INTERFACE   ------------------------------//

   //
   // pixel inputs
   //
   input  wire [`COLS*`ROWS*`REGIONS*`REG_PIXELS-1:0] ANA_HIT,

   //
   // external reference-current calibration
   //
   input  wire IREF_TRIM0_PAD,                             // 4-bit bias generator current reference trimming
   input  wire IREF_TRIM1_PAD,
   input  wire IREF_TRIM2_PAD,
   input  wire IREF_TRIM3_PAD,

   //
   // **BACKUP: external DC calibration levels
   //
   inout  wire VINJ_HI_PAD,
   inout  wire VINJ_MID_PAD,

   //
   // monitoring
   //
   inout  wire IMUX_OUT_PAD,                               // output from current multiplexer
   inout  wire VMUX_OUT_PAD,                               // output from voltage multiplexer

   //
   // **BACKUP: external ADC reference voltages
   //
   inout  wire VREF_ADC_IN_PAD,
   inout  wire VREF_ADC_OUT_PAD,

   //
   // **BACKUP: bias currents
   //
   inout  wire IREF_IN_PAD,                                // main reference current output
   inout  wire IREF_OUT_PAD,                               // reference current input to analog macro



   //---------------------------   POWER/GROUND INTERFACE   ---------------------------//

   //
   // ANALOG Shunt-LDO
   //
   inout  wire SLDO_REXT_A_PAD,                            // connection to external analog shunt resistor
   inout  wire SLDO_RINT_A_PAD,                            // connection to internal analog shunt resistor
   inout  wire SLDO_VREF_A_PAD,                            // reference voltage for VDDA (=VREFA), out for decoupling, in to override reference
   inout  wire SLDO_VOFFSET_A_PAD,                         // reference voltage for analog shunt offset voltage, out for decoupling, in to override reference
   inout  wire SLDO_VDDSHUNT_A_PAD,                        // power supply for analog shunt error amplifier

   //
   // DIGITAL Shunt-LDO
   //
   inout  wire SLDO_REXT_D_PAD,                            // connection to external digital shunt resistor
   inout  wire SLDO_RINT_D_PAD,                            // connection to internal digital shunt resistor
   inout  wire SLDO_VREF_D_PAD,                            // reference voltage for VDDD (=VREFD), out for decoupling, in to override reference
   inout  wire SLDO_VOFFSET_D_PAD,                         // reference voltage for digital shunt offset voltage, out for decoupling, in to override reference
   inout  wire SLDO_VDDSHUNT_D_PAD,                        // power supply for digital shunt error amplifier
   inout  wire COMP_LDO_EN_B_PAD,
   
   `ifdef USE_VAMS
   //
   // ANALOG core power/ground
   //
   inout  wire VDDA,                                       // core analog supply
   inout  wire GNDA,                                       // core analog ground
  
   //
   // DIGITAL core power/ground
   //
   inout  wire VDDD,                                       // digital supply
   inout  wire GNDD,                                       // core digital ground
   
   //
   // global substrate
   //
   inout  wire VSUB,                                       // global substrate connection

   
   `endif

   inout  wire VINA_PAD,                                   // voltage/current input for analog regulator
   inout  wire VIND_PAD,                                   // voltage/current input for digital regulator
   
   //
   // dedicated PLL power/ground rails
   //
   inout  wire VDD_PLL_PAD,
   inout  wire GND_PLL_PAD,
   
   //
   // dedicated CML driver power/ground rails
   //
   inout  wire VDD_CML_PAD,
   inout  wire GND_CML_PAD, 

   //
   // dedicated 5 Gb/s SER power/ground rails
   //
   //inout  wire GWT_VDD_PAD,
   //inout  wire GWT_VSS_PAD,
   //inout  wire GWT_VDDHS_PAD,
   //inout  wire GWT_GNDHS_PAD,
   //inout  wire GWT_VDDHS_CORE_PAD,
   //inout  wire GWT_GNDHS_CORE_PAD,

   //
   // ground for detector guard-ring pads
   //
   inout  wire DET_GRD0_PAD,
   inout  wire DET_GRD1_PAD,
  
    inout BGPV_OE12_PAD,
    inout BGPV_OE34_PAD,
    inout BGPV_OE56_PAD,
    inout BGPV_SF_IN_PAD,
    inout BGPV_SF_OUT1_PAD,
    inout BGPV_SF_OUT2_PAD,
    inout BGPV_SF_OUT3_PAD,
    inout BGPV_SF_OUT4_PAD,
    inout BGPV_SF_OUT5_PAD,
    inout BGPV_SF_OUT6_PAD,
    inout BGPV_SF_OUT_PAD,
    inout CLKN_DX_PAD,
    inout CLKN_SX_PAD,
    inout CLKP_DX_PAD,
    inout CLKP_SX_PAD,
    inout GND_TOP,
    inout LBNL_OUT1_1O_PAD,
    inout LBNL_OUT1_2O_PAD,
    inout LBNL_OUT1_3O_PAD,
    inout LBNL_OUT2B_1O_PAD,
    inout LBNL_OUT2B_2O_PAD,
    inout LBNL_OUT2B_3O_PAD,
    inout LBNL_OUT2_1O_PAD,
    inout LBNL_OUT2_2O_PAD,
    inout LBNL_OUT2_3O_PAD,
    inout TO_OE12_PAD,
    inout TO_OE34_PAD,
    inout TO_OE56_PAD,
    inout TO_SF_IN_PAD,
    inout TO_SF_OUT1_PAD,
    inout TO_SF_OUT2_PAD,
    inout TO_SF_OUT3_PAD,
    inout TO_SF_OUT4_PAD,
    inout TO_SF_OUT5_PAD,
    inout TO_SF_OUT6_PAD,
    inout TO_SF_OUT_PAD,
    inout VDD_CAP_DX_PAD,
    inout VDD_CAP_SX_PAD,
    inout VDD_PCAP_DX_PAD,
    inout VDD_PCAP_SX_PAD,
    inout VDD_TOP

   ) ;



   `ifndef ABSTRACT



   //----------------------   BOTTOM PADFRAME (I/O CELLS, SLVS TX/RX, SER, Shunt-LDO)   ---------------------//


   // internal wires for padframe interconnections

   wire bypass_cdr_noroute ;
   wire bypass_cmd ;
   wire debug_en ;

   wire ext_trigger ; 

   wire [1:0] inj_strb ;
   wire [2:0] chip_id ;

   wire status ;
   wire status_ds ;

   wire jtag_trst_b ;
   wire jtag_tck ;
   wire jtag_tms ;
   wire jtag_tdi ;
   wire jtag_tdo ;
   wire jtag_tdo_ds ;
   wire jtag_tdo_en ;

   wire ext_por_cap_noroute ;
   wire por_out_b_noroute ;
   wire pll_rst_b_noroute;
   wire pll_vctrl_noroute;
   wire por_out_b ;

   wire cdr_cmd_data_in_noroute ;
   wire cdr_cmd_data_out ;

   wire ext_cmd_clk_en_b ;
   wire ext_cmd_clk_noroute ;

   wire ext_ser_clk_en_b ;
   wire ext_ser_clk_noroute ;

   logic [3:0] gp_lvds ;         // logic since output from procedural block
   wire  [3:0] gp_lvds_en_b ;
   wire  [2:0] gp_lvds_ds ;      // 3-bit programmable driving capability for each SLVS TX

   //wire gtx0_lvds ;
   wire gtx0_lvds_en_b ;
   wire [2:0] gtx0_lvds_ds ;
 
   wire ser_rst_b ;
   wire [1:0] ser_inv_tap ; 
   wire [1:0] ser_en_tap ;
   wire [1:0] ser_sel_out0 ;
   wire [1:0] ser_sel_out1 ;
   wire [1:0] ser_sel_out2 ;
   wire [1:0] ser_sel_out3 ;

   wire cdr_ser_clk_noroute ;
   wire cdr_gwt_clk ;
   wire data_clk ;

   wire [19:0] ser_data1G_0 ;
   wire [19:0] ser_data1G_1 ;
   wire [19:0] ser_data1G_2 ;
   wire [19:0] ser_data1G_3 ;

   wire gwt_en ;
   wire [31:0] ser_data5G ;


   wire [3:0] cml_en_lane ;

   wire cml_tap_bias1_noroute ;
   wire cml_tap_bias2_noroute ;
   wire cml_tap_bias3_noroute ;

   wire Imux_out_noroute ;
   wire Iref_in_noroute ;
   wire Iref_out_noroute ;
   wire  [3:0] Iref_trim_noroute ;

   wire Vinj_hi_noroute ;
   wire Vinj_mid_noroute ;
   wire Vmux_out_noroute ;
   wire Vref_adc_in_noroute ;
   wire Vref_adc_out_noroute ;

   wire Vmon_sldo_analog_Ishunt_noroute ;
   wire Vmon_sldo_analog_Isupply_noroute ;
   wire Vmon_sldo_analog_Vin_noroute ;
   wire Vmon_sldo_analog_Voffset_noroute ;
   wire Vmon_sldo_analog_Vout_noroute ;
   wire Vmon_sldo_analog_Vref_noroute ;

   wire Vmon_sldo_digital_Ishunt_noroute ;
   wire Vmon_sldo_digital_Isupply_noroute ;
   wire Vmon_sldo_digital_Vin_noroute ;
   wire Vmon_sldo_digital_Voffset_noroute ;
   wire Vmon_sldo_digital_Vout_noroute ;
   wire Vmon_sldo_digital_Vref_noroute ;

   wire [4:0] sldo_analog_trim ;
   wire [4:0] sldo_digital_trim ;

   wire [1:0] det_grd_noroute ;

   wire [16*8-1:0]  TopPadframe_VOUT_PREAMP_TO;
   wire [17*8-1:0]  TopPadframe_PA_OUT_BG;
   wire [17*8-1:0]  TopPadframe_OUT1_LBNL;
   wire [17*8-1:0]  TopPadframe_OUT2_LBNL;
   wire [17*8-1:0]  TopPadframe_OUT2B_LBNL;

   
   RD53_PADFRAME_BOTTOM   PADFRAME_BOTTOM (

      //   ** on-pads layout pins **               ** to/from core internal pins **

      //
      // input CMOS pads with configuration
      //
      .BYPASS_CDR_PAD( BYPASS_CDR_PAD ),            .BYPASS_CDR_A       (               1'b0 ),
                                                    .BYPASS_CDR_DS      (               1'b0 ),
                                                    .BYPASS_CDR_OUT_EN  (               1'b0 ),
                                                    .BYPASS_CDR_PEN     (               1'b1 ),
                                                    .BYPASS_CDR_UD_B    (               1'b0 ),      //   **pull-down**
                                                    .BYPASS_CDR_Z       ( bypass_cdr_noroute ),

      .BYPASS_CMD_PAD( BYPASS_CMD_PAD ),            .BYPASS_CMD_A       (               1'b0 ),
                                                    .BYPASS_CMD_DS      (               1'b0 ),
                                                    .BYPASS_CMD_OUT_EN  (               1'b0 ),
                                                    .BYPASS_CMD_PEN     (               1'b1 ),
                                                    .BYPASS_CMD_UD_B    (               1'b0 ),      //   **pull-down**
                                                    .BYPASS_CMD_Z       (         bypass_cmd ),

      .DEBUG_EN_PAD( DEBUG_EN_PAD ),                .DEBUG_EN_A         (               1'b0 ),
                                                    .DEBUG_EN_DS        (               1'b0 ),
                                                    .DEBUG_EN_OUT_EN    (               1'b0 ),
                                                    .DEBUG_EN_PEN       (               1'b1 ),
                                                    .DEBUG_EN_UD_B      (               1'b0 ),      //   **pull-down**
                                                    .DEBUG_EN_Z         (           debug_en ),

      .EXT_TRIGGER_PAD( EXT_TRIGGER_PAD ),          .EXT_TRIGGER_A      (               1'b0 ),
                                                    .EXT_TRIGGER_DS     (               1'b0 ),
                                                    .EXT_TRIGGER_OUT_EN (               1'b0 ),
                                                    .EXT_TRIGGER_PEN    (               1'b1 ),
                                                    .EXT_TRIGGER_UD_B   (               1'b0 ),      //   **pull-down**
                                                    .EXT_TRIGGER_Z      (        ext_trigger ),

      .INJ_STRB0_PAD( INJ_STRB0_PAD ),              .INJ_STRB0_A        (               1'b0 ),
                                                    .INJ_STRB0_DS       (               1'b0 ),
                                                    .INJ_STRB0_OUT_EN   (               1'b0 ),
                                                    .INJ_STRB0_PEN      (               1'b1 ),
                                                    .INJ_STRB0_UD_B     (               1'b0 ),      //   **pull-down**
                                                    .INJ_STRB0_Z        (        inj_strb[0] ),

      .INJ_STRB1_PAD( INJ_STRB1_PAD ),              .INJ_STRB1_A        (               1'b0 ),
                                                    .INJ_STRB1_DS       (               1'b0 ),
                                                    .INJ_STRB1_OUT_EN   (               1'b0 ),
                                                    .INJ_STRB1_PEN      (               1'b1 ),
                                                    .INJ_STRB1_UD_B     (               1'b0 ),      //   **pull-down**
                                                    .INJ_STRB1_Z        (        inj_strb[1] ),

      .CHIPID0_PAD( CHIPID0_PAD ),                  .CHIPID0_A          (               1'b0 ),
                                                    .CHIPID0_DS         (               1'b0 ),      
                                                    .CHIPID0_OUT_EN     (               1'b0 ),
                                                    .CHIPID0_PEN        (               1'b1 ),
                                                    .CHIPID0_UD_B       (               1'b0 ),      //   **pull-down**
                                                    .CHIPID0_Z          (         chip_id[0] ),

      .CHIPID1_PAD( CHIPID1_PAD ),                  .CHIPID1_A          (               1'b0 ),
                                                    .CHIPID1_DS         (               1'b0 ),      
                                                    .CHIPID1_OUT_EN     (               1'b0 ),
                                                    .CHIPID1_PEN        (               1'b1 ),
                                                    .CHIPID1_UD_B       (               1'b0 ),      //   **pull-down**
                                                    .CHIPID1_Z          (         chip_id[1] ),

      .CHIPID2_PAD( CHIPID2_PAD ),                  .CHIPID2_A          (               1'b0 ),
                                                    .CHIPID2_DS         (               1'b0 ),      
                                                    .CHIPID2_OUT_EN     (               1'b0 ),
                                                    .CHIPID2_PEN        (               1'b1 ),
                                                    .CHIPID2_UD_B       (               1'b0 ),      //   **pull-down**
                                                    .CHIPID2_Z          (         chip_id[2] ),

      .TRST_B_PAD( JTAG_TRST_B_PAD ),               .TRST_B_A           (               1'b0 ),
                                                    .TRST_B_DS          (               1'b0 ),
                                                    .TRST_B_OUT_EN      (               1'b0 ),
                                                    .TRST_B_PEN         (               1'b1 ),
                                                    .TRST_B_UD_B        (               1'b0 ),      //   **pull-down**   (IEEE Std. broken)
                                                    .TRST_B_Z           (        jtag_trst_b ),

      .TCK_PAD( JTAG_TCK_PAD ),                     .TCK_A              (               1'b0 ),
                                                    .TCK_DS             (               1'b0 ),
                                                    .TCK_OUT_EN         (               1'b0 ),
                                                    .TCK_PEN            (               1'b1 ),
                                                    .TCK_UD_B           (               1'b0 ),      //   **pull-down**   (IEEE Std. compliant)
                                                    .TCK_Z              (           jtag_tck ),

      .TDI_PAD( JTAG_TDI_PAD ),                     .TDI_A              (               1'b0 ),
                                                    .TDI_DS             (               1'b0 ),
                                                    .TDI_OUT_EN         (               1'b0 ),
                                                    .TDI_PEN            (               1'b1 ),
                                                    .TDI_UD_B           (               1'b1 ),      //   **pull-up**     (IEEE Std. compliant)
                                                    .TDI_Z              (           jtag_tdi ),

      .TMS_PAD( JTAG_TMS_PAD ),                     .TMS_A              (               1'b0 ),
                                                    .TMS_DS             (               1'b0 ),
                                                    .TMS_OUT_EN         (               1'b0 ),
                                                    .TMS_PEN            (               1'b1 ),
                                                    .TMS_UD_B           (               1'b1 ),      //   **pull-up**     (IEEE Std. compliant)  
                                                    .TMS_Z              (           jtag_tms ),


      //
      // output CMOS pads with configuration
      //
      .STATUS_PAD( STATUS_PAD ),                    .STATUS_A           (             status ),
                                                    .STATUS_DS          (          status_ds ),
                                                    .STATUS_OUT_EN      (               1'b1 ),      // **NOTE: always enabled to **AVOID 3-STATE OUPUT**, but input signal "status" is gated using GlobalConfiguration bit
                                                    .STATUS_PEN         (               1'b0 ),
                                                    .STATUS_UD_B        (               1'b0 ),
                                                    .STATUS_Z           (                    ),

      .TDO_PAD( JTAG_TDO_PAD ),                     .TDO_A              (           jtag_tdo ),
                                                    .TDO_DS             (        jtag_tdo_ds ),
                                                    .TDO_OUT_EN         (        jtag_tdo_en ),      // from JTAG TAP state machine
                                                    .TDO_PEN            (               1'b0 ),
                                                    .TDO_UD_B           (               1'b0 ),
                                                    .TDO_Z              (                    ),



      //
      // bidirectional DIGITAL I/O pads
      //
      .EXT_POR_CAP_PAD( POR_EXT_CAP_PAD ),          .EXT_POR_CAP_O  ( ext_por_cap_noroute ),
                                                    .EXT_POR_CAP_I  (                     ),      //   **WARN: KEEP UNCONNECTED !

      .POR_OUT_B_PAD( POR_OUT_B_PAD ),              .POR_OUT_B_O    (   por_out_b_noroute ),
                                                    .POR_OUT_B_I    (             ),      //   **WARN: KEEP UNCONNECTED !
                                                    
      .PLL_RST_B_PAD( PLL_RST_B_PAD ),
                                                    .PLL_RST_B_O     ( pll_rst_b_noroute ),
                                                    .PLL_RST_B_I     (                   ),


      .PLL_VCTRL_PAD( PLL_VCTRL_PAD ),
                                                    .PLL_VCTRL_O     ( pll_vctrl_noroute ),
                                                    .PLL_VCTRL_I     (                   ),
                                                    
      .SLDO_POR_BG_PAD( POR_SLDO_BGP_PAD ),       



      //
      // SLVS RX interface
      //
      .CMD_PAD_P( CMD_P_PAD ),                      .CMD_EN_B          (                1'b0 ),      // SLVS RX enable, active-low
      .CMD_PAD_N( CMD_N_PAD ),                      .CMD_O             (     cdr_cmd_data_in_noroute ),

      .EXT_CMD_CLK_PAD_P( EXT_CMD_CLK_P_PAD ),      .EXT_CMD_CLK_EN_B  (                1'b0 ),      // SLVS RX enable, active-low
      .EXT_CMD_CLK_PAD_N( EXT_CMD_CLK_N_PAD ),      .EXT_CMD_CLK_O     ( ext_cmd_clk_noroute ),

      .EXT_SER_CLK_PAD_P( EXT_SER_CLK_P_PAD ),      .EXT_SER_CLK_EN_B  (                1'b0 ),      // SLVS RX enable, active-low
      .EXT_SER_CLK_PAD_N( EXT_SER_CLK_N_PAD ),      .EXT_SER_CLK_O     ( ext_ser_clk_noroute ),


      //
      // 4x general-purpose SLVS TX interface
      //
      .HITOR0_PAD_P( GPLVDS0_P_PAD ),               .HITOR0_I       (         gp_lvds[0] ),
      .HITOR0_PAD_N( GPLVDS0_N_PAD ),               .HITOR0_EN_B    (    gp_lvds_en_b[0] ),      // SLVS TX enable, active-low
                                                    .HITOR0_B       (    gp_lvds_ds[2:0] ),      // configurable 3-bit DS

      .HITOR1_PAD_P( GPLVDS1_P_PAD ),               .HITOR1_I       (         gp_lvds[1] ),
      .HITOR1_PAD_N( GPLVDS1_N_PAD ),               .HITOR1_EN_B    (    gp_lvds_en_b[1] ),      // SLVS TX enable, active-low
                                                    .HITOR1_B       (    gp_lvds_ds[2:0] ),      // configurable 3-bit DS

      .HITOR2_PAD_P( GPLVDS2_P_PAD ),               .HITOR2_I       (         gp_lvds[2] ),
      .HITOR2_PAD_N( GPLVDS2_N_PAD ),               .HITOR2_EN_B    (    gp_lvds_en_b[2] ),      // SLVS TX enable, active-low
                                                    .HITOR2_B       (    gp_lvds_ds[2:0] ),      // configurable 3-bit DS

      .HITOR3_PAD_P( GPLVDS3_P_PAD ),               .HITOR3_I       (         gp_lvds[3] ),
      .HITOR3_PAD_N( GPLVDS3_N_PAD ),               .HITOR3_EN_B    (    gp_lvds_en_b[3] ),      // SLVS TX enable, active-low
                                                    .HITOR3_B       (    gp_lvds_ds[2:0] ),      // configurable 3-bit DS


       //
       // backup single 1.28 Gb/s SLVS TX
       //
      .GTX0LVDS_PAD_P( GTX0LVDS_P_PAD ),            .GTX0LVDS_I     (               1'b0 ),     
      .GTX0LVDS_PAD_N( GTX0LVDS_N_PAD ),            .GTX0LVDS_EN_B  (     gtx0_lvds_en_b ),      // SLVS TX enable, active-low
                                                    .GTX0LVDS_B     (  gtx0_lvds_ds[2:0] ),      // configurable 3-bit DS


      //
      // 4x 1.2 Gb/s SER/CML TX interface
      //
      .GTX0_PAD_P( GTX0_P_PAD ),                    .SER_RST_B      (             ser_rst_b ),       // required to initialize SER internal LFSR for pseudo-random number generation 
      .GTX0_PAD_N( GTX0_N_PAD ),                    .SER_EN_LANE    (      cml_en_lane[3:0] ),
                                                    .SER_TX_CLK     (           cdr_ser_clk_noroute ),       // effective SER TX clock, either from CDR/PLL or from pad
      .GTX1_PAD_P( GTX1_P_PAD ),                    .SER_INV_TAP    (      ser_inv_tap[1:0] ),
      .GTX1_PAD_N( GTX1_N_PAD ),                    .SER_EN_TAP     (       ser_en_tap[1:0] ),
                                                    .SER_SEL_OUT0   (     ser_sel_out0[1:0] ), 
      .GTX2_PAD_P( GTX2_P_PAD ),                    .SER_SEL_OUT1   (     ser_sel_out1[1:0] ),
      .GTX2_PAD_N( GTX2_N_PAD ),                    .SER_SEL_OUT2   (     ser_sel_out2[1:0] ),
                                                    .SER_SEL_OUT3   (     ser_sel_out3[1:0] ),
      .GTX3_PAD_P( GTX3_P_PAD ),                    .SER_WORD0      (    ser_data1G_0[19:0] ),
      .GTX3_PAD_N( GTX3_N_PAD ),                    .SER_WORD1      (    ser_data1G_1[19:0] ),
                                                    .SER_WORD2      (    ser_data1G_2[19:0] ),
                                                    .SER_WORD3      (    ser_data1G_3[19:0] ),
                                                    .SER_WORD_CLK   (              data_clk ),        // divided clock for CDC FIFO/Aurora, bypassed by JTAG TCK
                                                    .CML_TAP_BIAS0  ( cml_tap_bias1_noroute ),
                                                    .CML_TAP_BIAS1  ( cml_tap_bias2_noroute ),
                                                    .CML_TAP_BIAS2  ( cml_tap_bias3_noroute ),


      //
      // single 5 Gb/s SER/GWT TX interface
      //
/*    .GWT_HS_Linkp_PAD ( GWTX_P_PAD ),             .GWT_start_up_En             (                  ),
      .GWT_HS_Linkn_PAD ( GWTX_N_PAD ),             .GWT_dllReset2Vdd            (                  ),
                                                    .GWT_dllConfirmCountSelect_0 (                  ),
                                                    .GWT_dllConfirmCountSelect_1 (                  ),
                                                    .GWT_dataIn                  ( ser_data5G[15:0] ),
                                                    .GWT_clock320MHz             (      cdr_gwt_clk ),
                                                    .GWT_reset                   (                  ),
                                                    .GWT_Threshold_for_DLL_Lock  (                  ),
                                                    .GWT_GWT_en                  (           gwt_en ),
                                                    .GWT_CP_cur_2UA              (                  ),
                                                    .GWT_CP_cur_4UA              (                  ),
                                                    .GWT_CP_cur_8UA              (                  ),    */


      //
      // bidirectional ANALOG I/O pads
      //
      .IMUX_OUT_PAD( IMUX_OUT_PAD ),                .IMUX_OUT_O      (     Imux_out_noroute ),
                                                    .IMUX_OUT_I      (                      ),      //   **WARN: KEEP UNCONNECTED !

      .IREF_IN_PAD( IREF_IN_PAD ),                  .IREF_IN_O       (      Iref_in_noroute ),
                                                    .IREF_IN_I       (                      ),      //   **WARN: KEEP UNCONNECTED !  

      .IREF_OUT_PAD( IREF_OUT_PAD ),                .IREF_OUT_O      (     Iref_out_noroute ),
                                                    .IREF_OUT_I      (                      ),      //   **WARN: KEEP UNCONNECTED !

      .IREF_TRIM0_PAD( IREF_TRIM0_PAD ),            .IREF_TRIM0_O    ( Iref_trim_noroute[0] ),      //   **WARN: KEEP UNCONNECTED !
                                                    .IREF_TRIM0_I    (                      ),

      .IREF_TRIM1_PAD( IREF_TRIM1_PAD ),            .IREF_TRIM1_O    ( Iref_trim_noroute[1] ),
                                                    .IREF_TRIM1_I    (                      ),      //   **WARN: KEEP UNCONNECTED !

      .IREF_TRIM2_PAD( IREF_TRIM2_PAD ),            .IREF_TRIM2_O    ( Iref_trim_noroute[2] ),
                                                    .IREF_TRIM2_I    (                      ),      //   **WARN: KEEP UNCONNECTED !

      .IREF_TRIM3_PAD( IREF_TRIM3_PAD ),            .IREF_TRIM3_O    ( Iref_trim_noroute[3] ),
                                                    .IREF_TRIM3_I    (                      ),      //   **WARN: KEEP UNCONNECTED !

      .VINJ_HI_PAD( VINJ_HI_PAD ),                  .VINJ_HI_O       (      Vinj_hi_noroute ),
                                                    .VINJ_HI_I       (                      ),      //   **WARN: KEEP UNCONNECTED !

      .VINJ_MID_PAD( VINJ_MID_PAD ),                .VINJ_MID_O      (     Vinj_mid_noroute ),
                                                    .VINJ_MID_I      (                      ),      //   **WARN: KEEP UNCONNECTED !

      .VMUX_OUT_PAD( VMUX_OUT_PAD ),                .VMUX_OUT_O      (     Vmux_out_noroute ),
                                                    .VMUX_OUT_I      (                      ),      //   **WARN: KEEP UNCONNECTED !

      .VREF_ADC_IN_PAD( VREF_ADC_IN_PAD ),          .VREF_ADC_IN_O   (  Vref_adc_in_noroute ),
                                                    .VREF_ADC_IN_I   (                      ),      //   **WARN: KEEP UNCONNECTED !
 
      .VREF_ADC_OUT_PAD( VREF_ADC_OUT_PAD ),        .VREF_ADC_OUT_O  ( Vref_adc_out_noroute ),
                                                    .VREF_ADC_OUT_I  (                      ),      //   **WARN: KEEP UNCONNECTED !


      //
      // Shunt-LDO section 
      //

      // ANALOG
      .SLDO_REXTA_PAD     (                  SLDO_REXT_A_PAD ),
      .SLDO_RINTA_PAD     (                  SLDO_RINT_A_PAD ),
      .SLDO_VDDSHUNTA_PAD (              SLDO_VDDSHUNT_A_PAD ),
      .SLDO_IOFFSETA_PAD  (               SLDO_VOFFSET_A_PAD ),
      .SLDO_VREFA_PAD     (                  SLDO_VREF_A_PAD ),

      .SLDO_MON_IINA      ( Vmon_sldo_analog_Isupply_noroute ),
      .SLDO_MON_ISHTA     (  Vmon_sldo_analog_Ishunt_noroute ),
      .SLDO_MON_VINA      (     Vmon_sldo_analog_Vin_noroute ),
      .SLDO_MON_VOFSA     ( Vmon_sldo_analog_Voffset_noroute ),
      .SLDO_MON_VOUTA     (    Vmon_sldo_analog_Vout_noroute ),
      .SLDO_MON_VREFA     (    Vmon_sldo_analog_Vref_noroute ),

      .SLDO_TRIMA         (            sldo_analog_trim[4:0] ),


      // DIGITAL
      .SLDO_REXTD_PAD     (                   SLDO_REXT_D_PAD ),
      .SLDO_RINTD_PAD     (                   SLDO_RINT_D_PAD ),
      .SLDO_VDDSHUNTD_PAD (               SLDO_VDDSHUNT_D_PAD ),
      .SLDO_IOFFSETD_PAD  (                SLDO_VOFFSET_D_PAD ),
      .SLDO_VREFD_PAD     (                   SLDO_VREF_D_PAD ),
      .SLDO_COMP_EN_B_PAD  (                 COMP_LDO_EN_B_PAD ),
      
      .SLDO_MON_IIND      ( Vmon_sldo_digital_Isupply_noroute ),
      .SLDO_MON_ISHTD     ( Vmon_sldo_digital_Ishunt_noroute  ),
      .SLDO_MON_VIND      (     Vmon_sldo_digital_Vin_noroute ),
      .SLDO_MON_VOFSD     ( Vmon_sldo_digital_Voffset_noroute ),
      .SLDO_MON_VOUTD     (    Vmon_sldo_digital_Vout_noroute ),
      .SLDO_MON_VREFD     (    Vmon_sldo_digital_Vref_noroute ),

      .SLDO_TRIMD         (            sldo_digital_trim[4:0] ),


      //
      // power/ground section
      //
      `ifdef USE_VAMS
      .VDDA ( VDDA ),
      .GNDA ( GNDA ),

      .VDDD ( VDDD ),
      .GNDD ( GNDD ),

      .VSUB ( VSUB ),
      

      `endif
      
      .VINA ( VINA_PAD ),
      .VIND ( VIND_PAD ),


      .VDD_PLL ( VDD_PLL_PAD ),
      .GND_PLL ( GND_PLL_PAD ),
      


      .VDD_CML ( VDD_CML_PAD ),
      .GND_CML ( GND_CML_PAD ),

      //.GWT_VDD_PAD        (        GWT_VDD_PAD ),
      //.GWT_VSS_PAD        (        GWT_VSS_PAD ),
      //.GWT_VDDHS_PAD      (      GWT_VDDHS_PAD ),
      //.GWT_GNDHS_PAD      (      GWT_GNDHS_PAD ),
      //.GWT_VDDHS_core_PAD ( GWT_VDDHS_CORE_PAD ),
      //.GWT_GNDHS_core_PAD ( GWT_GNDHS_CORE_PAD ),


       //
       // detector guard-ring ground
       //
      .DET_GRD0_PAD  ( DET_GRD0_PAD ),      .DET_GRD0_IO( det_grd_noroute[0] ),
      .DET_GRD1_PAD  ( DET_GRD1_PAD ),      .DET_GRD1_IO( det_grd_noroute[1] )

      ) ;

   //-----------------------------------   TOP PADFRAME (TEST PADS)   --------------------------------------//

   // internal connections to/from the core chip

/*
   PADFRAME_TOP   PADFRAME_TOP (
 
 
      ) ;
*/    


   //-----------------------------------------   JTAG MACRO    ---------------------------------------------//


   // internal wires for JTAG interconnections

   wire   [3:0] jtag_chip_id ;
   wire   [8:0] jtag_reg_addr ;
   wire  [15:0] jtag_reg_data ;
   wire   [2:0] jtag_edge_dly ;
   wire   [5:0] jtag_edge_width ;
   wire   [4:0] jtag_aux_dly ;
   wire         jtag_edge_mode ;
   wire         jtag_aux_mode ;
   wire   [3:0] jtag_global_pulse_width ;
   wire         jtag_wr_reg ;
   wire         jtag_rd_reg ;
   wire         jtag_ECR ;
   wire         jtag_BCR ;
   wire         jtag_gen_global_pulse ;
   wire         jtag_gen_cal ;
   wire [127:0] jtag_readback_data ;
   wire  [12:0] jtag_adc_data ;                  // **NOTE: valid bit + 12-bit conversion data
   wire         jtag_phi_az ;
   wire         jtag_tap_reset_b ;
   wire         jtag_boundary_scan_shift_en ;
   wire         jtag_shift_dr ;
   wire         jtag_update_dr ;
   wire         jtag_boundary_scan_ser_sel ;
   wire         jtag_boundary_scan_ser_mode ;
   wire         jtag_boundary_scan_ser_tdo ;
   wire         jtag_boundary_scan_dac_sel ;
   wire         jtag_boundary_scan_dac_mode ;
   wire         jtag_boundary_scan_dac_tdo ;

   wire         jtag_internal_scan_in ;
   wire         jtag_internal_scan_en ;
   wire         jtag_internal_scan_out ;
   wire         jtag_internal_scan_mode ;


   wire clk160 ;   // effective **DELAYED** 160 MHz system clock, used inside JTAG macro (also fed to general-purpose LVDS ouuputs)


   `ifndef EN_SIMPLE_TB
   JTAG_MACRO   JTAG (

      // standard JTAG I/O interface
      .JtagTrstB               (                  jtag_trst_b ),         // Test Reset (asynchronous, active low)
      .JtagTck                 (                     jtag_tck ),         // Test Clock
      .JtagTms                 (                     jtag_tms ),         // Test Mode Select
      .JtagTdi                 (                     jtag_tdi ),         // Test Data Input, sampled at posedge TCK
      .JtagTdo                 (                     jtag_tdo ),         // Test Data Output, sampled at negedge TCK
      .JtagTdoEnable           (                  jtag_tdo_en ),         // control signal for TDO tri-state CMOS output PAD
      .JtagTapResetB           (             jtag_tap_reset_b ),         // TAP reset, used only for boundary-scan registers

      // SER and DAC boundary scan chains
      .JtagBoundaryScanShiftEn (  jtag_boundary_scan_shift_en ),
      .JtagShiftDR             (                jtag_shift_dr ),
      .JtagUpdateDR            (               jtag_update_dr ),
      .JtagBoundaryScanSerSel  (   jtag_boundary_scan_ser_sel ),
      .JtagBoundaryScanSerMode (  jtag_boundary_scan_ser_mode ),
      .JtagBoundaryScanSerTdo  (   jtag_boundary_scan_ser_tdo ),
      .JtagBoundaryScanDacSel  (   jtag_boundary_scan_dac_sel ),
      .JtagBoundaryScanDacMode (  jtag_boundary_scan_dac_mode ),
      .JtagBoundaryScanDacTdo  (   jtag_boundary_scan_dac_tdo ),

      // command-decoder bypass
      .Clk160                  (                       clk160 ),
      .JtagChipID              (            jtag_chip_id[3:0] ),
      .JtagRegAddr             (           jtag_reg_addr[8:0] ),
      .JtagRegData             (          jtag_reg_data[15:0] ),
      .JtagEdgeDly             (           jtag_edge_dly[2:0] ),
      .JtagEdgeWidth           (         jtag_edge_width[5:0] ),
      .JtagAuxDly              (            jtag_aux_dly[4:0] ),
      .JtagEdgeMode            (               jtag_edge_mode ),
      .JtagAuxMode             (                jtag_aux_mode ),
      .JtagGlobalPulseWidth    ( jtag_global_pulse_width[3:0] ),
      .JtagWrReg               (                  jtag_wr_reg ),
      .JtagRdReg               (                  jtag_rd_reg ),
      .JtagECR                 (                     jtag_ECR ),
      .JtagBCR                 (                     jtag_BCR ),
      .JtagGenGlobalPulse      (        jtag_gen_global_pulse ),
      .JtagGenCal              (                 jtag_gen_cal ),

      // readback of monitoring data from ADC
      .JtagAdcData             (          jtag_adc_data[12:0] ),

      // readback of configuration data
      .JtagReadbackData        (    jtag_readback_data[127:0] ),

      // PWM signal for Torino-only autozeroing
      .JtagPhiAZ               (                  jtag_phi_az ),

      // internal scan-chain interface
      .JtagInternalScanTdi     (        jtag_internal_scan_in ),
      .JtagInternalScanEn      (        jtag_internal_scan_en ),
      .JtagInternalScanMode    (      jtag_internal_scan_mode ),
      .JtagInternalScanTdo     (       jtag_internal_scan_out )

      ) ;
    `endif
   // scan-chain interface
   wire   scan_mode ;
   assign scan_mode = jtag_internal_scan_mode & debug_en ;   // **NOTE: ensure that if DEBUG_EN = 1'b0 scan-chain is always disabled

   wire   scan_en ;
   assign scan_en = jtag_internal_scan_en & debug_en ;

   wire   scan_in ;
   assign scan_in = jtag_internal_scan_in & debug_en ;

   wire   scan_out ;
   assign jtag_internal_scan_out = ( scan_mode == 1'b1 ) ? scan_out : 1'b0 ; 




   //-----------------------------------   BOUNDARY-SCAN REGISTERS   ---------------------------------------//

   //
   // place boundary scan cells between Aurora outputs and serializers 
   //
   wire [19:0] bsr_ser_data1G_0 ;
   wire [19:0] bsr_ser_data1G_1 ;
   wire [19:0] bsr_ser_data1G_2 ;
   wire [19:0] bsr_ser_data1G_3 ;

   wire [79:0] bsr_ser_ndi ;
   assign bsr_ser_ndi = { bsr_ser_data1G_3[19:0] , bsr_ser_data1G_2[19:0] , bsr_ser_data1G_1[19:0] , bsr_ser_data1G_0[19:0] } ;


   wire [79:0] bsr_ser_ndo ;

   assign ser_data1G_0[19:0] = bsr_ser_ndo[19: 0] ;
   assign ser_data1G_1[19:0] = bsr_ser_ndo[39:20] ;
   assign ser_data1G_2[19:0] = bsr_ser_ndo[59:40] ;
   assign ser_data1G_3[19:0] = bsr_ser_ndo[79:60] ;

   JTAG_BOUNDARYSCAN_REGISTER  #( .DATA_WIDTH(4*20) )  BSR_SER_DATA1G (

      .RESET      (                    /*  jtag_trst_b & */ jtag_tap_reset_b ),
      .CLOCK_DR   (                                                 jtag_tck ),
      .SHIFT_DR   (               jtag_shift_dr & jtag_boundary_scan_ser_sel ),
      .SHIFT_EN   ( jtag_boundary_scan_shift_en & jtag_boundary_scan_ser_sel ),
      .NDI        (                                              bsr_ser_ndi ),
      .TDI        (                                                 jtag_tdi ),
      .UPDATE_DR  (              jtag_update_dr & jtag_boundary_scan_ser_sel ),
      .MODE       (                   jtag_boundary_scan_ser_mode & debug_en ),      // ensure that if JTAG is not used (DEBUG_EN = 1'b0), MODE is always 1'b0
      .NDO        (                                              bsr_ser_ndo ),
      .TDO        (                               jtag_boundary_scan_ser_tdo )

      ) ;

   //
   // place boundary scan cells for all global DACs in ACB
   //
   wire [ 9:0] dac_cp_cdr ;               wire [ 9:0] bsr_dac_cp_cdr ;              
   wire [ 9:0] dac_vcobuff_cdr ;          wire [ 9:0] bsr_dac_vcobuff_cdr ;
   wire [ 9:0] dac_vco_cdr ;              wire [ 9:0] bsr_dac_vco_cdr ;

   wire [ 9:0] dac_cml_bias_1 ;           wire [ 9:0] bsr_dac_cml_bias_1 ;
   wire [ 9:0] dac_cml_bias_2 ;           wire [ 9:0] bsr_dac_cml_bias_2 ;
   wire [ 9:0] dac_cml_bias_3 ;           wire [ 9:0] bsr_dac_cml_bias_3 ;

   wire [11:0] dac_cal_hi ;               wire [11:0] bsr_dac_cal_hi ;
   wire [11:0] dac_cal_mi ;               wire [11:0] bsr_dac_cal_mi ;

   wire [ 9:0] dac_ibiasp1_to ;           wire [ 9:0] bsr_dac_ibiasp1_to ;
   wire [ 9:0] dac_ibiasp2_to ;           wire [ 9:0] bsr_dac_ibiasp2_to ;
   wire [ 9:0] dac_ibias_sf_to ;          wire [ 9:0] bsr_dac_ibias_sf_to ;
   wire [ 9:0] dac_ibias_disc_to ;        wire [ 9:0] bsr_dac_ibias_disc_to ;
   wire [ 9:0] dac_ictrltot_to ;          wire [ 9:0] bsr_dac_ictrltot_to ;
   wire [ 9:0] dac_ifeed_to ;             wire [ 9:0] bsr_dac_ifeed_to ;
   wire [ 9:0] dac_ref_krum_to ;          wire [ 9:0] bsr_dac_ref_krum_to ;
   wire [ 9:0] dac_vbl_to ;               wire [ 9:0] bsr_dac_vbl_to ;
   wire [ 9:0] dac_vth_to ;               wire [ 9:0] bsr_dac_vth_to ;

   wire [ 9:0] dac_comp_bg ;              wire [ 9:0] bsr_dac_comp_bg ;
   wire [ 9:0] dac_fc_bias_bg ;           wire [ 9:0] bsr_dac_fc_bias_bg ;
   wire [ 9:0] dac_gdac_bg ;              wire [ 9:0] bsr_dac_gdac_bg ;
   wire [ 9:0] dac_krum_curr_bg ;         wire [ 9:0] bsr_dac_krum_curr_bg ;
   wire [ 9:0] dac_ldac_bg ;              wire [ 9:0] bsr_dac_ldac_bg ;
   wire [ 9:0] dac_pa_in_bias_bg ;        wire [ 9:0] bsr_dac_pa_in_bias_bg ;
   wire [ 9:0] dac_ref_krum_bg ;          wire [ 9:0] bsr_dac_ref_krum_bg ;

   wire [ 9:0] dac_compvbn_lbnl ;         wire [ 9:0] bsr_dac_compvbn_lbnl ;
   wire [ 9:0] dac_precompvbn_lbnl ;      wire [ 9:0] bsr_dac_precompvbn_lbnl ;
   wire [ 9:0] dac_prevbnfol_lbnl ;       wire [ 9:0] bsr_dac_prevbnfol_lbnl ;
   wire [ 9:0] dac_prevbp_lbnl ;          wire [ 9:0] bsr_dac_prevbp_lbnl ;
   wire [ 9:0] dac_vblcc_lbnl ;           wire [ 9:0] bsr_dac_vblcc_lbnl ;
   wire [ 9:0] dac_vff_lbnl ;             wire [ 9:0] bsr_dac_vff_lbnl ;
   wire [ 9:0] dac_vth1_lbnl ;            wire [ 9:0] bsr_dac_vth1_lbnl ;
   wire [ 9:0] dac_vth2_lbnl ;            wire [ 9:0] bsr_dac_vth2_lbnl ;
 

   wire [323:0] bsr_dac_ndi ;   // **NOTE: BSR assignment according to actual DACs placement into ACB macro !

   assign bsr_dac_ndi = {

      bsr_dac_vth1_lbnl[9:0],                // right-most DAC
      bsr_dac_vth2_lbnl[9:0],
      bsr_dac_precompvbn_lbnl[9:0],
      bsr_dac_compvbn_lbnl[9:0],
      bsr_dac_vblcc_lbnl[9:0],
      bsr_dac_vff_lbnl[9:0],
      bsr_dac_prevbp_lbnl[9:0],
      bsr_dac_prevbnfol_lbnl[9:0],

      bsr_dac_cml_bias_3[9:0],
      bsr_dac_cml_bias_2[9:0],
      bsr_dac_cml_bias_1[9:0],

      bsr_dac_cp_cdr[9:0],
      bsr_dac_vcobuff_cdr[9:0],
      bsr_dac_vco_cdr[9:0],

      bsr_dac_comp_bg[9:0],
      bsr_dac_ldac_bg[9:0],
      bsr_dac_ref_krum_bg[9:0],
      bsr_dac_gdac_bg[9:0],
      bsr_dac_pa_in_bias_bg[9:0],
      bsr_dac_krum_curr_bg[9:0],
      bsr_dac_fc_bias_bg[9:0],

      bsr_dac_vbl_to[9:0],
      bsr_dac_vth_to[9:0],
      bsr_dac_ictrltot_to[9:0],
      bsr_dac_ifeed_to[9:0],
      bsr_dac_ref_krum_to[9:0],
      bsr_dac_ibias_disc_to[9:0],
      bsr_dac_ibias_sf_to[9:0],
      bsr_dac_ibiasp2_to[9:0],
      bsr_dac_ibiasp1_to[9:0],

      bsr_dac_cal_mi[11:0],
      bsr_dac_cal_hi[11:0]                   // left-most DAC

   } ;


   wire [323:0] bsr_dac_ndo ;

   assign dac_vth1_lbnl[9:0]       = bsr_dac_ndo[323:314] ;
   assign dac_vth2_lbnl[9:0]       = bsr_dac_ndo[313:304] ;
   assign dac_precompvbn_lbnl[9:0] = bsr_dac_ndo[303:294] ;
   assign dac_compvbn_lbnl[9:0]    = bsr_dac_ndo[293:284] ;
   assign dac_vblcc_lbnl[9:0]      = bsr_dac_ndo[283:274] ;
   assign dac_vff_lbnl[9:0]        = bsr_dac_ndo[273:264] ;
   assign dac_prevbp_lbnl[9:0]     = bsr_dac_ndo[263:254] ;
   assign dac_prevbnfol_lbnl[9:0]  = bsr_dac_ndo[253:244] ;

   assign dac_cml_bias_3[9:0]      = bsr_dac_ndo[243:234] ;
   assign dac_cml_bias_2[9:0]      = bsr_dac_ndo[233:224] ;
   assign dac_cml_bias_1[9:0]      = bsr_dac_ndo[223:214] ;

   assign dac_cp_cdr[9:0]          = bsr_dac_ndo[213:204] ;
   assign dac_vcobuff_cdr[9:0]     = bsr_dac_ndo[203:194] ;
   assign dac_vco_cdr[9:0]         = bsr_dac_ndo[193:184] ;

   assign dac_comp_bg[9:0]         = bsr_dac_ndo[183:174] ;
   assign dac_ldac_bg[9:0]         = bsr_dac_ndo[173:164] ;
   assign dac_ref_krum_bg[9:0]     = bsr_dac_ndo[163:154] ;
   assign dac_gdac_bg[9:0]         = bsr_dac_ndo[153:144] ;
   assign dac_pa_in_bias_bg[9:0]   = bsr_dac_ndo[143:134] ;
   assign dac_krum_curr_bg[9:0]    = bsr_dac_ndo[133:124] ;
   assign dac_fc_bias_bg[9:0]      = bsr_dac_ndo[123:114] ;

   assign dac_vbl_to[9:0]          = bsr_dac_ndo[113:104] ;
   assign dac_vth_to[9:0]          = bsr_dac_ndo[103: 94] ;
   assign dac_ictrltot_to[9:0]     = bsr_dac_ndo[ 93: 84] ;
   assign dac_ifeed_to[9:0]        = bsr_dac_ndo[ 83: 74] ;
   assign dac_ref_krum_to[9:0]     = bsr_dac_ndo[ 73: 64] ;
   assign dac_ibias_disc_to[9:0]   = bsr_dac_ndo[ 63: 54] ;
   assign dac_ibias_sf_to[9:0]     = bsr_dac_ndo[ 53: 44] ;
   assign dac_ibiasp2_to[9:0]      = bsr_dac_ndo[ 43: 34] ;
   assign dac_ibiasp1_to[9:0]      = bsr_dac_ndo[ 33: 24] ;

   assign dac_cal_mi[11:0]         = bsr_dac_ndo[ 23: 12] ;       // **WARN: 12-bit DAC
   assign dac_cal_hi[11:0]         = bsr_dac_ndo[ 11:  0] ;       // **WARN: 12-bit DAC


   JTAG_BOUNDARYSCAN_REGISTER  #( .DATA_WIDTH(324) )  BSR_DAC ( 

      .RESET      (                    /*  jtag_trst_b & */ jtag_tap_reset_b ),
      .CLOCK_DR   (                                                 jtag_tck ),
      .SHIFT_DR   (               jtag_shift_dr & jtag_boundary_scan_dac_sel ),
      .SHIFT_EN   ( jtag_boundary_scan_shift_en & jtag_boundary_scan_dac_sel ),
      .NDI        (                                              bsr_dac_ndi ),
      .TDI        (                                                 jtag_tdi ),
      .UPDATE_DR  (              jtag_update_dr & jtag_boundary_scan_dac_sel ),
      .MODE       (                   jtag_boundary_scan_dac_mode & debug_en ),      // ensure that if JTAG is not used (DEBUG_EN = 1'b0), MODE is always 1'b0
      .NDO        (                                              bsr_dac_ndo ),
      .TDO        (                               jtag_boundary_scan_dac_tdo )

   ) ;



   //------------------------------------   ANALOG CHIP BOTTOM (ACB)   --------------------------------------//
//                              ###
//    ##                         ##                                  ####   ######
//    ##                         ##                                 ##  ##  ##   ##
//   ####    ## ###    ######    ##      #####    ######           ##       ##   ##
//   ## #    ###  ##  ##   ##    ##     ##   ##  ##   ##           ##       ######
//  ######   ##   ##  ##   ##    ##     ##   ##  ##   ##           ##       ##   ##
//  ##   #   ##   ##  ##  ###    ##     ##   ##  ##   ##            ##  ##  ##   ##
// ###   ##  ##   ##   ### ##   ####     #####    ######             ####   ######
//                                                    ##
//                                                #####

   // internal wires for ACB interconnections

   wire cdr_cmd_clk ;
   wire clk40 ;

   wire       cdr_en_gk2 ;
   wire [3:0] cdr_pd_del ;
   wire [1:0] cdr_pd_sel ;
   wire [2:0] cdr_vco_gain ;
   wire [2:0] cdr_sel_ser_clk ;
   wire       cdr_sel_del_clk ;

   wire [63:0] en_cal_to ;
   wire [67:0] en_cal_bg ;
   wire [67:0] en_cal_lbnl ;

   wire [4:0] mon_bg_trim ;
   wire [5:0] adc_trim ;
   wire adc_reset_b ;
   wire adc_soc ;
   wire adc_eoc_b ;
   wire [11:0] adc_data ;

   wire mon_enable ;
   wire [63:0] Vmonitor_select ;
   wire [31:0] Imonitor_select ;

   wire mon_sens_enable0 ;
   wire mon_sens_enable1 ;
   wire mon_sens_enable2 ;
   wire mon_sens_enable3 ;

   wire mon_sens_selbias0 ;
   wire mon_sens_selbias1 ;
   wire mon_sens_selbias2 ;
   wire mon_sens_selbias3 ;

   wire [3:0] mon_sens_dem0 ;
   wire [3:0] mon_sens_dem1 ;
   wire [3:0] mon_sens_dem2 ;
   wire [3:0] mon_sens_dem3 ;

   wire [63:0] AnalogBiasIf_IBIASP1_TO ;
   wire [63:0] AnalogBiasIf_IBIASP2_TO ;
   wire [63:0] AnalogBiasIf_IBIAS_DISC_TO ;
   wire [63:0] AnalogBiasIf_IBIAS_FEED_TO ;
   wire [63:0] AnalogBiasIf_IBIAS_SF_TO ;
   wire [63:0] AnalogBiasIf_ICTRL_TOT_TO ;
   wire [63:0] AnalogBiasIf_VCASN_TO ; 
   wire [63:0] AnalogBiasIf_VCASP1_TO ; 
   wire [63:0] AnalogBiasIf_VREF_KRUM_TO ;
   wire [63:0] AnalogBiasIf_VCAS_KRUM_TO ;
   wire [63:0] AnalogBiasIf_VCASN_DISC_TO ;
   wire [63:0] AnalogBiasIf_VBL_DISC_TO ; 
   wire [63:0] AnalogBiasIf_VTH_DISC_TO ;
   wire [63:0] AnalogBiasIf_CAL_HI_TO ;
   wire [63:0] AnalogBiasIf_CAL_MI_TO;

   wire [67:0] AnalogBiasIf_COMP_BIAS_BG ;
   wire [67:0] AnalogBiasIf_IFC_BIAS_BG ;
   wire [67:0] AnalogBiasIf_IHD_KRUM_BG ;
   wire [67:0] AnalogBiasIf_IHU_KRUM_BG ;
   wire [67:0] AnalogBiasIf_ILDAC_MIR1_BG ;
   wire [67:0] AnalogBiasIf_ILDAC_MIR2_BG ;
   wire [67:0] AnalogBiasIf_IPA_IN_BIAS_BG ;
   wire [67:0] AnalogBiasIf_VRIF_KRUM_BG ;
   wire [67:0] AnalogBiasIf_VTH_BG ;
   wire [67:0] AnalogBiasIf_CAL_HI_BG ;
   wire [67:0] AnalogBiasIf_CAL_MI_BG ;

   wire [67:0] AnalogBiasIf_PrmpVbnFol_LBNL ;
   wire [67:0] AnalogBiasIf_PrmpVbp_LBNL ;
   wire [67:0] AnalogBiasIf_VctrCF0_R_LBNL , AnalogBiasIf_VctrCF0_L_LBNL;
   wire [67:0] AnalogBiasIf_VctrLCC_R_LBNL , AnalogBiasIf_VctrLCC_L_LBNL; 
   wire [67:0] AnalogBiasIf_compVbn_LBNL ; 
   wire [67:0] AnalogBiasIf_preCompVbn_LBNL ; 
   wire [67:0] AnalogBiasIf_vbnLcc_LBNL ; 
   wire [67:0] AnalogBiasIf_vff_LBNL ;
   wire [67:0] AnalogBiasIf_vthin1_LBNL ;
   wire [67:0] AnalogBiasIf_vthin2_LBNL ;
   wire [67:0] AnalogBiasIf_CAL_HI_R_LBNL , AnalogBiasIf_CAL_HI_L_LBNL; 
   wire [67:0] AnalogBiasIf_CAL_MI_R_LBNL, AnalogBiasIf_CAL_MI_L_LBNL ;
   
   wire        LCC_X_DIFF;
   wire        FF_CAP_DIFF;


   wire ring_osc_reset ;
   wire ring_osc_start1_stop0 ;

   wire [7:0] ring_osc_enable ;

   wire [15:0] ring_osc_count0 ;
   wire [15:0] ring_osc_count1 ;
   wire [15:0] ring_osc_count2 ;
   wire [15:0] ring_osc_count3 ;
   wire [15:0] ring_osc_count4 ;
   wire [15:0] ring_osc_count5 ;
   wire [15:0] ring_osc_count6 ;
   wire [15:0] ring_osc_count7 ;



   RD53_ANALOG_CHIP_BOTTOM  ACB (

      // POR
      .POR_EXT_CAP              (                ext_por_cap_noroute ),
      .POR_OUT_B                (                          por_out_b_noroute ),
      .POR_DIG_B                (                          por_out_b ),
      // CDR
      .CDR_EN_GCK2              (                         cdr_en_gk2 ),
      .CDR_PD_DEL               (                    cdr_pd_del[3:0] ),
      .CDR_PD_SEL               (                    cdr_pd_sel[1:0] ),
      .CDR_VCO_GAIN             (                  cdr_vco_gain[2:0] ),
      .CDR_SEL_SER_CLK          (               cdr_sel_ser_clk[2:0] ),
      .CDR_SEL_DEL_CLK          (                    cdr_sel_del_clk ),
      .PLL_RST_B                (                  pll_rst_b_noroute ),
      .PLL_VCTRL                (                  pll_vctrl_noroute ),
      .DAC_CP_CDR               (                    dac_cp_cdr[9:0] ),
      .DAC_VCO_CDR              (                   dac_vco_cdr[9:0] ),
      .DAC_VCOBUFF_CDR          (               dac_vcobuff_cdr[9:0] ),

      .CDR_CMD_DATA_IN          (            cdr_cmd_data_in_noroute ),
      .CDR_CMD_DATA_OUT         (                   cdr_cmd_data_out ),
      .LOW_JITTER_EN            (                                    ),       // **TODO: Manchester-encoding enable

      .BYPASS_CDR               (                 bypass_cdr_noroute ),
      .EXT_CMD_CLK              (                ext_cmd_clk_noroute ),
      .EXT_SER_CLK              (                ext_ser_clk_noroute ),

      .CDR_CMD_CLK              (                        cdr_cmd_clk ),
      .CDR_SER_CLK              (                        cdr_ser_clk_noroute ),       // **NOTE: effective SER clock, either from CDR/PLL or from external SLVS pads
      .CDR_DEL_CLK              (                        cdr_del_clk ),
      .GWT_320_CLK              (                        cdr_gwt_clk ),


      // CML driver
      .DAC_CML_BIAS_1           (                dac_cml_bias_1[9:0] ),
      .DAC_CML_BIAS_2           (                dac_cml_bias_2[9:0] ),
      .DAC_CML_BIAS_3           (                dac_cml_bias_3[9:0] ),

      .CURR_CML_BIAS_1          (              cml_tap_bias1_noroute ),
      .CURR_CML_BIAS_2          (              cml_tap_bias2_noroute ),
      .CURR_CML_BIAS_3          (              cml_tap_bias3_noroute ),


      // global calibrarion DACs
      .DAC_CAL_HI               (                   dac_cal_hi[11:0] ),
      .DAC_CAL_MI               (                   dac_cal_mi[11:0] ),


      // Torino global DACs and bias lines to pixels
      .DAC_IBIASP1_TO           (                dac_ibiasp1_to[9:0] ),        
      .DAC_IBIASP2_TO           (                dac_ibiasp2_to[9:0] ),
      .DAC_IBIAS_DISC_TO        (             dac_ibias_disc_to[9:0] ),
      .DAC_IBIAS_SF_TO          (               dac_ibias_sf_to[9:0] ),
      .DAC_ICTRLTOT_TO          (               dac_ictrltot_to[9:0] ),
      .DAC_IFEED_TO             (                  dac_ifeed_to[9:0] ),
      .DAC_REF_KRUM_TO          (               dac_ref_krum_to[9:0] ),
      .DAC_VBL_TO               (                    dac_vbl_to[9:0] ),
      .DAC_VTH_TO               (                    dac_vth_to[9:0] ),

      .EN_CAL_TO                (                    en_cal_to[63:0] ),
      .CAL_HI_TO                (       AnalogBiasIf_CAL_HI_TO[63:0] ), 
      .CAL_MI_TO                (       AnalogBiasIf_CAL_MI_TO[63:0] ),

      .IBIASP1_TO               (      AnalogBiasIf_IBIASP1_TO[63:0] ), 
      .IBIASP2_TO               (      AnalogBiasIf_IBIASP2_TO[63:0] ), 
      .IBIAS_DISC_TO            (   AnalogBiasIf_IBIAS_DISC_TO[63:0] ), 
      .IBIAS_FEED_TO            (   AnalogBiasIf_IBIAS_FEED_TO[63:0] ),
      .IBIAS_SF_TO              (     AnalogBiasIf_IBIAS_SF_TO[63:0] ), 
      .ICTRL_TOT_TO             (    AnalogBiasIf_ICTRL_TOT_TO[63:0] ), 
      .VCASN_TO                 (        AnalogBiasIf_VCASN_TO[63:0] ), 
      .VCASP1_TO                (       AnalogBiasIf_VCASP1_TO[63:0] ), 
      .VREF_KRUM_TO             (    AnalogBiasIf_VREF_KRUM_TO[63:0] ), 
      .VCAS_KRUM_TO             (    AnalogBiasIf_VCAS_KRUM_TO[63:0] ), 
      .VCASN_DISC_TO            (   AnalogBiasIf_VCASN_DISC_TO[63:0] ),
      .VBL_DISC_TO              (     AnalogBiasIf_VBL_DISC_TO[63:0] ), 
      .VTH_DISC_TO              (     AnalogBiasIf_VTH_DISC_TO[63:0] ), 


      // Bergamo/Pavia global DACs and bias lines to pixels
      .DAC_COMP_BG              (                   dac_comp_bg[9:0] ),
      .DAC_FC_BIAS_BG           (                dac_fc_bias_bg[9:0] ),
      .DAC_GDAC_BG              (                   dac_gdac_bg[9:0] ),
      .DAC_KRUM_CURR_BG         (              dac_krum_curr_bg[9:0] ),
      .DAC_LDAC_BG              (                   dac_ldac_bg[9:0] ),
      .DAC_PA_IN_BIAS_BG        (             dac_pa_in_bias_bg[9:0] ),
      .DAC_REF_KRUM_BG          (               dac_ref_krum_bg[9:0] ),

      .EN_CAL_BG                (                    en_cal_bg[67:0] ),
      .CAL_HI_BG                (       AnalogBiasIf_CAL_HI_BG[67:0] ), 
      .CAL_MI_BG                (       AnalogBiasIf_CAL_MI_BG[67:0] ),

      .COMP_BIAS_BG             (    AnalogBiasIf_COMP_BIAS_BG[67:0] ), 
      .IPA_IN_BIAS_BG           (  AnalogBiasIf_IPA_IN_BIAS_BG[67:0] ), 
      .IFC_BIAS_BG              (     AnalogBiasIf_IFC_BIAS_BG[67:0] ), 
      .IHD_KRUM_BG              (     AnalogBiasIf_IHD_KRUM_BG[67:0] ), 
      .IHU_KRUM_BG              (     AnalogBiasIf_IHU_KRUM_BG[67:0] ),
      .ILDAC_MIR1_BG            (   AnalogBiasIf_ILDAC_MIR1_BG[67:0] ), 
      .ILDAC_MIR2_BG            (   AnalogBiasIf_ILDAC_MIR2_BG[67:0] ), 
      .VRIF_KRUM_BG             (    AnalogBiasIf_VRIF_KRUM_BG[67:0] ),
      .VTH_BG                   (          AnalogBiasIf_VTH_BG[67:0] ), 


      // LBNL global DACs and bias lines to pixels
      .DAC_COMPVBN_LBNL         (              dac_compvbn_lbnl[9:0] ),
      .DAC_PRECOMPVBN_LBNL      (           dac_precompvbn_lbnl[9:0] ),
      .DAC_PREVBNFOL_LBNL       (            dac_prevbnfol_lbnl[9:0] ),
      .DAC_PREVBP_LBNL          (               dac_prevbp_lbnl[9:0] ),
      .DAC_VBLCC_LBNL           (                dac_vblcc_lbnl[9:0] ),
      .DAC_VFF_LBNL             (                  dac_vff_lbnl[9:0] ),
      .DAC_VTH1_LBNL            (                 dac_vth1_lbnl[9:0] ),
      .DAC_VTH2_LBNL            (                 dac_vth2_lbnl[9:0] ),

      .EN_CAL_LBNL              (                  en_cal_lbnl[67:0] ),
      .CAL_HI_R_LBNL            (   AnalogBiasIf_CAL_HI_R_LBNL[67:0] ), 
      .CAL_HI_L_LBNL            (   AnalogBiasIf_CAL_HI_L_LBNL[67:0] ),
      .CAL_MI_R_LBNL            (   AnalogBiasIf_CAL_MI_R_LBNL[67:0] ),
      .CAL_MI_L_LBNL            (   AnalogBiasIf_CAL_MI_L_LBNL[67:0] ),

      .PRMPVBNFOL_LBNL          ( AnalogBiasIf_PrmpVbnFol_LBNL[67:0] ), 
      .PRMPVBP_LBNL             (    AnalogBiasIf_PrmpVbp_LBNL[67:0] ), 
      .VCTRCF0_R_LBNL           (  AnalogBiasIf_VctrCF0_R_LBNL[67:0] ), 
      .VCTRCF0_L_LBNL           (  AnalogBiasIf_VctrCF0_L_LBNL[67:0] ), 
      .VCTRLCC_R_LBNL           (  AnalogBiasIf_VctrLCC_R_LBNL[67:0] ), 
      .VCTRLCC_L_LBNL           (  AnalogBiasIf_VctrLCC_L_LBNL[67:0] ), 
      .COMPVBN_LBNL             (    AnalogBiasIf_compVbn_LBNL[67:0] ), 
      .PRECOMPVBN_LBNL          ( AnalogBiasIf_preCompVbn_LBNL[67:0] ), 
      .VBNLCC_LBNL              (     AnalogBiasIf_vbnLcc_LBNL[67:0] ), 
      .VFF_LBNL                 (        AnalogBiasIf_vff_LBNL[67:0] ), 
      .VTHIN1_LBNL              (     AnalogBiasIf_vthin1_LBNL[67:0] ), 
      .VTHIN2_LBNL              (     AnalogBiasIf_vthin2_LBNL[67:0] ),
      //
      .VCTRLCC_R_DIG_LBNL       (                   {68{LCC_X_DIFF}} ), 
      .VCTRLCC_L_DIG_LBNL       (                   {68{LCC_X_DIFF}} ), 
      .VCTRCF0_R_DIG_LBNL       (                  {68{FF_CAP_DIFF}} ), 
      .VCTRCF0_L_DIG_LBNL       (                  {68{FF_CAP_DIFF}} ), 
   
      // bandgap voltage reference and reference current
      .MON_BG_TRIM              (                   mon_bg_trim[4:0] ),
      .IREF_TRIM                (             Iref_trim_noroute[3:0] ),

      .IREF_IN                  (                    Iref_in_noroute ),
      .IREF_OUT                 (                   Iref_out_noroute ),

      //
      // monitoring ADC interface
      //
      .ADC_CLK40                (                              clk40 ),
      .ADC_RST_B                (                        adc_reset_b ),          // **WARN; ADC reset is active-low
      .ADC_TRIM                 (                      adc_trim[5:0] ),
      .ADC_SOC                  (                            adc_soc ),
      .ADC_EOC_B                (                          adc_eoc_b ),          // **WARN: ADC EOC flag is active-low !
      .ADC_OUT                  (                     adc_data[11:0] ),

      .VREF_ADC_IN              (                Vref_adc_in_noroute ),
      .VREF_ADC_OUT             (               Vref_adc_out_noroute ),

      // monitoring selection signals
      .MON_ENABLE               (                         mon_enable ),
      .MON_VIN_SEL              (              Vmonitor_select[39:0] ),

      // reference current
      .MON_4UA_REF              (                Imonitor_select[ 0] ),

      // Torino monitored bias
      .MON_IBIASP1_TO           (                Imonitor_select[ 1] ),
      .MON_IBIASP2_TO           (                Imonitor_select[ 2] ),
      .MON_IBIAS_DISC_TO        (                Imonitor_select[ 3] ),
      .MON_IBIAS_SF_TO          (                Imonitor_select[ 4] ),
      .MON_ICTRL_TOT_TO         (                Imonitor_select[ 5] ),
      .MON_IFEED_TO             (                Imonitor_select[ 6] ),

      // Bergamo/Pavia monitored bias
      .MON_COMP_BG              (                Imonitor_select[ 7] ),
      .MON_FC_BIAS_BG           (                Imonitor_select[ 8] ),
      .MON_KRUM_CURR_BG         (                Imonitor_select[ 9] ),
      .MON_LDAC_BG              (                Imonitor_select[10] ),
      .MON_PA_IN_BIAS_A_BG      (                Imonitor_select[11] ),

      // LNBL monitored bias
      .MON_COMPVBN_LBNL         (                Imonitor_select[12] ),
      .MON_PRECOMPVBN_LBNL      (                Imonitor_select[13] ),
      .MON_PREVBNFOL_LBNL       (                Imonitor_select[14] ),
      .MON_PREVBP_LBNL          (                Imonitor_select[15] ),
      .MON_VBLCC_LBNL           (                Imonitor_select[16] ),
      .MON_VFF_LBNL             (                Imonitor_select[17] ),
      .MON_VTH1_LBNL            (                Imonitor_select[18] ),
      .MON_VTH2_LBNL            (                Imonitor_select[19] ),

      // CDR
      .MON_CP_CDR               (                Imonitor_select[20] ),
      .MON_VCOBUFF_CDR          (                Imonitor_select[21] ),
      .MON_VCO_CDR              (                Imonitor_select[22] ),

      // CML
      .MON_CML_BIAS_1           (                Imonitor_select[23] ),
      .MON_CML_BIAS_2           (                Imonitor_select[24] ),
      .MON_CML_BIAS_3           (                Imonitor_select[25] ),

      // Shunt-LDOs
      .VMON_LDO_ANALOG_ISHUNT   (    Vmon_sldo_analog_Ishunt_noroute ),
      .VMON_LDO_ANALOG_ISUPPLY  (   Vmon_sldo_analog_Isupply_noroute ),
      .VMON_LDO_ANALOG_VIN      (       Vmon_sldo_analog_Vin_noroute ),
      .VMON_LDO_ANALOG_VOFFSET  (   Vmon_sldo_analog_Voffset_noroute ),
      .VMON_LDO_ANALOG_VOUT     (      Vmon_sldo_analog_Vout_noroute ),
      .VMON_LDO_ANALOG_VREF     (      Vmon_sldo_analog_Vref_noroute ),

      .VMON_LDO_DIGITAL_ISHUNT  (   Vmon_sldo_digital_Ishunt_noroute ),
      .VMON_LDO_DIGITAL_ISUPPLY (  Vmon_sldo_digital_Isupply_noroute ),
      .VMON_LDO_DIGITAL_VIN     (      Vmon_sldo_digital_Vin_noroute ),
      .VMON_LDO_DIGITAL_VOFFSET (  Vmon_sldo_digital_Voffset_noroute ),
      .VMON_LDO_DIGITAL_VOUT    (     Vmon_sldo_digital_Vout_noroute ),
      .VMON_LDO_DIGITAL_VREF    (     Vmon_sldo_digital_Vref_noroute ),

      // temperature sensors
      .MON_SENS_ENABLE1         (                   mon_sens_enable0 ),
      .MON_SENS_SELBIAS1        (                  mon_sens_selbias0 ),
      .MON_SENS_DEM1            (                 mon_sens_dem0[3:0] ),

      .MON_SENS_ENABLE2         (                   mon_sens_enable1 ),
      .MON_SENS_SELBIAS2        (                  mon_sens_selbias1 ),
      .MON_SENS_DEM2            (                 mon_sens_dem1[3:0] ),

      .MON_SENS_ENABLE3         (                   mon_sens_enable2 ),
      .MON_SENS_SELBIAS3        (                  mon_sens_selbias2 ),
      .MON_SENS_DEM3            (                 mon_sens_dem2[3:0] ),

      .MON_SENS_ENABLE4         (                   mon_sens_enable3 ),
      .MON_SENS_SELBIAS4        (                  mon_sens_selbias3 ),
      .MON_SENS_DEM4            (                 mon_sens_dem3[3:0] ),

      // current and voltage MUX outputs
      .IMUX_OUT                 (                   Imux_out_noroute ),
      .VMUX_OUT                 (                   Vmux_out_noroute ),


      // **BACKUP: external calibration voltages
      .VINJ_HI                  (                    Vinj_hi_noroute ),
      .VINJ_MID                 (                   Vinj_mid_noroute ),


      // ring-oscillators interface
      .RING_OSC_RESET           (                     ring_osc_reset ),
      .RING_OSC_START_STOPN     (              ring_osc_start1_stop0 ),

      .RING_OSC_EN_CKND0        (                 ring_osc_enable[0] ),
      .RING_OSC_EN_CKND4        (                 ring_osc_enable[1] ),
      .RING_OSC_EN_INVD0        (                 ring_osc_enable[2] ),
      .RING_OSC_EN_INVD4        (                 ring_osc_enable[3] ),
      .RING_OSC_EN_NAND0        (                 ring_osc_enable[4] ),
      .RING_OSC_EN_NAND4        (                 ring_osc_enable[5] ),
      .RING_OSC_EN_NORD0        (                 ring_osc_enable[6] ),
      .RING_OSC_EN_NORD4        (                 ring_osc_enable[7] ),

      .RING_OSC_COUNT_CKND0     (              ring_osc_count0[15:0] ),
      .RING_OSC_COUNT_CKND4     (              ring_osc_count1[15:0] ),
      .RING_OSC_COUNT_INVD0     (              ring_osc_count2[15:0] ),
      .RING_OSC_COUNT_INVD4     (              ring_osc_count3[15:0] ),
      .RING_OSC_COUNT_NAND0     (              ring_osc_count4[15:0] ),
      .RING_OSC_COUNT_NAND4     (              ring_osc_count5[15:0] ),
      .RING_OSC_COUNT_NORD0     (              ring_osc_count6[15:0] ),
      .RING_OSC_COUNT_NORD4     (              ring_osc_count7[15:0] ),


      // power/ground
      `ifdef USE_VAMS
      .VDDA                     (                               VDDA ),
      .GNDA                     (                               GNDA ),
      .VDDD                     (                               VDDD ),
      .GNDD                     (                               GNDD ),
      .VSUB                     (                               VSUB ),
      
      `endif

      .VDD_PLL                  (                        VDD_PLL_PAD ),
      .GND_PLL                  (                        GND_PLL_PAD ),
      
      // detector guard-ring bump
      .DET_GRD                  (               det_grd_noroute[1:0] )

      ) ;


   // check ADC_EOC_B value for ADC data sent to JTAG
   assign jtag_adc_data[12:0] = ( adc_eoc_b == 1'b0 ) ? { 1'b1 , adc_data[11:0] } : { 1'b0 , 12'hFFF } ;    // fill with all 1'b1 in case ADC not ready




   //-----------------------------------   DIGITAL CHIP BOTTOM (DCB)   -------------------------------------//
 //            ##                ##       ##               ###
 // #####      ##                ##       ##                ##                ####   ######
 // ##  ##                                ##                ##               ##  ##  ##   ##
 // ##   ##  ####      ######  ####     ######    ######    ##              ##       ##   ##
 // ##   ##    ##     ##   ##    ##       ##     ##   ##    ##              ##       ######
 // ##   ##    ##     ##   ##    ##       ##     ##   ##    ##              ##       ##   ##
 // ##  ##     ##     ##   ##    ##       ##     ##  ###    ##               ##  ##  ##   ##
 // #####    ######    ######  ######      ###    ### ##   ####               ####   ######
 //                        ##
 //                    #####

   // internal wires for DCB interconnections
   wire pix_reset ;
   wire pix_trigger ;

   wire [8:0] latency_config ;
   wire [1:0] wait_read_config;
   
   wire [`COLS-1:0] ready_col ;

   wire cal_edge ;
   wire cal_aux ;
   wire analog_injection_mode ;
   wire digital_injection_enable ;
   wire [3:0][`COLS-1:0] hit_or_mask;

   wire default_pixel_conf ;
   wire [`COLS-1:0] en_core_col ;
   wire [2:0] en_core_col_broadcast ;
   wire [11:0] address_conf_core ;
   wire [5:0] address_conf_col ;
   wire [7:0] data_conf_wr ;
   wire [7:0] data_conf_rd ;
   wire conf_wr ;

   wire [`COLS-1:0][15:0] data_col ;
   wire [`COLS-1:0][ 9:0] row_col ;
   wire [`COLS-1:0] data_ready_col ;
   wire [`COLS-1:0][4:0] trig_id_req_col_bin ;
   wire [5:0] trigger_id_cnt ;
   wire [5:0] trigger_id_current_req ;
   wire trigger_accept;

   wire [15:0] SkippedTriggerCnt;
   wire        SkippedTriggerCntErr;
   wire        WrSkippedTriggerCntRst;

   wire [2:0] gp_lvds_route ;
   // wire [3:0] enable_self_trigger;
   wire [3:0] pix_hit_or ;

   wire [5:0] write_synch_time_to ;
   wire cmd_phi_az ;
   wire free_running_az ;   // from global configuration
   wire sel_c2f_to ;
   wire sel_c4f_to ;
   wire fast_en_to ;

   wire cmd_data ;  //to general-purpose LVDS outputs

   wire backup_ser_output_0 ;
   wire backup_ser_output_1 ;
   wire backup_ser_output_2 ;
   wire backup_ser_output_3 ;

   wire enable_ext_cal ;

   DigitalChipBottom   DCB (

      // startup reset
      .PorResetB                (                           por_out_b ),        // **NOTE: active-LOW !

      // from CDR
      .CdrCmdData               (                    cdr_cmd_data_out ),
      .CdrCmdClk                (                         cdr_cmd_clk ),
      .CdrDelClk                (                         cdr_del_clk ),

      // local chip address
      .ChipID                   (                        chip_id[2:0] ),

      // **BACKUP
      .BypCmd                   (                          bypass_cmd ),
      .DebugEn                  (                            debug_en ),
      .ExtTrigger               (                         ext_trigger ),

      //
      // to/from serializers
      //
      .SerRstB                  (                           ser_rst_b ),        // Syncronous reset for the serializers
      .DataClk                  (                            data_clk ),

      .SerData1G_0              (              bsr_ser_data1G_0[19:0] ),        // Boundary-Scan Cells added to 1.28 Gb/s Aurora outputs
      .SerData1G_1              (              bsr_ser_data1G_1[19:0] ),
      .SerData1G_2              (              bsr_ser_data1G_2[19:0] ),
      .SerData1G_3              (              bsr_ser_data1G_3[19:0] ),

      .BackupSerOutput_0        (                 backup_ser_output_0 ),
      .BackupSerOutput_1        (                 backup_ser_output_1 ),
      .BackupSerOutput_2        (                 backup_ser_output_2 ),
      .BackupSerOutput_3        (                 backup_ser_output_3 ),

      //
      // to general-purpose LVDS outputs
      //
      .Clk160                   (                              clk160 ),        // **NOTE: effective **DELAYED** 160 MHz system clock, also sent to GP-LVDS
      .CmdData                  (                            cmd_data ),        // **NOTE: effective **DELAYED** command stream, also sent to GP-LVDS

      //
      // JTAG
      //
      .JtagTck                  (                            jtag_tck ),
      .JtagChipID               (                   jtag_chip_id[3:0] ),
      .JtagRegAddr              (                  jtag_reg_addr[8:0] ),
      .JtagRegData              (                 jtag_reg_data[15:0] ),
      .JtagEdgeDly              (                  jtag_edge_dly[2:0] ),
      .JtagEdgeWidth            (                jtag_edge_width[5:0] ),
      .JtagAuxDly               (                   jtag_aux_dly[4:0] ),
      .JtagEdgeMode             (                      jtag_edge_mode ),
      .JtagAuxMode              (                       jtag_aux_mode ),
      .JtagGlobalPulseWidth     (        jtag_global_pulse_width[3:0] ),
      .JtagWrReg                (                         jtag_wr_reg ),
      .JtagRdReg                (                         jtag_rd_reg ),
      .JtagECR                  (                            jtag_ECR ),
      .JtagBCR                  (                            jtag_BCR ),
      .JtagGenGlobalPulse       (               jtag_gen_global_pulse ),
      .JtagGenCal               (                        jtag_gen_cal ),
      .JtagReadbackData         (           jtag_readback_data[127:0] ),

      //
      // to pixel array
      //
      // clock, trigger and reset
      .Clk40                    (                               clk40 ),    // **NOTE: also fed to ADC !
      .PixReset                 (                           pix_reset ),
      .PixTrigger               (                         pix_trigger ),
      .LATENCY_CONFIG           (                 latency_config[8:0] ),
      .ReadyCol                 (                ready_col[`COLS-1:0] ),
      .WaitReadCnfg             (                    wait_read_config ),
      .HITOR_MASK               (                         hit_or_mask ),    // **NOTE:  [3:0][`COLS-1:0] //**TODO: verify connectivity when implemented in GlobalConfiguration
      .WrSkippedTriggerCntRst   (              WrSkippedTriggerCntRst ), 
      // .EnSelfTrigger            (            enable_self_trigger[3:0] ),    // Self Trigger Enable [to Pixel Region]

      //
      // from pixel array
      .SkippedTriggerCnt        (             SkippedTriggerCnt[15:0] ),
      .SkippedTriggerCntErr     (                SkippedTriggerCntErr ), 

      // charge injection
      .CalEdge                  (                            cal_edge ),
      .CalAux                   (                             cal_aux ),
      .AnalogInjectionMode      (               analog_injection_mode ),
      .DigitalInjectionEnable   (            digital_injection_enable ),             

      // configuration
      .DefaultPixelConf         (                  default_pixel_conf ),
      .EnCoreColBroadcast       (          en_core_col_broadcast[2:0] ),
      .AddressConfCore          (             address_conf_core[11:0] ),
      .AddressConfCol           (               address_conf_col[5:0] ),
      .DataConfWr               (                   data_conf_wr[7:0] ),
      .ConfWr                   (                             conf_wr ),

       // Torino-only control signals/config
      .WR_SYNC_DELAY_SYNC       (            write_synch_time_to[4:0] ), 
      .CmdPhiAZ                 (                          cmd_phi_az ),
      .FreeRunningAutoZero_SYNC (                     free_running_az ),
      .SelC2F_SYNC              (                          sel_c2f_to ),
      .SelC4F_SYNC              (                          sel_c4f_to ),
      .FastEn_SYNC              (                          fast_en_to ),

      //
      // from pixel array
      //
      // congiguration read-back data
      .DataConfRd               (                   data_conf_rd[7:0] ),

      // pixel data and flags
      .DataCol                  (                            data_col ),
      .RowCol                   (                             row_col ),
      .DataReadyCol             (           data_ready_col[`COLS-1:0] ),
      .TrigIdReqColBin          (                 trig_id_req_col_bin ),
      .TriggerIdCnt             (                 trigger_id_cnt[5:0] ),
      .TriggerIdCurrentReq      (         trigger_id_current_req[5:0] ),
      .TriggerAccept            (                      trigger_accept ),
      .PixHitOr                 (                     pix_hit_or[3:0] ),   // also to counters in GlobalConfiguration

      //
      // Global Configuration Registers (GCRs)
      //
      // CDR DACs/config
      .CDR_CP_IBIAS             (                 bsr_dac_cp_cdr[9:0] ), 
      .CDR_VCO_BUFF_BIAS        (            bsr_dac_vcobuff_cdr[9:0] ),
      .CDR_VCO_IBIAS            (                bsr_dac_vco_cdr[9:0] ),
         
      .CDR_PD_SEL               (                     cdr_pd_sel[1:0] ),
      .CDR_PD_DEL               (                     cdr_pd_del[3:0] ),
      .CDR_EN_GCK2              (                          cdr_en_gk2 ),
      .CDR_VCO_GAIN             (                   cdr_vco_gain[2:0] ),
      .CDR_SEL_SER_CLK          (                cdr_sel_ser_clk[2:0] ),
      .CDR_SEL_DEL_CLK          (                     cdr_sel_del_clk ),
        
      // SERs config
      .SER_INV_TAP              (                    ser_inv_tap[1:0] ),
      .SER_EN_TAP               (                     ser_en_tap[1:0] ),

      .SER_SEL_OUT_0            (                   ser_sel_out0[1:0] ),
      .SER_SEL_OUT_1            (                   ser_sel_out1[1:0] ),
      .SER_SEL_OUT_2            (                   ser_sel_out2[1:0] ),
      .SER_SEL_OUT_3            (                   ser_sel_out3[1:0] ),

      // CML DACs/config
      .CML_EN_LANE              (                    cml_en_lane[3:0] ),
      .CML_TAP0_BIAS            (             bsr_dac_cml_bias_1[9:0] ),
      .CML_TAP1_BIAS            (             bsr_dac_cml_bias_2[9:0] ),
      .CML_TAP2_BIAS            (             bsr_dac_cml_bias_3[9:0] ),


      // status and CMOS output pads configutration
      .JtagTdoDs                (                         jtag_tdo_ds ),
      .StatusDs                 (                           status_ds ),
      .Status                   (                              status ),   // connected to channel synch. "locked" output if StatusEn = 1'b1
      .EnableExtCal             (                      enable_ext_cal ),


      // SLVS TX config
      .LANE0_LVDS_EN_B          (                      gtx0_lvds_en_b ),
      .LANE0_LVDS_BIAS          (                   gtx0_lvds_ds[2:0] ),

      .GP_LVDS_ROUTE            (                  gp_lvds_route[2:0] ),
      .GP_LVDS_EN_B             (                   gp_lvds_en_b[3:0] ),
      .GP_LVDS_BIAS             (                     gp_lvds_ds[2:0] ),


      // global calibration DACs
      .VCAL_HIGH                (                bsr_dac_cal_hi[11:0] ),
      .VCAL_MED                 (                bsr_dac_cal_mi[11:0] ),

      .EN_MACRO_COL_CAL_SYNC    (                     en_cal_to[63:0] ),
      .EN_MACRO_COL_CAL_LIN     (                     en_cal_bg[67:0] ),
      .EN_MACRO_COL_CAL_DIFF    (                   en_cal_lbnl[67:0] ),


      // Torino global DACs 
      .IBIASP1_SYNC             (             bsr_dac_ibiasp1_to[9:0] ),
      .IBIASP2_SYNC             (             bsr_dac_ibiasp2_to[9:0] ),
      .IBIAS_SF_SYNC            (            bsr_dac_ibias_sf_to[9:0] ),
      .IBIAS_KRUM_SYNC          (               bsr_dac_ifeed_to[9:0] ),
      .IBIAS_DISC_SYNC          (          bsr_dac_ibias_disc_to[9:0] ),
      .ICTRL_SYNCT_SYNC         (            bsr_dac_ictrltot_to[9:0] ),
      .VBL_SYNC                 (                 bsr_dac_vbl_to[9:0] ),
      .VTH_SYNC                 (                 bsr_dac_vth_to[9:0] ),
      .VREF_KRUM_SYNC           (            bsr_dac_ref_krum_to[9:0] ),

      // BG/PV global DACs
      .PA_IN_BIAS_LIN           (          bsr_dac_pa_in_bias_bg[9:0] ),
      .FC_BIAS_LIN              (             bsr_dac_fc_bias_bg[9:0] ),
      .KRUM_CURR_LIN            (           bsr_dac_krum_curr_bg[9:0] ),
      .LDAC_LIN                 (                bsr_dac_ldac_bg[9:0] ),
      .COMP_LIN                 (                bsr_dac_comp_bg[9:0] ),
      .REF_KRUM_LIN             (            bsr_dac_ref_krum_bg[9:0] ),
      .Vthreshold_LIN           (                bsr_dac_gdac_bg[9:0] ),

      // LBNL global DACs
      .PRMP_DIFF                (            bsr_dac_prevbp_lbnl[9:0] ),
      .FOL_DIFF                 (         bsr_dac_prevbnfol_lbnl[9:0] ),
      .PRECOMP_DIFF             (        bsr_dac_precompvbn_lbnl[9:0] ),
      .COMP_DIFF                (           bsr_dac_compvbn_lbnl[9:0] ),
      .VFF_DIFF                 (               bsr_dac_vff_lbnl[9:0] ),
      .VTH1_DIFF                (              bsr_dac_vth1_lbnl[9:0] ),
      .VTH2_DIFF                (              bsr_dac_vth2_lbnl[9:0] ),
      .LCC_DIFF                 (             bsr_dac_vblcc_lbnl[9:0] ),
      .LCC_X_DIFF               (                          LCC_X_DIFF ),
      .FF_CAP_DIFF              (                         FF_CAP_DIFF ),

      //
      // enable clock and trigger to pixel cores
      //
      .EN_CORE_COL_SYNC         (                  en_core_col[15 :0] ),
      .EN_CORE_COL_LIN          (                  en_core_col[32:16] ),
      .EN_CORE_COL_DIFF         (                  en_core_col[49:33] ),

      //
      // power section
      //
      .SLDOAnalogTrim           (               sldo_analog_trim[4:0] ),
      .SLDODigitalTrim          (              sldo_digital_trim[4:0] ),

      //
      // monitoring ADC
      //
      .MON_BG_TRIM              (                    mon_bg_trim[4:0] ),
      .MON_ADC_TRIM             (                       adc_trim[5:0] ),
      .MonitoringDataADC        (                      adc_data[11:0] ),
      .ADC_RST_B                (                         adc_reset_b ),
      .ADC_SOC                  (                             adc_soc ),
      .ADC_EOC_B                (                           adc_eoc_b ),

      //
      // monitoring analog MUXs
      //
      .MonitorEnable            (                          mon_enable ),
      .V_MONITOR_SELECT         (               Vmonitor_select[63:0] ),
      .I_MONITOR_SELECT         (               Imonitor_select[31:0] ),          

      .SENS_ENABLE0             (                    mon_sens_enable0 ),
      .SEN_SEL_BIAS0            (                   mon_sens_selbias0 ),
      .SENS_DEM0                (                  mon_sens_dem0[3:0] ),

      .SENS_ENABLE1             (                    mon_sens_enable1 ),
      .SEN_SEL_BIAS1            (                   mon_sens_selbias1 ),
      .SENS_DEM1                (                  mon_sens_dem1[3:0] ),

      .SENS_ENABLE2             (                    mon_sens_enable2 ),
      .SEN_SEL_BIAS2            (                   mon_sens_selbias2 ),
      .SENS_DEM2                (                  mon_sens_dem2[3:0] ),

      .SENS_ENABLE3             (                    mon_sens_enable3 ),
      .SEN_SEL_BIAS3            (                   mon_sens_selbias3 ),
      .SENS_DEM3                (                  mon_sens_dem3[3:0] ),


      //
      // Ring oscillators control signals
      //
      .WrRingOscCntRst          (                      ring_osc_reset ),
      .RingOscStart             (               ring_osc_start1_stop0 ),
      .RING_OSC_ENABLE          (                ring_osc_enable[7:0] ),
      .RING_OSC_0               (               ring_osc_count0[15:0] ),          
      .RING_OSC_1               (               ring_osc_count1[15:0] ),          
      .RING_OSC_2               (               ring_osc_count2[15:0] ),          
      .RING_OSC_3               (               ring_osc_count3[15:0] ),          
      .RING_OSC_4               (               ring_osc_count4[15:0] ),          
      .RING_OSC_5               (               ring_osc_count5[15:0] ),          
      .RING_OSC_6               (               ring_osc_count6[15:0] ),          
      .RING_OSC_7               (               ring_osc_count7[15:0] ),          


      //
      // access to internal scan-chain
      //
      .ScanMode                 (                           scan_mode ),
      .ScanIn                   (                             scan_in ),
      .ScanEn                   (                             scan_en ),
      .ScanOut                  (                            scan_out )

      ) ;

 //            ##                        ###
 // ######     ##                         ##                ##
 // ##   ##                               ##                ##
 // ##   ##  ####     ##  ##    #####     ##               ####    ## ###   ## ###    ######  ##  ##
 // ######     ##      ####    ##   ##    ##               ## #    ###      ###      ##   ##  ##  ##
 // ##         ##       ##     #######    ##              ######   ##       ##       ##   ##  ##  ##
 // ##         ##      ####    ##         ##              ##   #   ##       ##       ##  ###  ##  ##
 // ##       ######   ##  ##    #####    ####            ###   ##  ##       ##        ### ##   #####
 //                                                                                               ##
 //                                                                                            ####
   //-----------------------------------------   PIXEL ARRAY   ---------------------------------------------//


   wire [`COLS-1:0][`ROWS-1:0][`REGIONS-1:0][`REG_PIXELS-1:0] analog_hit ;
   assign analog_hit = ANA_HIT ;



   // **BACKUP: MUX for autozeroing signal
   wire   phi_az_to ;
   assign phi_az_to = ( /*bypass_cmd == 1'b1 || */ free_running_az == 1'b1 ) ? jtag_phi_az : cmd_phi_az ;


   // **BACKUP: MUX for CalEdge/CalAux using external injection strobes

   wire pix_cal_edge ;
   wire pix_cal_aux ;

   assign pix_cal_edge = ( (debug_en == 1'b1) && (enable_ext_cal == 1'b1) ) ? inj_strb[0] : cal_edge ; 
   assign pix_cal_aux  = ( (debug_en == 1'b1) && (enable_ext_cal == 1'b1) ) ? inj_strb[1] : cal_aux ;

   `ifndef EN_SIMPLE_TB
   PixelArray   PixelArray (

      `ifdef USE_VAMS

      .VDDA                          (                                VDDA ),
      .GNDA                          (                                GNDA ),
      .VDDD                          (                                VDDD ),
      .GNDD                          (                                GNDD ),
      .VSUB                          (                                VSUB ),

      `endif

      // pixel inputs
      .AnaHit                        (                          analog_hit ),

      // clock, trigger and reset
      .Clk40                         (                               clk40 ),
      .Reset                         (                           pix_reset ),
      .Trigger                       (                         pix_trigger ),
      .LatencyCnfg                   (                 latency_config[8:0] ),
      .WaitReadCnfg                  (                    wait_read_config ),
      
      // charge injection
      .CalEdge                       (                        pix_cal_edge ),
      .CalAux                        (                         pix_cal_aux ),
      .EnDigHit                      (            digital_injection_enable ),
      .AnaInjectionMode              (               analog_injection_mode ),

      // configuration
      .DefaultPixelConf              (                  default_pixel_conf ),
      .EnCoreCol                     (              en_core_col[`COLS-1:0] ),
      .EnCoreColBroadcast            (          en_core_col_broadcast[2:0] ),
      .EnCal_TO                      (                     en_cal_to[63:0] ),
      .EnCal_BG                      (                     en_cal_bg[67:0] ),
      .EnCal_LBNL                    (                   en_cal_lbnl[67:0] ),
      // .EnSelfTrigger                 (            enable_self_trigger[3:0] ),     // Self Trigger Enable [from Global Configuration]
      .AddressConfCore               (             address_conf_core[11:0] ),
      .AddressConfCol                (               address_conf_col[5:0] ),
      .DataConfWr                    (                   data_conf_wr[7:0] ),
      .DataConfRd                    (                   data_conf_rd[7:0] ),
      .ConfWr                        (                             conf_wr ),

      // 4x cluster-vased HitOR
      .HitOr                         (                     pix_hit_or[3:0] ),
      .HitOrMask                     (                         hit_or_mask ),     // **NOTE:  [3:0][`COLS-1:0] //**TODO: verify connectivity when implemented in GlobalConfiguration
      
      // triggered-data readout
      .DataCol                       (                            data_col ),     // **NOTE: [`COLS-1:0] [15:0] data_col
      .RowCol                        (                             row_col ),     // **NOTE: [`COLS-1:0] [9:0] row_col
      .ReadyCol                      (                ready_col[`COLS-1:0] ),
      .DataReadyCol                  (          data_ready_col [`COLS-1:0] ),
      .TrigIdReqColBin               (                 trig_id_req_col_bin ),
      .TriggerIdCnt                  (                 trigger_id_cnt[5:0] ),
      .TriggerIdCurrentReq           (         trigger_id_current_req[5:0] ),
      .TriggerAccept                 (                      trigger_accept ),
      // to/from DCB
      .SkippedTriggerCnt             (             SkippedTriggerCnt[15:0] ),
      .SkippedTriggerCntErr          (                SkippedTriggerCntErr ), 
      .WrSkippedTriggerCntRst        (              WrSkippedTriggerCntRst ), 
      
      // Torino-only control signals
      .WriteSyncTimeTo               (            write_synch_time_to[4:0] ),
      .PHI_AZ_TO                     (                           phi_az_to ),
      .SELC2F_TO                     (                          sel_c2f_to ),
      .SELC4F_TO                     (                          sel_c4f_to ),
      .FastEnTo                      (                          fast_en_to ),

       // Torino bias lines to pixels
      .AnalogBiasIf_IBIASP1_TO       (       AnalogBiasIf_IBIASP1_TO[63:0] ),
      .AnalogBiasIf_IBIASP2_TO       (       AnalogBiasIf_IBIASP2_TO[63:0] ),
      .AnalogBiasIf_IBIAS_DISC_TO    (    AnalogBiasIf_IBIAS_DISC_TO[63:0] ),
      .AnalogBiasIf_IBIAS_FEED_TO    (    AnalogBiasIf_IBIAS_FEED_TO[63:0] ),
      .AnalogBiasIf_IBIAS_SF_TO      (      AnalogBiasIf_IBIAS_SF_TO[63:0] ),
      .AnalogBiasIf_ICTRL_TOT_TO     (     AnalogBiasIf_ICTRL_TOT_TO[63:0] ),
      .AnalogBiasIf_VCASN_TO         (         AnalogBiasIf_VCASN_TO[63:0] ), 
      .AnalogBiasIf_VCASP1_TO        (        AnalogBiasIf_VCASP1_TO[63:0] ),
      .AnalogBiasIf_VREF_KRUM_TO     (     AnalogBiasIf_VREF_KRUM_TO[63:0] ),
      .AnalogBiasIf_VCAS_KRUM_TO     (     AnalogBiasIf_VCAS_KRUM_TO[63:0] ),
      .AnalogBiasIf_VCASN_DISC_TO    (    AnalogBiasIf_VCASN_DISC_TO[63:0] ),
      .AnalogBiasIf_VBL_DISC_TO      (      AnalogBiasIf_VBL_DISC_TO[63:0] ),
      .AnalogBiasIf_VTH_DISC_TO      (      AnalogBiasIf_VTH_DISC_TO[63:0] ),
      .AnalogBiasIf_CAL_HI_TO        (        AnalogBiasIf_CAL_HI_TO[63:0] ),
      .AnalogBiasIf_CAL_MI_TO        (        AnalogBiasIf_CAL_MI_TO[63:0] ),
 
      // Bergamo/Pavia bias lines to pixels
      .AnalogBiasIf_COMP_BIAS_BG     (     AnalogBiasIf_COMP_BIAS_BG[67:0] ),
      .AnalogBiasIf_IFC_BIAS_BG      (      AnalogBiasIf_IFC_BIAS_BG[67:0] ),
      .AnalogBiasIf_IHD_KRUM_BG      (      AnalogBiasIf_IHD_KRUM_BG[67:0] ),
      .AnalogBiasIf_IHU_KRUM_BG      (      AnalogBiasIf_IHU_KRUM_BG[67:0] ),
      .AnalogBiasIf_ILDAC_MIR1_BG    (    AnalogBiasIf_ILDAC_MIR1_BG[67:0] ),
      .AnalogBiasIf_ILDAC_MIR2_BG    (    AnalogBiasIf_ILDAC_MIR2_BG[67:0] ),
      .AnalogBiasIf_IPA_IN_BIAS_BG   (   AnalogBiasIf_IPA_IN_BIAS_BG[67:0] ),
      .AnalogBiasIf_VRIF_KRUM_BG     (     AnalogBiasIf_VRIF_KRUM_BG[67:0] ),
      .AnalogBiasIf_VTH_BG           (           AnalogBiasIf_VTH_BG[67:0] ),
      .AnalogBiasIf_CAL_HI_BG        (        AnalogBiasIf_CAL_HI_BG[67:0] ),
      .AnalogBiasIf_CAL_MI_BG        (        AnalogBiasIf_CAL_MI_BG[67:0] ),
      // Torino pins to top padframe
      .TopPadframe_VOUT_PREAMP_TO    (           TopPadframe_VOUT_PREAMP_TO), // [16:0][7:0] /* TODO: To be connected to PADFRAME_TOP */ 
      // Bergamo/Pavia pins to top padframe
      .TopPadframe_PA_OUT_BG         (           TopPadframe_PA_OUT_BG), // [16:0][7:0] /* TODO: To be connected to PADFRAME_TOP */ 
      // LBNL pins to top padframe
      .TopPadframe_out1         (           TopPadframe_OUT1_LBNL), // [16:0][7:0] /* TODO: To be connected to PADFRAME_TOP */
      .TopPadframe_out2         (           TopPadframe_OUT2_LBNL), // [16:0][7:0] /* TODO: To be connected to PADFRAME_TOP */ 
      .TopPadframe_out2b         (           TopPadframe_OUT2B_LBNL), // [16:0][7:0] /* TODO: To be connected to PADFRAME_TOP */ 
      // LBNL bias lines to pixels
      .AnalogBiasIf_PrmpVbnFol_LBNL  (  AnalogBiasIf_PrmpVbnFol_LBNL[67:0] ),
      .AnalogBiasIf_PrmpVbp_LBNL     (     AnalogBiasIf_PrmpVbp_LBNL[67:0] ),
      .AnalogBiasIf_VctrCF0_R_LBNL     (     AnalogBiasIf_VctrCF0_R_LBNL[67:0] ), 
      .AnalogBiasIf_VctrCF0_L_LBNL     (     AnalogBiasIf_VctrCF0_L_LBNL[67:0] ), 
      .AnalogBiasIf_VctrLCC_R_LBNL     (     AnalogBiasIf_VctrLCC_R_LBNL[67:0] ),
      .AnalogBiasIf_VctrLCC_L_LBNL     (     AnalogBiasIf_VctrLCC_L_LBNL[67:0] ),
      .AnalogBiasIf_compVbn_LBNL     (     AnalogBiasIf_compVbn_LBNL[67:0] ),
      .AnalogBiasIf_preCompVbn_LBNL  (  AnalogBiasIf_preCompVbn_LBNL[67:0] ), 
      .AnalogBiasIf_vbnLcc_LBNL      (      AnalogBiasIf_vbnLcc_LBNL[67:0] ),
      .AnalogBiasIf_vff_LBNL         (         AnalogBiasIf_vff_LBNL[67:0] ),
      .AnalogBiasIf_vthin1_LBNL      (      AnalogBiasIf_vthin1_LBNL[67:0] ),
      .AnalogBiasIf_vthin2_LBNL      (      AnalogBiasIf_vthin2_LBNL[67:0] ),
      .AnalogBiasIf_CAL_HI_R_LBNL      (      AnalogBiasIf_CAL_HI_R_LBNL[67:0] ),
      .AnalogBiasIf_CAL_HI_L_LBNL      (      AnalogBiasIf_CAL_HI_L_LBNL[67:0] ),
      .AnalogBiasIf_CAL_MI_R_LBNL      (      AnalogBiasIf_CAL_MI_R_LBNL[67:0] ),
      .AnalogBiasIf_CAL_MI_L_LBNL      (      AnalogBiasIf_CAL_MI_L_LBNL[67:0] )
      ) ;

    `endif


   //-------------------------   ROUTING TO 4x GENERAL-PURPOSE LVDS OUTPUTS   ------------------------------//

   always_comb begin

      case( gp_lvds_route[2:0] )

         3'b000 : begin
                     gp_lvds[0] = pix_hit_or[0] ;
                     gp_lvds[1] = pix_hit_or[1] ;
                     gp_lvds[2] = pix_hit_or[2] ;
                     gp_lvds[3] = pix_hit_or[3] ;
                  end

         3'b001 : begin
                     gp_lvds[0] = cmd_data ;
                     gp_lvds[1] = clk160 ;
                     gp_lvds[2] = clk40 ;
                     gp_lvds[3] = pix_reset ;
                  end

         3'b010 : begin
                     gp_lvds[0] = pix_cal_edge ;
                     gp_lvds[1] = pix_cal_aux ;
                     gp_lvds[2] = pix_trigger ;
                     gp_lvds[3] = pix_hit_or[3] ;
                  end

         3'b011 : begin
                     gp_lvds[0] = data_clk ;          // divided clock for Aurora
                     gp_lvds[1] = cdr_del_clk ;       // 640 MHz fine-delay clock
                     gp_lvds[2] = cdr_cmd_clk ;       // 160 MHz clock from CDR
                     gp_lvds[3] = clk160 ;            // effective 160 MHz clock after fine-delay
                  end

         3'b100 : begin
                     gp_lvds[0] = pix_cal_edge ;
                     gp_lvds[1] = pix_cal_aux ;
                     gp_lvds[2] = pix_trigger ;
                     gp_lvds[3] = clk40 ;
                  end

         3'b101 : begin
                     gp_lvds[0] = clk40 ;
                     gp_lvds[1] = phi_az_to ;
                     gp_lvds[2] = pix_trigger ;
                     gp_lvds[3] = pix_cal_edge ;
                  end  

         3'b110 : begin
                     gp_lvds[0] = backup_ser_output_0 ;
                     gp_lvds[1] = backup_ser_output_1 ;
                     gp_lvds[2] = backup_ser_output_2 ;
                     gp_lvds[3] = backup_ser_output_3 ;
                  end

         3'b111 : begin
                     gp_lvds[0] = 1'b1 ;      // fill with 4'b0001 when all-ones for easier debug
                     gp_lvds[1] = 1'b0 ;
                     gp_lvds[2] = 1'b0 ;
                     gp_lvds[3] = 1'b0 ;
                  end

         default : begin
                     gp_lvds[0] = pix_hit_or[0] ;
                     gp_lvds[1] = pix_hit_or[1] ;
                     gp_lvds[2] = pix_hit_or[2] ;
                     gp_lvds[3] = pix_hit_or[3] ;
                  end
      endcase
   end   // always_comb

   
   
   RD53_TOP_BLOCKS TOP_BLOCKS (
            .BGPV_OE12(BGPV_OE12_PAD),
            .BGPV_OE34(BGPV_OE34_PAD),
            .BGPV_OE56(BGPV_OE56_PAD),
            .BGPV_PA1(TopPadframe_PA_OUT_BG[4]),
            .BGPV_PA2(TopPadframe_PA_OUT_BG[5]),
            .BGPV_PA3(TopPadframe_PA_OUT_BG[76]),
            .BGPV_PA4(TopPadframe_PA_OUT_BG[77]),
            .BGPV_PA5(TopPadframe_PA_OUT_BG[132]),
            .BGPV_PA6(TopPadframe_PA_OUT_BG[133]),
            .BGPV_SF_IN(BGPV_SF_IN_PAD),
            .BGPV_SF_OUT(BGPV_SF_OUT_PAD),
            .BGPV_SF_OUT1(BGPV_SF_OUT1_PAD),
            .BGPV_SF_OUT2(BGPV_SF_OUT2_PAD),
            .BGPV_SF_OUT3(BGPV_SF_OUT3_PAD),
            .BGPV_SF_OUT4(BGPV_SF_OUT4_PAD),
            .BGPV_SF_OUT5(BGPV_SF_OUT5_PAD),
            .BGPV_SF_OUT6(BGPV_SF_OUT6_PAD),
            .CLKN_DX(CLKN_DX_PAD),
            .CLKN_SX(CLKN_SX_PAD),
            .CLKP_DX(CLKP_DX_PAD),
            .CLKP_SX(CLKP_SX_PAD),
            //.GNDA_BGPV_MON(GNDA),
            //.GNDA_LBL_MON(GNDA),
            //.GNDA_TO_MON(GNDA),
            //.GNDA_WC_BGPV_MON(GNDA),
            //.GNDA_WC_LBL_MON(GNDA),
            //.GNDA_WC_TO_MON(GNDA),
            //.GNDD_BGPV_MON(GNDD),
            //.GNDD_LBL_MON(GNDD),
            //.GNDD_TO_MON(GNDD),
            //.GNDD_WC_BGPV_MON(GNDD),
            //.GNDD_WC_LBL_MON(GNDD),
            //.GNDD_WC_TO_MON(GNDD),
            .GND_TOP(GND_TOP),
            .LBNL_OUT1_1I(TopPadframe_OUT1_LBNL[6]),
            .LBNL_OUT1_1O(LBNL_OUT1_1O_PAD),
            .LBNL_OUT1_2I(TopPadframe_OUT1_LBNL[43]),
            .LBNL_OUT1_2O(LBNL_OUT1_2O_PAD),
            .LBNL_OUT1_3I(TopPadframe_OUT1_LBNL[83]),
            .LBNL_OUT1_3O(LBNL_OUT1_3O_PAD),
            .LBNL_OUT2B_1I(TopPadframe_OUT2B_LBNL[6]),
            .LBNL_OUT2B_1O(LBNL_OUT2B_1O_PAD),
            .LBNL_OUT2B_2I(TopPadframe_OUT2B_LBNL[43]),
            .LBNL_OUT2B_2O(LBNL_OUT2B_2O_PAD),
            .LBNL_OUT2B_3I(TopPadframe_OUT2B_LBNL[83]),
            .LBNL_OUT2B_3O(LBNL_OUT2B_3O_PAD),
            .LBNL_OUT2_1I(TopPadframe_OUT2_LBNL[6]),
            .LBNL_OUT2_1O(LBNL_OUT2_1O_PAD),
            .LBNL_OUT2_2I(TopPadframe_OUT2_LBNL[43]),
            .LBNL_OUT2_2O(LBNL_OUT2_2O_PAD),
            .LBNL_OUT2_3I(TopPadframe_OUT2_LBNL[83]),
            .LBNL_OUT2_3O(LBNL_OUT2_3O_PAD),
            .TO_OE12(TO_OE12_PAD),
            .TO_OE34(TO_OE34_PAD),
            .TO_OE56(TO_OE56_PAD),
            .TO_PA1(TopPadframe_VOUT_PREAMP_TO[40]),
            .TO_PA2(TopPadframe_VOUT_PREAMP_TO[41]),
            .TO_PA3(TopPadframe_VOUT_PREAMP_TO[60]),
            .TO_PA4(TopPadframe_VOUT_PREAMP_TO[61]),
            .TO_PA5(TopPadframe_VOUT_PREAMP_TO[108]),
            .TO_PA6(TopPadframe_VOUT_PREAMP_TO[109]),
            .TO_SF_IN(TO_SF_IN_PAD),
            .TO_SF_OUT(TO_SF_OUT_PAD),
            .TO_SF_OUT1(TO_SF_OUT1_PAD),
            .TO_SF_OUT2(TO_SF_OUT2_PAD),
            .TO_SF_OUT3(TO_SF_OUT3_PAD),
            .TO_SF_OUT4(TO_SF_OUT4_PAD),
            .TO_SF_OUT5(TO_SF_OUT5_PAD),
            .TO_SF_OUT6(TO_SF_OUT6_PAD),
            //.VDDA_BGPV_MON(VDDA),
            //.VDDA_LBL_MON(VDDA),
            //.VDDA_TOP_LBNL(VDDA),
            //.VDDA_TO_MON(VDDA),
            //.VDDA_WC_BGPV_MON(VDDA),
            //.VDDA_WC_LBL_MON(VDDA),
            //.VDDA_WC_TO_MON(VDDA),
            //.VDDD_BGPV_MON(VDDD),
            //.VDDD_LBL_MON(VDDD),
            //.VDDD_TO_MON(VDDD),
            //.VDDD_WC_BGPV_MON(VDDD),
            //.VDDD_WC_LBL_MON(VDDD),
            //.VDDD_WC_TO_MON(VDDD),
            .VDD_CAP_DX(VDD_CAP_DX_PAD),
            .VDD_CAP_SX(VDD_CAP_SX_PAD),
            .VDD_PCAP_DX(VDD_PCAP_DX_PAD),
            .VDD_PCAP_SX(VDD_PCAP_SX_PAD),
            .VDD_TOP(VDD_TOP) //,
            //.VSUB(VSUB)
    );

   `endif   // ABSTRACT

endmodule : RD53A

`endif


