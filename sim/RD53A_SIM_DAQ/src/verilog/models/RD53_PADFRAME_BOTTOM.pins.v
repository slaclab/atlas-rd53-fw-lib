// Verilog file for cell "RD53_PADFRAME_BOTTOM" view "symbol" 
// Language Version: 2001 

module RD53_PADFRAME_BOTTOM (
    BYPASS_CDR_A,
    BYPASS_CDR_DS,
    BYPASS_CDR_OUT_EN,
    BYPASS_CDR_PAD,
    BYPASS_CDR_PEN,
    BYPASS_CDR_UD_B,
    BYPASS_CDR_Z,
    BYPASS_CMD_A,
    BYPASS_CMD_DS,
    BYPASS_CMD_OUT_EN,
    BYPASS_CMD_PAD,
    BYPASS_CMD_PEN,
    BYPASS_CMD_UD_B,
    BYPASS_CMD_Z,
    CHIPID0_A,
    CHIPID0_DS,
    CHIPID0_OUT_EN,
    CHIPID0_PAD,
    CHIPID0_PEN,
    CHIPID0_UD_B,
    CHIPID0_Z,
    CHIPID1_A,
    CHIPID1_DS,
    CHIPID1_OUT_EN,
    CHIPID1_PAD,
    CHIPID1_PEN,
    CHIPID1_UD_B,
    CHIPID1_Z,
    CHIPID2_A,
    CHIPID2_DS,
    CHIPID2_OUT_EN,
    CHIPID2_PAD,
    CHIPID2_PEN,
    CHIPID2_UD_B,
    CHIPID2_Z,
    CMD_EN_B,
    CMD_O,
    CMD_PAD_N,
    CMD_PAD_P,
    CML_TAP_BIAS0,
    CML_TAP_BIAS1,
    CML_TAP_BIAS2,
    DEBUG_EN_A,
    DEBUG_EN_DS,
    DEBUG_EN_OUT_EN,
    DEBUG_EN_PAD,
    DEBUG_EN_PEN,
    DEBUG_EN_UD_B,
    DEBUG_EN_Z,
    DET_GRD0_IO,
    DET_GRD0_PAD,
    DET_GRD1_IO,
    DET_GRD1_PAD,
    EXT_CMD_CLK_EN_B,
    EXT_CMD_CLK_O,
    EXT_CMD_CLK_PAD_N,
    EXT_CMD_CLK_PAD_P,
    EXT_POR_CAP_I,
    EXT_POR_CAP_O,
    EXT_POR_CAP_PAD,
    EXT_SER_CLK_EN_B,
    EXT_SER_CLK_O,
    EXT_SER_CLK_PAD_N,
    EXT_SER_CLK_PAD_P,
    EXT_TRIGGER_A,
    EXT_TRIGGER_DS,
    EXT_TRIGGER_OUT_EN,
    EXT_TRIGGER_PAD,
    EXT_TRIGGER_PEN,
    EXT_TRIGGER_UD_B,
    EXT_TRIGGER_Z,
    GNDA,
    GNDD,
    GND_PLL,
    GTX0LVDS_B,
    GTX0LVDS_EN_B,
    GTX0LVDS_I,
    GTX0LVDS_PAD_N,
    GTX0LVDS_PAD_P,
    GTX0_PAD_N,
    GTX0_PAD_P,
    GTX1_PAD_N,
    GTX1_PAD_P,
    GTX2_PAD_N,
    GTX2_PAD_P,
    GTX3_PAD_N,
    GTX3_PAD_P,
/*    GWT_CP_cur_2UA,
    GWT_CP_cur_4UA,
    GWT_CP_cur_8UA,
    GWT_GNDHS_PAD,
    GWT_GNDHS_core_PAD,
    GWT_GWT_en,
    GWT_HS_Linkn_PAD,
    GWT_HS_Linkp_PAD,
    GWT_Threshold_for_DLL_Lock,
    GWT_VDDHS_PAD,
    GWT_VDDHS_core_PAD,
    GWT_VDD_PAD,
    GWT_VSS_PAD,
    GWT_reset,
    GWT_clock320MHz,
    GWT_dataIn,
    GWT_dllConfirmCountSelect_0,
    GWT_dllConfirmCountSelect_1,
    GWT_dllReset2Vdd,
    GWT_start_up_En,   */
    HITOR0_B,
    HITOR0_EN_B,
    HITOR0_I,
    HITOR0_PAD_N,
    HITOR0_PAD_P,
    HITOR1_B,
    HITOR1_EN_B,
    HITOR1_I,
    HITOR1_PAD_N,
    HITOR1_PAD_P,
    HITOR2_B,
    HITOR2_EN_B,
    HITOR2_I,
    HITOR2_PAD_N,
    HITOR2_PAD_P,
    HITOR3_B,
    HITOR3_EN_B,
    HITOR3_I,
    HITOR3_PAD_N,
    HITOR3_PAD_P,
    IMUX_OUT_I,
    IMUX_OUT_O,
    IMUX_OUT_PAD,
    INJ_STRB0_A,
    INJ_STRB0_DS,
    INJ_STRB0_OUT_EN,
    INJ_STRB0_PAD,
    INJ_STRB0_PEN,
    INJ_STRB0_UD_B,
    INJ_STRB0_Z,
    INJ_STRB1_A,
    INJ_STRB1_DS,
    INJ_STRB1_OUT_EN,
    INJ_STRB1_PAD,
    INJ_STRB1_PEN,
    INJ_STRB1_UD_B,
    INJ_STRB1_Z,
    IREF_IN_I,
    IREF_IN_O,
    IREF_IN_PAD,
    IREF_OUT_I,
    IREF_OUT_O,
    IREF_OUT_PAD,
    IREF_TRIM0_I,
    IREF_TRIM0_O,
    IREF_TRIM0_PAD,
    IREF_TRIM1_I,
    IREF_TRIM1_O,
    IREF_TRIM1_PAD,
    IREF_TRIM2_I,
    IREF_TRIM2_O,
    IREF_TRIM2_PAD,
    IREF_TRIM3_I,
    IREF_TRIM3_O,
    IREF_TRIM3_PAD,
    //POR_LDO_BG_IO,
    SLDO_POR_BG_PAD,
    POR_OUT_B_I,
    POR_OUT_B_O,
    POR_OUT_B_PAD,
    SER_EN_LANE,
    SER_EN_TAP,
    SER_INV_TAP,
    SER_RST_B,
    SER_SEL_OUT0,
    SER_SEL_OUT1,
    SER_SEL_OUT2,
    SER_SEL_OUT3,
    SER_TX_CLK,
    SER_WORD0,
    SER_WORD1,
    SER_WORD2,
    SER_WORD3,
    SER_WORD_CLK,
    SLDO_MON_IINA,
    SLDO_MON_IIND,
    SLDO_MON_ISHTA,
    SLDO_MON_ISHTD,
    SLDO_MON_VINA,
    SLDO_MON_VIND,
    SLDO_MON_VOFSA,
    SLDO_MON_VOFSD,
    SLDO_MON_VOUTA,
    SLDO_MON_VOUTD,
    SLDO_MON_VREFA,
//    SLDO_MON_VREFD,
//    SLDO_PORA,
//    SLDO_PORD,
    SLDO_REXTA_PAD,
    SLDO_REXTD_PAD,
    SLDO_RINTA_PAD,
    SLDO_RINTD_PAD,
    SLDO_TRIMA,
    SLDO_TRIMD,
    SLDO_VDDSHUNTA_PAD,
    SLDO_VDDSHUNTD_PAD,
    SLDO_IOFFSETA_PAD,
    SLDO_IOFFSETD_PAD,
    SLDO_VREFA_PAD,
    SLDO_VREFD_PAD,
    STATUS_A,
    STATUS_DS,
    STATUS_OUT_EN,
    STATUS_PAD,
    STATUS_PEN,
    STATUS_UD_B,
    STATUS_Z,
    TCK_A,
    TCK_DS,
    TCK_OUT_EN,
    TCK_PAD,
    TCK_PEN,
    TCK_UD_B,
    TCK_Z,
    TDI_A,
    TDI_DS,
    TDI_OUT_EN,
    TDI_PAD,
    TDI_PEN,
    TDI_UD_B,
    TDI_Z,
    TDO_A,
    TDO_DS,
    TDO_OUT_EN,
    TDO_PAD,
    TDO_PEN,
    TDO_UD_B,
    TDO_Z,
    TMS_A,
    TMS_DS,
    TMS_OUT_EN,
    TMS_PAD,
    TMS_PEN,
    TMS_UD_B,
    TMS_Z,
    TRST_B_A,
    TRST_B_DS,
    TRST_B_OUT_EN,
    TRST_B_PAD,
    TRST_B_PEN,
    TRST_B_UD_B,
    TRST_B_Z,
    VDDA,
    VDDD,
    VDD_CML,
    VDD_PLL,
    VINA,
    VIND,
    VINJ_HI_I,
    VINJ_HI_O,
    VINJ_HI_PAD,
    VINJ_MID_I,
    VINJ_MID_O,
    VINJ_MID_PAD,
    VMUX_OUT_I,
    VMUX_OUT_O,
    VMUX_OUT_PAD,
    VREF_ADC_IN_I,
    VREF_ADC_IN_O,
    VREF_ADC_IN_PAD,
    VREF_ADC_OUT_I,
    VREF_ADC_OUT_O,
    VREF_ADC_OUT_PAD,
    SLDO_MON_VREFD,
    GND_CML,
    VSUB,
    //COMP_LDO_EN_B_PAD,
    SLDO_COMP_EN_B_PAD,
    PLL_RST_B_PAD,
    PLL_RST_B_O,
    PLL_RST_B_I,
    PLL_VCTRL_I,
    PLL_VCTRL_O,
    PLL_VCTRL_PAD);

    input wire BYPASS_CDR_A;
    input wire BYPASS_CDR_DS;
    input wire BYPASS_CDR_OUT_EN;
    inout wire BYPASS_CDR_PAD;
    input wire BYPASS_CDR_PEN;
    input wire BYPASS_CDR_UD_B;
    output wire BYPASS_CDR_Z;
    input wire BYPASS_CMD_A;
    input wire BYPASS_CMD_DS;
    input wire BYPASS_CMD_OUT_EN;
    inout wire BYPASS_CMD_PAD;
    input wire BYPASS_CMD_PEN;
    input wire BYPASS_CMD_UD_B;
    output wire BYPASS_CMD_Z;
    input wire CHIPID0_A;
    input wire CHIPID0_DS;
    input wire CHIPID0_OUT_EN;
    inout wire CHIPID0_PAD;
    input wire CHIPID0_PEN;
    input wire CHIPID0_UD_B;
    output wire CHIPID0_Z;
    input wire CHIPID1_A;
    input wire CHIPID1_DS;
    input wire CHIPID1_OUT_EN;
    inout wire CHIPID1_PAD;
    input wire CHIPID1_PEN;
    input wire CHIPID1_UD_B;
    output wire CHIPID1_Z;
    input wire CHIPID2_A;
    input wire CHIPID2_DS;
    input wire CHIPID2_OUT_EN;
    inout wire CHIPID2_PAD;
    input wire CHIPID2_PEN;
    input wire CHIPID2_UD_B;
    output wire CHIPID2_Z;
    input wire CMD_EN_B;
    output wire CMD_O;
    input wire CMD_PAD_N;
    input wire CMD_PAD_P;
    inout wire CML_TAP_BIAS1;
    inout wire CML_TAP_BIAS2;
    inout wire CML_TAP_BIAS3;
    input wire DEBUG_EN_A;
    input wire DEBUG_EN_DS;
    input wire DEBUG_EN_OUT_EN;
    inout wire DEBUG_EN_PAD;
    input wire DEBUG_EN_PEN;
    input wire DEBUG_EN_UD_B;
    output wire DEBUG_EN_Z;
    inout wire DET_GRD0_IO;
    inout wire DET_GRD0_PAD;
    inout wire DET_GRD1_IO;
    inout wire DET_GRD1_PAD;
    input wire EXT_CMD_CLK_EN_B;
    output wire EXT_CMD_CLK_O;
    input wire EXT_CMD_CLK_PAD_N;
    input wire EXT_CMD_CLK_PAD_P;
    input wire EXT_POR_CAP_I;
    output wire EXT_POR_CAP_O;
    inout wire EXT_POR_CAP_PAD;
    input wire PLL_RST_B_I;
    output wire PLL_RST_B_O;
    inout wire PLL_RST_B_PAD;
    inout wire PLL_VCTRL_I;
    inout wire PLL_VCTRL_O;
    inout wire PLL_VCTRL_PAD;
    input wire EXT_SER_CLK_EN_B;
    output wire EXT_SER_CLK_O;
    input wire EXT_SER_CLK_PAD_N;
    input wire EXT_SER_CLK_PAD_P;
    input wire EXT_TRIGGER_A;
    input wire EXT_TRIGGER_DS;
    input wire EXT_TRIGGER_OUT_EN;
    inout wire EXT_TRIGGER_PAD;
    input wire EXT_TRIGGER_PEN;
    input wire EXT_TRIGGER_UD_B;
    output wire EXT_TRIGGER_Z;
    inout wire GNDA;
    inout wire GNDD;
    inout wire GND_PLL;
    input wire [2:0] GTX0LVDS_B;
    input wire GTX0LVDS_EN_B;
    input wire GTX0LVDS_I;
    output wire GTX0LVDS_PAD_N;
    output wire GTX0LVDS_PAD_P;
    output wire GTX0_PAD_N;
    output wire GTX0_PAD_P;
    output wire GTX1_PAD_N;
    output wire GTX1_PAD_P;
    output wire GTX2_PAD_N;
    output wire GTX2_PAD_P;
    output wire GTX3_PAD_N;
    output wire GTX3_PAD_P;

