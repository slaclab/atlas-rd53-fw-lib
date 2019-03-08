//----------------------------------------------------------------------------------------------------------------------
// [Filename]       GlobalConfiguration.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Roberto Beccherle - Roberto.Beccherle@cern.ch
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        15/02/2017
// [Description]    Global configuration for the chip
//                  It also includes autoincrement
//
// [Clock]          - ClkCmd is the 160 MHz clock
//                  - ClkBx  is the  40 MHz clock
// [Reset]          - GC_Reset_Async_b (Asynchronous active low) used to set Configuration Register to its default values
//                                                               The ONLY way to reset Global Configuration Registers is
//                                                               using POR or overwriting the register values!
//                  - GC_Reset_b       ( Synchronous active low) for all other uses
// 
// [Change history] 02/03/2017 - Version 1.0
//                             Initial release
//                  03/03/2017 - Version 1.1
//                             Made the reset asynchronous and active low
//----------------------------------------------------------------------------------------------------------------------
//
// [Dependencies]
//
// $RTL_DIR/eoc/gcr/GCR_Assigns.sv
// $RTL_DIR/eoc/gcr/GCR_Regs.sv
//----------------------------------------------------------------------------------------------------------------------


`ifndef GLOBALCONFIGURATION_SV 
`define GLOBALCONFIGURATION_SV

