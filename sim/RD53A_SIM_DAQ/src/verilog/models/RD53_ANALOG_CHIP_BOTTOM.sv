
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53_ANALOG_CHIP_BOTTOM.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 24, 2017
// [Modified]       May  2, 2017
// [Description]    Verilog abstract and behavioural description for the Analog Chip Bottom (ACB) block
//                  (POR, CDR/PLL, global DACs, replicated bias cells and monitoring)
//
// [Notes]          ABSTRACT macro NOT implemented to disable the behavioral code used for functional
//                  simulations. Synthesis pragmas synopsys translate_off/on are used insteadi.
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/models/RD53_POR_EXTERNAL_CAP_SEVILLA.sv
// $RTL_DIR/models/RD53_CDR_BONN.sv
// $RTL_DIR/models/RD53_CDAC10_DNW_BA.sv
// $RTL_DIR/models/RD53_RINGOSC_LAL.v
// $RTL_DIR/../vams/RD53_AFE_BGPV_BIAS.vams   **WARN: *.vams files cannot be automatically included
// $RTL_DIR/../vams/RD53_AFE_TO_BIAS.vams
// $RTL_DIR/../vams/RD53_AFE_LBNL_BIAS.vams


`ifndef RD53_ANALOG_CHIP_BOTTOM__SV
`define RD53_ANALOG_CHIP_BOTTOM__SV


`timescale  1ns / 1ps
//`include "timescale.v"


// synopsys translate_off

`include "models/RD53_POR_EXTERNAL_CAP_SEVILLA.sv"
`include "models/RD53_CDR_BONN.sv"
`include "models/RD53_CDAC10_DNW_BA.sv"
`include "models/RD53_DAC_PRAGUE.sv"
`include "models/RD53_MONITORING.sv"
`include "models/RD53_RINGOSC_LAL.sv"

// synopsys translate_on


