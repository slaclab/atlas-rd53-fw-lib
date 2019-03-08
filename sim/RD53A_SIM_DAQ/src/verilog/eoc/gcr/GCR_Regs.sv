// ---------------------------------------------------------------------------------------------------------------------
// Name:              REGION_COL
// Address:           1
// Field Description: Region Column Address
//
GCR_reg #(.WIDTH(8),.ResetValue(8'b0) ) GCR_1 (
    // Register is Read/Write
    .OutData(OutDataGC[1][7:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[1]),.InData(RegDataCmd[7:0]));
assign OutDataGC[1][15:8] = 8'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              REGION_ROW
// Address:           2
// Field Description: Region Row Address
//
GCR_reg #(.WIDTH(9),.ResetValue(9'b0) ) GCR_2 (
    // Register is Read/Write
    .OutData(OutDataGC[2][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[2]),.InData(RegDataCmd[8:0]));
assign OutDataGC[2][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              PIX_MODE
// Address:           3
// Field Description: Mode bits: Broadcast, AutoCol,AutoRow,BroadcastMask
//
GCR_reg #(.WIDTH(6),.ResetValue(6'b00_0111) ) GCR_3 (
    // Register is Read/Write
    .OutData(OutDataGC[3][5:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[3]),.InData(RegDataCmd[5:0]));
assign OutDataGC[3][15:6] = 10'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              PIX_DEFAULT_CONFIG
// Address:           4
// Field Description: Selects default configuration in Pixels
//
GCR_reg #(.WIDTH(16),.ResetValue(16'h9ce2) ) GCR_4 (
    // Register is Read/Write
    .OutData(OutDataGC[4]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[4]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              IBIASP1_SYNC
// Address:           5
// Field Description: Current of the main branch of the CSA
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd100) ) GCR_5 (
    // Register is Read/Write
    .OutData(OutDataGC[5][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[5]),.InData(RegDataCmd[8:0]));
assign OutDataGC[5][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              IBIASP2_SYNC
// Address:           6
// Field Description: Current of the splitting branch of the CSA
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd150) ) GCR_6 (
    // Register is Read/Write
    .OutData(OutDataGC[6][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[6]),.InData(RegDataCmd[8:0]));
assign OutDataGC[6][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              IBIAS_SF_SYNC
// Address:           7
// Field Description: Current of the preamplifier SF
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd100) ) GCR_7 (
    // Register is Read/Write
    .OutData(OutDataGC[7][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[7]),.InData(RegDataCmd[8:0]));
assign OutDataGC[7][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              IBIAS_KRUM_SYNC
// Address:           8
// Field Description: Current of the Krummenacher feedback
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd140) ) GCR_8 (
    // Register is Read/Write
    .OutData(OutDataGC[8][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[8]),.InData(RegDataCmd[8:0]));
assign OutDataGC[8][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              IBIAS_DISC_SYNC
// Address:           9
// Field Description: Current of the Comparator Diff Amp
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd200) ) GCR_9 (
    // Register is Read/Write
    .OutData(OutDataGC[9][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[9]),.InData(RegDataCmd[8:0]));
assign OutDataGC[9][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              ICTRL_SYNCT_SYNC
// Address:           10
// Field Description: Current of the oscillator delay line
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd100) ) GCR_10 (
    // Register is Read/Write
    .OutData(OutDataGC[10][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[10]),.InData(RegDataCmd[9:0]));
assign OutDataGC[10][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VBL_SYNC
// Address:           11
// Field Description: Baseline voltage for offset compens
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd450) ) GCR_11 (
    // Register is Read/Write
    .OutData(OutDataGC[11][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[11]),.InData(RegDataCmd[9:0]));
assign OutDataGC[11][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VTH_SYNC
// Address:           12
// Field Description: Discriminator threshold voltage
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd300) ) GCR_12 (
    // Register is Read/Write
    .OutData(OutDataGC[12][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[12]),.InData(RegDataCmd[9:0]));
assign OutDataGC[12][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VREF_KRUM_SYNC
// Address:           13
// Field Description: Krummenacher voltage reference
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd490) ) GCR_13 (
    // Register is Read/Write
    .OutData(OutDataGC[13][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[13]),.InData(RegDataCmd[9:0]));
assign OutDataGC[13][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              PA_IN_BIAS_LIN
// Address:           14
// Field Description: preampli input branch current
//
GCR_reg #(.WIDTH(9),.ResetValue(10'd300) ) GCR_14 (
    // Register is Read/Write
    .OutData(OutDataGC[14][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[14]),.InData(RegDataCmd[8:0]));
assign OutDataGC[14][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              FC_BIAS_LIN
// Address:           15
// Field Description: folded cascode branch current
//
GCR_reg #(.WIDTH(8),.ResetValue(10'd20) ) GCR_15 (
    // Register is Read/Write
    .OutData(OutDataGC[15][7:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[15]),.InData(RegDataCmd[7:0]));
assign OutDataGC[15][15:8] = 8'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              KRUM_CURR_LIN
// Address:           16
// Field Description: Krummenacher current
//
GCR_reg #(.WIDTH(9),.ResetValue(10'd50) ) GCR_16 (
    // Register is Read/Write
    .OutData(OutDataGC[16][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[16]),.InData(RegDataCmd[8:0]));
assign OutDataGC[16][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              LDAC_LIN
// Address:           17
// Field Description: fine threshold
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd80) ) GCR_17 (
    // Register is Read/Write
    .OutData(OutDataGC[17][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[17]),.InData(RegDataCmd[9:0]));
assign OutDataGC[17][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              COMP_LIN
// Address:           18
// Field Description: Comparator current
//
GCR_reg #(.WIDTH(9),.ResetValue(10'd110) ) GCR_18 (
    // Register is Read/Write
    .OutData(OutDataGC[18][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[18]),.InData(RegDataCmd[8:0]));
assign OutDataGC[18][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              REF_KRUM_LIN
// Address:           19
// Field Description: Krummenacher reference voltage
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd300) ) GCR_19 (
    // Register is Read/Write
    .OutData(OutDataGC[19][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[19]),.InData(RegDataCmd[9:0]));
assign OutDataGC[19][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              Vthreshold_LIN
// Address:           20
// Field Description: Global threshold voltage
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd408) ) GCR_20 (
    // Register is Read/Write
    .OutData(OutDataGC[20][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[20]),.InData(RegDataCmd[9:0]));
assign OutDataGC[20][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              PRMP_DIFF
// Address:           21
// Field Description: Preamp input stage current
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd533) ) GCR_21 (
    // Register is Read/Write
    .OutData(OutDataGC[21][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[21]),.InData(RegDataCmd[9:0]));
assign OutDataGC[21][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              FOL_DIFF
// Address:           22
// Field Description: Preamp output follower current
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd542) ) GCR_22 (
    // Register is Read/Write
    .OutData(OutDataGC[22][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[22]),.InData(RegDataCmd[9:0]));
assign OutDataGC[22][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              PRECOMP_DIFF
// Address:           23
// Field Description: Precomparator tail current
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd551) ) GCR_23 (
    // Register is Read/Write
    .OutData(OutDataGC[23][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[23]),.InData(RegDataCmd[9:0]));
assign OutDataGC[23][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              COMP_DIFF
// Address:           24
// Field Description: Comparator total current
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd528) ) GCR_24 (
    // Register is Read/Write
    .OutData(OutDataGC[24][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[24]),.InData(RegDataCmd[9:0]));
assign OutDataGC[24][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VFF_DIFF
// Address:           25
// Field Description: Preamp feedback current (return to baseline)
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd164) ) GCR_25 (
    // Register is Read/Write
    .OutData(OutDataGC[25][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[25]),.InData(RegDataCmd[9:0]));
assign OutDataGC[25][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VTH1_DIFF
// Address:           26
// Field Description: Negative branch voltage offset (vth1)
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd1023) ) GCR_26 (
    // Register is Read/Write
    .OutData(OutDataGC[26][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[26]),.InData(RegDataCmd[9:0]));
assign OutDataGC[26][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VTH2_DIFF
// Address:           27
// Field Description: Positive branch voltage offset (vth2)
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd0) ) GCR_27 (
    // Register is Read/Write
    .OutData(OutDataGC[27][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[27]),.InData(RegDataCmd[9:0]));
assign OutDataGC[27][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              LCC_DIFF
// Address:           28
// Field Description: Leakage current compensation current
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd20) ) GCR_28 (
    // Register is Read/Write
    .OutData(OutDataGC[28][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[28]),.InData(RegDataCmd[9:0]));
assign OutDataGC[28][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CONF_FE_DIFF
// Address:           29
// Field Description: Connect leakace current comp. circuit, Preamp feedback capacitance
//
GCR_reg #(.WIDTH(2),.ResetValue(2'b10) ) GCR_29 (
    // Register is Read/Write
    .OutData(OutDataGC[29][1:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[29]),.InData(RegDataCmd[1:0]));
assign OutDataGC[29][15:2] = 14'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CONF_FE_SYNC
// Address:           30
// Field Description: Configuration for Sync Front End
//
GCR_reg #(.WIDTH(5),.ResetValue(5'b00100) ) GCR_30 (
    // Register is Read/Write
    .OutData(OutDataGC[30][4:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[30]),.InData(RegDataCmd[4:0]));
assign OutDataGC[30][15:5] = 11'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VOLTAGE_TRIM
// Address:           31
// Field Description: Analog and Digital voltage regulator trim
//
GCR_reg #(.WIDTH(10),.ResetValue(10'b10000_10000) ) GCR_31 (
    // Register is Read/Write
    .OutData(OutDataGC[31][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[31]),.InData(RegDataCmd[9:0]));
assign OutDataGC[31][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_CORE_COL_SYNC
// Address:           32
// Field Description: Enable Core (SYNC)
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_32 (
    // Register is Read/Write
    .OutData(OutDataGC[32]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[32]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_CORE_COL_LIN_1
// Address:           33
// Field Description: Enable Core (LIN)
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_33 (
    // Register is Read/Write
    .OutData(OutDataGC[33]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[33]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_CORE_COL_LIN_2
// Address:           34
// Field Description: Enable Core (LIN)
//
GCR_reg #(.WIDTH(1),.ResetValue(16'b0) ) GCR_34 (
    // Register is Read/Write
    .OutData(OutDataGC[34][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[34]),.InData(RegDataCmd[0]));
assign OutDataGC[34][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_CORE_COL_DIFF_1
// Address:           35
// Field Description: Enable Core (DIFF)
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_35 (
    // Register is Read/Write
    .OutData(OutDataGC[35]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[35]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_CORE_COL_DIFF_2
// Address:           36
// Field Description: Enable Core (DIFF)
//
GCR_reg #(.WIDTH(1),.ResetValue(16'b0) ) GCR_36 (
    // Register is Read/Write
    .OutData(OutDataGC[36][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[36]),.InData(RegDataCmd[0]));
assign OutDataGC[36][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              LATENCY_CONFIG
// Address:           37
// Field Description: Latency Configuration
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd500) ) GCR_37 (
    // Register is Read/Write
    .OutData(OutDataGC[37][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[37]),.InData(RegDataCmd[8:0]));
assign OutDataGC[37][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              WR_SYNC_DELAY_SYNC
// Address:           38
// Field Description: Write Synchronization delay (SYNC)
//
GCR_reg #(.WIDTH(5),.ResetValue(5'b10000) ) GCR_38 (
    // Register is Read/Write
    .OutData(OutDataGC[38][4:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[38]),.InData(RegDataCmd[4:0]));
assign OutDataGC[38][15:5] = 11'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              INJECTION_SELECT
// Address:           39
// Field Description: Analog injection, Digital injection, Injection fine delay
//
GCR_reg #(.WIDTH(6),.ResetValue(6'b10_0000) ) GCR_39 (
    // Register is Read/Write
    .OutData(OutDataGC[39][5:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[39]),.InData(RegDataCmd[5:0]));
assign OutDataGC[39][15:6] = 10'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CLK_DATA_DELAY
// Address:           40
// Field Description: Clock and Data fine delay
//
GCR_reg #(.WIDTH(9),.ResetValue(9'b0) ) GCR_40 (
    // Register is Read/Write
    .OutData(OutDataGC[40][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[40]),.InData(RegDataCmd[8:0]));
assign OutDataGC[40][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VCAL_HIGH
// Address:           41
// Field Description: VCAL high
//
GCR_reg #(.WIDTH(12),.ResetValue(12'd500) ) GCR_41 (
    // Register is Read/Write
    .OutData(OutDataGC[41][11:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[41]),.InData(RegDataCmd[11:0]));
assign OutDataGC[41][15:12] = 4'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              VCAL_MED
// Address:           42
// Field Description: VCAL med
//
GCR_reg #(.WIDTH(12),.ResetValue(12'd300) ) GCR_42 (
    // Register is Read/Write
    .OutData(OutDataGC[42][11:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[42]),.InData(RegDataCmd[11:0]));
assign OutDataGC[42][15:12] = 4'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CH_SYNC_CONF
// Address:           43
// Field Description: Threshold and Phase adjust settings for the Channel Synchronizer
//
GCR_reg #(.WIDTH(12),.ResetValue(12'b00_10000_01000) ) GCR_43 (
    // Register is Read/Write
    .OutData(OutDataGC[43][11:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[43]),.InData(RegDataCmd[11:0]));
assign OutDataGC[43][15:12] = 4'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              GLOBAL_PULSE_ROUTE
// Address:           44
// Field Description: Global pulse routing select
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_44 (
    // Register is Read/Write
    .OutData(OutDataGC[44]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[44]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              MONITOR_FRAME_SKIP
// Address:           45
// Field Description: How many Data frames to skip before sending a Monitor Frame
//
GCR_reg #(.WIDTH(8),.ResetValue(8'd50) ) GCR_45 (
    // Register is Read/Write
    .OutData(OutDataGC[45][7:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[45]),.InData(RegDataCmd[7:0]));
assign OutDataGC[45][15:8] = 8'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_SYNC_1
// Address:           46
// Field Description: Enable macrocolumn analog calibrationfor the SYNC frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_46 (
    // Register is Read/Write
    .OutData(OutDataGC[46]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[46]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_SYNC_2
// Address:           47
// Field Description: Enable macrocolumn analog calibrationfor the SYNC frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_47 (
    // Register is Read/Write
    .OutData(OutDataGC[47]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[47]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_SYNC_3
// Address:           48
// Field Description: Enable macrocolumn analog calibrationfor the SYNC frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_48 (
    // Register is Read/Write
    .OutData(OutDataGC[48]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[48]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_SYNC_4
// Address:           49
// Field Description: Enable macrocolumn analog calibrationfor the SYNC frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_49 (
    // Register is Read/Write
    .OutData(OutDataGC[49]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[49]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_LIN_1
// Address:           50
// Field Description: Enable macrocolumn analog calibrationfor the LIN frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_50 (
    // Register is Read/Write
    .OutData(OutDataGC[50]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[50]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_LIN_2
// Address:           51
// Field Description: Enable macrocolumn analog calibrationfor the LIN frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_51 (
    // Register is Read/Write
    .OutData(OutDataGC[51]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[51]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_LIN_3
// Address:           52
// Field Description: Enable macrocolumn analog calibrationfor the LIN frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_52 (
    // Register is Read/Write
    .OutData(OutDataGC[52]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[52]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_LIN_4
// Address:           53
// Field Description: Enable macrocolumn analog calibrationfor the LIN frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_53 (
    // Register is Read/Write
    .OutData(OutDataGC[53]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[53]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_LIN_5
// Address:           54
// Field Description: Enable macrocolumn analog calibrationfor the LIN frontend 
//
GCR_reg #(.WIDTH(4),.ResetValue(4'hf) ) GCR_54 (
    // Register is Read/Write
    .OutData(OutDataGC[54][3:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[54]),.InData(RegDataCmd[3:0]));
assign OutDataGC[54][15:4] = 12'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_DIFF_1
// Address:           55
// Field Description: Enable macrocolumn analog calibrationfor the LBNL frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_55 (
    // Register is Read/Write
    .OutData(OutDataGC[55]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[55]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_DIFF_2
// Address:           56
// Field Description: Enable macrocolumn analog calibrationfor the DIFF frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_56 (
    // Register is Read/Write
    .OutData(OutDataGC[56]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[56]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_DIFF_3
// Address:           57
// Field Description: Enable macrocolumn analog calibrationfor the DIFF frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_57 (
    // Register is Read/Write
    .OutData(OutDataGC[57]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[57]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_DIFF_4
// Address:           58
// Field Description: Enable macrocolumn analog calibrationfor the DIFF frontend 
//
GCR_reg #(.WIDTH(16),.ResetValue(16'hffff) ) GCR_58 (
    // Register is Read/Write
    .OutData(OutDataGC[58]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[58]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              EN_MACRO_COL_CAL_DIFF_5
// Address:           59
// Field Description: Enable macrocolumn analog calibrationfor the DIFF frontend 
//
GCR_reg #(.WIDTH(4),.ResetValue(4'hf) ) GCR_59 (
    // Register is Read/Write
    .OutData(OutDataGC[59][3:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[59]),.InData(RegDataCmd[3:0]));
assign OutDataGC[59][15:4] = 12'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              DEBUG_CONFIG
// Address:           60
// Field Description: Output channel and driver configuration
//
GCR_reg #(.WIDTH(2),.ResetValue(2'b0) ) GCR_60 (
    // Register is Read/Write
    .OutData(OutDataGC[60][1:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[60]),.InData(RegDataCmd[1:0]));
assign OutDataGC[60][15:2] = 14'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              OUTPUT_CONFIG
// Address:           61
// Field Description: Output channel and driver configuration
//
GCR_reg #(.WIDTH(9),.ResetValue(9'b00_0_0001_00) ) GCR_61 (
    // Register is Read/Write
    .OutData(OutDataGC[61][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[61]),.InData(RegDataCmd[8:0]));
assign OutDataGC[61][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              OUT_PAD_CONFIG
// Address:           62
// Field Description: LVDS Configuration
//
GCR_reg #(.WIDTH(14),.ResetValue(14'b0_1_0_1_000_0000_100) ) GCR_62 (
    // Register is Read/Write
    .OutData(OutDataGC[62][13:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[62]),.InData(RegDataCmd[13:0]));
assign OutDataGC[62][15:14] = 2'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              GP_LVDS_ROUTE
// Address:           63
// Field Description: General Pourpose Output routing configuration
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_63 (
    // Register is Read/Write
    .OutData(OutDataGC[63]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[63]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CDR_CONFIG
// Address:           64
// Field Description: CDR Configuration
//
GCR_reg #(.WIDTH(14),.ResetValue(14'b0_00_1000_0_011_000) ) GCR_64 (
    // Register is Read/Write
    .OutData(OutDataGC[64][13:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[64]),.InData(RegDataCmd[13:0]));
assign OutDataGC[64][15:14] = 2'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CDR_VCO_BUFF_BIAS
// Address:           65
// Field Description: Bias current for VCO buffer of CDR
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd400) ) GCR_65 (
    // Register is Read/Write
    .OutData(OutDataGC[65][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[65]),.InData(RegDataCmd[9:0]));
assign OutDataGC[65][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CDR_CP_IBIAS
// Address:           66
// Field Description: Bias current for CP of CDR
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd50) ) GCR_66 (
    // Register is Read/Write
    .OutData(OutDataGC[66][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[66]),.InData(RegDataCmd[9:0]));
assign OutDataGC[66][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CDR_VCO_IBIAS
// Address:           67
// Field Description: Bias current for VCO of CDR
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd500) ) GCR_67 (
    // Register is Read/Write
    .OutData(OutDataGC[67][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[67]),.InData(RegDataCmd[9:0]));
assign OutDataGC[67][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              SER_SEL_OUT
// Address:           68
// Field Description: 20bit Serializer Output Select
//
GCR_reg #(.WIDTH(8),.ResetValue(8'b01_01_01_01) ) GCR_68 (
    // Register is Read/Write
    .OutData(OutDataGC[68][7:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[68]),.InData(RegDataCmd[7:0]));
assign OutDataGC[68][15:8] = 8'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CML_CONFIG
// Address:           69
// Field Description: 20bit Serializer Output Settings
//
GCR_reg #(.WIDTH(8),.ResetValue(8'b00_11_1111) ) GCR_69 (
    // Register is Read/Write
    .OutData(OutDataGC[69][7:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[69]),.InData(RegDataCmd[7:0]));
assign OutDataGC[69][15:8] = 8'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CML_TAP0_BIAS
// Address:           70
// Field Description: Bias current 0 for CML driver
//
GCR_reg #(.WIDTH(10),.ResetValue(10'd500) ) GCR_70 (
    // Register is Read/Write
    .OutData(OutDataGC[70][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[70]),.InData(RegDataCmd[9:0]));
assign OutDataGC[70][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CML_TAP1_BIAS
// Address:           71
// Field Description: Bias current 1 for CML driver
//
GCR_reg #(.WIDTH(10),.ResetValue(10'b0) ) GCR_71 (
    // Register is Read/Write
    .OutData(OutDataGC[71][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[71]),.InData(RegDataCmd[9:0]));
assign OutDataGC[71][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CML_TAP2_BIAS
// Address:           72
// Field Description: Bias current 2 for CML driver
//
GCR_reg #(.WIDTH(10),.ResetValue(10'b0) ) GCR_72 (
    // Register is Read/Write
    .OutData(OutDataGC[72][9:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[72]),.InData(RegDataCmd[9:0]));
assign OutDataGC[72][15:10] = 6'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AURORA_CC_CONFIG
// Address:           73
// Field Description: Aurora configuration bits
//
GCR_reg #(.WIDTH(8),.ResetValue(8'b011001_11) ) GCR_73 (
    // Register is Read/Write
    .OutData(OutDataGC[73][7:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[73]),.InData(RegDataCmd[7:0]));
assign OutDataGC[73][15:8] = 8'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AURORA_CB_CONFIG0
// Address:           74
// Field Description: Aurora Channel Bonding configuration bits
//
GCR_reg #(.WIDTH(8),.ResetValue(16'b1111_0000) ) GCR_74 (
    // Register is Read/Write
    .OutData(OutDataGC[74][7:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[74]),.InData(RegDataCmd[7:0]));
assign OutDataGC[74][15:8] = 8'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AURORA_CB_CONFIG1
// Address:           75
// Field Description: Aurora Channel Bonding configuration bits
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b1111) ) GCR_75 (
    // Register is Read/Write
    .OutData(OutDataGC[75]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[75]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AURORA_INIT_WAIT
// Address:           76
// Field Description: Aurora Init Wait
//
GCR_reg #(.WIDTH(11),.ResetValue(11'h20) ) GCR_76 (
    // Register is Read/Write
    .OutData(OutDataGC[76][10:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[76]),.InData(RegDataCmd[10:0]));
assign OutDataGC[76][15:11] = 5'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              MONITOR_SELECT
// Address:           77
// Field Description: Current and Voltage monitoring MUX selection
//
GCR_reg #(.WIDTH(14),.ResetValue(14'h1fff) ) GCR_77 (
    // Register is Read/Write
    .OutData(OutDataGC[77][13:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[77]),.InData(RegDataCmd[13:0]));
assign OutDataGC[77][15:14] = 2'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_0_MASK_SYNC
// Address:           78
// Field Description: Mask bits for the HitOr_0 for SYNC Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_78 (
    // Register is Read/Write
    .OutData(OutDataGC[78]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[78]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_1_MASK_SYNC
// Address:           79
// Field Description: Mask bits for the HitOr_1 for SYNC Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_79 (
    // Register is Read/Write
    .OutData(OutDataGC[79]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[79]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_2_MASK_SYNC
// Address:           80
// Field Description: Mask bits for the HitOr_2 for SYNC Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_80 (
    // Register is Read/Write
    .OutData(OutDataGC[80]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[80]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_3_MASK_SYNC
// Address:           81
// Field Description: Mask bits for the HitOr_3 for SYNC Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_81 (
    // Register is Read/Write
    .OutData(OutDataGC[81]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[81]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_0_MASK_LIN_0
// Address:           82
// Field Description: Mask bits for the HitOr_0 for LIN Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_82 (
    // Register is Read/Write
    .OutData(OutDataGC[82]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[82]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_0_MASK_LIN_1
// Address:           83
// Field Description: Mask bits for the HitOr_0 for LIN Front End
//
GCR_reg #(.WIDTH(1),.ResetValue(1'b0) ) GCR_83 (
    // Register is Read/Write
    .OutData(OutDataGC[83][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[83]),.InData(RegDataCmd[0]));
assign OutDataGC[83][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_1_MASK_LIN_0
// Address:           84
// Field Description: Mask bits for the HitOr_1 for LIN Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_84 (
    // Register is Read/Write
    .OutData(OutDataGC[84]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[84]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_1_MASK_LIN_1
// Address:           85
// Field Description: Mask bits for the HitOr_1 for LIN Front End
//
GCR_reg #(.WIDTH(1),.ResetValue(1'b0) ) GCR_85 (
    // Register is Read/Write
    .OutData(OutDataGC[85][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[85]),.InData(RegDataCmd[0]));
assign OutDataGC[85][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_2_MASK_LIN_0
// Address:           86
// Field Description: Mask bits for the HitOr_2 for LIN Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_86 (
    // Register is Read/Write
    .OutData(OutDataGC[86]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[86]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_2_MASK_LIN_1
// Address:           87
// Field Description: Mask bits for the HitOr_2 for LIN Front End
//
GCR_reg #(.WIDTH(1),.ResetValue(1'b0) ) GCR_87 (
    // Register is Read/Write
    .OutData(OutDataGC[87][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[87]),.InData(RegDataCmd[0]));
assign OutDataGC[87][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_3_MASK_LIN_0
// Address:           88
// Field Description: Mask bits for the HitOr_3 for LIN Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_88 (
    // Register is Read/Write
    .OutData(OutDataGC[88]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[88]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_3_MASK_LIN_1
// Address:           89
// Field Description: Mask bits for the HitOr_3 for LIN Front End
//
GCR_reg #(.WIDTH(1),.ResetValue(1'b0) ) GCR_89 (
    // Register is Read/Write
    .OutData(OutDataGC[89][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[89]),.InData(RegDataCmd[0]));
assign OutDataGC[89][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_0_MASK_DIFF_0
// Address:           90
// Field Description: Mask bits for the HitOr_0 for DIFF Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_90 (
    // Register is Read/Write
    .OutData(OutDataGC[90]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[90]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_0_MASK_DIFF_1
// Address:           91
// Field Description: Mask bits for the HitOr_0 for DIFF Front End
//
GCR_reg #(.WIDTH(1),.ResetValue(1'b0) ) GCR_91 (
    // Register is Read/Write
    .OutData(OutDataGC[91][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[91]),.InData(RegDataCmd[0]));
assign OutDataGC[91][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_1_MASK_DIFF_0
// Address:           92
// Field Description: Mask bits for the HitOr_1 for DIFF Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_92 (
    // Register is Read/Write
    .OutData(OutDataGC[92]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[92]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_1_MASK_DIFF_1
// Address:           93
// Field Description: Mask bits for the HitOr_1 for DIFF Front End
//
GCR_reg #(.WIDTH(1),.ResetValue(1'b0) ) GCR_93 (
    // Register is Read/Write
    .OutData(OutDataGC[93][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[93]),.InData(RegDataCmd[0]));
assign OutDataGC[93][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_2_MASK_DIFF_0
// Address:           94
// Field Description: Mask bits for the HitOr_2 for DIFF Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_94 (
    // Register is Read/Write
    .OutData(OutDataGC[94]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[94]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_2_MASK_DIFF_1
// Address:           95
// Field Description: Mask bits for the HitOr_2 for DIFF Front End
//
GCR_reg #(.WIDTH(1),.ResetValue(1'b0) ) GCR_95 (
    // Register is Read/Write
    .OutData(OutDataGC[95][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[95]),.InData(RegDataCmd[0]));
assign OutDataGC[95][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_3_MASK_DIFF_0
// Address:           96
// Field Description: Mask bits for the HitOr_3 for DIFF Front End
//
GCR_reg #(.WIDTH(16),.ResetValue(16'b0) ) GCR_96 (
    // Register is Read/Write
    .OutData(OutDataGC[96]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[96]),.InData(RegDataCmd));

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HITOR_3_MASK_DIFF_1
// Address:           97
// Field Description: Mask bits for the HitOr_3 for DIFF Front End
//
GCR_reg #(.WIDTH(1),.ResetValue(1'b0) ) GCR_97 (
    // Register is Read/Write
    .OutData(OutDataGC[97][0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[97]),.InData(RegDataCmd[0]));
assign OutDataGC[97][15:1] = 15'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              MONITOR_CONFIG
// Address:           98
// Field Description: ADC Band gap trimming bits, ADC trimming bits
//
GCR_reg #(.WIDTH(11),.ResetValue(16'b0) ) GCR_98 (
    // Register is Read/Write
    .OutData(OutDataGC[98][10:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[98]),.InData(RegDataCmd[10:0]));
assign OutDataGC[98][15:11] = 5'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              SENSOR_CONFIG_0
// Address:           99
// Field Description: Enable temp/rad sensors, Dynamic element matching bits, Current bias select 
//
GCR_reg #(.WIDTH(12),.ResetValue(12'b0) ) GCR_99 (
    // Register is Read/Write
    .OutData(OutDataGC[99][11:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[99]),.InData(RegDataCmd[11:0]));
assign OutDataGC[99][15:12] = 4'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              SENSOR_CONFIG_1
// Address:           100
// Field Description: Enable temp/rad sensors, Dynamic element matching bits, Current bias select 
//
GCR_reg #(.WIDTH(12),.ResetValue(12'b0) ) GCR_100 (
    // Register is Read/Write
    .OutData(OutDataGC[100][11:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[100]),.InData(RegDataCmd[11:0]));
assign OutDataGC[100][15:12] = 4'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AutoRead0
// Address:           101
// Field Description: Auto Read Register A for line 0
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd136) ) GCR_101 (
    // Register is Read/Write
    .OutData(OutDataGC[101][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[101]),.InData(RegDataCmd[8:0]));
assign OutDataGC[101][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AutoRead1
// Address:           102
// Field Description: Auto Read Register B for line 0
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd130) ) GCR_102 (
    // Register is Read/Write
    .OutData(OutDataGC[102][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[102]),.InData(RegDataCmd[8:0]));
assign OutDataGC[102][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AutoRead2
// Address:           103
// Field Description: Auto Read Register A for line 1
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd118) ) GCR_103 (
    // Register is Read/Write
    .OutData(OutDataGC[103][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[103]),.InData(RegDataCmd[8:0]));
assign OutDataGC[103][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AutoRead3
// Address:           104
// Field Description: Auto Read Register B for line 1
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd119) ) GCR_104 (
    // Register is Read/Write
    .OutData(OutDataGC[104][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[104]),.InData(RegDataCmd[8:0]));
assign OutDataGC[104][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AutoRead4
// Address:           105
// Field Description: Auto Read Register A for line 2
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd120) ) GCR_105 (
    // Register is Read/Write
    .OutData(OutDataGC[105][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[105]),.InData(RegDataCmd[8:0]));
assign OutDataGC[105][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AutoRead5
// Address:           106
// Field Description: Auto Read Register B for line 2
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd121) ) GCR_106 (
    // Register is Read/Write
    .OutData(OutDataGC[106][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[106]),.InData(RegDataCmd[8:0]));
assign OutDataGC[106][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AutoRead6
// Address:           107
// Field Description: Auto Read Register A for line 3
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd122) ) GCR_107 (
    // Register is Read/Write
    .OutData(OutDataGC[107][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[107]),.InData(RegDataCmd[8:0]));
assign OutDataGC[107][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AutoRead7
// Address:           108
// Field Description: Auto Read Register B for line 3
//
GCR_reg #(.WIDTH(9),.ResetValue(9'd123) ) GCR_108 (
    // Register is Read/Write
    .OutData(OutDataGC[108][8:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[108]),.InData(RegDataCmd[8:0]));
assign OutDataGC[108][15:9] = 7'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_ENABLE
// Address:           109
// Field Description: Enable ring oscillator
//
GCR_reg #(.WIDTH(8),.ResetValue(8'b0) ) GCR_109 (
    // Register is Read/Write
    .OutData(OutDataGC[109][7:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[109]),.InData(RegDataCmd[7:0]));
assign OutDataGC[109][15:8] = 8'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_0
// Address:           110
// Field Description: Counter value of ring oscillator #0 
//
// Register 110 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_1
// Address:           111
// Field Description: Counter value of ring oscillator #1 
//
// Register 111 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_2
// Address:           112
// Field Description: Counter value of ring oscillator #2
//
// Register 112 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_3
// Address:           113
// Field Description: Counter value of ring oscillator #3
//
// Register 113 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_4
// Address:           114
// Field Description: Counter value of ring oscillator #4
//
// Register 114 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_5
// Address:           115
// Field Description: Counter value of ring oscillator #5
//
// Register 115 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_6
// Address:           116
// Field Description: Counter value of ring oscillator #6
//
// Register 116 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              RING_OSC_7
// Address:           117
// Field Description: Counter value of ring oscillator #7
//
// Register 117 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              BCIDCnt
// Address:           118
// Field Description: Bunch counter
//
// Register 118 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              TrigCnt
// Address:           119
// Field Description: Counts all received triggers
//
// Register 119 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              LockLossCnt
// Address:           120
// Field Description: Counts the number of times the Channle Sync lost lock state
//
// Register 120 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              BitFlipWngCnt
// Address:           121
// Field Description: Counts the Bit Flip Warning messages
//
// Register 121 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              BitFlipErrCnt
// Address:           122
// Field Description: Counts the Bit Flip Error Messages
//
// Register 122 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              CmdErrCnt
// Address:           123
// Field Description: Counts Command Decoder Error messages
//
// Register 123 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              WngFifoFullCnt_0
// Address:           124
// Field Description: Counters that hold the # of Writes when fifo was full
//
// Register 124 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              WngFifoFullCnt_1
// Address:           125
// Field Description: Counters that hold the # of Writes when fifo was full
//
// Register 125 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              WngFifoFullCnt_2
// Address:           126
// Field Description: Counters that hold the # of Writes when fifo was full
//
// Register 126 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              WngFifoFullCnt_3
// Address:           127
// Field Description: Counters that hold the # of Writes when fifo was full
//
// Register 127 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AI_REGION_COL
// Address:           128
// Field Description: Allows to read the Auto Increment Column value
//
// Register 128 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              AI_REGION_ROW
// Address:           129
// Field Description: Allows to read the Auto Increment Row value
//
// Register 129 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HitOr_0_Cnt
// Address:           130
// Field Description: HitOr_0 Counter
//
// Register 130 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HitOr_1_Cnt
// Address:           131
// Field Description: HitOr_1 Counter
//
// Register 131 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HitOr_2_Cnt
// Address:           132
// Field Description: HitOr_2 Counter
//
// Register 132 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              HitOr_3_Cnt
// Address:           133
// Field Description: HitOr_3 Counter
//
// Register 133 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              SkippedTriggerCnt
// Address:           134
// Field Description: Skipped Trigger counter
//
// Register 134 is not a real register, read directly values from bus.

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              ErrWngMask
// Address:           135
// Field Description: Mask single Error Warning messages
//
GCR_reg #(.WIDTH(14),.ResetValue(14'b0) ) GCR_135 (
    // Register is Read/Write
    .OutData(OutDataGC[135][13:0]), .Clk(ClkCmd), .Reset_b(GC_Reset_Async_b),.Wr(WrGC[135]),.InData(RegDataCmd[13:0]));
assign OutDataGC[135][15:14] = 2'b0; // Assign most significant bits to zero

//
// ---------------------------------------------------------------------------------------------------------------------
// Name:              MonitoringDataADC
// Address:           136
// Field Description: Contains the value of the ADC to be read back
//
// Register 136 is not a real register, read directly values from bus.

//