module GlobalConfiguration(
    // Inputs
    input  wire             ClkCmd,             // 160 MHz clock
    input  wire             GC_Reset_Async_b,   // Asynchronous reset active low (Just for Global Configuration Registers)
    input  wire             GC_Reset_b,         // Synchronous reset active low

    input  wire             WrRegCmd,           // We have to write data to a register
    input  wire             RdRegCmd,           // We have to read back a value
    input  wire       [8:0] RegAddrCmd,         // Address of the register
    input  wire      [15:0] RegDataCmd,         // Data to be written
    input  wire       [7:0] DataConfRd,         // Data to be read from the Pixels
    //
    input  wire      [15:0] RING_OSC_0,         // Counter value of ring oscillator #0 
    input  wire      [15:0] RING_OSC_1,         // Counter value of ring oscillator #1 
    input  wire      [15:0] RING_OSC_2,         // Counter value of ring oscillator #2
    input  wire      [15:0] RING_OSC_3,         // Counter value of ring oscillator #3
    input  wire      [15:0] RING_OSC_4,         // Counter value of ring oscillator #4
    input  wire      [15:0] RING_OSC_5,         // Counter value of ring oscillator #5
    input  wire      [15:0] RING_OSC_6,         // Counter value of ring oscillator #6
    input  wire      [15:0] RING_OSC_7,         // Counter value of ring oscillator #7
    //
    input  wire      [15:0] BCIDCnt,            // BCID counter value     [from Command Decoder]
    input  wire      [15:0] TrigCnt,            // Trigger counter value  [from Command Decoder]
    input  wire      [15:0] LockLossCnt,        // LockLossCnt counter value [from Channel Synchronizer]
    input  wire      [15:0] BitFlipWngCnt,      // BitFlipWngCnt counter value [from Command Decoder]
    input  wire      [15:0] BitFlipErrCnt,      // BitFlipErrCnt counter value [from Command Decoder]
    input  wire      [15:0] CmdErrCnt,          // CmdErrCnt counter value [from Command Decoder]
    input  wire      [11:0] MonitoringDataADC,  // Contains the value of the DAC to be read back
    input  wire      [15:0] SkippedTriggerCnt,  // Skipped Trigger counter
    input  wire  [7:0][7:0] WngFifoFullCnt,     // Counters that hold the # of Writes when fifo was full
    // From the Pixel Region
    input  wire       [3:0] HitOr,              // HitOr bus to be counted here [signals are synchronized in DCB]
    //
    // Outputs
    // Pixel read/write configuration 
    output logic     [11:0] AddressConfCore,    // Where, inside the core, we have to write data
    output logic      [5:0] AddressConfCol,     // In which column we have to write data
    output logic      [7:0] DataConfWr,         // Data to be written it the pixel   
    output logic            ConfWr,             // There is some data to be written
    //
    output logic            DefaultPixelConf,   // Pixel Default Configuration XXXXX not connected XXXXX
    //
    // Outputs coming from GCR register values
    output wire     [2:0]   EnCoreColBroadcast, // Broadcast bit for each Front End
    output wire             WrRingOscCntRst,    // Reset signal for the Ring Oscillator counters (one for all)
    //
    // To Monitoring 
    output logic             NewRegData,        // There is new data to store in the monitor Fifo
    output logic             LoadDataMaskRst_b, // Reset (Synchronous Active low) for LoadDataMask
    output logic      [25:0] RegData,           // Data coming from a Rd Register [To Monitor Fifo]
    output logic [7:0][25:0] AutoReadData,      // Auto Read Registers
//
// Pixel Matrix Section
//
    // SYNC Front End
    output wire       [9:0] IBIASP1_SYNC,       //  Current of the main branch of the CSA
    output wire       [9:0] IBIASP2_SYNC,       //  Current of the splitting branch of the CSA
    output wire       [9:0] IBIAS_SF_SYNC,      //  Current of the preamplifier SF
    output wire       [9:0] IBIAS_KRUM_SYNC,    //  Current of the Krummenacher feedback
    output wire       [9:0] IBIAS_DISC_SYNC,    //  Current of the Comparator Diff Amp
    output wire       [9:0] ICTRL_SYNCT_SYNC,   //  Current of the oscillator delay line
    output wire       [9:0] VBL_SYNC,           // Baseline voltage for offset compens
    output wire       [9:0] VTH_SYNC,           // Discriminator threshold voltage
    output wire       [9:0] VREF_KRUM_SYNC,     // Krummenacher voltage reference
    output wire             SelC2F_SYNC,        // Connect to SYNC Front End
    output wire             SelC4F_SYNC,        // Connect to SYNC Front End
    output wire             FastEn_SYNC,        // Connect to SYNC Front End
    output wire       [1:0] AutoZeroMode_SYNC,  // Configuration for Sync Front End
    // LIN Front End
    output wire       [9:0] PA_IN_BIAS_LIN,     // preampli input branch current
    output wire       [9:0] FC_BIAS_LIN,        // folded cascode branch current
    output wire       [9:0] KRUM_CURR_LIN,      // Krummenacher current
    output wire       [9:0] LDAC_LIN,           // fine threshold
    output wire       [9:0] COMP_LIN,           // Comparator current
    output wire       [9:0] REF_KRUM_LIN,       // Krummenacher reference voltage
    output wire       [9:0] Vthreshold_LIN,     // Global threshold voltage
    // DIFF Front End
    output wire       [9:0] PRMP_DIFF,          // Preamp input stage current
    output wire       [9:0] FOL_DIFF,           // Preamp output follower current
    output wire       [9:0] PRECOMP_DIFF,       // Precomparator tail current
    output wire       [9:0] COMP_DIFF,          // Comparator total current
    output wire       [9:0] VFF_DIFF,           // Preamp feedback current (return to baseline)
    output wire       [9:0] VTH1_DIFF,          // Negative branch voltage offset (vth1)
    output wire       [9:0] VTH2_DIFF,          // Positive branch voltage offset (vth2)
    output wire       [9:0] LCC_DIFF,           // Leakage current compensation current
    output wire             LCC_X_DIFF,         // Connect leakace current comp. circuit
    output wire             FF_CAP_DIFF,        // Select preamp feedback capacitance
//
// Power Section
//
    output wire       [4:0] SLDOAnalogTrim,     // Analog and Digital voltage regulator trim
    output wire       [4:0] SLDODigitalTrim,    // Analog and Digital voltage regulator trim
// 
// Digital Matrix Section
//
    output wire      [15:0] EN_CORE_COL_SYNC,   // Disable Core (SYNC Front End)
    output wire      [16:0] EN_CORE_COL_LIN,    // Disable Core (LIN Front End)
    output wire      [16:0] EN_CORE_COL_DIFF,   // Disable Core (DIFF Front End)
    output wire       [8:0] LATENCY_CONFIG,     // Latency Configuration
    output wire       [4:0] WR_SYNC_DELAY_SYNC, // Write Synchronization delay (SYNC)
//
// Functions Section
//
    // output wire       [3:0] EnSelfTrigger,          // Enable Self Triggering [to PixelArray]
    output wire             AnalogInjectionMode,    // Analog injection mode
    output wire             DigitalInjectionEnable, // Digital injection enable
    output wire       [3:0] InjectionFineDelay,     // Injection fine delay
    output wire             SelClkPhase,            // Clock phase selection
    output wire       [3:0] ClkFineDelay,           // Clock fine delay
    output wire       [3:0] DataFineDelay,          // Data fine delay
    output wire      [11:0] VCAL_HIGH,              // VCAL high
    output wire      [11:0] VCAL_MED,               // VCAL med
    output wire       [1:0] ChSyncPhaseAdj,         // Threshold and Phase adjust settings for the Channel Synchronizer
    output wire       [4:0] ChSyncLockThr,          // Threshold and Phase adjust settings for the Channel Synchronizer
    output wire       [4:0] ChSyncUnlockThr,        // Threshold and Phase adjust settings for the Channel Synchronizer
    output wire      [15:0] GLOBAL_PULSE_ROUTE,     // Global pulse routing select
    output wire       [7:0] MONITOR_FRAME_SKIP,     // How many Data frames to skip before sending a Monitor Frame
    output wire      [63:0] EN_MACRO_COL_CAL_SYNC,  // Enable macrocolumn analog calibrationfor the SYNC frontend 
    output wire      [67:0] EN_MACRO_COL_CAL_LIN,   // Enable macrocolumn analog calibrationfor the LIN frontend 
    output wire      [67:0] EN_MACRO_COL_CAL_DIFF,  // Enable macrocolumn analog calibrationfor the DIFF frontend 
//
// I/O Section
//
    output wire             EnableExtCal,           // Output channel and driver configuration
    output wire             EnablePRBS,             // Output channel and driver configuration
    output wire             SelSerializerType,      // Output channel and driver configuration
    output wire       [1:0] DataReadDelay,          // Output channel and driver configuration
    output wire       [3:0] ActiveLanes,            // Output channel and driver configuration
    output wire       [1:0] OutputFormat,           // Output format: hdr, tag, hdr+tag, compressed
    output wire             JTAG_TDO_DS,            // LVDS Configuration
    output wire             STATUS_EN,              // LVDS Configuration
    output wire             STATUS_DS,              // LVDS Configuration
    output wire             LANE0_LVDS_EN_B,        // LVDS Configuration
    output wire       [2:0] LANE0_LVDS_BIAS,        // LVDS Configuration
    output wire       [3:0] GP_LVDS_EN_B,           // LVDS Configuration
    output wire       [2:0] GP_LVDS_BIAS,           // LVDS Configuration
    output wire      [15:0] GP_LVDS_ROUTE,          // General Pourpose Output routing configuration
    output wire             CDR_SEL_DEL_CLK,        // CDR Configuration
    output wire       [1:0] CDR_PD_SEL,             // CDR Configuration
    output wire       [3:0] CDR_PD_DEL,             // CDR Configuration
    output wire             CDR_EN_GCK2,            // CDR Configuration
    output wire       [2:0] CDR_VCO_GAIN,           // CDR Configuration
    output wire       [2:0] CDR_SEL_SER_CLK,        // CDR Configuration
    output wire       [9:0] CDR_VCO_BUFF_BIAS,      // Bias current for VCO buffer of CDR
    output wire       [9:0] CDR_CP_IBIAS,           // Bias current for CP of CDR
    output wire       [9:0] CDR_VCO_IBIAS,          // Bias current for VCO of CDR
    output wire       [1:0] SerSelOut3,             // 20bit Serializer Output Select
    output wire       [1:0] SerSelOut2,             // 20bit Serializer Output Select
    output wire       [1:0] SerSelOut1,             // 20bit Serializer Output Select
    output wire       [1:0] SerSelOut0,             // 20bit Serializer Output Select
    output wire       [1:0] SER_INV_TAP,            // 20bit Serializer Output Settings
    output wire       [1:0] SER_EN_TAP,             // 20bit Serializer Output Settings
    output wire       [3:0] CML_EN_LANE,            // 20bit Serializer Output Settings
    output wire       [9:0] CML_TAP0_BIAS,          // Bias current 0 for CML driver
    output wire       [9:0] CML_TAP1_BIAS,          // Bias current 1 for CML driver
    output wire       [9:0] CML_TAP2_BIAS,          // Bias current 2 for CML driver
    output wire       [5:0] CCWait,                 // Aurora Clock Compensation configuration bits
    output wire       [1:0] CCSend,                 // Aurora Clock Compensation configuration bits
    output wire      [19:0] CBWait,                 // Aurora Channel Bonding configuration bits
    output wire       [3:0] CBSend,                 // Aurora Channel Bonding configuration bits
    output wire      [10:0] AURORA_INIT_WAIT,       // Aurora Init Wait
//
// Test Section
//
    output wire             MonitorEnable,          // Enable Monitoring block
    output wire      [63:0] V_MONITOR_SELECT,       // Voltage monitoring MUX selection
    output wire      [31:0] I_MONITOR_SELECT,       // Current monitoring MUX selection
    output wire [3:0][49:0] HITOR_MASK,             // Mask bits for the HitOr
    output wire       [4:0] MON_BG_TRIM,            // ADC Band gap trimming bits
    output wire       [5:0] MON_ADC_TRIM,           // ADC trimming bits
    output wire       [3:0] SENS_DEM0,              // Dynamic element matching bits
    output wire             SEN_SEL_BIAS0,          // Current bias select 
    output wire             SEN_SEL_BIAS1,          // Current bias select 
    output wire             SEN_SEL_BIAS2,          // Current bias select 
    output wire             SEN_SEL_BIAS3,          // Current bias select 
    output wire             SENS_ENABLE0,           // Enable temp/rad sensors
    output wire             SENS_ENABLE1,           // Enable temp/rad sensors
    output wire             SENS_ENABLE2,           // Enable temp/rad sensors
    output wire             SENS_ENABLE3,           // Enable temp/rad sensors
    output wire       [3:0] SENS_DEM1,              // Dynamic element matching bits
    output wire       [3:0] SENS_DEM2,              // Dynamic element matching bits
    output wire       [3:0] SENS_DEM3,              // Dynamic element matching bits
    output wire       [7:0] RING_OSC_ENABLE,        // Enable Ring Oscillator
//
// Diagnostics Section
//
    output wire          WrBCIDCntRst,              // Resets the BCID Counter              [in Command Decoder]
    output wire          WrTrigCntRst,              // Resets the Trigger Counter           [in Command Decoder]
    output wire          WrLockLossCntRst,          // Resets the Lock Loss Counter         [in Channel Syncronizer]
    output wire          WrCmdErrCntRst,            // Resets the Error Counter             [in Command Decoder]
    output wire          WrBitFlipWngCntRst,        // Resets the Bit Flip Warning Counter  [in Command Decoder]
    output wire          WrBitFlipErrCntRst,        // Resets the Bit Flip Error Counter    [in Command Decoder]
    output wire          WrMonitoringDataADCRst,    // Resets the Monitoring ADC            [in Analog Chip Bottom]
    output wire          WrSkippedTriggerCntRst,    // Resets the Skipped Trigger Counter   [in Pixel Array]
    output wire   [13:0] ErrWngMask,                // Mask single Error Warning messages   [to Monitor Data]
    output wire    [3:0] WrWngFifoFullCntRst,       // Reset for the WngFifoFullCnt counter [in Monitor Data]
    // remove this one
    output wire          LastOne // To be removed
    ); 