module RD53_ANALOG_CHIP_BOTTOM (

   // POR
   input  wire POR_BGP,                              // dedicated external startup reset for Shunt-LDO bandgap
   input  wire POR_EXT_CAP,                          // POR external-cap pin, can also trigger a POR signal in case POR stucks
   input wire POR_OUT_B,                            // monitor POR output signal or force it, also fed to core logic
   output wire POR_DIG_B,

   // Clock-Data Recovery (CDR) global DACs and signals

   input  wire CDR_EN_GCK2,
   input  wire [3:0] CDR_PD_DEL,
   input  wire [1:0] CDR_PD_SEL,
   input  wire [2:0] CDR_VCO_GAIN,
   input  wire [2:0] CDR_SEL_SER_CLK,
   input  wire CDR_SEL_DEL_CLK,
   input  wire PLL_RST_B,
   input  wire PLL_VCTRL,
   
   input  wire [9:0] DAC_CP_CDR,                     // charge-pump DAC
   input  wire [9:0] DAC_VCO_CDR,                    // VCO DAC
   input  wire [9:0] DAC_VCOBUFF_CDR,                // VCO DAC

   input  wire CDR_CMD_DATA_IN,                      // serial input data stream from SLVS RX, fed to CDR
   output wire CDR_CMD_DATA_OUT,                     // output data fed to channel synchronizer 
   output wire CDR_CMD_CLK,                          // effective 160 MHz clock command clock, either from CDR/PLL or from EXT_CMD_CLK
   output wire CDR_SER_CLK,                          // recovered high-speed clock for serializers
   output wire CDR_DEL_CLK,                          // 640 MHz clock for fine-delay, either from PLL or from EXT_SER_CLK according to CDR_SEL_DEL_CLK MUX
   output wire GWT_320_CLK,

   input  wire BYPASS_CDR,                           // MUX control
   input  wire EXT_CMD_CLK,                          // external 160 MHz clock
   input  wire EXT_SER_CLK,                          // external SER clock
   input  wire LOW_JITTER_EN,                        // enable/disable manchester encoding for incoming data

   // Current Mode Logic (CML) driver global DACs and bias lines
   input  wire [9:0] DAC_CML_BIAS_1,
   input  wire [9:0] DAC_CML_BIAS_2,
   input  wire [9:0] DAC_CML_BIAS_3,

   inout  wire CURR_CML_BIAS_1,
   inout  wire CURR_CML_BIAS_2,
   inout  wire CURR_CML_BIAS_3,


   // global calibrarion DACs
   input  wire [11:0] DAC_CAL_HI,
   input  wire [11:0] DAC_CAL_MI,


   // Torino global DACs and bias lines to pixels
   input  wire [9:0] DAC_IBIASP1_TO,
   input  wire [9:0] DAC_IBIASP2_TO,
   input  wire [9:0] DAC_IBIAS_DISC_TO,
   input  wire [9:0] DAC_IBIAS_SF_TO,
   input  wire [9:0] DAC_ICTRLTOT_TO,
   input  wire [9:0] DAC_IFEED_TO,
   input  wire [9:0] DAC_REF_KRUM_TO,
   input  wire [9:0] DAC_VBL_TO,
   input  wire [9:0] DAC_VTH_TO,

   input  wire [63:0] EN_CAL_TO,
   inout  wire [63:0] CAL_HI_TO,
   inout  wire [63:0] CAL_MI_TO,

   inout  wire [63:0] IBIASP1_TO,
   inout  wire [63:0] IBIASP2_TO,
   inout  wire [63:0] IBIAS_DISC_TO,
   inout  wire [63:0] IBIAS_FEED_TO,
   inout  wire [63:0] IBIAS_SF_TO,
   inout  wire [63:0] ICTRL_TOT_TO,
   inout  wire [63:0] VBL_DISC_TO,
   inout  wire [63:0] VCASN_DISC_TO,
   inout  wire [63:0] VCASN_TO,
   inout  wire [63:0] VCASP1_TO,
   inout  wire [63:0] VCAS_KRUM_TO,
   inout  wire [63:0] VTH_DISC_TO,
   inout  wire [63:0] VREF_KRUM_TO,

   // Bergamo/Pavia global DACs and bias lines to pixels
   input  wire [9:0] DAC_COMP_BG,
   input  wire [9:0] DAC_FC_BIAS_BG,
   input  wire [9:0] DAC_GDAC_BG,
   input  wire [9:0] DAC_KRUM_CURR_BG,
   input  wire [9:0] DAC_LDAC_BG,
   input  wire [9:0] DAC_PA_IN_BIAS_BG,
   input  wire [9:0] DAC_REF_KRUM_BG,

   input  wire [67:0] EN_CAL_BG,
   inout  wire [67:0] CAL_HI_BG,
   inout  wire [67:0] CAL_MI_BG,

   inout  wire [67:0] COMP_BIAS_BG,
   inout  wire [67:0] IPA_IN_BIAS_BG,
   inout  wire [67:0] IFC_BIAS_BG,
   inout  wire [67:0] IHD_KRUM_BG,
   inout  wire [67:0] IHU_KRUM_BG,
   inout  wire [67:0] ILDAC_MIR1_BG,
   inout  wire [67:0] ILDAC_MIR2_BG,
   inout  wire [67:0] VRIF_KRUM_BG,
   inout  wire [67:0] VTH_BG,

   // LBNL global DACs and bias lines to pixels
   input  wire [9:0] DAC_COMPVBN_LBNL,
   input  wire [9:0] DAC_PRECOMPVBN_LBNL,
   input  wire [9:0] DAC_PREVBNFOL_LBNL,
   input  wire [9:0] DAC_PREVBP_LBNL,
   input  wire [9:0] DAC_VBLCC_LBNL,
   input  wire [9:0] DAC_VFF_LBNL,
   input  wire [9:0] DAC_VTH1_LBNL,
   input  wire [9:0] DAC_VTH2_LBNL,

   input  wire [67:0] EN_CAL_LBNL,
   inout  wire [67:0] CAL_HI_R_LBNL, CAL_HI_L_LBNL,
   inout  wire [67:0] CAL_MI_R_LBNL, CAL_MI_L_LBNL,
   

   inout  wire [67:0] COMPVBN_LBNL,
   inout  wire [67:0] PRECOMPVBN_LBNL,
   inout  wire [67:0] PRMPVBNFOL_LBNL,
   inout  wire [67:0] PRMPVBP_LBNL,
   inout  wire [67:0] VBNLCC_LBNL,
   inout  wire [67:0] VCTRCF0_R_LBNL, VCTRCF0_L_LBNL,
   inout  wire [67:0] VCTRLCC_R_LBNL, VCTRLCC_L_LBNL,
   inout  wire [67:0] VTHIN1_LBNL,
   inout  wire [67:0] VTHIN2_LBNL,
   inout  wire [67:0] VFF_LBNL,

   input  wire [67:0] VCTRLCC_R_DIG_LBNL, VCTRLCC_L_DIG_LBNL,
   input  wire [67:0] VCTRCF0_R_DIG_LBNL, VCTRCF0_L_DIG_LBNL,
   
   // bandgap voltage reference and reference current
   input  wire [4:0] MON_BG_TRIM,
   input  wire [3:0] IREF_TRIM,                     // **NOTE: hard-wired from bidirectional pads

   inout  wire IREF_IN,
   inout  wire IREF_OUT,

   // monitoring ADC interface 
   input  wire ADC_CLK40,
   input  wire ADC_RST_B,
   input  wire [5:0] ADC_TRIM,
   input  wire ADC_SOC,
   output wire ADC_EOC_B,
   output wire [11:0] ADC_OUT,

   inout wire VREF_ADC_IN,
   inout wire VREF_ADC_OUT,


   // analog MUX selection bits
   input  wire MON_ENABLE,
   input  wire [39:0] MON_VIN_SEL,

   input  wire MON_CP_CDR,
   input  wire MON_VCOBUFF_CDR,
   input  wire MON_VCO_CDR,

   input  wire MON_4UA_REF,

   input  wire MON_CML_BIAS_1,
   input  wire MON_CML_BIAS_2,
   input  wire MON_CML_BIAS_3,

   input  wire MON_IBIASP1_TO,
   input  wire MON_IBIASP2_TO,
   input  wire MON_IBIAS_DISC_TO,
   input  wire MON_IBIAS_SF_TO,
   input  wire MON_ICTRL_TOT_TO,
   input  wire MON_IFEED_TO,

   input  wire MON_COMP_BG,
   input  wire MON_FC_BIAS_BG,
   input  wire MON_KRUM_CURR_BG,
   input  wire MON_LDAC_BG,
   input  wire MON_PA_IN_BIAS_A_BG,

   input  wire MON_COMPVBN_LBNL,
   input  wire MON_PRECOMPVBN_LBNL,
   input  wire MON_PREVBNFOL_LBNL,
   input  wire MON_PREVBP_LBNL,
   input  wire MON_VBLCC_LBNL,
   input  wire MON_VFF_LBNL,
   input  wire MON_VTH1_LBNL,
   input  wire MON_VTH2_LBNL,

   // temperature sensors
   input wire [3:0] MON_SENS_DEM1,
   input wire MON_SENS_ENABLE1,
   input wire MON_SENS_SELBIAS1,

   input wire [3:0] MON_SENS_DEM2,
   input wire MON_SENS_ENABLE2,
   input wire MON_SENS_SELBIAS2,

   input wire [3:0] MON_SENS_DEM3,
   input wire MON_SENS_ENABLE3,
   input wire MON_SENS_SELBIAS3,

   input wire [3:0] MON_SENS_DEM4,
   input wire MON_SENS_ENABLE4,
   input wire MON_SENS_SELBIAS4,

   // shunt-LDOs
   input wire VMON_LDO_ANALOG_ISHUNT,
   input wire VMON_LDO_ANALOG_ISUPPLY,
   input wire VMON_LDO_ANALOG_VIN,
   input wire VMON_LDO_ANALOG_VOFFSET,
   input wire VMON_LDO_ANALOG_VOUT,
   input wire VMON_LDO_ANALOG_VREF,

   input wire VMON_LDO_DIGITAL_ISHUNT,
   input wire VMON_LDO_DIGITAL_ISUPPLY,
   input wire VMON_LDO_DIGITAL_VIN,
   input wire VMON_LDO_DIGITAL_VOFFSET,
   input wire VMON_LDO_DIGITAL_VOUT,
   input wire VMON_LDO_DIGITAL_VREF,

   inout  wire IMUX_OUT,
   inout  wire VMUX_OUT,


   // **BACKUP: external calibration voltages
   inout  wire VINJ_HI,
   inout  wire VINJ_MID,


   // ring-oscillators interface
   input wire RING_OSC_RESET,
   input wire RING_OSC_START_STOPN,

   input wire RING_OSC_EN_CKND0,
   input wire RING_OSC_EN_CKND4,
   input wire RING_OSC_EN_INVD0,
   input wire RING_OSC_EN_INVD4,
   input wire RING_OSC_EN_NAND0,
   input wire RING_OSC_EN_NAND4,
   input wire RING_OSC_EN_NORD0,
   input wire RING_OSC_EN_NORD4,

   output wire [15:0] RING_OSC_COUNT_CKND0,
   output wire [15:0] RING_OSC_COUNT_CKND4,
   output wire [15:0] RING_OSC_COUNT_INVD0,
   output wire [15:0] RING_OSC_COUNT_INVD4,
   output wire [15:0] RING_OSC_COUNT_NAND0,
   output wire [15:0] RING_OSC_COUNT_NAND4,
   output wire [15:0] RING_OSC_COUNT_NORD0,
   output wire [15:0] RING_OSC_COUNT_NORD4,


   // power/ground
   //inout  wire VDDA,
   //inout  wire GNDA,
   //inout  wire VDDD,
   //inout  wire GNDD,
   inout  wire VDD_PLL,
   inout  wire GND_PLL, 
   //inout  wire VSUB,

   // detector guard-ring bumps
   inout  wire [1:0] DET_GRD

   ) ;



   // synopsys translate_off


   //--------------------------------------   POR/EXTERNAL RESET   -----------------------------------------// 

   RD53_POR_EXTERNAL_CAP_SEVILLA  POR (

      .POR_EXT_CAP  ( POR_EXT_CAP ),
      .POR_OUT_B    (   POR_OUT_B )

      ) ;

    assign POR_DIG_B = POR_OUT_B;

   //---------------------------------------   REFERENCE CURRENT   -----------------------------------------// 


   // bandgap

   real vout_bg ;

   RD53_BGP_BGPV  BGP_IREF (

      .B0     (    1'b0 ),        // **NOTE: hard-wired trimming bits as in OA schematic !
      .B1     (    1'b0 ),
      .B2     (    1'b0 ),
      .B3     (    1'b0 ),
      .B4     (    1'b1 ),
      .POR    ( POR_BGP ),
      .VREF   ( vout_bg ),        // **NOTE: just feed to monitoring block, not used to derive reference current Iref
      .VDDA   (         ),
      .GNDA   (         ),
      .VSUB   (         )

   ) ;


   // nominal 3.5 uA reference current
   parameter real Iref_BGR = 3.5e-6 ;
   parameter real Itrim_LSB = 1.0e-6/16.0 ; 

   // effective reference current fed to DACs
   real Iref ;

   logic [3:0] Ntrim ;

   always @( IREF_TRIM ) begin

      if( ^IREF_TRIM === 1'bx )
         Ntrim = 4'b0 ;
      else
         Ntrim = IREF_TRIM ;

      Iref =  Iref_BGR + Ntrim * Itrim_LSB ;
   end




   //-------------------------------------------   CDR/PLL   -----------------------------------------------// 


   real Ibias_cdr_cp ;
   real Ibias_cdr_vco ;
   real Ibias_cdr_vcobuff ;

   RD53_CDAC10_DNW_BA  CP_CDR_dac10       ( .BIN(      DAC_CP_CDR[9:0] ), .IREF( Iref ), .IOUT_P(      Ibias_cdr_cp ) ) ;
   RD53_CDAC10_DNW_BA  VCOBUFF_CDR_dac10  ( .BIN( DAC_VCOBUFF_CDR[9:0] ), .IREF( Iref ), .IOUT_P(     Ibias_cdr_vco ) ) ;
   RD53_CDAC10_DNW_BA  VCO_CDR_dac10      ( .BIN(     DAC_VCO_CDR[9:0] ), .IREF( Iref ), .IOUT_P( Ibias_cdr_vcobuff ) ) ;


   RD53_CDR_BONN  CDR_PLL (

      .CMD               (      CDR_CMD_DATA_IN ),
      .CDR_PD_SEL        (      CDR_PD_SEL[1:0] ),
      .CDR_PD_DEL        (      CDR_PD_DEL[2:0] ),
      .CDR_VCO_GAIN      (    CDR_VCO_GAIN[2:0] ),
      .CDR_EN_GCK2       (          CDR_EN_GCK2 ),
      .CDR_SEL_SER_CLK   ( CDR_SEL_SER_CLK[2:0] ),
      .CDR_SEL_DEL_CLK   (      CDR_SEL_DEL_CLK ),
      .BYPASS_CDR        (           BYPASS_CDR ),
      .EXT_CMD_CLK       (          EXT_CMD_CLK ),
      .EXT_SER_CLK       (          EXT_SER_CLK ),
      .CMD_CLK           (          CDR_CMD_CLK ),
      .DEL_CLK           (          CDR_DEL_CLK ),
      .SER_CLK           (          CDR_SER_CLK ),
      .CMD_DATA          (     CDR_CMD_DATA_OUT ),
      .GWT_320_CLK       (          GWT_320_CLK ),
      .CDR_CP_BIAS       (         Ibias_cdr_cp ),     
      .CDR_VCO_BIAS      (        Ibias_cdr_vco ),
      .CDR_VCO_BUFF_BIAS (    Ibias_cdr_vcobuff ),
      .VDD_PLL           (              VDD_PLL ),
      .VSS_PLL           (              GND_PLL )

      ) ;





   //----------------------------------------   CML BIASING DACs   -----------------------------------------//

   real Ibias_cml_1 ;
   real Ibias_cml_2 ;
   real Ibias_cml_3 ;

   RD53_CDAC10_DNW_BA  CML_BIAS_1_dac10 ( .BIN( DAC_CML_BIAS_1[9:0] ), .IREF( Iref ), .IOUT_P( Ibias_cml_1 ) ) ;
   RD53_CDAC10_DNW_BA  CML_BIAS_2_dac10 ( .BIN( DAC_CML_BIAS_2[9:0] ), .IREF( Iref ), .IOUT_P( Ibias_cml_2 ) ) ;
   RD53_CDAC10_DNW_BA  CML_BIAS_3_dac10 ( .BIN( DAC_CML_BIAS_3[9:0] ), .IREF( Iref ), .IOUT_P( Ibias_cml_3 ) ) ;





   //--------------------------------------   CALIBRATION DACs   -------------------------------------------//

   real cal_hi_gbl, cal_mi_gbl ;

   real VrefP = 1.200 ;
   real VrefN = 0.000 ;

   RD53_DAC_PRAGUE  CAL_HI_dac12 (

      .BIN    ( DAC_CAL_HI[11:0] ),
      .VREF_P (            VrefP ),
      .VREF_N (            VrefN ),
      .DACOUT (       cal_hi_gbl ),
      .VDDA   (                  ),
      .GNDA   (                  ),
      .VSUB   (                  )

      ) ;


   RD53_DAC_PRAGUE  CAL_MI_dac12 (

      .BIN    ( DAC_CAL_MI[11:0] ),
      .VREF_P (            VrefP ),
      .VREF_N (            VrefN ),
      .DACOUT (       cal_mi_gbl ),
      .VDDA   (                  ),
      .GNDA   (                  ),
      .VSUB   (                  )

      ) ;




   //---------------------------------------  FEs BIASING DACs   --------------------------------------------//

   // **NOTE: for the moment only for connectivity checks, not intended to drive SPICE components

   // Torino global DACs
   RD53_CDAC10_DNW_BA  IBIASP1_TO_dac10      ( .BIN(      DAC_IBIASP1_TO[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  IBIASP2_TO_dac10      ( .BIN(      DAC_IBIASP2_TO[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  IBIAS_DISC_TO_dac10   ( .BIN(   DAC_IBIAS_DISC_TO[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  IBIAS_SF_TO_dac10     ( .BIN(     DAC_IBIAS_SF_TO[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  ICTRLTOT_TO_dac10     ( .BIN(     DAC_ICTRLTOT_TO[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  IFEED_TO_dac10        ( .BIN(        DAC_IFEED_TO[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  REF_KRUM_TO_dac10     ( .BIN(     DAC_REF_KRUM_TO[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  VBL_TO_dac10          ( .BIN(          DAC_VBL_TO[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  VTH_TO_dac10          ( .BIN(          DAC_VTH_TO[9:0] ), .IREF( Iref ) ) ;

   // Bergamo/Pavia global DACs
   RD53_CDAC10_DNW_BA  COMP_BG_dac10         ( .BIN(         DAC_COMP_BG[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  FC_BIAS_BG_dac10      ( .BIN(      DAC_FC_BIAS_BG[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  GDAC_BG_dac10         ( .BIN(         DAC_GDAC_BG[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  KRUM_CURR_BG_dac10    ( .BIN(    DAC_KRUM_CURR_BG[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  LDAC_BG_dac10         ( .BIN(         DAC_LDAC_BG[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  PA_IN_BIAS_BG_dac10   ( .BIN(   DAC_PA_IN_BIAS_BG[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  REF_KRUM_BG_dac10     ( .BIN(     DAC_REF_KRUM_BG[9:0] ), .IREF( Iref ) ) ; 


   // LBNL global DACs 
   RD53_CDAC10_DNW_BA  COMPVBN_LBNL_dac10    ( .BIN(    DAC_COMPVBN_LBNL[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  PRECOMPVBN_LBNL_dac10 ( .BIN( DAC_PRECOMPVBN_LBNL[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  PREVBNFOL_LBNL_dac10  ( .BIN(  DAC_PREVBNFOL_LBNL[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  PREVBP_LBNL_dac10     ( .BIN(     DAC_PREVBP_LBNL[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  VBLCC_LBNL_dac10      ( .BIN(      DAC_VBLCC_LBNL[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  VFF_LBNL_dac10        ( .BIN(        DAC_VFF_LBNL[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  VTH1_LBNL_dac10       ( .BIN(       DAC_VTH1_LBNL[9:0] ), .IREF( Iref ) ) ;
   RD53_CDAC10_DNW_BA  VTH2_LBNL_dac10       ( .BIN(       DAC_VTH2_LBNL[9:0] ), .IREF( Iref ) ) ;



   //--------------------------------------   MONITORING BLOCK   -------------------------------------------//


   real vmon_tsens1, vmon_radsens1, vmon_tsens2, vmon_radsens2, vmon_tsens4, vmon_radsens4, vmon_vref_vdac ;
   real vmon_radsens3, vmon_tsens3, vmon_ref_krum_bg, vmon_vth_bg, vmon_vth_to, vmon_vbl_to, vmon_ref_frum_to, vmon_vth_high_lbnl, vmon_vth_low_lbnl ;


   real MON_INPUT[39:1] ;

   assign MON_INPUT[ 1] = cal_mi_gbl ;
   assign MON_INPUT[ 2] = cal_hi_gbl ;
   assign MON_INPUT[ 3] = vmon_tsens1 ;
   assign MON_INPUT[ 4] = vmon_radsens1 ;
   assign MON_INPUT[ 5] = vmon_tsens2 ;
   assign MON_INPUT[ 6] = vmon_radsens2 ;
   assign MON_INPUT[ 7] = vmon_tsens4 ;
   assign MON_INPUT[ 8] = vmon_radsens4 ;
   assign MON_INPUT[ 9] = vmon_vref_vdac ;
   assign MON_INPUT[10] = vout_bg ;
   assign MON_INPUT[11] = IMUX_OUT ;
   assign MON_INPUT[12] = cal_mi_gbl ;
   assign MON_INPUT[13] = cal_hi_gbl ;
   assign MON_INPUT[14] = vmon_radsens3 ;
   assign MON_INPUT[15] = vmon_tsens3 ;
   assign MON_INPUT[16] = vmon_ref_krum_bg ;
   assign MON_INPUT[17] = vmon_vth_bg ;
   assign MON_INPUT[18] = vmon_vth_to ;
   assign MON_INPUT[19] = vmon_vbl_to ;
   assign MON_INPUT[20] = vmon_ref_frum_to ;
   assign MON_INPUT[21] = vmon_vth_high_lbnl ;
   assign MON_INPUT[22] = vmon_vth_low_lbnl ;
   assign MON_INPUT[23] = VMON_LDO_DIGITAL_VIN ;
   assign MON_INPUT[24] = VMON_LDO_DIGITAL_VOUT ;
   assign MON_INPUT[25] = VMON_LDO_DIGITAL_VREF ;
   assign MON_INPUT[26] = VMON_LDO_DIGITAL_VOFFSET ;
   assign MON_INPUT[27] = VMON_LDO_DIGITAL_ISUPPLY ;
   assign MON_INPUT[28] = VMON_LDO_DIGITAL_ISHUNT ;
   assign MON_INPUT[29] = VMON_LDO_ANALOG_VIN ;
   assign MON_INPUT[30] = VMON_LDO_ANALOG_VOUT ;
   assign MON_INPUT[31] = VMON_LDO_ANALOG_VREF ;
   assign MON_INPUT[32] = VMON_LDO_ANALOG_VOFFSET ;
   assign MON_INPUT[33] = VMON_LDO_ANALOG_ISUPPLY ;
   assign MON_INPUT[34] = VMON_LDO_ANALOG_ISHUNT ;
   assign MON_INPUT[35] = 0.000 ;
   assign MON_INPUT[36] = 0.000 ;
   assign MON_INPUT[37] = 0.000 ;
   assign MON_INPUT[38] = 0.000 ;
   assign MON_INPUT[39] = 0.000 ;


   parameter real Vref = 900e-3 ;


   RD53_MONITORING  MONITORING_BLOCK (

      .MON_ENABLE   (                   ),
      .POR_BGP      (                   ),
      .MON_BG_TRIM  (  MON_BG_TRIM[4:0] ),
      .MON_VIN_SEL  ( MON_VIN_SEL[39:0] ),
      .MON_INPUT    (   MON_INPUT[39:1] ),
      .adc_vin      (                   ),
      .vref_in      (              Vref ),
      .vref_out     (                   ),
      .ADC_SOC      (           ADC_SOC ),
      .ADC_TRIM     (     ADC_TRIM[5:0] ),
      .CLK40        (         ADC_CLK40 ),
      .RST_B        (         ADC_RST_B ),
      .ADC_EOC_B    (         ADC_EOC_B ),
      .ADC_OUT      (     ADC_OUT[11:0] ),
      .Ibias_comp   (                   ),
      .Ibias_opamp  (                   ),
      .AVDD         (                   ),
      .AGND         (                   ),
      .DVDD         (                   ),
      .DGND         (                   ),
      .VSUB         (                   )

      ) ;




   `ifdef USE_VAMS

   //-------------------------------   REPLICATED BIAS CELLS FOR TO AFE   ----------------------------------//


   // replicated bias cells (simpler transistor-level model)
   RD53_AFE_TO_BIAS  TO_BIAS (

      .IBIASP1_TO     (    IBIASP1_TO[63:0] ),
      .IBIASP2_TO     (    IBIASP2_TO[63:0] ),
      .VCASN_TO       (      VCASN_TO[63:0] ),
      .VCASP1_TO      (     VCASP1_TO[63:0] ),
      .IBIAS_SF_TO    (   IBIAS_SF_TO[63:0] ),
      .VCAS_KRUM_TO   (  VCAS_KRUM_TO[63:0] ),
      .IBIAS_FEED_TO  ( IBIAS_FEED_TO[63:0] ),
      .IBIAS_DISC_TO  ( IBIAS_DISC_TO[63:0] ),
      .VCASN_DISC_TO  ( VCASN_DISC_TO[63:0] ),
      .ICTRL_TOT_TO   (  ICTRL_TOT_TO[63:0] ),
      .VREF_KRUM_TO   (  VREF_KRUM_TO[63:0] ),
      .VBL_DISC_TO    (   VBL_DISC_TO[63:0] ),
      .VTH_DISC_TO    (   VTH_DISC_TO[63:0] ),
      .cal_hi_gbl     (          cal_hi_gbl ),
      .cal_mi_gbl     (          cal_mi_gbl ),
      .EN_CAL_TO      (     EN_CAL_TO[63:0] ),
      .CAL_HI_TO      (     CAL_HI_TO[63:0] ),
      .CAL_MI_TO      (     CAL_MI_TO[63:0] ),
      .VDDA           (                VDDA ),
      .GNDA           (                GNDA )


      ) ;



   //-----------------------------   REPLICATED BIAS CELLS FOR BG/PV AFE   ---------------------------------//


   // replicated bias cells (simpler transistor-level model)
   RD53_AFE_BGPV_BIAS  BGPV_BIAS (

      .IFC_BIAS_BG	(     IFC_BIAS_BG[67:0] ),
      .IPA_IN_BIAS_BG   (  IPA_IN_BIAS_BG[67:0] ),
      .IHU_KRUM_BG	(     IHU_KRUM_BG[67:0] ),
      .IHD_KRUM_BG	(     IHD_KRUM_BG[67:0] ),
      .COMP_BIAS_BG     (    COMP_BIAS_BG[67:0] ),
      .ILDAC_MIR1_BG    (   ILDAC_MIR1_BG[67:0] ),
      .ILDAC_MIR2_BG    (   ILDAC_MIR2_BG[67:0] ),
      .VRIF_KRUM_BG     (    VRIF_KRUM_BG[67:0] ),
      .VTH_BG           (          VTH_BG[67:0] ),
      .cal_hi_gbl       (            cal_hi_gbl ),
      .cal_mi_gbl       (            cal_mi_gbl ),
      .EN_CAL_BG        (       EN_CAL_BG[67:0] ),
      .CAL_HI_BG        (       CAL_HI_BG[67:0] ),
      .CAL_MI_BG        (       CAL_MI_BG[67:0] ),
      .VDDA             (                  VDDA ),
      .GNDA             (                  GNDA )

      ) ;



   //------------------------------   REPLICATED BIAS CELLS FOR LBNL AFE   ---------------------------------//


   // replicated bias cells (simpler transistor-level model)
   RD53_AFE_LBNL_BIAS  LBNL_BIAS (

      .PRMPVBNFOL_LBNL ( PRMPVBNFOL_LBNL[67:0] ),
      .PRMPVBP_LBNL    (    PRMPVBP_LBNL[67:0] ),
      .VCTRCF0_LBNL    (    VCTRCF0_LBNL[67:0] ),
      .VCTRLCC_LBNL    (    VCTRLCC_LBNL[67:0] ),
      .COMPVBN_LBNL    (    COMPVBN_LBNL[67:0] ),
      .PRECOMPVBN_LBNL ( PRECOMPVBN_LBNL[67:0] ),
      .VBNLCC_LBNL     (     VBNLCC_LBNL[67:0] ),
      .VFF_LBNL        (        VFF_LBNL[67:0] ),
      .VTHIN1_LBNL     (     VTHIN1_LBNL[67:0] ),
      .VTHIN2_LBNL     (     VTHIN2_LBNL[67:0] ),
      .cal_hi_gbl      (            cal_hi_gbl ),
      .cal_mi_gbl      (            cal_mi_gbl ),
      .EN_CAL_LBNL     (     EN_CAL_LBNL[67:0] ),
      .CAL_HI_LBNL     (     CAL_HI_LBNL[67:0] ),
      .CAL_MI_LBNL     (     CAL_MI_LBNL[67:0] ),
      .VDDA            (                  VDDA ),
      .GNDA            (                  GNDA )

      ) ;



   `endif




   //-----------------------------------   RING OSCILLATORS (LAL)   ----------------------------------------//


   RD53_RINGOSC_LAL   RINGOSC (

      .reset        (             RING_OSC_RESET ),
      .start_stopN  (       RING_OSC_START_STOPN ),
      .en_cknd0     (          RING_OSC_EN_CKND0 ),
      .en_cknd4     (          RING_OSC_EN_CKND4 ),
      .en_invd0     (          RING_OSC_EN_INVD0 ),
      .en_invd4     (          RING_OSC_EN_INVD4 ),
      .en_nand0     (          RING_OSC_EN_NAND0 ),
      .en_nand4     (          RING_OSC_EN_NAND4 ),
      .en_nord0     (          RING_OSC_EN_NORD0 ),
      .en_nord4     (          RING_OSC_EN_NORD4 ),
      .count_cknd0  ( RING_OSC_COUNT_CKND0[15:0] ),
      .count_cknd4  ( RING_OSC_COUNT_CKND4[15:0] ),
      .count_invd0  ( RING_OSC_COUNT_INVD0[15:0] ),
      .count_invd4  ( RING_OSC_COUNT_INVD4[15:0] ),
      .count_nand0  ( RING_OSC_COUNT_NAND0[15:0] ),
      .count_nand4  ( RING_OSC_COUNT_NAND4[15:0] ),
      .count_nord0  ( RING_OSC_COUNT_NORD0[15:0] ),
      .count_nord4  ( RING_OSC_COUNT_NORD4[15:0] ),
      .VDD          (                            ),
      .GND          (                            ),
      .VSUB         (                            )
 
      ) ;

   // synopsys translate_on

endmodule : RD53_ANALOG_CHIP_BOTTOM

`endif

