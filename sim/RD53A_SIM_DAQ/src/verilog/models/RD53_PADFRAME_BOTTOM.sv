
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_PADFRAME_BOTTOM.sv [IP/BEHAVIOURAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 22, 2017
// [Modified]       Mar 22, 2017
// [Description]    Verilog abstract and behavioural description for the I/O and power block 
//                  (I/O cells, SLVS TX/RX, Shunt-LDO and serializers).
//                  Ref. to https://twiki.cern.ch/twiki/bin/view/RD53/IoPadFrame for the complete
//                  I/O padlist
//
// [Notes]          ABSTRACT macro NOT implemented to disable the behavioral code used for functional 
//                  simulations. Synthesis pragmas synopsys translate_off/on are used instead
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/models/RD53_IO.v


`ifndef RD53_PADFRAME_BOTTOM__SV
`define RD53_PADFRAME_BOTTOM__SV


`timescale  1ns / 1ps
//`include "timescale.v"


//synopsys translate_off
`include "models/RD53_IO.v"
//synopsys translate_on


module RD53_PADFRAME_BOTTOM (


   //---------------------------------   PROGRAMMABLE CMOS I/O PADS   --------------------------------------//

   //    **pad side**                        **core side**

   // input CMOS pads with configuration

   inout wire BYPASS_CDR_PAD,           input  wire BYPASS_CDR_A,
                                        input  wire BYPASS_CDR_DS,
                                        input  wire BYPASS_CDR_OUT_EN,
                                        input  wire BYPASS_CDR_PEN,
                                        input  wire BYPASS_CDR_UD_B,
                                        output wire BYPASS_CDR_Z,

   inout wire BYPASS_CMD_PAD,           input  wire BYPASS_CMD_A,
                                        input  wire BYPASS_CMD_DS,
                                        input  wire BYPASS_CMD_OUT_EN,
                                        input  wire BYPASS_CMD_PEN,
                                        input  wire BYPASS_CMD_UD_B,
                                        output wire BYPASS_CMD_Z,

   inout wire DEBUG_EN_PAD,             input  wire DEBUG_EN_A,
                                        input  wire DEBUG_EN_DS,
                                        input  wire DEBUG_EN_OUT_EN,
                                        input  wire DEBUG_EN_PEN,
                                        input  wire DEBUG_EN_UD_B,
                                        output wire DEBUG_EN_Z,

   inout wire EXT_TRIGGER_PAD,          input  wire EXT_TRIGGER_A,
                                        input  wire EXT_TRIGGER_DS,
                                        input  wire EXT_TRIGGER_OUT_EN,
                                        input  wire EXT_TRIGGER_PEN,
                                        input  wire EXT_TRIGGER_UD_B,
                                        output wire EXT_TRIGGER_Z,

   inout wire INJ_STRB0_PAD,            input  wire INJ_STRB0_A,
                                        input  wire INJ_STRB0_DS,
                                        input  wire INJ_STRB0_OUT_EN,
                                        input  wire INJ_STRB0_PEN,
                                        input  wire INJ_STRB0_UD_B,
                                        output wire INJ_STRB0_Z,

   inout wire INJ_STRB1_PAD,            input  wire INJ_STRB1_A,
                                        input  wire INJ_STRB1_DS,
                                        input  wire INJ_STRB1_OUT_EN,
                                        input  wire INJ_STRB1_PEN,
                                        input  wire INJ_STRB1_UD_B,
                                        output wire INJ_STRB1_Z,

   inout wire CHIPID0_PAD,              input  wire CHIPID0_A,
                                        input  wire CHIPID0_DS,
                                        input  wire CHIPID0_OUT_EN,
                                        input  wire CHIPID0_PEN,
                                        input  wire CHIPID0_UD_B,
                                        output wire CHIPID0_Z,

   inout wire CHIPID1_PAD,              input  wire CHIPID1_A,
                                        input  wire CHIPID1_DS,
                                        input  wire CHIPID1_OUT_EN,
                                        input  wire CHIPID1_PEN,
                                        input  wire CHIPID1_UD_B,
                                        output wire CHIPID1_Z,

   inout wire CHIPID2_PAD,              input  wire CHIPID2_A,
                                        input  wire CHIPID2_DS,
                                        input  wire CHIPID2_OUT_EN,
                                        input  wire CHIPID2_PEN,
                                        input  wire CHIPID2_UD_B,
                                        output wire CHIPID2_Z,

   inout wire TRST_B_PAD,               input  wire TRST_B_A, 
                                        input  wire TRST_B_DS,
                                        input  wire TRST_B_OUT_EN,
                                        input  wire TRST_B_PEN,
                                        input  wire TRST_B_UD_B,
                                        output wire TRST_B_Z,

   inout wire TCK_PAD,                  input  wire TCK_A, 
                                        input  wire TCK_DS,
                                        input  wire TCK_OUT_EN,
                                        input  wire TCK_PEN,
                                        input  wire TCK_UD_B,
                                        output wire TCK_Z,
 
   inout wire TDI_PAD,                  input  wire TDI_A, 
                                        input  wire TDI_DS,
                                        input  wire TDI_OUT_EN,
                                        input  wire TDI_PEN,
                                        input  wire TDI_UD_B,
                                        output wire TDI_Z,

   inout wire TMS_PAD,                  input  wire TMS_A, 
                                        input  wire TMS_DS,
                                        input  wire TMS_OUT_EN,
                                        input  wire TMS_PEN,
                                        input  wire TMS_UD_B,
                                        output wire TMS_Z,


   // output CMOS pads with configuration

   inout wire STATUS_PAD,               input  wire STATUS_A,
                                        input  wire STATUS_DS,
                                        input  wire STATUS_OUT_EN,
                                        input  wire STATUS_PEN,
                                        input  wire STATUS_UD_B,
                                        output wire STATUS_Z,

   inout wire TDO_PAD,                  input  wire TDO_A, 
                                        input  wire TDO_DS,
                                        input  wire TDO_OUT_EN,
                                        input  wire TDO_PEN,
                                        input  wire TDO_UD_B,
                                        output wire TDO_Z,




   //-------------------------------   BIDIRECTIONAL DIGITAL I/O PADS   ------------------------------------//

   //    **pad side**                        **core side**

   inout wire EXT_POR_CAP_PAD,          inout wire EXT_POR_CAP_O,
                                        inout wire EXT_POR_CAP_I,          // **WARN: KEEP UNCONNECTED !

   inout wire POR_OUT_B_PAD,            inout wire POR_OUT_B_O,
                                        inout wire POR_OUT_B_I,            // **WARN: KEEP UNCONNECTED !
   
   inout wire PLL_RST_B_PAD,            inout wire PLL_RST_B_O,
                                        inout wire PLL_RST_B_I,            // **WARN: KEEP UNCONNECTED !

   inout wire PLL_VCTRL_PAD,            inout wire PLL_VCTRL_O,
                                        inout wire PLL_VCTRL_I,            // **WARN: KEEP UNCONNECTED !
                                        
   inout wire SLDO_POR_BG_PAD,           //inout wire POR_LDO_BG_IO, 





   //--------------------------------------   SLVS RX INTERFACE   ------------------------------------------//

   //    **pad side**                        **core side**

   input wire CMD_PAD_P,                input  wire CMD_EN_B,
   input wire CMD_PAD_N,                output wire CMD_O,

   input wire EXT_CMD_CLK_PAD_P,        input  wire EXT_CMD_CLK_EN_B,
   input wire EXT_CMD_CLK_PAD_N,        output wire EXT_CMD_CLK_O,

   input wire EXT_SER_CLK_PAD_P,        input  wire EXT_SER_CLK_EN_B,
   input wire EXT_SER_CLK_PAD_N,        output wire EXT_SER_CLK_O,




   //--------------------------------------   SLVS TX INTERFACE   ------------------------------------------//

   //    **pad side**                        **core side**

   output wire HITOR0_PAD_P,            input wire HITOR0_I,
   output wire HITOR0_PAD_N,            input wire HITOR0_EN_B,
                                        input wire [2:0] HITOR0_B,
 
   output wire HITOR1_PAD_P,            input wire HITOR1_I,
   output wire HITOR1_PAD_N,            input wire HITOR1_EN_B,
                                        input wire [2:0] HITOR1_B,

   output wire HITOR2_PAD_P,            input wire HITOR2_I,
   output wire HITOR2_PAD_N,            input wire HITOR2_EN_B,
                                        input wire [2:0] HITOR2_B,

   output wire HITOR3_PAD_P,            input wire HITOR3_I,
   output wire HITOR3_PAD_N,            input wire HITOR3_EN_B,
                                        input wire [2:0] HITOR3_B,

   output wire GTX0LVDS_PAD_P,          input wire GTX0LVDS_I,
   output wire GTX0LVDS_PAD_N,          input wire GTX0LVDS_EN_B,
                                        input wire [2:0] GTX0LVDS_B, 



   //------------------------------   4x 1.2 Gb/s CML SER/TX INTERFACE   -----------------------------------//

   //    **pad side**                        **core side**

   output wire GTX0_PAD_P,              input  wire SER_RST_B,                   // required to initialize SER internal LFSR for pseudo-random number generation
   output wire GTX0_PAD_N,              input  wire [3:0] SER_EN_LANE,
   output wire GTX1_PAD_P,              input  wire SER_TX_CLK,                  // SER clock, either from CDR/PLL or from external SLVS
   output wire GTX1_PAD_N,              input  wire [2:1] SER_INV_TAP,
   output wire GTX2_PAD_P,              input  wire [2:1] SER_EN_TAP,
   output wire GTX2_PAD_N,              input  wire [1:0] SER_SEL_OUT0, 
   output wire GTX3_PAD_P,              input  wire [1:0] SER_SEL_OUT1,
   output wire GTX3_PAD_N,              input  wire [1:0] SER_SEL_OUT2,
                                        input  wire [1:0] SER_SEL_OUT3,

                                        input  wire [19:0] SER_WORD0,
                                        input  wire [19:0] SER_WORD1,
                                        input  wire [19:0] SER_WORD2,
                                        input  wire [19:0] SER_WORD3,

                                        output wire SER_WORD_CLK,                 // divided clock for Aurora, bypassed by JTAG TCK

                                        inout  wire CML_TAP_BIAS0,
                                        inout  wire CML_TAP_BIAS1,
                                        inout  wire CML_TAP_BIAS2,

   /*

   //-------------------------------   SINGLE 5 Gb/s SER/TX INTERFACE   ------------------------------------//

   //    **pad side**                        **core side**

   output wire GWT_HS_Linkp_PAD,        input wire GWT_start_up_En,
   output wire GWT_HS_Linkn_PAD,        input wire GWT_dllReset2Vdd,
                                        input wire GWT_dllConfirmCountSelect_0,
                                        input wire GWT_dllConfirmCountSelect_1,

                                        input wire [15:0] GWT_dataIn,
                                        input wire GWT_clock320MHz,
                                        input wire GWT_reset,
                                        input wire [5:0] GWT_Threshold_for_DLL_Lock,
                                        input wire GWT_GWT_en,

                                        inout wire GWT_CP_cur_2UA,
                                        inout wire GWT_CP_cur_4UA,
                                        inout wire GWT_CP_cur_8UA,                                        

   */



   //--------------------------------   BIDIRECTIONAL ANALOG I/O PADS   ------------------------------------//

   //    **pad side**                        **core side**

   inout wire IMUX_OUT_PAD,             inout wire IMUX_OUT_O, 
                                        inout wire IMUX_OUT_I,            // **WARN: KEEP UNCONNECTED !

   inout wire IREF_IN_PAD,              inout wire IREF_IN_O,
                                        inout wire IREF_IN_I,             // **WARN: KEEP UNCONNECTED !

   inout wire IREF_OUT_PAD,             inout wire IREF_OUT_O,
                                        inout wire IREF_OUT_I,            // **WARN: KEEP UNCONNECTED !

   inout wire IREF_TRIM0_PAD,           inout wire IREF_TRIM0_O,
                                        inout wire IREF_TRIM0_I,          // **WARN: KEEP UNCONNECTED ! 

   inout wire IREF_TRIM1_PAD,           inout wire IREF_TRIM1_O,
                                        inout wire IREF_TRIM1_I,          // **WARN: KEEP UNCONNECTED !

   inout wire IREF_TRIM2_PAD,           inout wire IREF_TRIM2_O,
                                        inout wire IREF_TRIM2_I,          // **WARN: KEEP UNCONNECTED !

   inout wire IREF_TRIM3_PAD,           inout wire IREF_TRIM3_O,
                                        inout wire IREF_TRIM3_I,          // **WARN: KEEP UNCONNECTED !

   inout wire VINJ_HI_PAD,              inout wire VINJ_HI_O,
                                        inout wire VINJ_HI_I,             // **WARN: KEEP UNCONNECTED !

   inout wire VINJ_MID_PAD,             inout wire VINJ_MID_O,
                                        inout wire VINJ_MID_I,            // **WARN: KEEP UNCONNECTED !

   inout wire VMUX_OUT_PAD,             inout wire VMUX_OUT_O,
                                        inout wire VMUX_OUT_I,            // **WARN: KEEP UNCONNECTED !

   inout wire VREF_ADC_IN_PAD,          inout wire VREF_ADC_IN_O,
                                        inout wire VREF_ADC_IN_I,         // **WARN: KEEP UNCONNECTED !

   inout wire VREF_ADC_OUT_PAD,         inout wire VREF_ADC_OUT_O,
                                        inout wire VREF_ADC_OUT_I,        // **WARN: KEEP UNCONNECTED !



   //------------------------------------   SHUNTO-LDO SECTION   -------------------------------------------//

   // ANALOG Shunt-LDO
   inout wire SLDO_REXTA_PAD,
   inout wire SLDO_RINTA_PAD,
   inout wire SLDO_VDDSHUNTA_PAD,
   inout wire SLDO_IOFFSETA_PAD,
   inout wire SLDO_VREFA_PAD,

   inout wire SLDO_MON_IINA,
   inout wire SLDO_MON_ISHTA,
   inout wire SLDO_MON_VINA,
   inout wire SLDO_MON_VOFSA,
   inout wire SLDO_MON_VOUTA,
   inout wire SLDO_MON_VREFA,

   //input wire SLDO_PORA,
   input wire [4:0] SLDO_TRIMA,


   // DIGITAL Shunt-LDO
   inout wire SLDO_REXTD_PAD,
   inout wire SLDO_RINTD_PAD,
   inout wire SLDO_VDDSHUNTD_PAD,
   inout wire SLDO_IOFFSETD_PAD,
   inout wire SLDO_VREFD_PAD,

   inout wire SLDO_MON_IIND,
   inout wire SLDO_MON_ISHTD,
   inout wire SLDO_MON_VIND,
   inout wire SLDO_MON_VOFSD,
   inout wire SLDO_MON_VOUTD,
   inout wire SLDO_MON_VREFD,
   inout wire SLDO_COMP_EN_B_PAD,

   //input wire SLDO_PORD,
   input wire [4:0] SLDO_TRIMD,


   //-----------------------------------   POWER/GROUND SECTION   ------------------------------------------//

   //    **pad side**                        **core side**

   inout wire VDDA,
   inout wire GNDA,
   inout wire VDDD,
   inout wire GNDD,

   inout wire VINA,
   inout wire VIND,

   inout wire VDD_PLL,
   inout wire GND_PLL,

   inout wire VDD_CML,
   inout wire GND_CML,

//   inout wire GWT_VDD_PAD,
//   inout wire GWT_VSS_PAD,
//   inout wire GWT_VDDHS_PAD,
//   inout wire GWT_GNDHS_PAD,
//   inout wire GWT_VDDHS_core_PAD,
//   inout wire GWT_GNDHS_core_PAD,
   
   inout wire VSUB,

   inout wire DET_GRD0_PAD,             inout wire DET_GRD0_IO,
   inout wire DET_GRD1_PAD,             inout wire DET_GRD1_IO

   ) ;



   //synopsys translate_off


   //---------------------------------   PROGRAMMABLE CMOS I/O PADS   --------------------------------------//

   // input CMOS I/O cells with configuration

   CMOS_pad  BYPASS_CDR_pad (

      .PAD    ( BYPASS_CDR_PAD    ),
      .A      ( BYPASS_CDR_A      ),               // 1'b0
      .DS     ( BYPASS_CDR_DS     ),               // 1'b0
      .OUT_EN ( BYPASS_CDR_OUT_EN ),               // 1'b0
      .PEN    ( BYPASS_CDR_PEN    ),               // 1'b1
      .UD_B   ( BYPASS_CDR_UD_B   ),               // 1'b0       **pull-down**
      .Z      ( BYPASS_CDR_Z      ),               // to core
      .VDD    (              VDDD ),
      .VSS    (              GNDD ),
      .VDDPST (              VDDD ),
      .VSSPST (              GNDD )

   ) ;


   CMOS_pad  BYPASS_CMD_pad (

      .PAD    ( BYPASS_CMD_PAD    ),
      .A      ( BYPASS_CMD_A      ),               // 1'b0
      .DS     ( BYPASS_CMD_DS     ),               // 1'b0
      .OUT_EN ( BYPASS_CMD_OUT_EN ),               // 1'b0
      .PEN    ( BYPASS_CMD_PEN    ),               // 1'b1
      .UD_B   ( BYPASS_CMD_UD_B   ),               // 1'b0       **pull-down**
      .Z      ( BYPASS_CMD_Z      ),               // to core
      .VDD    (              VDDD ),
      .VSS    (              GNDD ),
      .VDDPST (              VDDD ),
      .VSSPST (              GNDD )

      ) ;


   CMOS_pad  DEBUG_EN_pad (

      .PAD    ( DEBUG_EN_PAD    ),
      .A      ( DEBUG_EN_A      ),                 // 1'b0
      .DS     ( DEBUG_EN_DS     ),                 // 1'b0
      .OUT_EN ( DEBUG_EN_OUT_EN ),                 // 1'b0
      .PEN    ( DEBUG_EN_PEN    ),                 // 1'b1
      .UD_B   ( DEBUG_EN_UD_B   ),                 // 1'b0       **pull-down**
      .Z      ( DEBUG_EN_Z      ),                 // to core
      .VDD    (            VDDD ),
      .VSS    (            GNDD ),
      .VDDPST (            VDDD ),
      .VSSPST (            GNDD )

      ) ;


   CMOS_pad  EXT_TRIGGER_pad (

      .PAD    ( EXT_TRIGGER_PAD    ),
      .A      ( EXT_TRIGGER_A      ),              // 1'b0
      .DS     ( EXT_TRIGGER_DS     ),              // 1'b0
      .OUT_EN ( EXT_TRIGGER_OUT_EN ),              // 1'b0
      .PEN    ( EXT_TRIGGER_PEN    ),              // 1'b1
      .UD_B   ( EXT_TRIGGER_UD_B   ),              // 1'b0       **pull-down**
      .Z      ( EXT_TRIGGER_Z      ),              // to core
      .VDD    (               VDDD ),
      .VSS    (               GNDD ),
      .VDDPST (               VDDD ),
      .VSSPST (               GNDD )

      ) ;


   CMOS_pad  INJ_STRB0_pad (

      .PAD    ( INJ_STRB0_PAD    ),
      .A      ( INJ_STRB0_A      ),                // 1'b0
      .DS     ( INJ_STRB0_DS     ),                // 1'b0
      .OUT_EN ( INJ_STRB0_OUT_EN ),                // 1'b0
      .PEN    ( INJ_STRB0_PEN    ),                // 1'b1
      .UD_B   ( INJ_STRB0_UD_B   ),                // 1'b0       **pull-down**
      .Z      ( INJ_STRB0_Z      ),                // to core
      .VDD    (             VDDD ),
      .VSS    (             GNDD ),
      .VDDPST (             VDDD ),
      .VSSPST (             GNDD )

      ) ;


   CMOS_pad  INJ_STRB1_pad (

      .PAD    ( INJ_STRB1_PAD    ),
      .A      ( INJ_STRB1_A      ),                // 1'b0
      .DS     ( INJ_STRB1_DS     ),                // 1'b0
      .OUT_EN ( INJ_STRB1_OUT_EN ),                // 1'b0
      .PEN    ( INJ_STRB1_PEN    ),                // 1'b1       **pull-down**
      .UD_B   ( INJ_STRB1_UD_B   ),                // 1'b0
      .Z      ( INJ_STRB1_Z      ),                // to core
      .VDD    (             VDDD ),
      .VSS    (             GNDD ),
      .VDDPST (             VDDD ),
      .VSSPST (             GNDD )

      ) ;



   CMOS_pad  CHIPID0_pad (

      .PAD    ( CHIPID0_PAD    ),
      .A      ( CHIPID0_A      ),                  // 1'b0
      .DS     ( CHIPID0_DS     ),                  // 1'b0
      .OUT_EN ( CHIPID0_OUT_EN ),                  // 1'b0
      .PEN    ( CHIPID0_PEN    ),                  // 1'b1 
      .UD_B   ( CHIPID0_UD_B   ),                  // 1'b0      **pull-down**
      .Z      ( CHIPID0_Z      ),                  // to core
      .VDD    (           VDDD ),
      .VSS    (           GNDD ),
      .VDDPST (           VDDD ),
      .VSSPST (           GNDD )

      ) ;


   CMOS_pad  CHIPID1_pad (

      .PAD    ( CHIPID1_PAD    ),
      .A      ( CHIPID1_A      ),                  // 1'b0
      .DS     ( CHIPID1_DS     ),                  // 1'b0
      .OUT_EN ( CHIPID1_OUT_EN ),                  // 1'b0
      .PEN    ( CHIPID1_PEN    ),                  // 1'b1
      .UD_B   ( CHIPID1_UD_B   ),                  // 1'b0      **pull-down**
      .Z      ( CHIPID1_Z      ),                  // to core
      .VDD    (           VDDD ),
      .VSS    (           GNDD ),
      .VDDPST (           VDDD ),
      .VSSPST (           GNDD )

      ) ;


   CMOS_pad  CHIPID2_pad (

      .PAD    ( CHIPID2_PAD    ),
      .A      ( CHIPID2_A      ),                  // 1'b0
      .DS     ( CHIPID2_DS     ),                  // 1'b0
      .OUT_EN ( CHIPID2_OUT_EN ),                  // 1'b0
      .PEN    ( CHIPID2_PEN    ),                  // 1'b1
      .UD_B   ( CHIPID2_UD_B   ),                  // 1'b0      **pull-down**
      .Z      ( CHIPID2_Z      ),                  // to core
      .VDD    (           VDDD ),
      .VSS    (           GNDD ),
      .VDDPST (           VDDD ),
      .VSSPST (           GNDD )

      ) ;


   CMOS_pad  TRST_B_pad (

      .PAD    ( TRST_B_PAD    ),
      .A      ( TRST_B_A      ),                   // 1'b0
      .DS     ( TRST_B_DS     ),                   // 1'b0
      .OUT_EN ( TRST_B_OUT_EN ),                   // 1'b0
      .PEN    ( TRST_B_PEN    ),                   // 1'b1
      .UD_B   ( TRST_B_UD_B   ),                   // 1'b0      **pull-down**   (IEEE Std. broken)
      .Z      ( TRST_B_Z      ),                   // to core
      .VDD    (          VDDD ),
      .VSS    (          GNDD ),
      .VDDPST (          VDDD ),
      .VSSPST (          GNDD )

      ) ;


   CMOS_pad  TCK_pad (

      .PAD    ( TCK_PAD    ),
      .A      ( TCK_A      ),                      // 1'b0
      .DS     ( TCK_DS     ),                      // 1'b0
      .OUT_EN ( TCK_OUT_EN ),                      // 1'b0
      .PEN    ( TCK_PEN    ),                      // 1'b1
      .UD_B   ( TCK_UD_B   ),                      // 1'b0      **pull-down**   (IEEE Std. compliant)
      .Z      ( TCK_Z      ),                      // to core
      .VDD    (       VDDD ),
      .VSS    (       GNDD ),
      .VDDPST (       VDDD ),
      .VSSPST (       GNDD )

      ) ;


   CMOS_pad  TDI_pad (

      .PAD    ( TDI_PAD    ),
      .A      ( TDI_A      ),                      // 1'b0
      .DS     ( TDI_DS     ),                      // 1'b0
      .OUT_EN ( TDI_OUT_EN ),                      // 1'b0
      .PEN    ( TDI_PEN    ),                      // 1'b1
      .UD_B   ( TDI_UD_B   ),                      // 1'b1      **pull-up**    (IEEE Std. compliant)
      .Z      ( TDI_Z      ),                      // to core
      .VDD    (       VDDD ),
      .VSS    (       GNDD ),
      .VDDPST (       VDDD ),
      .VSSPST (       GNDD )

      ) ;


   CMOS_pad  TMS_pad (

      .PAD    ( TMS_PAD    ),
      .A      ( TMS_A      ),                      // 1'b0
      .DS     ( TMS_DS     ),                      // 1'b0
      .OUT_EN ( TMS_OUT_EN ),                      // 1'b0
      .PEN    ( TMS_PEN    ),                      // 1'b1
      .UD_B   ( TMS_UD_B   ),                      // 1'b1      **pull-up**    (IEEE Std. compliant)
      .Z      ( TMS_Z      ),                      // to core
      .VDD    (       VDDD ),
      .VSS    (       GNDD ),
      .VDDPST (       VDDD ),
      .VSSPST (       GNDD )

      ) ;



   // output CMOS I/O cells with configuration

   CMOS_pad  STATUS_pad (

      .PAD    ( STATUS_PAD    ),
      .A      ( STATUS_A      ),                   // from core
      .DS     ( STATUS_DS     ),                   // configuration bit
      .OUT_EN ( STATUS_OUT_EN ),                   // configuration bit
      .PEN    ( STATUS_PEN    ),                   // 1'b0
      .UD_B   ( STATUS_UD_B   ),                   // 1'b0
      .Z      ( STATUS_Z      ),                   // 1'b0
      .VDD    (          VDDD ),
      .VSS    (          GNDD ),
      .VDDPST (          VDDD ),
      .VSSPST (          GNDD )

      ) ;


   CMOS_pad  TDO_pad (

      .PAD    ( TDO_PAD    ),
      .A      ( TDO_A      ),                      // from core
      .DS     ( TDO_DS     ),                      // configuration bit
      .OUT_EN ( TDO_OUT_EN ),                      // JTAG_TDO_ENABLE
      .PEN    ( TDO_PEN    ),                      // 1'b0
      .UD_B   ( TDO_UD_B   ),                      // 1'b0
      .Z      ( TDO_Z      ),                      // 1'b0
      .VDD    (       VDDD ),
      .VSS    (       GNDD ),
      .VDDPST (       VDDD ),
      .VSSPST (       GNDD )

      ) ;



   //-------------------------------   BIDIRECTIONAL DIGITAL I/O PADS   ------------------------------------//


   PASSIVE_pad  EXT_POR_CAP_pad (

      .PAD ( EXT_POR_CAP_PAD ), 
      .O   ( EXT_POR_CAP_O   ),
      .I   ( EXT_POR_CAP_I   )                     // **WARN: KEEP UNCONNECTED !

      ) ;


   PASSIVE_pad  POR_OUT_B_pad (

      .PAD ( POR_OUT_B_PAD ), 
      .O   ( POR_OUT_B_O   ),
      .I   ( POR_OUT_B_I   )                       // **WARN: KEEP UNCONNECTED !

      ) ;



   PASSIVE_OVT_PD_pad  POR_SLDO_pad (

      .PAD( POR_LDO_BG_PAD )

      ) ;


   //--------------------------------------   SLVS RX INTERFACE   ------------------------------------------//

   LVDS_RX_pad  CMD_pad (

      .PAD_P  ( CMD_PAD_P ),
      .PAD_N  ( CMD_PAD_N ),
      .EN_B   ( CMD_EN_B  ),
      .O      ( CMD_O     ),
      .VDD    (      VDDD ),
      .VSS    (      GNDD ),
      .VDDPST (      VDDD ),
      .VSSPST (      GNDD )

      ) ;



   LVDS_RX_pad  EXT_CMD_CLK_pad (

      .PAD_P  ( EXT_CMD_CLK_PAD_P ),
      .PAD_N  ( EXT_CMD_CLK_PAD_N ),
      .EN_B   ( EXT_CMD_CLK_EN_B  ),
      .O      ( EXT_CMD_CLK_O     ),
      .VDD    (              VDDD ),
      .VSS    (              GNDD ),
      .VDDPST (              VDDD ),
      .VSSPST (              GNDD )

      ) ;


   LVDS_RX_pad  EXT_SER_CLK_pad (

      .PAD_P  ( EXT_SER_CLK_PAD_P ),
      .PAD_N  ( EXT_SER_CLK_PAD_N ),
      .EN_B   ( EXT_SER_CLK_EN_B  ),
      .O      ( EXT_SER_CLK_O     ),
      .VDD    (              VDDD ),
      .VSS    (              GNDD ),
      .VDDPST (              VDDD ),
      .VSSPST (              GNDD )
     
      ) ;



   //--------------------------------------   SLVS TX INTERFACE   ------------------------------------------//

   LVDS_TX_pad  HITOR0_pad (

      .I      ( HITOR0_I     ),
      .EN_B   ( HITOR0_EN_B  ),
      .B      ( HITOR0_B     ),
      .PAD_P  ( HITOR0_PAD_P ),
      .PAD_N  ( HITOR0_PAD_N ),
      .VDD    (         VDDD ),
      .VSS    (         GNDD ),
      .VDDPST (         VDDD ),
      .VSSPST (         GNDD )     

      ) ;


   LVDS_TX_pad  HITOR1_pad (

      .I      ( HITOR1_I     ),
      .EN_B   ( HITOR1_EN_B  ),
      .B      ( HITOR1_B     ),
      .PAD_P  ( HITOR1_PAD_P ),
      .PAD_N  ( HITOR1_PAD_N ),
      .VDD    (         VDDD ),
      .VSS    (         GNDD ),
      .VDDPST (         VDDD ),
      .VSSPST (         GNDD )     

      ) ;


   LVDS_TX_pad  HITOR2_pad (

      .I      ( HITOR2_I     ),
      .EN_B   ( HITOR2_EN_B  ),
      .B      ( HITOR2_B     ),
      .PAD_P  ( HITOR2_PAD_P ),
      .PAD_N  ( HITOR2_PAD_N ),
      .VDD    (         VDDD ),
      .VSS    (         GNDD ),
      .VDDPST (         VDDD ),
      .VSSPST (         GNDD )     

      ) ;


   LVDS_TX_pad  HITOR3_pad (

      .I      ( HITOR3_I     ),
      .EN_B   ( HITOR3_EN_B  ),
      .B      ( HITOR3_B     ),
      .PAD_P  ( HITOR3_PAD_P ),
      .PAD_N  ( HITOR3_PAD_N ),
      .VDD    (         VDDD ),
      .VSS    (         GNDD ),
      .VDDPST (         VDDD ),
      .VSSPST (         GNDD )     

      ) ;



   LVDS_TX_pad  GTX0LVDS_pad (

      .I      ( GTX0LVDS_I     ),
      .EN_B   ( GTX0LVDS_EN_B  ),
      .B      ( GTX0LVDS_B     ),
      .PAD_P  ( GTX0LVDS_PAD_P ),
      .PAD_N  ( GTX0LVDS_PAD_N ),
      .VDD    (           VDDD ),
      .VSS    (           GNDD ),
      .VDDPST (           VDDD ),
      .VSSPST (           GNDD )
    
      ) ;




   //------------------------------------   4x 1.6 Gb/s SERIALIZERS   --------------------------------------//


   GTX_pad  GTX4_pad (

      .SER_RST_B      (     SER_RST_B ),
      .SER_TX_CLK     (    SER_TX_CLK ),
      .SER_EN_LANE    (   SER_EN_LANE ),
      .SER_INV_TAP    (   SER_INV_TAP ),
      .SER_EN_TAP     (    SER_EN_TAP ),
      .SER_SEL_OUT0   (  SER_SEL_OUT0 ),
      .SER_SEL_OUT1   (  SER_SEL_OUT1 ),
      .SER_SEL_OUT2   (  SER_SEL_OUT2 ),
      .SER_SEL_OUT3   (  SER_SEL_OUT3 ),
      .SER_WORD0      (     SER_WORD0 ),
      .SER_WORD1      (     SER_WORD1 ),
      .SER_WORD2      (     SER_WORD2 ),
      .SER_WORD3      (     SER_WORD3 ),
      .SER_WORD_CLK   (  SER_WORD_CLK ),
      .GTX0_PAD_P     (    GTX0_PAD_P ),
      .GTX0_PAD_N     (    GTX0_PAD_N ),
      .GTX1_PAD_P     (    GTX1_PAD_P ),
      .GTX1_PAD_N     (    GTX1_PAD_N ),
      .GTX2_PAD_P     (    GTX2_PAD_P ),
      .GTX2_PAD_N     (    GTX2_PAD_N ),
      .GTX3_PAD_P     (    GTX3_PAD_P ),
      .GTX3_PAD_N     (    GTX3_PAD_N ),
      .CML_TAP_BIAS1  ( CML_TAP_BIAS0 ),
      .CML_TAP_BIAS2  ( CML_TAP_BIAS1 ),
      .CML_TAP_BIAS3  ( CML_TAP_BIAS2 ),
      .VDDD           (          VDDD ),
      .GNDD           (          GNDD ),
      .VDD_CML        (       VDD_CML ),
      .GND_CML        (       GND_CML )

      ) ;


   //-------------------------------   SINGLE 5 Gb/s SER/TX INTERFACE   ------------------------------------//

   // **TODO



   //--------------------------------   BIDIRECTIONAL ANALOG I/O PADS   ------------------------------------//


   PASSIVE_pad  IMUX_OUT_pad (

      .PAD ( IMUX_OUT_PAD ), 
      .O   ( IMUX_OUT_O   ),
      .I   ( IMUX_OUT_I   )                        // **UNCONNECTED

      ) ;


   PASSIVE_pad  IREF_IN_pad (

      .PAD ( IREF_IN_PAD ),
      .O   ( IREF_IN_O   ),
      .I   ( IREF_IN_I   )                         // **UNCONNECTED

      ) ;


   PASSIVE_pad  IREF_OUT_pad (

      .PAD ( IREF_OUT_PAD ),
      .O   ( IREF_OUT_O   ),
      .I   ( IREF_OUT_I   )                        // **UNCONNECTED

      ) ;


   PASSIVE_pad  IREF_TRIM0_pad (

      .PAD ( IREF_TRIM0_PAD ),
      .O   ( IREF_TRIM0_O   ),
      .I   ( IREF_TRIM0_I   )                      // **UNCONNECTED

      ) ;


   PASSIVE_pad  IREF_TRIM1_pad (

      .PAD ( IREF_TRIM1_PAD ),
      .O   ( IREF_TRIM1_O   ),
      .I   ( IREF_TRIM1_I   )                      // **UNCONNECTED

      ) ;


   PASSIVE_pad  IREF_TRIM2_pad (

      .PAD ( IREF_TRIM2_PAD ),
      .O   ( IREF_TRIM2_O   ),
      .I   ( IREF_TRIM2_I   )                      // **UNCONNECTED

      ) ;


   PASSIVE_pad  IREF_TRIM3_pad (

      .PAD ( IREF_TRIM3_PAD ), 
      .O   ( IREF_TRIM3_O   ),
      .I   ( IREF_TRIM3_I   )                      // **UNCONNECTED

      ) ;


   PASSIVE_pad  VINJ_HI_pad (

      .PAD ( VINJ_HI_PAD ),
      .O   ( VINJ_HI_O   ),
      .I   ( VINJ_HI_I   )                         // **UNCONNECTED

      ) ;


   PASSIVE_pad  VINJ_MID_pad (

      .PAD ( VINJ_MID_PAD ),
      .O   ( VINJ_MID_O   ),
      .I   ( VINJ_MID_I   )                        // **UNCONNECTED

      ) ;


   PASSIVE_pad  VMUX_OUT_pad (

      .PAD ( VMUX_OUT_PAD ),
      .O   ( VMUX_OUT_O   ),
      .I   ( VMUX_OUT_I   )                        // **UNCONNECTED

      ) ;


   PASSIVE_pad  VREF_ADC_IN_pad (

      .PAD ( VREF_ADC_IN_PAD ),
      .O   ( VREF_ADC_IN_O   ),
      .I   ( VREF_ADC_IN_I   )                     // **UNCONNECTED

      ) ;



   PASSIVE_pad  REF_ADC_OUT_pad (

      .PAD ( VREF_ADC_OUT_PAD ),
      .O   ( VREF_ADC_OUT_O   ),
      .I   ( VREF_ADC_OUT_I   )                    // **UNCONNECTED

      ) ;



   //-----------------------------------   POWER/GROUND SECTION   ------------------------------------------//


   POWER_pad   VDD_PLL_pad ( .PAD(VDD_PLL) ) ;
   GROUND_pad  GND_PLL_pad ( .PAD(GND_PLL) ) ;

   //PASSIVE_noESD_pad  VSUB_pad ( .PAD(VSUB_PAD), .IO(VSUB_IO) ) ;

   PASSIVE_noESD_pad  DET_GRD0_pad ( .PAD(DET_GRD0_PAD), .IO(DET_GRD0_IO) ) ;
   PASSIVE_noESD_pad  DET_GRD1_pad ( .PAD(DET_GRD1_PAD), .IO(DET_GRD1_IO) ) ;



   //synopsys translate_on

endmodule : RD53_PADFRAME_BOTTOM

`endif