//
// Local signal definition
//

//TODO: All configuration should got to RD53A_defines.sv file as structure
localparam CONF_REG_ADDR_WIDTH = 9   ;
localparam CONF_REG_DATA_WIDTH = 16  ;
localparam            GCR_SIZE = 137 ; 
localparam                COLS = 50  ;
localparam                ROWS = 48  ;
localparam             REGIONS = 4*4 ;
localparam          REG_PIXELS = 4   ;
// localparam           SYNC_COLS = 16  ; // Number of columns of SYNC FE flavour
// localparam            LIN_COLS = 17  ; // Number of columns of  LIN FE flavour
// localparam           DIFF_COLS = 17  ; // Number of columns of DIFF FE flavour

/* */
// generate
//     genvar conf_inx;
//     for (conf_inx=0; conf_inx<CONF_REG_SIZE; conf_inx=conf_inx+1)
//     begin: global_conf_gen
//         always_ff@(posedge ClkCmd) begin
//             if(WrRegCmd && RegAddrCmd==conf_inx)
//                 GlobalConf[(conf_inx+1)*CONF_REG_WIDTH-1:conf_inx*CONF_REG_WIDTH] <= RegDataCmd;
//         end
//     end // global_conf_gen
// endgenerate
//
//            ##                         ##                                     ##
//  #####     ##                         ##                ####                 ##
// ##   ##    ##                         ##               ##  ##                ##
// ##       ######    ######  ## ###   ######            ##        #####    ######   #####
//  #####     ##     ##   ##  ###        ##              ##       ##   ##  ##   ##  ##   ##
//      ##    ##     ##   ##  ##         ##              ##       ##   ##  ##   ##  #######
// ##   ##    ##     ##  ###  ##         ##               ##  ##  ##   ##  ##   ##  ##
//  #####      ###    ### ##  ##          ###              ####    #####    ######   #####
//
// Pixel Global Configuration
// Numbering scheme sterts from top left (0,0) to (49,47)
// CoreCol[5:0] from 0 to 49
// CoreRow[5:0] from 0 to 47
// With these two registers you address a single Core
// Each core has 16 Regions that are addressed by 
// RegionInCoreCol[0] and RegionInCoreRow[2:0]
// and again starts from top left (0,0) to (1,7)
// Each Region has a PixelPair[0] address 
// that allows to distinguish between Left (0) and Right (1)
//
// AutoIncrement has 3 possible modes:          AutoIncrementMode[1:0]
// 0 - No AutoIncrement
// 1 - Auto Increment Region Colums [8 bit]     From 0 to 50*4 - 1
// 2 - Auto Increment Region Rows   [9 bit]     From 0 to 48*8 - 1
// 3 - Auto Increment PixelPairs   [17 bit]     Not implemented
// Auto increment can start from any value and will wrap around
//

//
// Registers used to configure Pixels
logic [7:0] REGION_COL;     // Global Configuration register for columns 
logic [8:0] REGION_ROW;     // Global Configuration register for rows 
logic [7:0] AI_REGION_COL;  // Global Configuration register for reading back ai columns counter 
logic [8:0] AI_REGION_ROW;  // Global Configuration register for reading back ai rows counter 
logic [7:0] AIRegionCol;    // used for Auto Increment
logic [8:0] AIRegionRow;    // used for Auto Increment
//
// registers used internally to address Cores and PixelPairs inside a Core
logic [5:0] CoreCol;
logic [5:0] CoreRow;
logic       RegionInCoreCol;
logic [2:0] RegionInCoreRow;
logic       PixelPair;
logic [1:0] AutoIncrementMode;
logic       RdPixelConf, WrPixelConf, RdWrPixelConf;
logic       ACCZero;
//
// Registers to read/write Global Configuration Registers
logic [15:0] OutDataGC[GCR_SIZE-1:1]; // OutDataGC[0] is not a real register 
logic [GCR_SIZE-1:0] WrGC;
logic [GCR_SIZE-1:0] RdGC;
//
// Contains configuration data read out from Pixel matrix
logic [15:0] PixDataRd;
//
// Combinatorial logic to be synchronized
logic [15:0] RegDataRd;
logic  [8:0] RegDataRdAddr;
logic        AddrFlag;
//
// Some Global Configuration Registers
logic [15:0] EN_MACRO_COL_CAL_SYNC_1, EN_MACRO_COL_CAL_SYNC_2, EN_MACRO_COL_CAL_SYNC_3, EN_MACRO_COL_CAL_SYNC_4 ;
logic [15:0] EN_MACRO_COL_CAL_LIN_1, EN_MACRO_COL_CAL_LIN_2, EN_MACRO_COL_CAL_LIN_3, EN_MACRO_COL_CAL_LIN_4 ;
logic  [3:0] EN_MACRO_COL_CAL_LIN_5 ; 
logic [15:0] EN_MACRO_COL_CAL_DIFF_1, EN_MACRO_COL_CAL_DIFF_2, EN_MACRO_COL_CAL_DIFF_3, EN_MACRO_COL_CAL_DIFF_4 ;
logic  [3:0] EN_MACRO_COL_CAL_DIFF_5 ;
logic [15:0] EN_CORE_COL_LIN_1 ;
logic        EN_CORE_COL_LIN_2 ;
logic [15:0] EN_CORE_COL_DIFF_1 ;
logic        EN_CORE_COL_DIFF_2 ;
logic [15:0] HITOR_0_MASK_SYNC;   // Mask bits for the HitOr_0 for SYNC Front End
logic [15:0] HITOR_1_MASK_SYNC;   // Mask bits for the HitOr_1 for SYNC Front End
logic [15:0] HITOR_2_MASK_SYNC;   // Mask bits for the HitOr_2 for SYNC Front End
logic [15:0] HITOR_3_MASK_SYNC;   // Mask bits for the HitOr_3 for SYNC Front End
logic [15:0] HITOR_0_MASK_LIN_0;  // Mask bits for the HitOr_0 for LIN Front End
logic        HITOR_0_MASK_LIN_1;  // Mask bits for the HitOr_0 for LIN Front End
logic [15:0] HITOR_1_MASK_LIN_0;  // Mask bits for the HitOr_1 for LIN Front End
logic        HITOR_1_MASK_LIN_1;  // Mask bits for the HitOr_1 for LIN Front End
logic [15:0] HITOR_2_MASK_LIN_0;  // Mask bits for the HitOr_2 for LIN Front End
logic        HITOR_2_MASK_LIN_1;  // Mask bits for the HitOr_2 for LIN Front End
logic [15:0] HITOR_3_MASK_LIN_0;  // Mask bits for the HitOr_3 for LIN Front End
logic        HITOR_3_MASK_LIN_1;  // Mask bits for the HitOr_3 for LIN Front End
logic [15:0] HITOR_0_MASK_DIFF_0; // Mask bits for the HitOr_0 for DIFF Front End
logic        HITOR_0_MASK_DIFF_1; // Mask bits for the HitOr_0 for DIFF Front End
logic [15:0] HITOR_1_MASK_DIFF_0; // Mask bits for the HitOr_1 for DIFF Front End
logic        HITOR_1_MASK_DIFF_1; // Mask bits for the HitOr_1 for DIFF Front End
logic [15:0] HITOR_2_MASK_DIFF_0; // Mask bits for the HitOr_2 for DIFF Front End
logic        HITOR_2_MASK_DIFF_1; // Mask bits for the HitOr_2 for DIFF Front End
logic [15:0] HITOR_3_MASK_DIFF_0; // Mask bits for the HitOr_3 for DIFF Front End
logic        HITOR_3_MASK_DIFF_1; // Mask bits for the HitOr_3 for DIFF Front End
logic  [6:0] VMonitor;
logic  [5:0] IMonitor;
logic [15:0] PIX_DEFAULT_CONFIG;
//
// Hit Or
logic [15:0] HitOr_0_Cnt;
logic [15:0] HitOr_1_Cnt;
logic [15:0] HitOr_2_Cnt;
logic [15:0] HitOr_3_Cnt;
logic [3:0][15:0] HitOrCnt; // 4 HitOr counters
wire         WrHitOr_0_CntRst;      // Resets the HitOr_0 counter 
wire         WrHitOr_1_CntRst;      // Resets the HitOr_1 counter
wire         WrHitOr_2_CntRst;      // Resets the HitOr_2 counter
wire         WrHitOr_3_CntRst;      // Resets the HitOr_3 counter
                                    // Bus that holds all HitOr resets