/*    input wire GWT_CP_cur_2UA;
    input wire GWT_CP_cur_4UA;
    input wire GWT_CP_cur_8UA;
    input wire GWT_GWT_en;
    output wire GWT_HS_Linkn_PAD;
    output wire GWT_HS_Linkp_PAD;
    input wire [5:0] GWT_Threshold_for_DLL_Lock;
    input wire GWT_reset;
    input wire GWT_clock320MHz;
    input wire [15:0] GWT_dataIn;
    input wire GWT_dllConfirmCountSelect_0;
    input wire GWT_dllConfirmCountSelect_1;
    input wire GWT_dllReset2Vdd;
    input wire GWT_start_up_En;

    inout wire GWT_VDDHS_PAD;
    inout wire GWT_VDDHS_core_PAD;
    inout wire GWT_VDD_PAD;
    inout wire GWT_VSS_PAD;
    inout wire GWT_GNDHS_PAD;
    inout wire GWT_GNDHS_core_PAD; */

    input wire [2:0] HITOR0_B;
    input wire HITOR0_EN_B;
    input wire HITOR0_I;
    output wire HITOR0_PAD_N;
    output wire HITOR0_PAD_P;
    input wire [2:0] HITOR1_B;
    input wire HITOR1_EN_B;
    input wire HITOR1_I;
    output wire HITOR1_PAD_N;
    output wire HITOR1_PAD_P;
    input wire [2:0] HITOR2_B;
    input wire HITOR2_EN_B;
    input wire HITOR2_I;
    output wire HITOR2_PAD_N;
    output wire HITOR2_PAD_P;
    input wire [2:0] HITOR3_B;
    input wire HITOR3_EN_B;
    input wire HITOR3_I;
    output wire HITOR3_PAD_N;
    output wire HITOR3_PAD_P;
    input wire IMUX_OUT_I;
    output wire IMUX_OUT_O;
    inout wire IMUX_OUT_PAD;
    input wire INJ_STRB0_A;
    input wire INJ_STRB0_DS;
    input wire INJ_STRB0_OUT_EN;
    inout wire INJ_STRB0_PAD;
    input wire INJ_STRB0_PEN;
    input wire INJ_STRB0_UD_B;
    output wire INJ_STRB0_Z;
    input wire INJ_STRB1_A;
    input wire INJ_STRB1_DS;
    input wire INJ_STRB1_OUT_EN;
    inout wire INJ_STRB1_PAD;
    input wire INJ_STRB1_PEN;
    input wire INJ_STRB1_UD_B;
    output wire INJ_STRB1_Z;
    input wire IREF_IN_I;
    output wire IREF_IN_O;
    inout wire IREF_IN_PAD;
    input wire IREF_OUT_I;
    output wire IREF_OUT_O;
    inout wire IREF_OUT_PAD;
    input wire IREF_TRIM0_I;
    output wire IREF_TRIM0_O;
    inout wire IREF_TRIM0_PAD;
    input wire IREF_TRIM1_I;
    output wire IREF_TRIM1_O;
    inout wire IREF_TRIM1_PAD;
    input wire IREF_TRIM2_I;
    output wire IREF_TRIM2_O;
    inout wire IREF_TRIM2_PAD;
    input wire IREF_TRIM3_I;
    output wire IREF_TRIM3_O;
    inout wire IREF_TRIM3_PAD;
