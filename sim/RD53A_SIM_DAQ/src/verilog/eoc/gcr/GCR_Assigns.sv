//
// Name:              REGION_COL
// Size:              8
// Address:           1
// Field Description: [7:0]
assign REGION_COL[7:0] = OutDataGC[1][7:0];
//
// Name:              REGION_ROW
// Size:              9
// Address:           2
// Field Description: [8:0]
assign REGION_ROW[8:0] = OutDataGC[2][8:0];
//
// Name:              PIX_MODE
// Size:              6
// Address:           3
// Field Description: {Broadcast,AutoCol,AutoRow,BroadcastMask[2:0]}
logic [2:0] BroadcastMask;
logic       Broadcast, AutoCol, AutoRow;
logic       BroadcastTo, BroadcastBgPv, BroadcastLbnl;
assign {Broadcast,AutoCol,AutoRow,BroadcastMask[2:0]} = OutDataGC[3][5:0];
assign AutoIncrementMode = {AutoCol,AutoRow};
assign BroadcastTo   = Broadcast & BroadcastMask[2];
assign BroadcastBgPv = Broadcast & BroadcastMask[1];
assign BroadcastLbnl = Broadcast & BroadcastMask[0];
assign EnCoreColBroadcast[0] = BroadcastTo   ; // Assign broadcast bit to SYNC FE
assign EnCoreColBroadcast[1] = BroadcastBgPv ; // Assign broadcast bit to  LIN FE
assign EnCoreColBroadcast[2] = BroadcastLbnl ; // Assign broadcast bit to DIFF FE
//
// Name:              PIX_DEFAULT_CONFIG
// Size:              16
// Address:           4
// Field Description: [15:0]
assign PIX_DEFAULT_CONFIG[15:0] = OutDataGC[4][15:0];
//
// Name:              IBIASP1_SYNC
// Size:              9
// Address:           5
// Field Description: 1'b0,[8:0]
assign IBIASP1_SYNC[8:0] = OutDataGC[5][8:0];
//
// Name:              IBIASP2_SYNC
// Size:              9
// Address:           6
// Field Description: 1'b0,[8:0]
assign IBIASP2_SYNC[8:0] = OutDataGC[6][8:0];
//
// Name:              IBIAS_SF_SYNC
// Size:              9
// Address:           7
// Field Description: 1'b0,[8:0]
assign IBIAS_SF_SYNC[8:0] = OutDataGC[7][8:0];
//
// Name:              IBIAS_KRUM_SYNC
// Size:              9
// Address:           8
// Field Description: 1'b0,[8:0]
assign IBIAS_KRUM_SYNC[8:0] = OutDataGC[8][8:0];
//
// Name:              IBIAS_DISC_SYNC
// Size:              9
// Address:           9
// Field Description: 1'b0,[8:0]
assign IBIAS_DISC_SYNC[8:0] = OutDataGC[9][8:0];
//
// Name:              ICTRL_SYNCT_SYNC
// Size:              10
// Address:           10
// Field Description: [9:0]
assign ICTRL_SYNCT_SYNC[9:0] = OutDataGC[10][9:0];
//
// Name:              VBL_SYNC
// Size:              10
// Address:           11
// Field Description: [9:0]
assign VBL_SYNC[9:0] = OutDataGC[11][9:0];
//
// Name:              VTH_SYNC
// Size:              10
// Address:           12
// Field Description: [9:0]
assign VTH_SYNC[9:0] = OutDataGC[12][9:0];
//
// Name:              VREF_KRUM_SYNC
// Size:              10
// Address:           13
// Field Description: [9:0]
assign VREF_KRUM_SYNC[9:0] = OutDataGC[13][9:0];
//
// Name:              PA_IN_BIAS_LIN
// Size:              9
// Address:           14
// Field Description: 1'b0,[8:0]
assign PA_IN_BIAS_LIN[8:0] = OutDataGC[14][8:0];
//
// Name:              FC_BIAS_LIN
// Size:              8
// Address:           15
// Field Description: 2'b0,[7:0]
assign FC_BIAS_LIN[7:0] = OutDataGC[15][7:0];
//
// Name:              KRUM_CURR_LIN
// Size:              9
// Address:           16
// Field Description: 1'b0,[8:0]
assign KRUM_CURR_LIN[8:0] = OutDataGC[16][8:0];
//
// Name:              LDAC_LIN
// Size:              10
// Address:           17
// Field Description: [9:0]
assign LDAC_LIN[9:0] = OutDataGC[17][9:0];
//
// Name:              COMP_LIN
// Size:              9
// Address:           18
// Field Description: 1'b0,[8:0]
assign COMP_LIN[8:0] = OutDataGC[18][8:0];
//
// Name:              REF_KRUM_LIN
// Size:              10
// Address:           19
// Field Description: [9:0]
assign REF_KRUM_LIN[9:0] = OutDataGC[19][9:0];
//
// Name:              Vthreshold_LIN
// Size:              10
// Address:           20
// Field Description: [9:0]
assign Vthreshold_LIN[9:0] = OutDataGC[20][9:0];
//
// Name:              PRMP_DIFF
// Size:              10
// Address:           21
// Field Description: [9:0]
assign PRMP_DIFF[9:0] = OutDataGC[21][9:0];
//
// Name:              FOL_DIFF
// Size:              10
// Address:           22
// Field Description: [9:0]
assign FOL_DIFF[9:0] = OutDataGC[22][9:0];
//
// Name:              PRECOMP_DIFF
// Size:              10
// Address:           23
// Field Description: [9:0]
assign PRECOMP_DIFF[9:0] = OutDataGC[23][9:0];
//
// Name:              COMP_DIFF
// Size:              10
// Address:           24
// Field Description: [9:0]
assign COMP_DIFF[9:0] = OutDataGC[24][9:0];
//
// Name:              VFF_DIFF
// Size:              10
// Address:           25
// Field Description: [9:0]
assign VFF_DIFF[9:0] = OutDataGC[25][9:0];
//
// Name:              VTH1_DIFF
// Size:              10
// Address:           26
// Field Description: [9:0]
assign VTH1_DIFF[9:0] = OutDataGC[26][9:0];
//
// Name:              VTH2_DIFF
// Size:              10
// Address:           27
// Field Description: [9:0]
assign VTH2_DIFF[9:0] = OutDataGC[27][9:0];
//
// Name:              LCC_DIFF
// Size:              10
// Address:           28
// Field Description: [9:0]
assign LCC_DIFF[9:0] = OutDataGC[28][9:0];
//
// Name:              CONF_FE_DIFF
// Size:              2
// Address:           29
// Field Description: {LCC_X_DIFF, FF_CAP_DIFF}
assign {LCC_X_DIFF, FF_CAP_DIFF} = OutDataGC[29][1:0];
//
// Name:              CONF_FE_SYNC
// Size:              5
// Address:           30
// Field Description: {AutoZeroMode_SYNC[1:0],SelC2F_SYNC,SelC4F_SYNC,FastEn_SYNC}
assign {AutoZeroMode_SYNC[1:0],SelC2F_SYNC,SelC4F_SYNC,FastEn_SYNC} = OutDataGC[30][4:0];
//
// Name:              VOLTAGE_TRIM
// Size:              10
// Address:           31
// Field Description: {SLDOAnalogTrim[4:0], SLDODigitalTrim[4:0]}
assign {SLDOAnalogTrim[4:0], SLDODigitalTrim[4:0]} = OutDataGC[31][9:0];
//
// Name:              EN_CORE_COL_SYNC
// Size:              16
// Address:           32
// Field Description: [15:0]
assign EN_CORE_COL_SYNC[15:0] = OutDataGC[32][15:0];
//
// Name:              EN_CORE_COL_LIN_1
// Size:              16
// Address:           33
// Field Description: [15:0]
assign EN_CORE_COL_LIN_1[15:0] = OutDataGC[33][15:0];
//
// Name:              EN_CORE_COL_LIN_2
// Size:              1
// Address:           34
// Field Description: [16]
assign EN_CORE_COL_LIN_2 = OutDataGC[34][0];
//
// Name:              EN_CORE_COL_DIFF_1
// Size:              16
// Address:           35
// Field Description: [15:0]
assign EN_CORE_COL_DIFF_1[15:0] = OutDataGC[35][15:0];
//
// Name:              EN_CORE_COL_DIFF_2
// Size:              1
// Address:           36
// Field Description: [16]
assign EN_CORE_COL_DIFF_2 = OutDataGC[36][0];
//
// Name:              LATENCY_CONFIG
// Size:              9
// Address:           37
// Field Description: [8:0]
assign LATENCY_CONFIG[8:0] = OutDataGC[37][8:0];
//
// Name:              WR_SYNC_DELAY_SYNC
// Size:              5
// Address:           38
// Field Description: [4:0]
assign WR_SYNC_DELAY_SYNC[4:0] = OutDataGC[38][4:0];
//
// Name:              INJECTION_SELECT
// Size:              6
// Address:           39
// Field Description: {AnalogInjectionMode, DigitalInjectionEnable, InjectionFineDelay[3:0]}
assign {AnalogInjectionMode, DigitalInjectionEnable, InjectionFineDelay[3:0]} = OutDataGC[39][5:0];
//
// Name:              CLK_DATA_DELAY
// Size:              9
// Address:           40
// Field Description: {SelClkPhase,ClkFineDelay[3:0], DataFineDelay[3:0]}
assign {SelClkPhase,ClkFineDelay[3:0], DataFineDelay[3:0]} = OutDataGC[40][8:0];
//
// Name:              VCAL_HIGH
// Size:              12
// Address:           41
// Field Description: [11:0]
assign VCAL_HIGH[11:0] = OutDataGC[41][11:0];
//
// Name:              VCAL_MED
// Size:              12
// Address:           42
// Field Description: [11:0]
assign VCAL_MED[11:0] = OutDataGC[42][11:0];
//
// Name:              CH_SYNC_CONF
// Size:              12
// Address:           43
// Field Description: {ChSyncPhaseAdj[1:0],ChSyncLockThr[4:0],ChSyncUnlockThr[4:0]}
assign {ChSyncPhaseAdj[1:0],ChSyncLockThr[4:0],ChSyncUnlockThr[4:0]} = OutDataGC[43][11:0];
//
// Name:              GLOBAL_PULSE_ROUTE
// Size:              16
// Address:           44
// Field Description: [15:0]
assign GLOBAL_PULSE_ROUTE[15:0] = OutDataGC[44][15:0];
//
// Name:              MONITOR_FRAME_SKIP
// Size:              8
// Address:           45
// Field Description: [7:0]
assign MONITOR_FRAME_SKIP[7:0] = OutDataGC[45][7:0];
//
// Name:              EN_MACRO_COL_CAL_SYNC_1
// Size:              16
// Address:           46
// Field Description: EnMacroColCalSYNC[15:0]
assign EN_MACRO_COL_CAL_SYNC_1[15:0] = OutDataGC[46][15:0];
//
// Name:              EN_MACRO_COL_CAL_SYNC_2
// Size:              16
// Address:           47
// Field Description: EnMacroColCalSYNC[31:16]
assign EN_MACRO_COL_CAL_SYNC_2[15:0] = OutDataGC[47][15:0];
//
// Name:              EN_MACRO_COL_CAL_SYNC_3
// Size:              16
// Address:           48
// Field Description: EnMacroColCalSYNC[47:32]
assign EN_MACRO_COL_CAL_SYNC_3[15:0] = OutDataGC[48][15:0];
//
// Name:              EN_MACRO_COL_CAL_SYNC_4
// Size:              16
// Address:           49
// Field Description: EnMacroColCalSYNC[63:48]
assign EN_MACRO_COL_CAL_SYNC_4[15:0] = OutDataGC[49][15:0];
//
// Name:              EN_MACRO_COL_CAL_LIN_1
// Size:              16
// Address:           50
// Field Description: EnMacroColCalLIN[15:0]
assign EN_MACRO_COL_CAL_LIN_1[15:0] = OutDataGC[50][15:0];
//
// Name:              EN_MACRO_COL_CAL_LIN_2
// Size:              16
// Address:           51
// Field Description: EnMacroColCalLIN[31:16]
assign EN_MACRO_COL_CAL_LIN_2[15:0] = OutDataGC[51][15:0];
//
// Name:              EN_MACRO_COL_CAL_LIN_3
// Size:              16
// Address:           52
// Field Description: EnMacroColCalLIN[47:32]
assign EN_MACRO_COL_CAL_LIN_3[15:0] = OutDataGC[52][15:0];
//
// Name:              EN_MACRO_COL_CAL_LIN_4
// Size:              16
// Address:           53
// Field Description: EnMacroColCalLIN[63:48]
assign EN_MACRO_COL_CAL_LIN_4[15:0] = OutDataGC[53][15:0];
//
// Name:              EN_MACRO_COL_CAL_LIN_5
// Size:              4
// Address:           54
// Field Description: EnMacroColCalLIN[67:64]
assign EN_MACRO_COL_CAL_LIN_5[3:0] = OutDataGC[54][3:0];
//
// Name:              EN_MACRO_COL_CAL_DIFF_1
// Size:              16
// Address:           55
// Field Description: EnMacroColCalDIFF[15:0]
assign EN_MACRO_COL_CAL_DIFF_1[15:0] = OutDataGC[55][15:0];
//
// Name:              EN_MACRO_COL_CAL_DIFF_2
// Size:              16
// Address:           56
// Field Description: EnMacroColCalLBNL[31:16]
assign EN_MACRO_COL_CAL_DIFF_2[15:0] = OutDataGC[56][15:0];
//
// Name:              EN_MACRO_COL_CAL_DIFF_3
// Size:              16
// Address:           57
// Field Description: EnMacroColCalDIFF[47:32]
assign EN_MACRO_COL_CAL_DIFF_3[15:0] = OutDataGC[57][15:0];
//
// Name:              EN_MACRO_COL_CAL_DIFF_4
// Size:              16
// Address:           58
// Field Description: EnMacroColCalDIFF[63:48]
assign EN_MACRO_COL_CAL_DIFF_4[15:0] = OutDataGC[58][15:0];
//
// Name:              EN_MACRO_COL_CAL_DIFF_5
// Size:              4
// Address:           59
// Field Description: EnMacroColCalDIFF[67:64]
assign EN_MACRO_COL_CAL_DIFF_5[3:0] = OutDataGC[59][3:0];
//
// Name:              DEBUG_CONFIG
// Size:              2
// Address:           60
// Field Description: {EnableExtCal,EnablePRBS}
assign {EnableExtCal,EnablePRBS} = OutDataGC[60][1:0];
//
// Name:              OUTPUT_CONFIG
// Size:              9
// Address:           61
// Field Description: {DataReadDelay[1:0],SelSerializerType, ActiveLanes[3:0],OutputFormat[1:0]}
assign {DataReadDelay[1:0],SelSerializerType, ActiveLanes[3:0],OutputFormat[1:0]} = OutDataGC[61][8:0];
assign WrOUTPUT_CONFIGRst = WrGC[61];
//
// Name:              OUT_PAD_CONFIG
// Size:              14
// Address:           62
// Field Description: {JTAG_TDO_DS,STATUS_EN,STATUS_DS,LANE0_LVDS_EN_B, LANE0_LVDS_BIAS[2:0], GP_LVDS_EN_B[3:0], GP_LVDS_BIAS[2:0]}
assign {JTAG_TDO_DS,STATUS_EN,STATUS_DS,LANE0_LVDS_EN_B, LANE0_LVDS_BIAS[2:0], GP_LVDS_EN_B[3:0], GP_LVDS_BIAS[2:0]} = OutDataGC[62][13:0];
//
// Name:              GP_LVDS_ROUTE
// Size:              16
// Address:           63
// Field Description: [15:0]
assign GP_LVDS_ROUTE[15:0] = OutDataGC[63][15:0];
//
// Name:              CDR_CONFIG
// Size:              14
// Address:           64
// Field Description: {CDR_SEL_DEL_CLK,CDR_PD_SEL[1:0], CDR_PD_DEL[3:0], CDR_EN_GCK2, CDR_VCO_GAIN[2:0], CDR_SEL_SER_CLK[2:0]}
assign {CDR_SEL_DEL_CLK,CDR_PD_SEL[1:0], CDR_PD_DEL[3:0], CDR_EN_GCK2, CDR_VCO_GAIN[2:0], CDR_SEL_SER_CLK[2:0]} = OutDataGC[64][13:0];
//
// Name:              CDR_VCO_BUFF_BIAS
// Size:              10
// Address:           65
// Field Description: [9:0]
assign CDR_VCO_BUFF_BIAS[9:0] = OutDataGC[65][9:0];
//
// Name:              CDR_CP_IBIAS
// Size:              10
// Address:           66
// Field Description: [9:0]
assign CDR_CP_IBIAS[9:0] = OutDataGC[66][9:0];
//
// Name:              CDR_VCO_IBIAS
// Size:              10
// Address:           67
// Field Description: [9:0]
assign CDR_VCO_IBIAS[9:0] = OutDataGC[67][9:0];
//
// Name:              SER_SEL_OUT
// Size:              8
// Address:           68
// Field Description: {SerSelOut3[1:0],SerSelOut2[1:0],SerSelOut1[1:0],SerSelOut0[1:0]}
assign {SerSelOut3[1:0],SerSelOut2[1:0],SerSelOut1[1:0],SerSelOut0[1:0]} = OutDataGC[68][7:0];
//
// Name:              CML_CONFIG
// Size:              8
// Address:           69
// Field Description: {SER_INV_TAP[1:0], SER_EN_TAP[1:0], CML_EN_LANE[3:0]}
assign {SER_INV_TAP[1:0], SER_EN_TAP[1:0], CML_EN_LANE[3:0]} = OutDataGC[69][7:0];
//
// Name:              CML_TAP0_BIAS
// Size:              10
// Address:           70
// Field Description: [9:0]
assign CML_TAP0_BIAS[9:0] = OutDataGC[70][9:0];
//
// Name:              CML_TAP1_BIAS
// Size:              10
// Address:           71
// Field Description: [9:0]
assign CML_TAP1_BIAS[9:0] = OutDataGC[71][9:0];
//
// Name:              CML_TAP2_BIAS
// Size:              10
// Address:           72
// Field Description: [9:0]
assign CML_TAP2_BIAS[9:0] = OutDataGC[72][9:0];
//
// Name:              AURORA_CC_CONFIG
// Size:              8
// Address:           73
// Field Description: {CCWait[5:0], CCSend[1:0]}
assign {CCWait[5:0], CCSend[1:0]} = OutDataGC[73][7:0];
//
// Name:              AURORA_CB_CONFIG0
// Size:              8
// Address:           74
// Field Description: {CBWait[3:0],CBSend[3:0]}
assign {CBWait[3:0],CBSend[3:0]} = OutDataGC[74][7:0];
//
// Name:              AURORA_CB_CONFIG1
// Size:              16
// Address:           75
// Field Description: {CBWait[19:4]}
assign {CBWait[19:4]} = OutDataGC[75][15:0];
//
// Name:              AURORA_INIT_WAIT
// Size:              11
// Address:           76
// Field Description: [10:0]
assign AURORA_INIT_WAIT[10:0] = OutDataGC[76][10:0];
//
// Name:              MONITOR_SELECT
// Size:              14
// Address:           77
// Field Description: {MonitorEnable,IMonitor[5:0],VMonitor[6:0]}
assign {MonitorEnable,IMonitor[5:0],VMonitor[6:0]} = OutDataGC[77][13:0];
//
// Name:              HITOR_0_MASK_SYNC
// Size:              16
// Address:           78
// Field Description: [15:0]
assign HITOR_0_MASK_SYNC[15:0] = OutDataGC[78][15:0];
//
// Name:              HITOR_1_MASK_SYNC
// Size:              16
// Address:           79
// Field Description: [15:0]
assign HITOR_1_MASK_SYNC[15:0] = OutDataGC[79][15:0];
//
// Name:              HITOR_2_MASK_SYNC
// Size:              16
// Address:           80
// Field Description: [15:0]
assign HITOR_2_MASK_SYNC[15:0] = OutDataGC[80][15:0];
//
// Name:              HITOR_3_MASK_SYNC
// Size:              16
// Address:           81
// Field Description: [15:0]
assign HITOR_3_MASK_SYNC[15:0] = OutDataGC[81][15:0];
//
// Name:              HITOR_0_MASK_LIN_0
// Size:              16
// Address:           82
// Field Description: [15:0]
assign HITOR_0_MASK_LIN_0[15:0] = OutDataGC[82][15:0];
//
// Name:              HITOR_0_MASK_LIN_1
// Size:              1
// Address:           83
// Field Description: [16]
assign HITOR_0_MASK_LIN_1 = OutDataGC[83][0];
//
// Name:              HITOR_1_MASK_LIN_0
// Size:              16
// Address:           84
// Field Description: [15:0]
assign HITOR_1_MASK_LIN_0[15:0] = OutDataGC[84][15:0];
//
// Name:              HITOR_1_MASK_LIN_1
// Size:              1
// Address:           85
// Field Description: [16]
assign HITOR_1_MASK_LIN_1 = OutDataGC[85][0];
//
// Name:              HITOR_2_MASK_LIN_0
// Size:              16
// Address:           86
// Field Description: [15:0]
assign HITOR_2_MASK_LIN_0[15:0] = OutDataGC[86][15:0];
//
// Name:              HITOR_2_MASK_LIN_1
// Size:              1
// Address:           87
// Field Description: [16]
assign HITOR_2_MASK_LIN_1 = OutDataGC[87][0];
//
// Name:              HITOR_3_MASK_LIN_0
// Size:              16
// Address:           88
// Field Description: [15:0]
assign HITOR_3_MASK_LIN_0[15:0] = OutDataGC[88][15:0];
//
// Name:              HITOR_3_MASK_LIN_1
// Size:              1
// Address:           89
// Field Description: [16]
assign HITOR_3_MASK_LIN_1 = OutDataGC[89][0];
//
// Name:              HITOR_0_MASK_DIFF_0
// Size:              16
// Address:           90
// Field Description: [15:0]
assign HITOR_0_MASK_DIFF_0[15:0] = OutDataGC[90][15:0];
//
// Name:              HITOR_0_MASK_DIFF_1
// Size:              1
// Address:           91
// Field Description: [16]
assign HITOR_0_MASK_DIFF_1 = OutDataGC[91][0];
//
// Name:              HITOR_1_MASK_DIFF_0
// Size:              16
// Address:           92
// Field Description: [15:0]
assign HITOR_1_MASK_DIFF_0[15:0] = OutDataGC[92][15:0];
//
// Name:              HITOR_1_MASK_DIFF_1
// Size:              1
// Address:           93
// Field Description: [16]
assign HITOR_1_MASK_DIFF_1 = OutDataGC[93][0];
//
// Name:              HITOR_2_MASK_DIFF_0
// Size:              16
// Address:           94
// Field Description: [15:0]
assign HITOR_2_MASK_DIFF_0[15:0] = OutDataGC[94][15:0];
//
// Name:              HITOR_2_MASK_DIFF_1
// Size:              1
// Address:           95
// Field Description: [16]
assign HITOR_2_MASK_DIFF_1 = OutDataGC[95][0];
//
// Name:              HITOR_3_MASK_DIFF_0
// Size:              16
// Address:           96
// Field Description: [15:0]
assign HITOR_3_MASK_DIFF_0[15:0] = OutDataGC[96][15:0];
//
// Name:              HITOR_3_MASK_DIFF_1
// Size:              1
// Address:           97
// Field Description: [16]
assign HITOR_3_MASK_DIFF_1 = OutDataGC[97][0];
//
// Name:              MONITOR_CONFIG
// Size:              11
// Address:           98
// Field Description: {MON_BG_TRIM[4:0],MON_ADC_TRIM[5:0]}
assign {MON_BG_TRIM[4:0],MON_ADC_TRIM[5:0]} = OutDataGC[98][10:0];
//
// Name:              SENSOR_CONFIG_0
// Size:              12
// Address:           99
// Field Description: {SENS_ENABLE1,SENS_DEM1[3:0],SEN_SEL_BIAS1,SENS_ENABLE0,SENS_DEM0[3:0],SEN_SEL_BIAS0}
assign {SENS_ENABLE1,SENS_DEM1[3:0],SEN_SEL_BIAS1,SENS_ENABLE0,SENS_DEM0[3:0],SEN_SEL_BIAS0} = OutDataGC[99][11:0];
//
// Name:              SENSOR_CONFIG_1
// Size:              12
// Address:           100
// Field Description: {SENS_ENABLE3,SENS_DEM3[3:0],SEN_SEL_BIAS3,SENS_ENABLE2,SENS_DEM2[3:0],SEN_SEL_BIAS2}
assign {SENS_ENABLE3,SENS_DEM3[3:0],SEN_SEL_BIAS3,SENS_ENABLE2,SENS_DEM2[3:0],SEN_SEL_BIAS2} = OutDataGC[100][11:0];
//
// Name:              AutoRead0
// Size:              9
// Address:           101
// Field Description: [8:0]
assign AutoRead0[8:0] = OutDataGC[101][8:0];
//
// Name:              AutoRead1
// Size:              9
// Address:           102
// Field Description: [8:0]
assign AutoRead1[8:0] = OutDataGC[102][8:0];
//
// Name:              AutoRead2
// Size:              9
// Address:           103
// Field Description: [8:0]
assign AutoRead2[8:0] = OutDataGC[103][8:0];
//
// Name:              AutoRead3
// Size:              9
// Address:           104
// Field Description: [8:0]
assign AutoRead3[8:0] = OutDataGC[104][8:0];
//
// Name:              AutoRead4
// Size:              9
// Address:           105
// Field Description: [8:0]
assign AutoRead4[8:0] = OutDataGC[105][8:0];
//
// Name:              AutoRead5
// Size:              9
// Address:           106
// Field Description: [8:0]
assign AutoRead5[8:0] = OutDataGC[106][8:0];
//
// Name:              AutoRead6
// Size:              9
// Address:           107
// Field Description: [8:0]
assign AutoRead6[8:0] = OutDataGC[107][8:0];
//
// Name:              AutoRead7
// Size:              9
// Address:           108
// Field Description: [8:0]
assign AutoRead7[8:0] = OutDataGC[108][8:0];
//
// Name:              RING_OSC_ENABLE
// Size:              8
// Address:           109
// Field Description: [7:0]
assign RING_OSC_ENABLE[7:0] = OutDataGC[109][7:0];
//
// Name:              RING_OSC_0
// Size:              16
// Address:           110
// Field Description: [15:0]
assign OutDataGC[110][15:0] = RING_OSC_0[15:0];
assign WrRING_OSC_0Rst = WrGC[110];
//
// Name:              RING_OSC_1
// Size:              16
// Address:           111
// Field Description: [15:0]
assign OutDataGC[111][15:0] = RING_OSC_1[15:0];
assign WrRING_OSC_1Rst = WrGC[111];
//
// Name:              RING_OSC_2
// Size:              16
// Address:           112
// Field Description: [15:0]
assign OutDataGC[112][15:0] = RING_OSC_2[15:0];
assign WrRING_OSC_2Rst = WrGC[112];
//
// Name:              RING_OSC_3
// Size:              16
// Address:           113
// Field Description: [15:0]
assign OutDataGC[113][15:0] = RING_OSC_3[15:0];
assign WrRING_OSC_3Rst = WrGC[113];
//
// Name:              RING_OSC_4
// Size:              16
// Address:           114
// Field Description: [15:0]
assign OutDataGC[114][15:0] = RING_OSC_4[15:0];
assign WrRING_OSC_4Rst = WrGC[114];
//
// Name:              RING_OSC_5
// Size:              16
// Address:           115
// Field Description: [15:0]
assign OutDataGC[115][15:0] = RING_OSC_5[15:0];
assign WrRING_OSC_5Rst = WrGC[115];
//
// Name:              RING_OSC_6
// Size:              16
// Address:           116
// Field Description: [15:0]
assign OutDataGC[116][15:0] = RING_OSC_6[15:0];
assign WrRING_OSC_6Rst = WrGC[116];
//
// Name:              RING_OSC_7
// Size:              16
// Address:           117
// Field Description: [15:0]
assign OutDataGC[117][15:0] = RING_OSC_7[15:0];
assign WrRING_OSC_7Rst = WrGC[117];
//
// Name:              BCIDCnt
// Size:              16
// Address:           118
// Field Description: [15:0]
assign OutDataGC[118][15:0] = BCIDCnt[15:0];
assign WrBCIDCntRst = WrGC[118];
//
// Name:              TrigCnt
// Size:              16
// Address:           119
// Field Description: [15:0]
assign OutDataGC[119][15:0] = TrigCnt[15:0];
assign WrTrigCntRst = WrGC[119];
//
// Name:              LockLossCnt
// Size:              16
// Address:           120
// Field Description: [15:0]
assign OutDataGC[120][15:0] = LockLossCnt[15:0];
assign WrLockLossCntRst = WrGC[120];
//
// Name:              BitFlipWngCnt
// Size:              16
// Address:           121
// Field Description: [15:0]
assign OutDataGC[121][15:0] = BitFlipWngCnt[15:0];
assign WrBitFlipWngCntRst = WrGC[121];
//
// Name:              BitFlipErrCnt
// Size:              16
// Address:           122
// Field Description: [15:0]
assign OutDataGC[122][15:0] = BitFlipErrCnt[15:0];
assign WrBitFlipErrCntRst = WrGC[122];
//
// Name:              CmdErrCnt
// Size:              16
// Address:           123
// Field Description: [15:0]
assign OutDataGC[123][15:0] = CmdErrCnt[15:0];
assign WrCmdErrCntRst = WrGC[123];
//
// Name:              WngFifoFullCnt_0
// Size:              16
// Address:           124
// Field Description: {WngFifoFullCnt1[7:0],WngFifoFullCnt0[7:0]}
assign OutDataGC[124][15:0] = WngFifoFullCnt_0[15:0];
assign WrWngFifoFullCnt_0Rst = WrGC[124];
//
// Name:              WngFifoFullCnt_1
// Size:              16
// Address:           125
// Field Description: {WngFifoFullCnt3[7:0],WngFifoFullCnt2[7:0]}
assign OutDataGC[125][15:0] = WngFifoFullCnt_1[15:0];
assign WrWngFifoFullCnt_1Rst = WrGC[125];
//
// Name:              WngFifoFullCnt_2
// Size:              16
// Address:           126
// Field Description: {WngFifoFullCnt5[7:0],WngFifoFullCnt4[7:0]}
assign OutDataGC[126][15:0] = WngFifoFullCnt_2[15:0];
assign WrWngFifoFullCnt_2Rst = WrGC[126];
//
// Name:              WngFifoFullCnt_3
// Size:              16
// Address:           127
// Field Description: {WngFifoFullCnt7[7:0],WngFifoFullCnt6[7:0]}
assign OutDataGC[127][15:0] = WngFifoFullCnt_3[15:0];
assign WrWngFifoFullCnt_3Rst = WrGC[127];
//
// Name:              AI_REGION_COL
// Size:              8
// Address:           128
// Field Description: [7:0]
assign OutDataGC[128][7:0] = AI_REGION_COL[7:0];
assign OutDataGC[128][15:8] = 8'b0;
//
// Name:              AI_REGION_ROW
// Size:              9
// Address:           129
// Field Description: [8:0]
assign OutDataGC[129][8:0] = AI_REGION_ROW[8:0];
assign OutDataGC[129][15:9] = 7'b0;
//
// Name:              HitOr_0_Cnt
// Size:              16
// Address:           130
// Field Description: [15:0]
assign OutDataGC[130][15:0] = HitOr_0_Cnt[15:0];
assign WrHitOr_0_CntRst = WrGC[130];
//
// Name:              HitOr_1_Cnt
// Size:              16
// Address:           131
// Field Description: [15:0]
assign OutDataGC[131][15:0] = HitOr_1_Cnt[15:0];
assign WrHitOr_1_CntRst = WrGC[131];
//
// Name:              HitOr_2_Cnt
// Size:              16
// Address:           132
// Field Description: [15:0]
assign OutDataGC[132][15:0] = HitOr_2_Cnt[15:0];
assign WrHitOr_2_CntRst = WrGC[132];
//
// Name:              HitOr_3_Cnt
// Size:              16
// Address:           133
// Field Description: [15:0]
assign OutDataGC[133][15:0] = HitOr_3_Cnt[15:0];
assign WrHitOr_3_CntRst = WrGC[133];
//
// Name:              SkippedTriggerCnt
// Size:              16
// Address:           134
// Field Description: [15:0]
assign OutDataGC[134][15:0] = SkippedTriggerCnt[15:0];
assign WrSkippedTriggerCntRst = WrGC[134];
//
// Name:              ErrWngMask
// Size:              14
// Address:           135
// Field Description: [13:0]
assign ErrWngMask[13:0] = OutDataGC[135][13:0];
//
// Name:              MonitoringDataADC
// Size:              12
// Address:           136
// Field Description: [11:0]
assign OutDataGC[136][11:0] = MonitoringDataADC[11:0];
assign OutDataGC[136][15:12] = 4'b0;
assign WrMonitoringDataADCRst = WrGC[136];