wire      [3:0] WrHitOrCntRst = {WrHitOr_3_CntRst, WrHitOr_2_CntRst, WrHitOr_1_CntRst, WrHitOr_0_CntRst};
//
// Auto Read
wire      [8:0] AutoRead0;         //  Auto Read Register line 0 (Address pointed by AutoRead0)
wire      [8:0] AutoRead1;         //  Auto Read Register line 0 (Address pointed by AutoRead1)
wire      [8:0] AutoRead2;         //  Auto Read Register line 1 (Address pointed by AutoRead2)
wire      [8:0] AutoRead3;         //  Auto Read Register line 1 (Address pointed by AutoRead3)
wire      [8:0] AutoRead4;         //  Auto Read Register line 2 (Address pointed by AutoRead4)
wire      [8:0] AutoRead5;         //  Auto Read Register line 2 (Address pointed by AutoRead5)
wire      [8:0] AutoRead6;         //  Auto Read Register line 3 (Address pointed by AutoRead6)
wire      [8:0] AutoRead7;         //  Auto Read Register line 3 (Address pointed by AutoRead7)
wire [7:0][8:0] AutoRead = {AutoRead7, AutoRead6, AutoRead5, AutoRead4, AutoRead3, AutoRead2, AutoRead1, AutoRead0};
//
// WngFifoFullCnt
//
logic [15:0] WngFifoFullCnt_0;    // 2 8bit counters merged in one 16bit counter
logic [15:0] WngFifoFullCnt_1;    // 2 8bit counters merged in one 16bit counter
logic [15:0] WngFifoFullCnt_2;    // 2 8bit counters merged in one 16bit counter
logic [15:0] WngFifoFullCnt_3;    // 2 8bit counters merged in one 16bit counter
// WrWngFifoFullCntRst 
wire         WrWngFifoFullCnt_0Rst, WrWngFifoFullCnt_1Rst, WrWngFifoFullCnt_2Rst, WrWngFifoFullCnt_3Rst;

//----------------------------------------------------------------------------------------------------------------------
//                                                                  ##
//   ####     ####   ######              ##                         ##
//  ##  ##   ##  ##  ##   ##             ##
// ##       ##       ##   ##            ####     #####    #####   ####      ######  ## ###    #####
// ##       ##       ######             ## #    ##       ##         ##     ##   ##  ###  ##  ##
// ##  ###  ##       ## ##             ######    ####     ####      ##     ##   ##  ##   ##   ####
//  ##  ##   ##  ##  ##  ##            ##   #       ##       ##     ##     ##   ##  ##   ##      ##
//   #####    ####   ##   ##          ###   ##  #####    #####    ######    ######  ##   ##  #####
//                                                                              ##
//                                                                          #####
//----------------------------------------------------------------------------------------------------------------------
// Assign values from Global Configuration Register
logic WrRING_OSC_0Rst, WrRING_OSC_1Rst, WrRING_OSC_2Rst, WrRING_OSC_3Rst,
      WrRING_OSC_4Rst, WrRING_OSC_5Rst, WrRING_OSC_6Rst, WrRING_OSC_7Rst;
logic WrOUTPUT_CONFIGRst; 
     