//    inout wire POR_LDO_BG_IO;
    inout wire SLDO_POR_BG_PAD;
    input wire POR_OUT_B_I;
    output wire POR_OUT_B_O;
    inout wire POR_OUT_B_PAD;
    input wire [3:0] SER_EN_LANE;
    input wire [2:1] SER_EN_TAP;
    input wire [2:1] SER_INV_TAP;
    input wire SER_RST_B;
    input wire [1:0] SER_SEL_OUT0;
    input wire [1:0] SER_SEL_OUT1;
    input wire [1:0] SER_SEL_OUT2;
    input wire [1:0] SER_SEL_OUT3;
    input wire SER_TX_CLK;
    input wire [19:0] SER_WORD0;
    input wire [19:0] SER_WORD1;
    input wire [19:0] SER_WORD2;
    input wire [19:0] SER_WORD3;
    output wire SER_WORD_CLK;
    inout wire SLDO_MON_IINA;
    inout wire SLDO_MON_IIND;
    inout wire SLDO_MON_ISHTA;
    inout wire SLDO_MON_ISHTD;
    inout wire SLDO_MON_VINA;
    inout wire SLDO_MON_VIND;
    inout wire SLDO_MON_VOFSA;
    inout wire SLDO_MON_VOFSD;
    inout wire SLDO_MON_VOUTA;
    inout wire SLDO_MON_VOUTD;
    inout wire SLDO_MON_VREFA;