`include "eoc/gcr/GCR_Assigns.sv"

//
//----------------------------------------------------------------------------------------------------------------------
// 
// Combine EN_MACRO_COL_CAL_SYNC, EN_MACRO_COL_CAL_LIN, EN_MACRO_COL_CAL_DIFF
assign EN_MACRO_COL_CAL_SYNC[63:0] = { EN_MACRO_COL_CAL_SYNC_4,EN_MACRO_COL_CAL_SYNC_3,
                                       EN_MACRO_COL_CAL_SYNC_2,EN_MACRO_COL_CAL_SYNC_1};
assign  EN_MACRO_COL_CAL_LIN[67:0] = { EN_MACRO_COL_CAL_LIN_5,EN_MACRO_COL_CAL_LIN_4,
                                       EN_MACRO_COL_CAL_LIN_3,EN_MACRO_COL_CAL_LIN_2,EN_MACRO_COL_CAL_LIN_1};
assign EN_MACRO_COL_CAL_DIFF[67:0] = { EN_MACRO_COL_CAL_DIFF_5,EN_MACRO_COL_CAL_DIFF_4,
                                       EN_MACRO_COL_CAL_DIFF_3,EN_MACRO_COL_CAL_DIFF_2,EN_MACRO_COL_CAL_DIFF_1};
//
// Combine HITOR_MASKS
assign HITOR_MASK[3][49:0] = { HITOR_3_MASK_DIFF_1, HITOR_3_MASK_DIFF_0, HITOR_3_MASK_LIN_1, HITOR_3_MASK_LIN_0, 
                               HITOR_3_MASK_SYNC };
assign HITOR_MASK[2][49:0] = { HITOR_2_MASK_DIFF_1, HITOR_2_MASK_DIFF_0, HITOR_2_MASK_LIN_1, HITOR_2_MASK_LIN_0, 
                               HITOR_2_MASK_SYNC };
assign HITOR_MASK[1][49:0] = { HITOR_1_MASK_DIFF_1, HITOR_1_MASK_DIFF_0, HITOR_1_MASK_LIN_1, HITOR_1_MASK_LIN_0, 
                               HITOR_1_MASK_SYNC };
assign HITOR_MASK[0][49:0] = { HITOR_0_MASK_DIFF_1, HITOR_0_MASK_DIFF_0, HITOR_0_MASK_LIN_1, HITOR_0_MASK_LIN_0, 
                               HITOR_0_MASK_SYNC };
//
// Combine EN_CORE_COL_LIN
assign EN_CORE_COL_LIN[16:0] = { EN_CORE_COL_LIN_2, EN_CORE_COL_LIN_1[15:0]};
//
// Combine EN_CORE_COL_DIFF
assign EN_CORE_COL_DIFF[16:0] = { EN_CORE_COL_DIFF_2, EN_CORE_COL_DIFF_1[15:0]};
//
// IBIAS registers are one bit shorter
assign     IBIASP1_SYNC[9] = 1'b0;
assign     IBIASP2_SYNC[9] = 1'b0;
assign IBIAS_DISC_SYNC [9] = 1'b0;
assign IBIAS_KRUM_SYNC [9] = 1'b0;
assign   IBIAS_SF_SYNC [9] = 1'b0;
//
// Some bits are tied down to 0
assign   PA_IN_BIAS_LIN[9] = 1'b0;
assign    FC_BIAS_LIN[9:8] = 2'b0;
assign    KRUM_CURR_LIN[9] = 1'b0;
assign         COMP_LIN[9] = 1'b0;
//
// HitOr_X_Cnt output registers 
assign HitOr_0_Cnt = HitOrCnt[0];
assign HitOr_1_Cnt = HitOrCnt[1];
assign HitOr_2_Cnt = HitOrCnt[2];
assign HitOr_3_Cnt = HitOrCnt[3];
//
// Signal active if one ot the Ring Oscillator resets is active
assign WrRingOscCntRst = {WrRING_OSC_7Rst| WrRING_OSC_6Rst| WrRING_OSC_5Rst| WrRING_OSC_4Rst|
                          WrRING_OSC_3Rst| WrRING_OSC_2Rst| WrRING_OSC_1Rst| WrRING_OSC_0Rst| ~GC_Reset_b };  
//
// WngFifoFullCnt
assign WngFifoFullCnt_0 = {WngFifoFullCnt[1], WngFifoFullCnt[0]}; // 2 8bit counters merged in one 16bit counter
assign WngFifoFullCnt_1 = {WngFifoFullCnt[3], WngFifoFullCnt[2]}; // 2 8bit counters merged in one 16bit counter
assign WngFifoFullCnt_2 = {WngFifoFullCnt[5], WngFifoFullCnt[4]}; // 2 8bit counters merged in one 16bit counter
assign WngFifoFullCnt_3 = {WngFifoFullCnt[7], WngFifoFullCnt[6]}; // 2 8bit counters merged in one 16bit counter
// Reset for the WngFifoFullCnt counter
assign WrWngFifoFullCntRst = {WrWngFifoFullCnt_3Rst, WrWngFifoFullCnt_2Rst, WrWngFifoFullCnt_1Rst, WrWngFifoFullCnt_0Rst};

//
// Reset for LoadDataMaskRst_b : It is delayed by two clock cycles
//
logic LoadDataMaskRstDly_b;
//
always_ff @(posedge ClkCmd) begin : Dly_AFF
        {LoadDataMaskRst_b,LoadDataMaskRstDly_b} <= {LoadDataMaskRstDly_b,~(WrOUTPUT_CONFIGRst | ~GC_Reset_b)};
    end

//----------------------------------------------------------------------------------------------------------------------
//
// Combinatorial logic

assign AI_REGION_COL = AIRegionCol;
assign AI_REGION_ROW = AIRegionRow;
// 
// Calculate MONITOR settings (one active a time, or all zero)
//           to obtain all zero IMonitor has to be >= 32 and VMonitor >= 64
assign {V_MONITOR_SELECT[63:0]} = (1'b1 << VMonitor);       // V_MONITOR_SELECT goes from 001, 010, 110 ..., 000
assign {I_MONITOR_SELECT[31:0]} = (1'b1 << IMonitor);       // I_MONITOR_SELECT goes from 001, 010, 110 ..., 000

//
// Pixel Global Configuration Default values (Only if 16'h9ce2 is  matched we generate a DefaultPixelConf signal)
assign DefaultPixelConf = (PIX_DEFAULT_CONFIG == 16'h9ce2) ? 1'b1 : 1'b0;

//
// Write and Read signals for the Global configuration Register
// Only one bit is set at a time
//
always_ff @(posedge ClkCmd) begin : RdWrGC_AFF
    if(GC_Reset_b == 1'b0) begin
        RdGC <= 0;
        WrGC <= 0;
    end else begin
        WrGC <= (1'b1 << RegAddrCmd) & {GCR_SIZE{WrRegCmd}} ; // Write Global Configuration
        RdGC <= (1'b1 << RegAddrCmd) & {GCR_SIZE{RdRegCmd}} ; // Read  Global Configuration
    end
end : RdWrGC_AFF

//----------------------------------------------------------------------------------------------------------------------
//
//                      ##                                                            
//    ##                ##                       ######                               
//    ##                ##                         ##                                 
//   ####    ##   ##  ######    #####              ##     ## ###    #####   ## ###  
//   ## #    ##   ##    ##     ##   ##             ##     ###  ##  ##       ###     
//  ######   ##   ##    ##     ##   ##             ##     ##   ##  ##       ##      
//  ##   #   ##  ###    ##     ##   ##             ##     ##   ##  ##       ##      ##
// ###   ##   ### ##     ###    #####            ######   ##   ##   #####   ##      ##
//
// Mapping between pixel configuration registers and core addressing
assign CoreCol         = AIRegionCol[7:2];
assign RegionInCoreCol = AIRegionCol[1];
assign PixelPair       = AIRegionCol[0];
assign CoreRow         = AIRegionRow[8:3];
assign RegionInCoreRow = AIRegionRow[2:0];

//
// Assign Output addresses
//
//           [5:0]          [5:0]
assign AddressConfCol  = CoreCol;
//          [11:0]          [5:0],          [2:0],            [0],      [0],    [0]    
assign AddressConfCore = {CoreRow,RegionInCoreRow,RegionInCoreCol,PixelPair,ACCZero}; // {6,3,1,1,1} = 12

logic WrRegCol, WrRegRow;
// assign    WrRegCol = WrGC[1]; // #1 RegionCol, Copy register value on WrReg command 
// assign    WrRegRow = WrGC[2]; // #2 RegionRow, Copy register value on WrReg command 
// Signals to copy REGION_COL and REGION_ROW in the autoincrement regs
// logic CopyRegCol, CopyRegRow, WrAI_REGION_COLRst, WrAI_REGION_ROWRst;
// assign CopyRegCol = (WrAI_REGION_COLRst | WrRegCol);
// assign CopyRegRow = (WrAI_REGION_ROWRst | WrRegRow);
logic CopyRegCol, CopyRegRow;
always_ff @(posedge ClkCmd) begin :CopyReg_AFF
    if(GC_Reset_b == 1'b0) begin
        WrRegCol   <= 1'b0; CopyRegCol <= 1'b0; 
        WrRegRow   <= 1'b0; CopyRegRow <= 1'b0; 
    end else begin 
        {CopyRegCol, WrRegCol} <= {WrRegCol, WrGC[1]}; // #1 RegionCol, Copy register value on WrReg command 
        {CopyRegRow, WrRegRow} <= {WrRegRow, WrGC[2]}; // #2 RegionRow, Copy register value on WrReg command 
    end // end else 
end // CopyReg_AFF

//----------------------------------------------------------------------------------------------------------------------
//
// Write Pixel Counter [used for Writing to Pixels]
// Counter used for writing configuration to Pixels
// Counter starts with a WrPixel and stops at zero
// 
// Auto Increment (for read) should also work using AutoRead register
//
logic       AutoReadZero0, AutoReadZero1, AutoReadZero2, AutoReadZero3 ;
logic       AutoReadZero4, AutoReadZero5, AutoReadZero6, AutoReadZero7 ;
logic       AutoReadZero ;
assign AutoReadZero0 = (AutoRead0 == 'b0) ? 1'b1 : 1'b0 ;
assign AutoReadZero1 = (AutoRead1 == 'b0) ? 1'b1 : 1'b0 ;
assign AutoReadZero2 = (AutoRead2 == 'b0) ? 1'b1 : 1'b0 ;
assign AutoReadZero3 = (AutoRead3 == 'b0) ? 1'b1 : 1'b0 ;
assign AutoReadZero4 = (AutoRead4 == 'b0) ? 1'b1 : 1'b0 ;
assign AutoReadZero5 = (AutoRead5 == 'b0) ? 1'b1 : 1'b0 ;
assign AutoReadZero6 = (AutoRead6 == 'b0) ? 1'b1 : 1'b0 ;
assign AutoReadZero7 = (AutoRead7 == 'b0) ? 1'b1 : 1'b0 ;
//
// True if one of the eight auto read registers has address 0 (we are reading Pixel configuration)
assign AutoReadZero = (AutoReadZero0 | AutoReadZero1 | AutoReadZero2 | AutoReadZero3 |
                       AutoReadZero4 | AutoReadZero5 | AutoReadZero6 | AutoReadZero7 );

//
// Determine if we have to write or read pixel configuration
assign WrPixelConf = (WrGC[0] == 1'b1) ? 1'b1 : 1'b0;
assign RdPixelConf = (RdGC[0] == 1'b1) ? 1'b1 : 1'b0;
assign RdWrPixelConf = (RdPixelConf | WrPixelConf);

//----------------------------------------------------------------------------------------------------------------------
// Generate NewRegData each time there is a RdRegister command [to MonitorData block]
// 
logic RdRegCmdDly;
//
always_ff @(posedge ClkCmd) begin :RdRegCmdDly_AFF
    if(GC_Reset_b == 1'b0) begin 
        RdRegCmdDly <= 1'b0; 
    end else begin 
        RdRegCmdDly <= RdRegCmd;
    end // end else 
end // RdRegCmdDly_AFF

//----------------------------------------------------------------------------------------------------------------------
// Write Pixel Counter 
// Counter used for writing Pixel configuration 
// Counter starts with a WrPixelConf and stops at zero
//
logic [3:0] WrPixCnt; 
//
always_ff @(posedge ClkCmd) begin :WrPixCnt_ff
    if(GC_Reset_b == 1'b0) begin 
        WrPixCnt <= 0; 
    end else begin 
        if (WrPixelConf == 1'b1) begin // We are writing the WrPixel Register [Addr == 0]
            WrPixCnt <= 4'b1;
        end else if (WrPixCnt == 'b0) begin // Stop at zero
            WrPixCnt <= 'b0;
        end else begin
            WrPixCnt <= WrPixCnt + 1;
        end // else
    end // end else 
end // WrPixCnt_ff
//
// WrPixCnt Full logic
//
logic WrPixCntFull;
//
always_ff @(posedge ClkCmd) begin : WrPixCntFull_AFF
    if(GC_Reset_b == 1'b0) begin
        WrPixCntFull <= 1'b0;
    end else if (WrPixCnt == 4'b1111) begin
        WrPixCntFull <= 1'b1;
    end else begin
        WrPixCntFull <= 1'b0;
    end
end // WrPixCntFull_AFF

//----------------------------------------------------------------------------------------------------------------------
// Read Pixel Counter 
// Counter used for reading configuration from Pixels
// Counter starts with a RdPixel and stops at zero (unless one autoread register points to Address == 0)
//
logic [4:0] RdPixCnt; 
//
always_ff @(posedge ClkCmd) begin :RdPixCnt_ff
    if(GC_Reset_b == 1'b0) begin 
        RdPixCnt <= 0; 
    end else begin 
        // if (RdPixelConf == 1'b1) begin // We are reading from the WrPixel Register
        if (RdRegCmdDly == 1'b1) begin // We are reading a Register
            RdPixCnt <= 4'b1;
        end else if ((RdPixCnt == 'b0) && (AutoReadZero == 1'b0)) begin // Stop at zero (Only if we do not have to AutoRead the register)
            RdPixCnt <= 'b0;
        end else begin
            RdPixCnt <= RdPixCnt + 1;
        end // else
    end // end else 
end // RdPixCnt_ff

//
// RdPixCnt Full logic
//
logic RdPixCntFull;
//
always_ff @(posedge ClkCmd) begin : RdPixCntFull_AFF
    if(GC_Reset_b == 1'b0) begin
        RdPixCntFull <= 1'b0;
    end else if (RdPixCnt == 5'b1_1111) begin
        RdPixCntFull <= 1'b1;
    end else begin
        RdPixCntFull <= 1'b0;
    end
end // RdPixCntFull_AFF

//----------------------------------------------------------------------------------------------------------------------
// Generate signal to copy data read from Pixels
// 
logic CpPixelData;
//
always_ff @(posedge ClkCmd) begin :CpPixelData_AFF
    if(GC_Reset_b == 1'b0) begin 
        CpPixelData <= 1'b0; 
    end else begin 
        if(RdPixCnt == 27) CpPixelData <= 1'b1;
        else               CpPixelData <= 1'b0;
    end // end else 
end // CpPixelData_AFF


//----------------------------------------------------------------------------------------------------------------------
// Generate signal to store data in the Monitor FIFO
// 
always_ff @(posedge ClkCmd) begin :NewRegData_AFF
    if(GC_Reset_b == 1'b0) begin 
        NewRegData <= 1'b0; 
    end else begin 
        if(RdPixCnt == 29) NewRegData <= 1'b1;
        else               NewRegData <= 1'b0;
    end // end else 
end // NewRegData_AFF

//----------------------------------------------------------------------------------------------------------------------
//
//                                      1                   2              
//                  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
//                       ___     ___     ___     ___     ___
//                  |___|   |___|   |___|   |___|   |___|   |__
//                    _
//        WrRegCmd: _| |_______________________________________
//                   _______________________________ __________
//      RegDataCmd: X_______________________________X__________
//                       ___            ___
//          ConfWr: ____|2 3|__________|0 1|___________________
//                  ______________ _______________ ____________
//       PixDataRd: ______________X_______________X____________
//                   _______________ _______________ __________
// AddressConfCore: X_______________X_______________X__________
//                        ACC             ACC+1
//
//----------------------------------------------------------------------------------------------------------------------

//
// Read back pixel configuration 
// On the bus we have data addressed by AddressConfCol
//
always_ff@(posedge ClkCmd) begin : PixelRd_ff
    if(GC_Reset_b == 1'b0) begin 
        PixDataRd <= 'b0; 
    end else begin 
        if(RdPixCnt == 11)
            PixDataRd[7:0]  <= DataConfRd;
        else if(RdPixCnt == 23)
            PixDataRd[15:8] <= DataConfRd;
        else
            PixDataRd <= PixDataRd;
    end
end // PixelRd_ff

//
// Generate write pulses for pixel configuration
// Only for write commands (there has not been a Rd detected)
always_ff@(posedge ClkCmd) begin : ConfWr_ff
    if(GC_Reset_b == 1'b0) begin 
        ConfWr <= 'b0; 
    end else begin if(WrPixCnt > 1 & WrPixCnt < 4)
            ConfWr <= 1'b1;
        else if(WrPixCnt > 9 & WrPixCnt <= 11)
            ConfWr <= 1'b1;
        else
            ConfWr <= 0;
    end
end // ConfWr_ff

//
// Select data to write to pixels
always_ff @(posedge ClkCmd) begin : DataConfWr_aff
    if(GC_Reset_b == 1'b0) begin 
        DataConfWr <= 'b0; 
    end 
    // else begin if(WrPixCnt >= 0 & WrPixCnt < 7) begin
    //         DataConfWr <= RegDataCmd[15:8]; 
    //     // end else if(WrPixCnt > 6 & WrPixCnt <= 15) begin
    //     end else begin
    //         DataConfWr <= RegDataCmd[7:0]; 
    //     end
    // end // else begin if(WrPixCnt >= 0 & WrPixCnt < 7)
    else begin 
        if (WrPixCnt == 4'd1) begin
            DataConfWr <= RegDataCmd[15:8]; 
            // end else if(WrPixCnt > 6 & WrPixCnt <= 15) begin
        end else if (WrPixCnt == 4'd9) begin
            DataConfWr <= RegDataCmd[7:0]; 
        end else begin
            DataConfWr <= DataConfWr;
        end
    end // else
end // DataConfWr_aff

//
// Set ACCZero when reading/writing from/to pixels
always_ff @(posedge ClkCmd) begin : ACCZero_aff
    if(GC_Reset_b == 1'b0) begin 
        ACCZero    <= 'b0;
    end 
    // Only generate ACCZero when RegAddrCmd == 'b0
    else begin if( ((WrPixCnt > 0 & WrPixCnt < 7) | (RdPixCnt > 0 & RdPixCnt < 17)) & (RegAddrCmd == 'b0) ) begin
            ACCZero    <= 1'b1;
        end else begin 
            ACCZero    <= 1'b0;
        end
    end
end // ACCZero_aff

//
// Perform the Auto Increment of the Address
always_ff @(posedge ClkCmd) begin : AutoIncrement_ff
    if(GC_Reset_b == 1'b0) begin
        // AIRegionCol <= REGION_COL; // Selects which column of regions is selected
        // AIRegionRow <= REGION_ROW; // Bus that goes to the Pixels
        AIRegionCol <= 'b0 ; // Selects which column of regions is selected
        AIRegionRow <= 'b0 ; // Bus that goes to the Pixels
    end else begin
        unique case (AutoIncrementMode) // AutoIncrementMode = {AutoCol,AutoRow};
            2'b00 : begin // Auto Increment is disabled
                AIRegionCol <= REGION_COL;
                AIRegionRow <= REGION_ROW;
            end // 2'b00 :
            2'b01 : begin // Auto Increment Region Rows
                AIRegionCol <= REGION_COL; // Columns are not affected
                unique if ((RdWrPixelConf == 1'b1) && (AIRegionRow== 'b0)) begin
                    // AIRegionRow <= REGION_ROW; // Starting point 
                    AIRegionRow <= AIRegionRow; // Starting point 
                end
                // else if (!(AIRegionRow == ROWS*8 - 1)&(WrPixCnt == 4'b1111))   AIRegionRow <= AIRegionRow + 1;
                else if (!(AIRegionRow == ROWS*8 - 1) & ( (WrPixCntFull == 1'b1)|(RdPixCntFull == 1'b1) ))   
                    AIRegionRow <= AIRegionRow + 1;
                // else if (AIRegionRow == `ROWS*8 - 1) AIRegionRow <= REGION_ROW; // There are maximum ROWS*8 region rows 
                // else if ( (AIRegionRow == ROWS*8 - 1)&(WrPixCnt == 4'b1111)) AIRegionRow <= 'b0; // There are maximum ROWS*8 region rows 
                else if ( (AIRegionRow == ROWS*8 - 1) & ( (WrPixCntFull == 1'b1)|(RdPixCntFull == 1'b1) )) 
                    AIRegionRow <= 'b0; // There are maximum ROWS*8 region rows 
                else if (CopyRegRow == 1'b1) 
                    AIRegionRow <= REGION_ROW; // Copy register value on WrReg command
                else                                
                    AIRegionRow <= AIRegionRow;
            end // 2'b01 :
            2'b10 : begin // Auto Increment Region Columns
                AIRegionRow <= REGION_ROW; // Rows are not affected
                unique if ((RdWrPixelConf == 1'b1) && (AIRegionCol == 'b0)) begin
                    // AIRegionCol <= REGION_COL; // Starting point 
                    AIRegionCol <= AIRegionCol; // Starting point 
                end
                // else if (!(AIRegionRow == ROWS*8 - 1)&(WrPixCnt == 4'b1111))     AIRegionCol <= AIRegionCol + 1;
                else if (!(AIRegionRow == ROWS*8 - 1) & ( (WrPixCntFull == 1'b1)|(RdPixCntFull == 1'b1) ))     
                    AIRegionCol <= AIRegionCol + 1;
                // else if (AIRegionCol == COLS*4 - 1) AIRegionCol <= REGION_COL; // There are maximum COLS*4 region columns           
                // else if ( (AIRegionCol == COLS*4 - 1)&(WrPixCnt == 4'b1111)) AIRegionCol <= 'b0; // There are maximum COLS*4 region columns           
                else if ( (AIRegionCol == COLS*4 - 1) & ( (WrPixCntFull == 1'b1)|(RdPixCntFull == 1'b1) )) 
                    AIRegionCol <= 'b0; // There are maximum COLS*4 region columns           
                else if (CopyRegCol == 1'b1) 
                    AIRegionCol <= REGION_COL; // Copy register value on WrReg command
                else
                    AIRegionCol <= AIRegionCol;
            end // 2'b10 :
            2'b11 : begin // Auto Increment both Region Columns and Region Rows (not implemented for now)
                AIRegionCol <= REGION_COL;
                AIRegionRow <= REGION_ROW;
            end // 2'b11 :
            default: begin
                AIRegionCol <= REGION_COL;
                AIRegionRow <= REGION_ROW;
            end
        endcase // AutoIncrementMode
    end // end else
end // AutoIncrement_ff

 //                              ##       ##                                                    ##                                                       ##
 // ##   ##                      ##       ##                                #####               ##                       ##   ##                         ##
 // ##   ##                               ##                                ##  ##              ##                       ##   ##                         ##
 // ### ###   #####   ## ###   ####     ######    #####   ## ###            ##   ##   ######  ######    ######           ## # ##   #####   ## ###    ######
 // ## # ##  ##   ##  ###  ##    ##       ##     ##   ##  ###               ##   ##  ##   ##    ##     ##   ##           ## # ##  ##   ##  ###      ##   ##
 // ## # ##  ##   ##  ##   ##    ##       ##     ##   ##  ##                ##   ##  ##   ##    ##     ##   ##           ## # ##  ##   ##  ##       ##   ##
 // ##   ##  ##   ##  ##   ##    ##       ##     ##   ##  ##                ##  ##   ##  ###    ##     ##  ###           ### ###  ##   ##  ##       ##   ##
 // ##   ##   #####   ##   ##  ######      ###    #####   ##                #####     ### ##     ###    ### ##           ##   ##   #####   ##        ######

//
//----------------------------------------------------------------------------------------------------------------------
//
// Generate Monitor data word based on selected Register Address
// 
always_ff @(posedge ClkCmd) begin : SyncRegData
    if(GC_Reset_b == 1'b0) begin
             AddrFlag <=  'b0   ;
        RegDataRdAddr <= 9'h1ff ; // Use an invalid address
            RegDataRd <=  'b0   ;
    end else begin
        if (CpPixelData == 1'b1) begin 
            AddrFlag      <= (RegAddrCmd == 'b0) ?        1'b1 : 1'b0                  ;
            RegDataRdAddr <= (RegAddrCmd == 'b0) ? AIRegionRow : RegAddrCmd            ;
            RegDataRd     <= (RegAddrCmd == 'b0) ?   PixDataRd : OutDataGC[RegAddrCmd] ;
        end else begin  
            AddrFlag      <= AddrFlag;
            RegDataRdAddr <= RegDataRdAddr;
            RegDataRd     <= RegDataRd;
        end // end else
    end // end else
end // SyncRegData

//
// Generate data word to be stored in the monitoring Fifo
assign RegData = {AddrFlag,RegDataRdAddr,RegDataRd};

//
//----------------------------------------------------------------------------------------------------------------------
// 
// Detect edges of HitOr signals
logic [3:0] HitOrDly, HitOrEdge;
generate genvar iEdge;
    for (iEdge = 0; iEdge < 4 ; iEdge = iEdge + 1) begin 
        always_ff @(posedge ClkCmd) begin : HitOrDly_AFF
            if(GC_Reset_b == 1'b0) begin
                HitOrEdge[iEdge] <= 1'b0;
                HitOrDly[iEdge]  <= 1'b0;
            end else begin
                HitOrDly[iEdge] <= HitOr[iEdge];
                if ({HitOr[iEdge],HitOrDly[iEdge]} == 2'b10) begin
                    HitOrEdge[iEdge] <= 1'b1;
                end else begin
                    HitOrEdge[iEdge] <= 1'b0;
                end
            end
        end // HitOrDly_AFF 
    end // for (iEdge = 0; iEdge < 4 ; iEdge = iEdge + 1)
endgenerate

//----------------------------------------------------------------------------------------------------------------------
//
// HitOr counters
generate
    genvar iCnt;
    for (iCnt = 0; iCnt < 4 ; iCnt = iCnt + 1) begin 
        always_ff @(posedge ClkCmd) begin : HitOrCnt_AFF
            if(~GC_Reset_b || WrHitOrCntRst[iCnt]) begin
                HitOrCnt[iCnt] <= 0;
            end else begin
                if (HitOrEdge[iCnt] == 1'b1) begin
                    HitOrCnt[iCnt] <= HitOrCnt[iCnt] + 1;
                end else begin
                    HitOrCnt[iCnt] <= HitOrCnt[iCnt];
                end
            end
        end // HitOrCnt_AFF
    end // for (iCnt = 0; iCnt < 4 ; iCnt = iCnt + 1)
endgenerate

//----------------------------------------------------------------------------------------------------------------------
// 
// Select which Data words have to be sent to MonitorData block
//
//  [25:0]    AutoReadData = {AddrFlag,Addr[8:0],Data[15:0]}
//                AddrFlag = 1 --> Data belongs to Pixels           --> Addr[8:0] = RegionRowAddr
//                           0 --> Data is from GlobalConfiguration --> Addr[8:0] = GC_Address
//  [15:0]            Data = Data to be sent out
//
//
// Assign Data to send out on wire [3:0][25:0] DataA, DataB
generate
    genvar ARDi;
    for (ARDi = 0; ARDi < 8 ; ARDi = ARDi + 1) begin 
        //                                                Case for Virtual Register                 Case for Regular Register
        // assign AutoReadData[ARDi] = (AutoRead[ARDi] == 'b0) ? {1'b1,AIRegionRow,PixDataRd} : {1'b0,AutoRead[ARDi],OutDataGC[AutoRead[ARDi]]} ;
        always_ff @(posedge ClkCmd) AutoReadData[ARDi] = (AutoRead[ARDi] == 'b0) ? {1'b1,AIRegionRow,PixDataRd} : {1'b0,AutoRead[ARDi],OutDataGC[AutoRead[ARDi]]} ;
    end // for (ARDi = 0; ARDi < 4 ; ARDi = ARDi + 1)
endgenerate

//----------------------------------------------------------------------------------------------------------------------
//                                                                                             ##
//                        ##            ###                                                    ##
// ##   ##                ##             ##                       ######                       ##
// ##   ##                ##             ##                         ##                         ##
// ### ###   #####    ######  ##   ##    ##      #####              ##     ## ###    #####   ######
// ## # ##  ##   ##  ##   ##  ##   ##    ##     ##   ##             ##     ###  ##  ##         ##
// ## # ##  ##   ##  ##   ##  ##   ##    ##     #######             ##     ##   ##   ####      ##
// ##   ##  ##   ##  ##   ##  ##  ###    ##     ##                  ##     ##   ##      ##     ##
// ##   ##   #####    ######   ### ##   ####     #####            ######   ##   ##  #####       ###
//

`include "eoc/gcr/GCR_Regs.sv"

endmodule // GlobalConfiguration


//
//----------------------------------------------------------------------------------------------------------------------
//                       ##   ##    ###    #####    ##   ##  ##       #######   #####
//                       ##   ##   ## ##   ##  ##   ##   ##  ##       ##       ##   ##
//                       ### ###  ##   ##  ##   ##  ##   ##  ##       ##       ##
//                       ## # ##  ##   ##  ##   ##  ##   ##  ##       #####     #####
//                       ## # ##  ##   ##  ##   ##  ##   ##  ##       ##            ##
//                       ##   ##   ## ##   ##  ##   ##   ##  ##       ##       ##   ##
//                       ##   ##    ###    #####     #####   ######   #######   #####
//----------------------------------------------------------------------------------------------------------------------
//
// 16 bit wide register with async active low reset
module GCR_reg #(parameter WIDTH = 16, 
                 parameter [WIDTH-1:0] ResetValue = 'b0)
               (
               // Outputs
               output logic [WIDTH-1:0] OutData,    // Output Data
               // Inputs
               input  wire              Clk ,       // Clock
               input  wire              Reset_b,    // Asynchronous active low reset
               input  wire  [WIDTH-1:0] InData,     // Input Data
               input  wire              Wr          // Write
               ); 

// Default value in case of reset
//parameter [WIDTH-1:0] ResetValue = 'b0;

logic [WIDTH-1:0] gc_value_tmr;
always_ff @(posedge Clk, negedge Reset_b) begin : OutData_ff
    if(~Reset_b) begin
        gc_value_tmr <= ResetValue;
    end else if (Wr == 1'b1) begin
        gc_value_tmr <= InData;
    end else begin
        gc_value_tmr <= gc_value_tmr;
    end
end // OutData_ff

assign OutData = gc_value_tmr;

endmodule // GCR_reg

`endif // GLOBALCONFIGURATION_SV