//    inout wire SLDO_MON_VREFD;
//    input wire SLDO_PORA;
//    input wire SLDO_PORD;
    inout wire SLDO_REXTA_PAD;
    inout wire SLDO_REXTD_PAD;
    inout wire SLDO_RINTA_PAD;
    inout wire SLDO_RINTD_PAD;
    input wire [4:0] SLDO_TRIMA;
    input wire [4:0] SLDO_TRIMD;
    inout wire SLDO_VDDSHUNTA_PAD;
    inout wire SLDO_VDDSHUNTD_PAD;
    inout wire SLDO_IOFFSETA_PAD;
    inout wire SLDO_IOFFSETD_PAD;
    inout wire SLDO_VREFA_PAD;
    inout wire SLDO_VREFD_PAD;
    input wire STATUS_A;
    input wire STATUS_DS;
    input wire STATUS_OUT_EN;
    inout wire STATUS_PAD;
    input wire STATUS_PEN;
    input wire STATUS_UD_B;
    output wire STATUS_Z;
    input wire TCK_A;
    input wire TCK_DS;
    input wire TCK_OUT_EN;
    inout wire TCK_PAD;
    input wire TCK_PEN;
    input wire TCK_UD_B;
    output wire TCK_Z;
    input wire TDI_A;
    input wire TDI_DS;
    input wire TDI_OUT_EN;
    inout wire TDI_PAD;
    input wire TDI_PEN;
    input wire TDI_UD_B;
    output wire TDI_Z;
    input wire TDO_A;
    input wire TDO_DS;
    input wire TDO_OUT_EN;
    inout wire TDO_PAD;
    input wire TDO_PEN;
    input wire TDO_UD_B;
    output wire TDO_Z;
    input wire TMS_A;
    input wire TMS_DS;
    input wire TMS_OUT_EN;
    inout wire TMS_PAD;
    input wire TMS_PEN;
    input wire TMS_UD_B;
    output wire TMS_Z;
    input wire TRST_B_A;
    input wire TRST_B_DS;
    input wire TRST_B_OUT_EN;
    inout wire TRST_B_PAD;
    input wire TRST_B_PEN;
    input wire TRST_B_UD_B;
    output wire TRST_B_Z;
    inout wire VDDA;
    inout wire VDDD;
    inout wire VDD_CML;
    inout wire VDD_PLL;
    inout wire VINA;
    inout wire VIND;
    inout wire VINJ_HI_I;
    inout wire VINJ_HI_O;
    inout wire VINJ_HI_PAD;
    inout wire VINJ_MID_I;
    inout wire VINJ_MID_O;
    inout wire VINJ_MID_PAD;
    inout wire VMUX_OUT_I;
    inout wire VMUX_OUT_O;
    inout wire VMUX_OUT_PAD;
    inout wire VREF_ADC_IN_I;
    inout wire VREF_ADC_IN_O;
    inout wire VREF_ADC_IN_PAD;
    inout wire VREF_ADC_OUT_I;
    inout wire VREF_ADC_OUT_O;
    inout wire VREF_ADC_OUT_PAD;
    inout wire GND_CML;
    inout wire VSUB;
    input wire SLDO_MON_VREFD;
    input wire SLDO_COMP_EN_B_PAD;
endmodule // RD53_PADFRAME_BOTTOM


