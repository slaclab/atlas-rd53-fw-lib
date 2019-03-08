
//-----------------------------------------------------------------------------------------------------
// [Filename]       DigitalChipBottom.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         -
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 21, 2017
// [Modified]       Jul  6, 2017
// [Description]    Digital bulk at the chip periphery
// [Notes]
// [Version]        1.0
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/top/RD53A_defines.sv
// $RTL_DIR/eoc/cmd/ChannelSync.sv
// $RTL_DIR/eoc/cmd/Cmd.sv
// $RTL_DIR/eoc/GlobalConfiguration.sv
// $RTL_DIR/eoc/DataConcentrator.sv
// $RTL_DIR/eoc/CdcResetSync.v
// $RTL_DIR/eoc/OutputCdcFifo.sv
// $RTL_DIR/eoc/TwoFFSync.sv
// $RTL_DIR/eoc/AlignData.sv
// $RTL_DIR/eoc/mon/MonitorData.sv
// $RTL_DIR/eoc/Aurora64b66b/aurora_frame_multilane_top.sv
// $RTL_DIR/eoc/autozeroing/phi_az_comb.sv
// $RTL_DIR/eoc/BackupSerializers.sv
// $RTL_DIR/eoc/CmdClkPhaseDelayHardCoded.sv

`ifndef DIGITAL_CHIP_BOTTOM__SV
`define DIGITAL_CHIP_BOTTOM__SV

`default_nettype none

`timescale  1ns / 1ps
//`include "timescale.v"

`include "top/RD53A_defines.sv"
`include "eoc/cmd/ChannelSync.sv"
`include "eoc/cmd/Cmd.sv"
`include "eoc/gcr/GlobalConfiguration.sv"
`include "eoc/DataConcentrator.sv"
`include "eoc/CdcResetSync.v"
`include "eoc/OutputCdcFifo.sv"
`include "eoc/TwoFFSync.sv"
`include "eoc/AlignData.sv"
`include "eoc/mon/MonitorData.sv"
`include "eoc/Aurora64b66b/aurora_frame_multilane_top.sv"
`include "eoc/autozeroing/phi_az_comb.sv"
`include "eoc/BackupSerializers.sv"
`include "eoc/CmdClkPhaseDelayHardCoded.sv"


module DigitalChipBottom (

    // startup reset
    input  wire        PorResetB,                // input reset from POR or from external pad (asynchronous, active-LOW )
    input  wire        BypCmd,                   // bypass command decoder and use JTAG
    input  wire        CdrCmdData,               // Command/data serial stream, either from CDR/PLL or bypassed at SLVS RX output
    input  wire        CdrCmdClk,                // Nominal 160 MHz master clock, either from CDR/PLL or bypassed at SLVS RX output (also fed to JTAG)
    input  wire        CdrDelClk,                // DEL_CLK coming from CDR/PLL
    input  wire  [2:0] ChipID,                   // external 3-bit hard-wired chip local address
    input  wire        ExtTrigger,               // **BACKUP: external trigger
    // to/from high-speed serializers
    output logic       SerRstB,                  // required to initialize SER internal LFSR for pseudo-random number generation (configuration bit)
    input  wire        DataClk,                  // divided clock for CDC FIFO/Aurora from SER
    output logic [19:0] SerData1G_0,              // 20-bit output boundles fed to 4x 1.6 Gb/s high-speed serializer #0
    output logic [19:0] SerData1G_1,              // 20-bit output boundles fed to 4x 1.6 Gb/s high-speed serializer #1
    output logic [19:0] SerData1G_2,              // 20-bit output boundles fed to 4x 1.6 Gb/s high-speed serializer #2
    output logic [19:0] SerData1G_3,              // 20-bit output boundles fed to 4x 1.6 Gb/s high-speed serializer #3

    // **TODO: to be removed ------------------------------------------------------------------------
    //output wire [15:0] SerData5G,                // 16-bit output boundle fed to 5 Gb/s high-speed serializer
    //---------------------------------------------------------------------------------------------------------------


    // **BACKUP: RTL serializers routed to GP-LVDS TX
    output wire BackupSerOutput_0,
    output wire BackupSerOutput_1,
    output wire BackupSerOutput_2,
    output wire BackupSerOutput_3,

    input  wire DebugEn,                         // global debug-enable pin, tied-down by default

    output wire Clk160,                          // effective **DELAYED** 160 MHz clock, used in the Digital Chip Bottom, also sent to GP-LVDS
    output wire CmdData,                         // effective **DELAYED** data stream fed to the Channel Synchronizer, also sent to GP-LVDS

    // To ACB
    output logic ADC_RST_B,                      // Reset for the Monitoring Data ADC
    output wire  ADC_SOC,                        // Start conversion in Monitoring Data ADC
    // From ACB
    input  wire [11:0] MonitoringDataADC,        // Bus to be read out coming from the monitoring block
    input  wire ADC_EOC_B,                       // receive ADC End-Of-Conversion, active-low

    // JTAG
    input  wire         JtagTck,
    input  wire   [3:0] JtagChipID,               // bypass command-decoder FSM outputs [ 3:0] CmdChipID
    input  wire   [8:0] JtagRegAddr,              // bypass command-decoder FSM outputs [ 8:0] CmdRegAddr
    input  wire  [15:0] JtagRegData,              // bypass command-decoder FSM outputs [15:0] CmdRegData
    input  wire   [2:0] JtagEdgeDly,              // bypass command-decoder FSM outputs [ 2:0] CmdEdgeDelay
    input  wire   [5:0] JtagEdgeWidth,            // bypass command-decoder FSM outputs [ 5:0] CmdEdgeWidth
    input  wire   [4:0] JtagAuxDly,               // bypass command-decoder FSM outputs [ 4:0] CmdAuxDly
    input  wire         JtagEdgeMode,             // bypass command-decoder FSM output         CmdEdgeMode
    input  wire         JtagAuxMode,              // bypass command-decoder FSM output         CmdAuxMode
    input  wire   [3:0] JtagGlobalPulseWidth,     // bypass command-decoder FSM outputs [ 3:0] CmdGlobalPulseWidth
    input  wire         JtagWrReg,                // bypass command-decoder FSM output         CmdWrReg
    input  wire         JtagRdReg,                // bypass command-decoder FSM output         CmdRdReg
    input  wire         JtagECR,                  // bypass command-decoder FSM output         CmdECR
    input  wire         JtagBCR,                  // bypass command-decoder FSM output         CmdBCR
    input  wire         JtagGenGlobalPulse,       // bypass command-decoder FSM output         CmdGenGlobalPulse
    input  wire         JtagGenCal,               // bypass command-decoder FSM output         CmdGenCal
    output wire [127:0] JtagReadbackData,         // send to JTAG 128-bit READBACK register     

    // to the pixel array
    output wire             Clk40,               // 40 MHz BX clock To the Pixel Array
    output logic            PixReset,            // reset fed to pixels, SYNCHRONOUS with 40 MHz clock, ACTIVE-HIGH
    output logic            PixTrigger,          // trigger fed to pixels
    output wire             DefaultPixelConf,
    output wire             CalEdge,
    output wire             CalAux,
    output wire       [2:0] EnCoreColBroadcast,
    output wire      [11:0] AddressConfCore,
    output wire       [5:0] AddressConfCol,
    output wire       [7:0] DataConfWr,
    output wire [`COLS-1:0] ReadyCol,
    output wire             ConfWr,
    // from the pixel array
    input  wire       [3:0] PixHitOr,            // HitOr bus coming from the Pixel Array
    //
    // Pixel Matrix Section
    //
    // SYN Front End
    output wire   [9:0] IBIASP1_SYNC,              //  Current of the main branch of the CSA
    output wire   [9:0] IBIASP2_SYNC,              //  Current of the splitting branch of the CSA
    output wire   [9:0] IBIAS_SF_SYNC,             //  Current of the preamplifier SF
    output wire   [9:0] IBIAS_KRUM_SYNC,           //  Current of the Krummenacher feedback
    output wire   [9:0] IBIAS_DISC_SYNC,           //  Current of the Comparator Diff Amp
    output wire   [9:0] ICTRL_SYNCT_SYNC,          //  Current of the oscillator delay line
    output wire   [9:0] VBL_SYNC,                  // Baseline voltage for offset compens
    output wire   [9:0] VTH_SYNC,                  // Discriminator threshold voltage
    output wire   [9:0] VREF_KRUM_SYNC,            // Krummenacher voltage reference
    output wire         SelC2F_SYNC,               // Connect to SYNC Front End
    output wire         SelC4F_SYNC,               // Connect to SYNC Front End
    output wire         FastEn_SYNC,               // Connect to SYNC Front End
    output wire         FreeRunningAutoZero_SYNC,  // Connect to SYNC Front End
    output wire         CmdPhiAZ,                  // Auto Zeroing pulse [generated in response to a GlobalPulse or a CalEdge]

    // LIN Front End
    output wire   [9:0] PA_IN_BIAS_LIN,          // preampli input branch current
    output wire   [9:0] FC_BIAS_LIN,             // folded cascode branch current
    output wire   [9:0] KRUM_CURR_LIN,           // Krummenacher current
    output wire   [9:0] LDAC_LIN,                // fine threshold
    output wire   [9:0] COMP_LIN,                // Comparator current
    output wire   [9:0] REF_KRUM_LIN,            // Krummenacher reference voltage
    output wire   [9:0] Vthreshold_LIN,          // Global threshold voltage
    // DIFF Front End
    output wire   [9:0] PRMP_DIFF,               // Preamp input stage current
    output wire   [9:0] FOL_DIFF,                // Preamp output follower current
    output wire   [9:0] PRECOMP_DIFF,            // Precomparator tail current
    output wire   [9:0] COMP_DIFF,               // Comparator total current
    output wire   [9:0] VFF_DIFF,                // Preamp feedback current (return to baseline)
    output wire   [9:0] VTH1_DIFF,               // Negative branch voltage offset (vth1)
    output wire   [9:0] VTH2_DIFF,               // Positive branch voltage offset (vth2)
    output wire   [9:0] LCC_DIFF,                // Leakage current compensation current
    output wire         LCC_X_DIFF,              // Connect leakace current comp. circuit
    output wire         FF_CAP_DIFF,             // Select preamp feedback capacitance
    //
    // Power Section
    //
    output wire       [4:0] SLDOAnalogTrim,      // Analog and Digital voltage regulator trim
    output wire       [4:0] SLDODigitalTrim,     // Analog and Digital voltage regulator trim
    // 
    // Digital Matrix Section
    //
    output wire      [15:0] EN_CORE_COL_SYNC,    // Enable Core Columns         (SYNC Front End)
    output wire       [4:0] WR_SYNC_DELAY_SYNC,  // Write Synchronization delay (SYNC Front End)
    output wire      [16:0] EN_CORE_COL_LIN,     // Enable Core Columns         (LIN Front End)
    output wire      [16:0] EN_CORE_COL_DIFF,    // Enable Core Columns         (DIFF Front End)
    output wire       [8:0] LATENCY_CONFIG,      // Latency Configuration
    output wire       [1:0] WaitReadCnfg,        // Delay Read Data from columns
    //
    // Functions Section
    //
    output wire             AnalogInjectionMode,       // Analog injection mode
    output wire             DigitalInjectionEnable,    // Digital injection mode
    output wire      [11:0] VCAL_HIGH,                 // VCAL high
    output wire      [11:0] VCAL_MED,                  // VCAL med
    output wire      [63:0] EN_MACRO_COL_CAL_SYNC,     // Enable macrocolumn analog calibrationfor the SYNC frontend 
    output wire      [67:0] EN_MACRO_COL_CAL_LIN,      // Enable macrocolumn analog calibrationfor the LIN frontend 
    output wire      [67:0] EN_MACRO_COL_CAL_DIFF,     // Enable macrocolumn analog calibrationfor the DIFF frontend 
    //
    // I/O Section
    //
    output wire JtagTdoDs,                       // configure drive-strength for JTAG TDO CMOS output pad
    output wire StatusDs,                        // configure drive-strength for STATUS CMOS output pad
    output wire Status,                          // general purpose debug, connected to channel synch "locked" signal
    output wire EnableExtCal,                    // enable external calibration with backup injection strobes


    // **TODO: to be removed ------------------------------------------------------------------------
    //output wire             En5G,                // Enable 5G driver
    //output wire             OutputSelect,        // Select output path 5G if 1'b1, 1.2G if 1'b0
    //output wire       [1:0] MultiLineOutSel,     // Multi-lane output mode (1, 2, or 4 outputs)
    //output wire       [1:0] OutputFormat,        // Output format: hdr, tag, hdr+tag, compressed
    //output wire       [1:0] Division5GBW,        // 5G bandwidth division factor (1,2,4,8)
    //-----------------------------------------------------------------------------------------------

    output wire       [9:0] CML_TAP0_BIAS,       // Bias current 0 for CML driver
    output wire       [9:0] CML_TAP1_BIAS,       // Bias current 1 for CML driver
    output wire       [9:0] CML_TAP2_BIAS,       // Bias current 2 for CML driver
    output wire       [9:0] CDR_CP_IBIAS,        // Bias current for CP of CDR
    output wire       [9:0] CDR_VCO_IBIAS,       // Bias current for VCO of CDR
    output wire       [9:0] CDR_VCO_BUFF_BIAS,   // Bias current for VCO buffer of CDR
    output wire       [1:0] CDR_PD_SEL,          // CDR Configuration
    output wire       [3:0] CDR_PD_DEL,          // CDR Configuration
    output wire             CDR_EN_GCK2,         // CDR Configuration
    output wire       [2:0] CDR_VCO_GAIN,        // CDR Configuration
    output wire       [2:0] CDR_SEL_SER_CLK,     // CDR Configuration
    output wire             CDR_SEL_DEL_CLK,     // CDR Configuration
    output wire       [1:0] SER_INV_TAP,         // 20bit Serializer Output Settings
    output wire       [1:0] SER_EN_TAP,          // 20bit Serializer Output Settings
    output wire       [3:0] CML_EN_LANE,         // 20bit Serializer Output Settings
    output wire       [1:0] SER_SEL_OUT_3,       // 20bit Serializer Output Select
    output wire       [1:0] SER_SEL_OUT_2,       // 20bit Serializer Output Select
    output wire       [1:0] SER_SEL_OUT_1,       // 20bit Serializer Output Select
    output wire       [1:0] SER_SEL_OUT_0,       // 20bit Serializer Output Select
    output wire             LANE0_LVDS_EN_B,     // LVDS Configuration
    output wire       [2:0] LANE0_LVDS_BIAS,     // LVDS Configuration
    output wire       [3:0] GP_LVDS_EN_B,        // General purpose LVDS Enable
    output wire       [2:0] GP_LVDS_BIAS,        // General purpose LVDS Bias
    output wire       [2:0] GP_LVDS_ROUTE,       // General purpose LVDS routing       // Only 3 bits used so far
    //
    // Test Section
    //
    output wire             MonitorEnable,       // Enable Monitoring Block
    output wire      [63:0] V_MONITOR_SELECT,    // Voltage monitoring MUX selection
    output wire      [31:0] I_MONITOR_SELECT,    // Current monitoring MUX selection
    output wire [3:0][49:0] HITOR_MASK,          // Mask bits for the HitOr
    output wire       [4:0] MON_BG_TRIM,         // ADC Band gap trimming bits
    output wire       [5:0] MON_ADC_TRIM,        // ADC trimming bits
    output wire             SENS_ENABLE0,        // Enable temp/rad sensors
    output wire       [3:0] SENS_DEM0,           // Dynamic element matching bits
    output wire             SEN_SEL_BIAS0,       // Current bias select 
    output wire             SENS_ENABLE1,        // Enable temp/rad sensors
    output wire       [3:0] SENS_DEM1,           // Dynamic element matching bits
    output wire             SEN_SEL_BIAS1,       // Current bias select 
    output wire             SENS_ENABLE2,        // Enable temp/rad sensors
    output wire       [3:0] SENS_DEM2,           // Dynamic element matching bits
    output wire             SEN_SEL_BIAS2,       // Current bias select 
    output wire             SENS_ENABLE3,        // Enable temp/rad sensors
    output wire       [3:0] SENS_DEM3,           // Dynamic element matching bits
    output wire             SEN_SEL_BIAS3,       // Current bias select 
    output wire       [7:0] RING_OSC_ENABLE,     // Enable Ring Oscillator
    // to Top
    output wire              WrRingOscCntRst ,   // Reset bus for the Ring Oscillator counters
    output wire              RingOscStart,       // start/stop for ring-oscillators (using global-pulse)
    // to Pixel Array
    output wire          WrSkippedTriggerCntRst, // Reset forthe Skipped Trigger counter

    //
    // from Top
    input  wire             [15:0] RING_OSC_0,
    input  wire             [15:0] RING_OSC_1,
    input  wire             [15:0] RING_OSC_2,
    input  wire             [15:0] RING_OSC_3,
    input  wire             [15:0] RING_OSC_4,
    input  wire             [15:0] RING_OSC_5,
    input  wire             [15:0] RING_OSC_6,
    input  wire             [15:0] RING_OSC_7,
    // from the pixel array
    input  wire              [7:0] DataConfRd,
    input  wire [`COLS-1:0] [15:0] DataCol,
    input  wire  [`COLS-1:0] [9:0] RowCol,
    input  wire        [`COLS-1:0] DataReadyCol,
    input  wire   [`COLS-1:0][4:0] TrigIdReqColBin,
    input  wire              [5:0] TriggerIdCnt,
    input  wire              [5:0] TriggerIdCurrentReq,
    input  wire                    TriggerAccept,
    input  wire             [15:0] SkippedTriggerCnt,
    input  wire                    SkippedTriggerCntErr, 

    // internal scan-chain interface
    // (just unconnected ports in RTL, actual connections are performed by the synthesis tool)
    input  wire             ScanMode,
    input  wire             ScanIn,
    input  wire             ScanEn,
    output wire             ScanOut

    ) ;


`ifndef ABSTRACT

 //                    ###                                           ##
 // #####               ##                                ##         ##
 // ##  ##              ##                                ##
 // ##   ##   #####     ##      ######  ##  ##            ##       ####     ## ###    #####    #####
 // ##   ##  ##   ##    ##     ##   ##  ##  ##            ##         ##     ###  ##  ##   ##  ##
 // ##   ##  #######    ##     ##   ##  ##  ##            ##         ##     ##   ##  #######   ####
 // ##  ##   ##         ##     ##  ###  ##  ##            ##         ##     ##   ##  ##           ##
 // #####     #####    ####     ### ##   #####            ######   ######   ##   ##   #####   #####
 //                                         ##
 //                                      ####




    // phase-selection on input clock using a MUX

    wire SelClkPhase; 

    //
    // Delay of Clock, Data and CalEdge using 640MHz clock
    //
    wire   [3:0] ClkFineDelay       ; // Clock fine delay
    wire   [3:0] DataFineDelay      ; // Data fine delay
    wire   [3:0] InjectionFineDelay ; // Injection fine delay
    logic [15:0] DlyData            ; // Input data delay line
    logic [15:0] DlyPulse           ; // CalEdge delay line
    wire         CalEdgeCmd         ; // CalEdge coming from Command Decoder

    //
    // CmdClk delay
    //
    
    CmdClkPhaseDelayHardCoded cmd_clk_delay_hardcoded  (.CdrCmdClk(CdrCmdClk), .CdrDelClk(CdrDelClk), 
                                                        .SelClkPhase(SelClkPhase), .ClkFineDelay(ClkFineDelay), 
                                                        .Clk160(Clk160)); 
    //
    // CmdData delay
    //
    
    logic cdr_data_resync;
    always_ff @(posedge CdrCmdClk)
        cdr_data_resync <= CdrCmdData;
    
    assign DlyData[0] = cdr_data_resync ; 

    always_ff @(posedge CdrDelClk) begin
        DlyData[15:1] <= DlyData[14:0] ;
    end

    assign CmdData = DlyData[DataFineDelay] ;

    //
    // CalEdge delay   
    //
    assign DlyPulse[0] = CalEdgeCmd ;

    always_ff @(posedge CdrDelClk) begin
        DlyPulse[15:1] <= DlyPulse[14:0] ;
    end

    assign CalEdge = DlyPulse[InjectionFineDelay] ;



 // ######   #######   #####   #######  ######             #####   ##  ##   ##   ##    ####   ##   ##
 // ##   ##  ##       ##   ##  ##         ##              ##   ##  ##  ##   ###  ##   ##  ##  ##   ##
 // ##   ##  ##       ##       ##         ##              ##        ####    ###  ##  ##       ##   ##
 // ######   #####     #####   #####      ##               #####     ##     ## # ##  ##       #######
 // ## ##    ##            ##  ##         ##                   ##    ##     ## # ##  ##       ##   ##
 // ##  ##   ##       ##   ##  ##         ##              ##   ##    ##     ##  ###   ##  ##  ##   ##
 // ##   ##  #######   #####   #######    ##               #####     ##     ##   ##    ####   ##   ##

    //-------------------------------------   RESET SYNCHRONIZER    -----------------------------------------//

    // **NOTE: Global configuration registers        =>  resetted by an **ASYNCHRONOUS** reset generated either from
    //                                                   POR/external pad reset or from JTAG TAP controller
    //
    //         Channel synchronizer/command decoder  =>  resetted by a **SYNCHRONOUS** reset generated starting
    //                                                   from the asynchronous one
    //
    //         All remaining readout components      =>  resetted by ECR command generated from command decoder or by JTAG

    wire   asynch_reset_b ;
    assign asynch_reset_b = PorResetB ; // Removed JtagTrstB mux on power on reset  

    logic synch_reset_q0 ;
    logic synch_reset_q1 ;

    // reset deglitcher
    wire del1, del2, asynch_reset_b_delayed ;

    `ifdef USE_VAMS

    assign #5ns asynch_reset_b_delayed = asynch_reset_b ;

    `else

    DEL1  DeglitcherDelay1( .I(asynch_reset_b), .Z(                  del1) ) ; 
    DEL1  DeglitcherDelay2( .I(          del1) ,.Z(                  del2) ) ;
    DEL3  DeglitcherDelay3( .I(          del2) ,.Z(asynch_reset_b_delayed) ) ;

    `endif

    // synopsys dc_script_begin
    // set_dont_touch DeglitcherDelay1
    // set_dont_touch DeglitcherDelay2
    // set_dont_touch DeglitcherDelay3
    // synopsys dc_script_end

    wire   asynch_reset_b_deglitched ;
    assign asynch_reset_b_deglitched = asynch_reset_b | asynch_reset_b_delayed ;

    always_ff @(negedge asynch_reset_b_deglitched or posedge Clk160 ) begin
        if( asynch_reset_b_deglitched == 1'b0 ) begin
            synch_reset_q0 <= 1'b0 ;
            synch_reset_q1 <= 1'b0 ;
        end else begin
            synch_reset_q0 <= 1'b1 ;
            synch_reset_q1 <= synch_reset_q0 ;
        end
    end  // always_ff

    wire   synch_reset_b ;                                        // synchronous, active-low
    assign synch_reset_b = synch_reset_q1 ;

 //            ##       ##
 // ##   ##    ##       ##       ###                       #####   ##  ##   ##   ##    ####   ##   ##
 // ##   ##             ##      ## ##                     ##   ##  ##  ##   ###  ##   ##  ##  ##   ##
 // ##   ##  ####     ######   ##   ##  ## ###            ##        ####    ###  ##  ##       ##   ##
 // #######    ##       ##     ##   ##  ###                #####     ##     ## # ##  ##       #######
 // ##   ##    ##       ##     ##   ##  ##                     ##    ##     ## # ##  ##       ##   ##
 // ##   ##    ##       ##      ## ##   ##                ##   ##    ##     ##  ###   ##  ##  ##   ##
 // ##   ##  ######      ###     ###    ##                 #####     ##     ##   ##    ####   ##   ##

    //
    // Synchronize HitOr signals that come from the PixelRegion
    logic [3:0] sync_hitor_q0, sync_hitor_q1;
    //
    always_ff @(posedge Clk160) begin : SyncHitOr_AFF
        if (synch_reset_b == 1'b0) begin
            sync_hitor_q0 <= 4'b0;
            sync_hitor_q1 <= 4'b0;
        end else begin
            sync_hitor_q0 <= PixHitOr;
            sync_hitor_q1 <= sync_hitor_q0;
        end
    end : SyncHitOr_AFF

    logic [3:0] PixHitOr_sync;
    assign PixHitOr_sync = sync_hitor_q1;


 //   ####   ##         ###    ######     ##     ##                ######   ##   ##  ##        #####   #######
 //  ##  ##  ##        ## ##   ##   ##    ##     ##                ##   ##  ##   ##  ##       ##   ##  ##
 // ##       ##       ##   ##  ##   ##   ####    ##                ##   ##  ##   ##  ##       ##       ##
 // ##       ##       ##   ##  ######    ## #    ##                ######   ##   ##  ##        #####   #####
 // ##  ###  ##       ##   ##  ##   ##  ######   ##                ##       ##   ##  ##            ##  ##
 //  ##  ##  ##        ## ##   ##   ##  ##   #   ##                ##       ##   ##  ##       ##   ##  ##
 //   #####  ######     ###    ######  ###   ##  ######            ##        #####   ######    #####   #######


    //------------------------------------   GLOBAL PULSE ROUTING    ----------------------------------------//
    // Define how to route the GlobalPulse command
    // GLOBAL_PULSE_ROUTE[0]   -->    Reset Channel Synchronizer
    // GLOBAL_PULSE_ROUTE[1]   -->    Reset Command Decoder
    // GLOBAL_PULSE_ROUTE[2]   -->    Reset Global Configuration
    // GLOBAL_PULSE_ROUTE[3]   -->    Reset Monitor Data
    // GLOBAL_PULSE_ROUTE[4]   -->    Reset Aurora
    // GLOBAL_PULSE_ROUTE[5]   -->    Reset Serializers
    // GLOBAL_PULSE_ROUTE[6]   -->    Reset ADC
    // GLOBAL_PULSE_ROUTE[7]   -->    
    // GLOBAL_PULSE_ROUTE[8]   -->    Enable Monitoring (temporary fix)
    // GLOBAL_PULSE_ROUTE[9]   -->    
    // GLOBAL_PULSE_ROUTE[10]  -->    
    // GLOBAL_PULSE_ROUTE[11]  -->    
    // GLOBAL_PULSE_ROUTE[12]  -->    ADC StartOfConversion
    // GLOBAL_PULSE_ROUTE[13]  -->    Send Start Signal to Ring Oscillators
    // GLOBAL_PULSE_ROUTE[14]  -->    Reset AutoZeroing
    // GLOBAL_PULSE_ROUTE[15]  -->    Route to SYNC Front End AutoZeroing
    wire [15:0] GLOBAL_PULSE_ROUTE;
    wire        global_pulse ;
    //
    // Reset Channel Synchronizer
    logic ResetChSync_b;     // Active low
    always_ff@(posedge Clk160) ResetChSync_b <= (GLOBAL_PULSE_ROUTE[0] == 1'b1) ? ( ~(global_pulse | ~synch_reset_b) ): synch_reset_b;
    //
    // Reset Command Decoder
    logic ResetCmd_b;        // Active low
    always_ff@(posedge Clk160) ResetCmd_b <= (GLOBAL_PULSE_ROUTE[1] == 1'b1) ? ( ~(global_pulse | ~synch_reset_b) ): synch_reset_b;
    //
    // Reset Global Configuration TH: This is problematic for timing and dangerous
    logic ResetGlobalConf_b; // Active low
    always_ff@(posedge Clk160) ResetGlobalConf_b <= (GLOBAL_PULSE_ROUTE[2] == 1'b1) ? ( ~(global_pulse | ~synch_reset_b) ): synch_reset_b; 
    
    //
    // Reset Monitor Data
    logic ResetMonData_b;    // Active low
    always_ff@(posedge Clk160) ResetMonData_b <= (GLOBAL_PULSE_ROUTE[3] == 1'b1) ? ( ~(global_pulse | ~synch_reset_b) ): synch_reset_b;
    //
    // Reset Aurora
    logic ResetAurora;    // Active high
    always_ff@(posedge Clk160) ResetAurora <= (GLOBAL_PULSE_ROUTE[4] == 1'b1) ? (  (global_pulse | ~synch_reset_b) ): ~synch_reset_b;
    //
    // Reset Serializers
    always_ff@(posedge Clk160) SerRstB <= (GLOBAL_PULSE_ROUTE[5] == 1'b1) ? ( ~(global_pulse | ~synch_reset_b) ): 1'b1;
    //
    // ADC reset: Has to be in or with WrMonitoringDataADCRst
    //
    logic WrMonitoringDataADCRst, ADC_RST;
    assign ADC_RST = (~synch_reset_b | WrMonitoringDataADCRst); // Synchronous Active High
    //
    always_ff@(posedge Clk160) ADC_RST_B <= (GLOBAL_PULSE_ROUTE[6] == 1'b1) ? ( ~(global_pulse | ADC_RST )): ~ADC_RST;  // Synchronous Active Low
    //
    // Enable Monitoring
    logic  EnMon, EnMontmp;
    assign EnMontmp          = (GLOBAL_PULSE_ROUTE[8] == 1'b1) ? ( global_pulse ) : 1'b0;
    always_ff @(posedge Clk160) begin : proc_EnMonitor
        if (synch_reset_b == 1'b0) begin
            EnMon <= 1'b0;
        end else if (EnMontmp == 1'b1) begin
            EnMon <= 1'b1;
        end else begin
            EnMon <= EnMon;
        end
    end
    //
    // ADC StartOfConversion
    assign ADC_SOC = (GLOBAL_PULSE_ROUTE[12] == 1'b1) ? global_pulse  : 1'b0 ;
    //
    // Send Start Signal to Ring Oscillators
    //wire   RingOscStart;
    assign RingOscStart      = (GLOBAL_PULSE_ROUTE[13] == 1'b1) ? (global_pulse): 1'b0;
    //
    //     wire   GP_phi_az ;
    assign GP_phi_az = (GLOBAL_PULSE_ROUTE[14] == 1'b1) ? (global_pulse): 1'b0;



    //------------------------------      AutoZeroing signal definition      --------------------------------//
    //
    // 2'b00 = GlobalPulse mode, 2'b01 = CalEdge mode, 2'b10 = FreeRunning mode, 2'b11 = TieHi
    wire [1:0] AutoZeroMode_SYNC ;   
    logic phi_az_pulse ;
    always_comb begin
       case( AutoZeroMode_SYNC[1:0] )
          2'b00   :  phi_az_pulse = GP_phi_az ; 
          2'b01   :  phi_az_pulse = CalEdge ;

          default :  phi_az_pulse = 1'b0 ;    // use free-running or tie-hi modes otherwise

       endcase
    end    
    // free-running mode
    assign FreeRunningAutoZero_SYNC = ( AutoZeroMode_SYNC[1:0] == 2'b10 ) ? 1'b1 : 1'b0 ;
    // tie-hi in case 2'b11
    wire   phi_az_tiehi ;
    assign phi_az_tiehi = ( AutoZeroMode_SYNC[1:0] == 2'b11 ) ? 1'b1 : 1'b0 ;
    // dedicated reset from GlobalPulse
    wire   GP_phi_az_reset_b ;
    assign GP_phi_az_reset_b = (GLOBAL_PULSE_ROUTE[15] == 1'b1) ? (~global_pulse) : 1'b1 ;
    // combine all resets
    wire   phi_az_reset_b ;
    assign phi_az_reset_b = PorResetB & GP_phi_az_reset_b & (~phi_az_tiehi) ;

    phi_az_comb  phi_az_comb (
       .reset_b     ( phi_az_reset_b ),
       .clk         (         Clk160 ),
       .pulse       (   phi_az_pulse ),
       .phi_az_comb (       CmdPhiAZ )
        ) ;
    
    //----------------------------------   RESET TO PIXELS    ------------------------------------//
    //
    wire ecr ; 
    wire ResetOrEcr; // Active High

    assign ResetOrEcr = ecr | (~ synch_reset_b);
    // re-synched trigger at 40 MHz
    always_ff @( posedge Clk40 ) begin
        PixReset   <= ResetOrEcr ; // Active High
    end // always_ff 

    
    //----------------------------------   TRIGGER TO PIXELS    ----------------------------------//
    //
    wire trigger ; 
    // re-synched trigger at 40 MHz
    always_ff @( posedge Clk40 ) begin
        PixTrigger <= trigger;                     
    end // always_ff 

 //   ####   ##   ##    ##     ##   ##  ##   ##  #######  ##                 #####   ##  ##   ##   ##    ####   ##   ##
 //  ##  ##  ##   ##    ##     ###  ##  ###  ##  ##       ##                ##   ##  ##  ##   ###  ##   ##  ##  ##   ##
 // ##       ##   ##   ####    ###  ##  ###  ##  ##       ##                ##        ####    ###  ##  ##       ##   ##
 // ##       #######   ## #    ## # ##  ## # ##  #####    ##                 #####     ##     ## # ##  ##       #######
 // ##       ##   ##  ######   ## # ##  ## # ##  ##       ##                     ##    ##     ## # ##  ##       ##   ##
 //  ##  ##  ##   ##  ##   #   ##  ###  ##  ###  ##       ##                ##   ##    ##     ##  ###   ##  ##  ##   ##
 //   ####   ##   ## ###   ##  ##   ##  ##   ##  #######  ######             #####     ##     ##   ##    ####   ##   ##

    //-------------------------------------   CHANNEL SYNCHRONIZER   ----------------------------------------//

    wire [15:0] rx_data_16 ;
    wire [15:0] LockLossCnt ;
    wire  [4:0] ChSyncLockThr;
    wire  [4:0] ChSyncUnlockThr;
    wire        rx_data_16_ld ;     
    wire        locked ;
    wire        LockLoss;
    wire        WrLockLossCntRst ;
    wire        ch_synch_clk_40 ;                // 40 MHz BX clock derived from 160 MHz recovered clock


    wire StatusEn ;   // from GlobalConfiguration
    assign Status = ( StatusEn == 1'b1 ) ? locked : 1'b0 ;    // send to STATUS pad the "locked" signal


    ChannelSync  ChannelSync (
        // Inputs
        .clk           (           Clk160 ),
        .Reset_b       (    ResetChSync_b ),       // Synchronous reset active low
        .ThrHigh       (    ChSyncLockThr ),       // Temporary value, has to come from configuration register
        .ThrLow        (  ChSyncUnlockThr ),       // Temporary value, has to come from configuration register
        .RxDat         (          CmdData ),
        .WrLockLossCnt ( WrLockLossCntRst ),       // Reset the Lock Loss Counter (comes from GCR)
        // Outputs
        .SyncData      (       rx_data_16 ),       // 16 bit parallel output data
        .SyncDataLoad  (    rx_data_16_ld ),       // when to load data
        .LockLossCnt   (      LockLossCnt ),       // Count how many times we lost lock
        .LockLoss      (         LockLoss ),       // There has been at least one lock loss
        .Clk40MHz      (  ch_synch_clk_40 ),       // 40 MHz clock signal generated from 160 MHz input clock
        .Locked        (           locked )        // Tells if link is locked
                                          ) ;

    // effective 40 MHz BX clock, either from channel synchronizer or from JTAG
    assign Clk40 = ( BypCmd == 1'b1 ) ? JtagTck : ch_synch_clk_40 ; 


 //   ####     ###    ##   ##  ##   ##    ##     ##   ##  #####             #####    #######    ####     ###    #####    #######  ######
 //  ##  ##   ## ##   ##   ##  ##   ##    ##     ###  ##  ##  ##            ##  ##   ##        ##  ##   ## ##   ##  ##   ##       ##   ##
 // ##       ##   ##  ### ###  ### ###   ####    ###  ##  ##   ##           ##   ##  ##       ##       ##   ##  ##   ##  ##       ##   ##
 // ##       ##   ##  ## # ##  ## # ##   ## #    ## # ##  ##   ##           ##   ##  #####    ##       ##   ##  ##   ##  #####    ######
 // ##       ##   ##  ## # ##  ## # ##  ######   ## # ##  ##   ##           ##   ##  ##       ##       ##   ##  ##   ##  ##       ## ##
 //  ##  ##   ## ##   ##   ##  ##   ##  ##   #   ##  ###  ##  ##            ##  ##   ##        ##  ##   ## ##   ##  ##   ##       ##  ##
 //   ####     ###    ##   ##  ##   ## ###   ##  ##   ##  #####             #####    #######    ####     ###    #####    #######  ##   ##

    //---------------------------------------   COMMAND DECODER    ------------------------------------------//

    // **NOTE: actually only the command-decoder FSM requires to be bypassed by JTAG outputs, multiplexers
    //         driven by TRST are included into Cmd.sv
    wire [ 8:0] RegAddrCmd ;
    wire [15:0] RegDataCmd ;
    wire [15:0] BCIDCnt ;
    wire [15:0] TrigCnt ;
    wire [15:0] CmdErrCnt ;
    wire        CmdErr ;
    wire [15:0] BitFlipErrCnt ;
    wire        BitFlipErr;
    wire [15:0] BitFlipWngCnt ;
    wire        BitFlipWng;

    wire WrRegCmd ;
    wire RdRegCmd ;
    wire [4:0] trigger_tag ; // Removed extension to 6 bit of TriggerTag
    wire WrBCIDCntRst;
    wire WrTrigCntRst;
    wire WrCmdErrCntRst;
    wire WrBitFlipWngCntRst;
    wire WrBitFlipErrCntRst;


    Cmd   CommandDecoder (                                // **NOTE: OLD interface!!! Waiting for new RTL

        // normal inputs
        .clk                   (               Clk160 ),
        .Reset_b               (           ResetCmd_b ),
        .ChipId                (               ChipID ),
        .Input                 (           rx_data_16 ),
        .Locked                (               locked ),
        .Load                  (        rx_data_16_ld ),

        // Reset counters signals
        .WrBCIDCnt             (         WrBCIDCntRst ),   // Resets the BCID Counter              (comes from Global Configuration Register)
        .WrTrigCnt             (         WrTrigCntRst ),   // Resets the Trigger Counter           (comes from Global Configuration Register)
        .WrErrCnt              (       WrCmdErrCntRst ),   // Resets the Error Counter             (comes from Global Configuration Register)
        .WrBitFlipWngCnt       (   WrBitFlipWngCntRst ),   // Resets the Bit Flip Warning Counter  (comes from Global Configuration Register)
        .WrBitFlipErrCnt       (   WrBitFlipErrCntRst ),   // Resets the Bit Flip Error Counter    (comes from Global Configuration Register)

 
        // external trigger and JTAG bypass
        .ExtTrigger            (           ExtTrigger ),
        .BypassCmd             (               BypCmd ),
        .JtagTck               (              JtagTck ),
        .JtagChipID            (           JtagChipID ),
        .JtagRegAddr           (          JtagRegAddr ),
        .JtagRegData           (          JtagRegData ),
        .JtagEdgeDly           (          JtagEdgeDly ),
        .JtagEdgeWidth         (        JtagEdgeWidth ),
        .JtagAuxDly            (           JtagAuxDly ),
        .JtagEdgeMode          (         JtagEdgeMode ),
        .JtagAuxMode           (          JtagAuxMode ),
        .JtagGlobalPulseWidth  ( JtagGlobalPulseWidth ),
        .JtagWrReg             (            JtagWrReg ),
        .JtagRdReg             (            JtagRdReg ),
        .JtagECR               (              JtagECR ),
        .JtagBCR               (              JtagBCR ),
        .JtagGenGlobalPulse    (   JtagGenGlobalPulse ),
        .JtagGenCal            (           JtagGenCal ),

        // outputs
        .Trigger               (              trigger ),
        .TriggerTag            (     trigger_tag[4:0] ),
        .ECR                   (                  ecr ),
        .CalEdge               (           CalEdgeCmd ),
        .CalAux                (               CalAux ),
        .WrReg                 (             WrRegCmd ),
        .RdReg                 (             RdRegCmd ),
        .GlobalPulse           (         global_pulse ),
        .RegAddr               (           RegAddrCmd ),      
        .RegData               (           RegDataCmd ),
        .BCIDCnt               (              BCIDCnt ),
        .TrigCnt               (              TrigCnt ),
        .ErrCnt                (            CmdErrCnt ),
        .CmdErr                (               CmdErr ), 
        .BitFlipErrCnt         (        BitFlipErrCnt ),
        .BitFlipErr            (           BitFlipErr ),
        .BitFlipWngCnt         (        BitFlipWngCnt ),
        .BitFlipWng            (           BitFlipWng )
                                                      ) ;
    

 //   ####   ##         ###    ######     ##     ##                  ####     ###    ##   ##  #######  ######     ####   
 //  ##  ##  ##        ## ##   ##   ##    ##     ##                 ##  ##   ## ##   ###  ##  ##         ##      ##  ##  
 // ##       ##       ##   ##  ##   ##   ####    ##                ##       ##   ##  ###  ##  ##         ##     ##       
 // ##       ##       ##   ##  ######    ## #    ##                ##       ##   ##  ## # ##  #####      ##     ##       
 // ##  ###  ##       ##   ##  ##   ##  ######   ##                ##       ##   ##  ## # ##  ##         ##     ##  ###  
 //  ##  ##  ##        ## ##   ##   ##  ##   #   ##                 ##  ##   ## ##   ##  ###  ##         ##      ##  ##  
 //   #####  ######     ###    ######  ###   ##  ######              ####     ###    ##   ##  ##       ######     #####  

   //------------------------------------   GLOBAL CONFIGURATION    ----------------------------------------//

   // 
   wire [7:0][25:0] AutoReadData        ; // Auto Read Registers
   wire [7:0][7:0]  WngFifoFullCnt      ; // Counters that hold the # of Writes when fifo was full
   wire      [25:0] RegDataToMon        ;
   wire             LoadDataMaskRst_b   ; // Reset for LoadDataMask
   wire             NewRegData          ;
   wire      [13:0] ErrWngMask          ; // Mask single Error Warning messages
   wire      [10:0] InitWait            ;
   wire       [7:0] FrameSkip           ;
   wire       [5:0] CCWait              ;
   wire       [1:0] CCSend              ;
   wire       [3:0] ActiveLanes         ; // Lanes active in the Aurora link
   wire       [3:0] WrWngFifoFullCntRst ;
   wire      [19:0] CBWait              ; // Aurora Channel Bonding configuration bits
   wire       [3:0] CBSend              ; // Aurora Channel Bonding configuration bits
   wire             EnSingle32Ser       ;
   wire             EnablePRBS          ;
   wire             SelSerializerType   ; // switch betwee RTL and macro serializers
   wire      [15:3] GP_LVDS_ROUTE_UNUSED; // These bits are NOT used at the moment

   // Auto Read used by Jtag [Only 16 data bits of the register are sent to Jtag]
   assign JtagReadbackData = {AutoReadData[7][15:0], AutoReadData[6][15:0], AutoReadData[5][15:0], AutoReadData[4][15:0], 
                              AutoReadData[3][15:0], AutoReadData[2][15:0], AutoReadData[1][15:0], AutoReadData[0][15:0]};


   wire   ClockGlobalConf ;
   assign ClockGlobalConf = ( ScanMode == 1'b1 ) ? JtagTck : Clk160 ;        

   wire [1:0] DataReadDelay;
   assign WaitReadCnfg = DataReadDelay; // From Glogal Configuration
   
   GlobalConfiguration   GlobalConfiguration (
      //
      // Inputs
      //
      .ClkCmd           (           ClockGlobalConf ),
      .GC_Reset_Async_b ( asynch_reset_b_deglitched ), // Asynchronous active low (Just for Global Configuration Registers)
      .GC_Reset_b       (         ResetGlobalConf_b ), //  Synchronous active low
      .WrRegCmd         (                  WrRegCmd ), // Write data to a register
      .RdRegCmd         (                  RdRegCmd ), // Read back a value
      .RegAddrCmd       (                RegAddrCmd ), // Address of the register
      .RegDataCmd       (                RegDataCmd ), // Data to be written
      .DataConfRd       (                DataConfRd ), // Data to be read from the Pixels
      //
      .RING_OSC_0       (                RING_OSC_0 ), // Counter value of ring oscillator #0
      .RING_OSC_1       (                RING_OSC_1 ), // Counter value of ring oscillator #1
      .RING_OSC_2       (                RING_OSC_2 ), // Counter value of ring oscillator #2
      .RING_OSC_3       (                RING_OSC_3 ), // Counter value of ring oscillator #3
      .RING_OSC_4       (                RING_OSC_4 ), // Counter value of ring oscillator #4
      .RING_OSC_5       (                RING_OSC_5 ), // Counter value of ring oscillator #5
      .RING_OSC_6       (                RING_OSC_6 ), // Counter value of ring oscillator #6
      .RING_OSC_7       (                RING_OSC_7 ), // Counter value of ring oscillator #7
      //
      // Counters
      .BCIDCnt           (                  BCIDCnt ), // BCID counter value                    [from Command Decoder]
      .TrigCnt           (                  TrigCnt ), // Trigger counter value                 [from Command Decoder]
      .LockLossCnt       (              LockLossCnt ), // LockLossCnt counter value             [from Channel Synchronizer]
      .BitFlipWngCnt     (            BitFlipWngCnt ), // BitFlipWngCnt counter value           [from Command Decoder]
      .BitFlipErrCnt     (            BitFlipErrCnt ), // BitFlipErrCnt counter value           [from Command Decoder]
      .CmdErrCnt         (                CmdErrCnt ), // CmdErrCnt counter value               [from Command Decoder]
      .SkippedTriggerCnt (        SkippedTriggerCnt ), // Skipped Trigger counter               [from Pixel Array]
      .MonitoringDataADC (        MonitoringDataADC ), // Contains the value of the ADC to be read back
      // From the Pixel Region
      .HitOr             (            PixHitOr_sync ), // HitOr bus to be counted here [synchronized]
      //
      // Outputs
      //
      .AddressConfCore   (          AddressConfCore ), // Where, inside the core, we have to write data
      .AddressConfCol    (           AddressConfCol ), // In which column we have to write data
      .DataConfWr        (               DataConfWr ), // Data to be written it the pixel 
      .ConfWr            (                   ConfWr ), // There is some data to be written
      .DefaultPixelConf  (         DefaultPixelConf ), // Pixel Default Configuration 
      .EnCoreColBroadcast(  EnCoreColBroadcast[2:0] ), // Enable broadcast to all Front Ends
      .WrRingOscCntRst   (          WrRingOscCntRst ), // Reset bus for the Ring Oscillator counters
      // To MonitorData
      .LoadDataMaskRst_b (        LoadDataMaskRst_b ), // Synchronous Active low
      .NewRegData        (               NewRegData ), // There is new data to store in the monitor Fifo
      .RegData           (             RegDataToMon ), // Data to store in the monitor Fifo
      .AutoReadData      (             AutoReadData ), // Auto Read Registers
      //
      // Pixel Matrix Section
      //
      // SYNC Front End
      .IBIASP1_SYNC      (             IBIASP1_SYNC ), // Current of the main branch of the CSA
      .IBIASP2_SYNC      (             IBIASP2_SYNC ), // Current of the splitting branch of the CSA
      .IBIAS_SF_SYNC     (            IBIAS_SF_SYNC ), // Current of the preamplifier SF
      .IBIAS_KRUM_SYNC   (          IBIAS_KRUM_SYNC ), // Current of the Krummenacher feedback
      .IBIAS_DISC_SYNC   (          IBIAS_DISC_SYNC ), // Current of the Comparator Diff Amp
      .ICTRL_SYNCT_SYNC  (         ICTRL_SYNCT_SYNC ), // Current of the oscillator delay line
      .VBL_SYNC          (                 VBL_SYNC ), // Baseline voltage for offset compens
      .VTH_SYNC          (                 VTH_SYNC ), // Discriminator threshold voltage
      .VREF_KRUM_SYNC    (           VREF_KRUM_SYNC ), // Krummenacher voltage reference
      .SelC2F_SYNC       (              SelC2F_SYNC ), // Connect to SYNC Front End
      .SelC4F_SYNC       (              SelC4F_SYNC ), // Connect to SYNC Front End
      .FastEn_SYNC       (              FastEn_SYNC ), // Connect to SYNC Front End
      .AutoZeroMode_SYNC (        AutoZeroMode_SYNC ), // 2'b00 = GlobalPulse mode, 2'b01 = CalEdge mode, 2'b10 = FreeRunning mode, 2'b11 = TieHi
      // LIN Front End
      .PA_IN_BIAS_LIN    (           PA_IN_BIAS_LIN ), // preampli input branch current
      .FC_BIAS_LIN       (              FC_BIAS_LIN ), // folded cascode branch current
      .KRUM_CURR_LIN     (            KRUM_CURR_LIN ), // Krummenacher current
      .LDAC_LIN          (                 LDAC_LIN ), // fine threshold
      .COMP_LIN          (                 COMP_LIN ), // Comparator current
      .REF_KRUM_LIN      (             REF_KRUM_LIN ), // Krummenacher reference voltage
      .Vthreshold_LIN    (           Vthreshold_LIN ), // Global threshold voltage
      // DIFF Front End
      .PRMP_DIFF         (                PRMP_DIFF ), // Preamp input stage current
      .FOL_DIFF          (                 FOL_DIFF ), // Preamp output follower current
      .PRECOMP_DIFF      (             PRECOMP_DIFF ), // Precomparator tail current
      .COMP_DIFF         (                COMP_DIFF ), // Comparator total current
      .VFF_DIFF          (                 VFF_DIFF ), // Preamp feedback current (return to baseline)
      .VTH1_DIFF         (                VTH1_DIFF ), // Negative branch voltage offset (vth1)
      .VTH2_DIFF         (                VTH2_DIFF ), // Positive branch voltage offset (vth2)
      .LCC_DIFF          (                 LCC_DIFF ), // Leakage current compensation current
      .LCC_X_DIFF        (               LCC_X_DIFF ), // Connect leakace current comp. circuit
      .FF_CAP_DIFF       (              FF_CAP_DIFF ), // Select preamp feedback capacitance
      //
      // Power Section
      //
      .SLDOAnalogTrim    (           SLDOAnalogTrim ), // Analog and Digital voltage regulator trim
      .SLDODigitalTrim   (          SLDODigitalTrim ), // Analog and Digital voltage regulator trim
      // 
      // Digital Matrix Section
      //
      .EN_CORE_COL_SYNC  (         EN_CORE_COL_SYNC ), // Enable Core (SYNC Front End)
      .WR_SYNC_DELAY_SYNC(       WR_SYNC_DELAY_SYNC ), // Write Synchronization delay (SYNC)
      .EN_CORE_COL_LIN   (          EN_CORE_COL_LIN ), // Enable Core (LIN Front End)
      .EN_CORE_COL_DIFF  (         EN_CORE_COL_DIFF ), // Enable Core (DIFF Front End)
      .LATENCY_CONFIG    (           LATENCY_CONFIG ), // Latency value stored in configuration register
      //
      // Functions Section
      //
      .AnalogInjectionMode    (       AnalogInjectionMode ), // Analog injection
      .DigitalInjectionEnable (    DigitalInjectionEnable ), // Digital injection
      .InjectionFineDelay     (        InjectionFineDelay ), // Injection fine delay
      .SelClkPhase            (               SelClkPhase ), // Clock phase selection
      .ClkFineDelay           (              ClkFineDelay ), // Clock fine delay
      .DataFineDelay          (             DataFineDelay ), // Data fine delay
      .VCAL_HIGH              (                 VCAL_HIGH ), // VCAL high
      .VCAL_MED               (                  VCAL_MED ), // VCAL med
      .ChSyncPhaseAdj         (  /* TBD */                ), //  Threshold and Phase adjust settings for the Channel Synchronizer
      .ChSyncLockThr          (             ChSyncLockThr ), // Lock threshold for the Channel Synchronizer
      .ChSyncUnlockThr        (           ChSyncUnlockThr ), // Unlock threshold for the Channel Synchronizer
      .GLOBAL_PULSE_ROUTE     (        GLOBAL_PULSE_ROUTE ), // Global pulse routing select
      .MONITOR_FRAME_SKIP     (                 FrameSkip ), //  How many Data frames to skip before sending a Monitor Frame
      .EN_MACRO_COL_CAL_SYNC  (     EN_MACRO_COL_CAL_SYNC ), // Enable macrocolumn analog calibrationfor the SYNC frontend 
      .EN_MACRO_COL_CAL_LIN   (      EN_MACRO_COL_CAL_LIN ), // Enable macrocolumn analog calibrationfor the LIN frontend 
      .EN_MACRO_COL_CAL_DIFF  (     EN_MACRO_COL_CAL_DIFF ), // Enable macrocolumn analog calibrationfor the DIFF frontend 
      //
      // I/O Section
      //
      .CML_TAP0_BIAS     (            CML_TAP0_BIAS ), // Bias current 0 for CML driver
      .CML_TAP1_BIAS     (            CML_TAP1_BIAS ), // Bias current 1 for CML driver
      .CML_TAP2_BIAS     (            CML_TAP2_BIAS ), // Bias current 2 for CML driver
      .CDR_CP_IBIAS      (             CDR_CP_IBIAS ), // Bias current for CP of CDR
      .CDR_VCO_IBIAS     (            CDR_VCO_IBIAS ), // Bias current for VCO of CDR
      .CDR_VCO_BUFF_BIAS (        CDR_VCO_BUFF_BIAS ), // Bias current for VCO buffer of CDR
      .CDR_PD_SEL        (               CDR_PD_SEL ), // CDR Configuration
      .CDR_PD_DEL        (          CDR_PD_DEL[3:0] ), // CDR Configuration
      .CDR_EN_GCK2       (              CDR_EN_GCK2 ), // CDR Configuration
      .CDR_VCO_GAIN      (             CDR_VCO_GAIN ), // CDR Configuration
      .CDR_SEL_SER_CLK   (          CDR_SEL_SER_CLK ), // CDR Configuration
      .CDR_SEL_DEL_CLK   (           CDR_SEL_DEL_CLK), // CDR Configuration
      .SER_INV_TAP       (              SER_INV_TAP ), // 20bit Serializer Output Settings
      .SER_EN_TAP        (               SER_EN_TAP ), // 20bit Serializer Output Settings
      .CML_EN_LANE       (              CML_EN_LANE ), // 20bit Serializer Output Settings
      .SerSelOut0        (            SER_SEL_OUT_0 ), // 20bit Serializer Output Select
      .SerSelOut1        (            SER_SEL_OUT_1 ), // 20bit Serializer Output Select
      .SerSelOut2        (            SER_SEL_OUT_2 ), // 20bit Serializer Output Select
      .SerSelOut3        (            SER_SEL_OUT_3 ), // 20bit Serializer Output Select
      .ActiveLanes       (              ActiveLanes ), // Lanes active in the Aurora link
      .SelSerializerType (        SelSerializerType ), // SelSerializerType = 1'b0 => Bonn, 1'b1 = RTL serializers
      .DataReadDelay     (       DataReadDelay[1:0] ), // Delay of Data readout
      .EnableExtCal      (             EnableExtCal ), // Enable external calibration with backup injection strobes
      .EnablePRBS        (               EnablePRBS ), // Aurora configuration bits
      .CCWait            (                   CCWait ), // Aurora configuration bits
      .CCSend            (                   CCSend ), // Aurora configuration bits
      .CBWait            (                   CBWait ), // Aurora Channel Bonding configuration bits
      .CBSend            (                   CBSend ), // Aurora Channel Bonding configuration bits
      .AURORA_INIT_WAIT  (                 InitWait ), // Aurora configuration bits
      .JTAG_TDO_DS       (                JtagTdoDs ), // LVDS Configuration
      .STATUS_DS         (                 StatusDs ), // LVDS Configuration
      .STATUS_EN         (                 StatusEn ), // LVDS Configuration
      .LANE0_LVDS_EN_B   (          LANE0_LVDS_EN_B ), // LVDS Configuration
      .LANE0_LVDS_BIAS   (          LANE0_LVDS_BIAS ), // LVDS Configuration
      .GP_LVDS_EN_B      (             GP_LVDS_EN_B ), // General Pourpose LVDS Enable
      .GP_LVDS_BIAS      (             GP_LVDS_BIAS ), // General Pourpose LVDS Bias
      .GP_LVDS_ROUTE     ( {GP_LVDS_ROUTE_UNUSED[15:3],GP_LVDS_ROUTE[2:0]} ), // General Pourpose Output routing configuration
      //
      // Test Section
      //
      .MonitorEnable     (            MonitorEnable ), // Enable Monitoring Blocks
      .V_MONITOR_SELECT  (         V_MONITOR_SELECT ), // Voltage monitoring MUX selec
      .I_MONITOR_SELECT  (         I_MONITOR_SELECT ), // Current monitoring MUX selection
      .HITOR_MASK        (               HITOR_MASK ), // Mask bits for the HitOr
      .MON_BG_TRIM       (              MON_BG_TRIM ), // ADC Band gap trimming
      .MON_ADC_TRIM      (             MON_ADC_TRIM ), // ADC trimming bits
      .SENS_ENABLE0      (             SENS_ENABLE0 ), // Enable temp/rad sensors
      .SENS_DEM0         (           SENS_DEM0[3:0] ), // Dynamic element matching bits
      .SEN_SEL_BIAS0     (            SEN_SEL_BIAS0 ), // Current bias select 
      .SENS_ENABLE1      (             SENS_ENABLE1 ), // Enable temp/rad sensors
      .SENS_DEM1         (           SENS_DEM1[3:0] ), // Dynamic element matching bits
      .SEN_SEL_BIAS1     (            SEN_SEL_BIAS1 ), // Current bias select 
      .SENS_ENABLE2      (             SENS_ENABLE2 ), // Enable temp/rad sensors
      .SENS_DEM2         (           SENS_DEM2[3:0] ), // Dynamic element matching bits
      .SEN_SEL_BIAS2     (            SEN_SEL_BIAS2 ), // Current bias select 
      .SENS_ENABLE3      (             SENS_ENABLE3 ), // Enable temp/rad sensors
      .SENS_DEM3         (           SENS_DEM3[3:0] ), // Dynamic element matching bits
      .SEN_SEL_BIAS3     (            SEN_SEL_BIAS3 ), // Current bias select 
      .RING_OSC_ENABLE   (          RING_OSC_ENABLE ), // Enable Ring Oscillator
      //
      // Diagnostics Section
      //
      .ErrWngMask             (             ErrWngMask ), // Mask single Error Warning messages
      .WngFifoFullCnt         (         WngFifoFullCnt ), // Counters that hold the # of Writes when fifo was full [7:0][7:0]
      .WrBCIDCntRst           (           WrBCIDCntRst ), // Resets the BCID Counter              [in Command Decoder]
      .WrTrigCntRst           (           WrTrigCntRst ), // Resets the Trigger Counter           [in Command Decoder]
      .WrLockLossCntRst       (       WrLockLossCntRst ), // Resets the Lock Loss Counter         [in Channel Syncronizer]
      .WrCmdErrCntRst         (         WrCmdErrCntRst ), // Resets the Error Counter             [in Command Decoder]
      .WrBitFlipWngCntRst     (     WrBitFlipWngCntRst ), // Resets the Bit Flip Warning Counter  [in Command Decoder]
      .WrBitFlipErrCntRst     (     WrBitFlipErrCntRst ), // Resets the Bit Flip Error Counter    [in Command Decoder]
      .WrMonitoringDataADCRst ( WrMonitoringDataADCRst ), // Resets the Monitoring ADC            [in Analog Chip Bottom]
      .WrSkippedTriggerCntRst ( WrSkippedTriggerCntRst ), // Resets the Skipped Trigger Counter   [in Pixel Array]
      .WrWngFifoFullCntRst    (    WrWngFifoFullCntRst )  // Reset for the WngFifoFullCnt counter [in Monitor Data]
                                                       ) ;






 // #####      ##     ######     ##                ####     ###    ##   ##    ####   #######  ##   ##  ######   ######     ##     ######     ###    ######
 // ##  ##     ##       ##       ##               ##  ##   ## ##   ###  ##   ##  ##  ##       ###  ##    ##     ##   ##    ##       ##      ## ##   ##   ##
 // ##   ##   ####      ##      ####             ##       ##   ##  ###  ##  ##       ##       ###  ##    ##     ##   ##   ####      ##     ##   ##  ##   ##
 // ##   ##   ## #      ##      ## #             ##       ##   ##  ## # ##  ##       #####    ## # ##    ##     ######    ## #      ##     ##   ##  ######
 // ##   ##  ######     ##     ######            ##       ##   ##  ## # ##  ##       ##       ## # ##    ##     ## ##    ######     ##     ##   ##  ## ##
 // ##  ##   ##   #     ##     ##   #             ##  ##   ## ##   ##  ###   ##  ##  ##       ##  ###    ##     ##  ##   ##   #     ##      ## ##   ##  ##
 // #####   ###   ##    ##    ###   ##             ####     ###    ##   ##    ####   #######  ##   ##    ##     ##   ## ###   ##    ##       ###    ##   ##

   //-------------------------------------   DATA CONCENTRATOR   -------------------------------------------//


   // internal connections to/from the output CDC FIFO 

   wire [31:0] concentrator_data_out ;
   wire concentrator_data_eof ;        // End-of-Frame flag
   wire cdc_fifo_write ;
   wire cdc_fifo_full ;

   wire [`COLS-1:0] concentrator_full ;
   assign ReadyCol = ~concentrator_full ;

   `ifndef EN_SIMPLE_TB

   DataConcentrator   DataConcentrator (

      .ClkIn               (                  Clk40 ),
      .ClkOut              (                 Clk160 ),
      .Reset               (               PixReset ),  // Active High
      .Write               (           DataReadyCol ),
      .DataIn              (                DataCol ),
      .TriggerId           (        TrigIdReqColBin ),
      .TriggerTag          (        trigger_tag[4:0]),
      .TriggerAccept       (           TriggerAccept),
      .RowId               (                 RowCol ),
      .Full                (      concentrator_full ),
      .TriggerCmd40        (             PixTrigger ),
      .BCIDCnt             (                BCIDCnt ),
      .TriggerIdGlobal     (           TriggerIdCnt ),
      .TriggerIdCurrentReq (    TriggerIdCurrentReq ),
      .DstReady            (         ~cdc_fifo_full ),
      .SrcReady            (         cdc_fifo_write ),
      .Data                (  concentrator_data_out ),
      .Sof                 ( /* Not needed     */   ),
      .Eof                 (  concentrator_data_eof )

      ) ;

    `endif

   //-------------------------   SER AND CDC FIFO/AURORA CLOCK MULTIPLEXING   ------------------------------//


   // bypass CDC FIFO/Aurora clock with strobes generated by RTL serializers
   wire cdc_fifo_rclk ;
   wire backup_data_clk ;     

   assign cdc_fifo_rclk = ( (DebugEn == 1'b1) && ( SelSerializerType == 1'b1 ) ) ? backup_data_clk : DataClk ;   // **NOTE: SelSerializerType = 1'b0 => use Bonn serializers, 1'b1 = use RTL serializers








 //   ###    ##   ##  ######   ######   ##   ##  ######              ####   #####      ####            #######  ######   #######    ###
 //  ## ##   ##   ##    ##     ##   ##  ##   ##    ##               ##  ##  ##  ##    ##  ##           ##         ##     ##        ## ##
 // ##   ##  ##   ##    ##     ##   ##  ##   ##    ##              ##       ##   ##  ##                ##         ##     ##       ##   ##
 // ##   ##  ##   ##    ##     ######   ##   ##    ##              ##       ##   ##  ##                #####      ##     #####    ##   ##
 // ##   ##  ##   ##    ##     ##       ##   ##    ##              ##       ##   ##  ##                ##         ##     ##       ##   ##
 //  ## ##   ##   ##    ##     ##       ##   ##    ##               ##  ##  ##  ##    ##  ##           ##         ##     ##        ## ##
 //   ###     #####     ##     ##        #####     ##                ####   #####      ####            ##       ######   ##         ###

   //--------------------------------------   OUTPUT CDC FIFO   --------------------------------------------//

    //
    // Aurora read-reset
    wire ResetAuroraSync;
    //
    CdcResetSync AuroraResetSync(
        // Outputs
        .pulse_out  ( ResetAuroraSync ),
        // Inputs
        .clk_in     (          Clk160 ),
        .clk_out    (   cdc_fifo_rclk ),
        .pulse_in   (     ResetAurora )
        );
        

    // CDC FIFO read-reset
    CdcResetSync CdcResetSync(
        // Outputs
        .pulse_out  ( cdc_fifo_rrst ),
        // Inputs
        .clk_in     (        Clk160 ),
        .clk_out    ( cdc_fifo_rclk ),
        .pulse_in   (    ResetOrEcr )
        );


   // internal connections
   wire cdc_fifo_read ;           // **NOTE: effective read-FIFO strobe, either from data-alignment FIFO or from JTAG (see below)
   wire cdc_fifo_empty ;
   wire align_fifo_full ;

   wire [32:0] cdc_fifo_data_in ;
   wire [32:0] cdc_fifo_data_out ;

   assign cdc_fifo_data_in = { concentrator_data_eof, concentrator_data_out } ;

   assign cdc_fifo_read = ~align_fifo_full ;

   `ifndef EN_SIMPLE_TB
   OutputCdcFifo  #( .DSIZE(33), .ASIZE(9) )  OutputCdcFifo (

      .rempty  (    cdc_fifo_empty ),
      .wdata   (  cdc_fifo_data_in ),
      .winc    (    cdc_fifo_write ),
      .wclk    (            Clk160 ),            // write clock at 160 MHz
      .wrst    (        ResetOrEcr ),
      .rdata   ( cdc_fifo_data_out ),
      .wfull   (     cdc_fifo_full ),
      .rinc    (     cdc_fifo_read ),
      .rclk    (            Clk160 ),            // read clock
      .rrst    (        ResetOrEcr )

      ) ;
    `endif







 // #####      ##     ######     ##                ##     ##       ######     ####   ##   ##           #######  ######   #######    ###
 // ##  ##     ##       ##       ##                ##     ##         ##      ##  ##  ###  ##           ##         ##     ##        ## ##
 // ##   ##   ####      ##      ####              ####    ##         ##     ##       ###  ##           ##         ##     ##       ##   ##
 // ##   ##   ## #      ##      ## #    #######   ## #    ##         ##     ##       ## # ##           #####      ##     #####    ##   ##
 // ##   ##  ######     ##     ######            ######   ##         ##     ##  ###  ## # ##           ##         ##     ##       ##   ##
 // ##  ##   ##   #     ##     ##   #            ##   #   ##         ##      ##  ##  ##  ###           ##         ##     ##        ## ##
 // #####   ###   ##    ##    ###   ##          ###   ##  ######   ######     #####  ##   ##           ##       ######   ##         ###

   //-------------------------------------   DATA-ALIGNMENT FIFO   -----------------------------------------//

   wire [7:0][31:0] data_to_aurora ;      // 256-bit data fed to Aurora
   wire [7:0] mask_to_aurora ;
   wire eof_to_aurora ;
   wire empty_to_aurora ;
   wire read_from_aurora ;


    //
    wire   [1:0] NumActiveLanes;
    wire   align_fifo_write ;
    assign align_fifo_write = ~cdc_fifo_empty ;
    //
    `ifndef EN_SIMPLE_TB
    
    wire [7:0][31:0] data_to_aurora_fifo;
    wire [7:0] mask_to_aurora_fifo ;
    wire eof_to_aurora_fifo ;
    wire empty_to_aurora_fifo ;
    wire full_aurora_fifo ;
   
    AlignData AlignData (  
        .Clk            (                   Clk160 ),
        .Reset          (                ResetOrEcr ),
        .ActiveLanes    (       NumActiveLanes[1:0] ), // Number of Active LAnes (1, 2, 3, 4)
        .Full           (           align_fifo_full ),
        .DataWrite      (   cdc_fifo_data_out[31:0] ),
        .EofWrite       (     cdc_fifo_data_out[32] ),
        .Write          (          align_fifo_write ),
        .Empty          (      empty_to_aurora_fifo ),
        .DataRead       (       data_to_aurora_fifo ),
        .ByteEnableRead (       mask_to_aurora_fifo ),
        .EofRead        (        eof_to_aurora_fifo ),
        .Read           (         ~full_aurora_fifo )
    );
                                                    
                                                    
    OutputCdcFifo  #( .DSIZE(265), .ASIZE(4) )  OutputCdcFifoAurora (
      .rempty  (                                                empty_to_aurora ),
      .wdata   ( {eof_to_aurora_fifo, mask_to_aurora_fifo, data_to_aurora_fifo} ),
      .winc    (                                          ~empty_to_aurora_fifo ),
      .wclk    (                                                         Clk160 ),            
      .wrst    (                                                     ResetOrEcr ),
      .rdata   (                {eof_to_aurora, mask_to_aurora, data_to_aurora} ),
      .wfull   (                                               full_aurora_fifo ),
      .rinc    (                                               read_from_aurora ),
      .rclk    (                                                  cdc_fifo_rclk ),   
      .rrst    (                                                  cdc_fifo_rrst )
    ) ;
      
    `endif
 //                              ##       ##                                           ##
 // ##   ##                      ##       ##                       #####               ##
 // ##   ##                               ##                       ##  ##              ##
 // ### ###   #####   ## ###   ####     ######    #####   ## ###   ##   ##   ######  ######    ######
 // ## # ##  ##   ##  ###  ##    ##       ##     ##   ##  ###      ##   ##  ##   ##    ##     ##   ##
 // ## # ##  ##   ##  ##   ##    ##       ##     ##   ##  ##       ##   ##  ##   ##    ##     ##   ##
 // ##   ##  ##   ##  ##   ##    ##       ##     ##   ##  ##       ##  ##   ##  ###    ##     ##  ###
 // ##   ##   #####   ##   ##  ######      ###    #####   ##       #####     ### ##     ###    ### ##

    //----------------------------------------    MonitorData   ---------------------------------------------//
    wire    [255:0] MonData        ;
    wire            Monitor_empty  ; 
    wire            Monitor_read   ;

    // 
    // Synchronize Monitor_empty
    //
    TwoFFSync TwoFFSync(
        // Outputs
        .Pulse_out  ( Monitor_empty_sync), // Output pulse
        // Inputs
        .Clk_in     (            Clk160 ), // Input clock
        .Clk_out    (     cdc_fifo_rclk ), // Output clock
        .Pulse_in   (     Monitor_empty )  // Input pulse
        );

    `ifndef EN_SIMPLE_TB
    MonitorData MonitorData (
        // Outputs
        .MonData              (        MonData[255:0] ), // Monitoring Data  [to Aurora]
        .MonitorEmpty         (         Monitor_empty ), // 
        .FifoFullCnt          (        WngFifoFullCnt ), // Counters that hold the # of Writes when fifo was full
        .NumActiveLanes       (   NumActiveLanes[1:0] ), // Number of Active LAnes (1, 2, 3, 4)
        // Inputs
        .Clk160               (                Clk160 ), // 160 MHz clock
        .ReadClk              (         cdc_fifo_rclk ), // Clock used to read data for Aurora
        .Reset_b              (        ResetMonData_b ), // Synchronous Active low
        .LoadDataMaskRst_b    (     LoadDataMaskRst_b ), // Synchronous Active low
        .EnMon                (                 EnMon ), // If true Monitoring data is active
        // From Global Configuration 
        .ActiveLanes          (      ActiveLanes[3:0] ), // Lanes active in the Aurora link
        .WrWngFifoFullCntRst  (  WrWngFifoFullCntRst ), // Reset for the WngFifoFullCnt counter [in Monitor Data]
        .FrameSkip            (             FrameSkip ), // # of Frames to skip before sending next data
        .MonitorRead          (          Monitor_read ), // Monitor Data processed by Aurora (Active when reading data)
        .NewRegData           (            NewRegData ), // There is new data to store in the monitor Fifo
        .RegData              (          RegDataToMon ), // Data to store in the monitor Fifo
        .AutoReadData         (          AutoReadData ), // Auto Read Registers
        .ErrWngMask           (            ErrWngMask ), // Mask single Error Warning messages

        // Error & Warning signals
        .LockLoss             (              LockLoss ), // Channel Sync has been out of lock
        .ChSyncOutOfLock      (               ~locked ), // Channel Sync is out of lock
        .SkippedTriggerCntErr (  SkippedTriggerCntErr ), // There is at least one Skipped Trigger [from Pixel Array]
        .CmdErr               (                CmdErr ), // Command Decoder Error [from Command Decoder] 
        .BitFlipErr           (            BitFlipErr ), // BitFlip Error         [from Command Decoder]
        .BitFlipWng           (            BitFlipWng )  // BitFlip Warning       [from Command Decoder]
                                                      );
    `endif
//    ##     ##   ##  ######     ###    ######     ##              #######  ##   ##    ####     ###    #####    #######  ######
//    ##     ##   ##  ##   ##   ## ##   ##   ##    ##              ##       ###  ##   ##  ##   ## ##   ##  ##   ##       ##   ##
//   ####    ##   ##  ##   ##  ##   ##  ##   ##   ####             ##       ###  ##  ##       ##   ##  ##   ##  ##       ##   ##
//   ## #    ##   ##  ######   ##   ##  ######    ## #             #####    ## # ##  ##       ##   ##  ##   ##  #####    ######
//  ######   ##   ##  ## ##    ##   ##  ## ##    ######            ##       ## # ##  ##       ##   ##  ##   ##  ##       ## ##
//  ##   #   ##   ##  ##  ##    ## ##   ##  ##   ##   #            ##       ##  ###   ##  ##   ## ##   ##  ##   ##       ##  ##
// ###   ##   #####   ##   ##    ###    ##   ## ###   ##           #######  ##   ##    ####     ###    #####    #######  ##   ##
    
   

   //-----------------------------------   AURORA 64b/66b ENCODER   ----------------------------------------//

   // multiple-lanes output boundles to 4x 1.6 Gb/s serializers
   wire [3:0][19:0] tx_data1G ;

   // single-lane output boundle to 5 Gb/s serializer
   wire [31:0] tx_data5G ;


   Aurora64b66b_Frame_Multilane_top #( .IW_WIDTH(11), .CCW_WIDTH(6), .CCS_WIDTH(2) , .CBW_WIDTH(20), .CBS_WIDTH(4)) 
   Aurora64b66b_Frame_Multilane_top (

      .Clk                          (       cdc_fifo_rclk ),
      .Rst                          (     ResetAuroraSync ), // Synchronized reset for Aurora (Active High)
      .EnableSingle32bitSerializer  (                1'b0 ), // Option not implemented (no 5 GHz serializer) 
      .ActiveLanes                  (    ActiveLanes[3:0] ), // Lanes active in the Aurora link
      .EnablePRBS                   (          EnablePRBS ), // Pseudo-Random Bit Stream
      .DataEOC                      (      data_to_aurora ),
      .DataMask                     (      mask_to_aurora ),
      .DataEOC_empty                (     empty_to_aurora ), 
      .DataEOC_EOF                  (       eof_to_aurora ),
      .DataEOC_read                 (    read_from_aurora ),
      .Monitor                      (      MonData[255:0] ), // Data coming from Monitoring block (has higher priority than normal data)
      .Monitor_empty                (  Monitor_empty_sync ), 
      .Monitor_read                 (        Monitor_read ),
      .ToSerializer20               (           tx_data1G ),
      .ToSerializer32               (           tx_data5G ),
      .SerializerLock               (                1'b1 ), // There is no Lock signal coming from the PLL
      .InitWait                     (            InitWait ),
      .CBWait                       (              CBWait ), //  Aurora Channel Bonding configuration bits
      .CBSend                       (              CBSend ), //  Aurora Channel Bonding configuration bits
      .CCWait                       (              CCWait ),
      .CCSend                       (              CCSend )
                                                          ) ;
/*
   assign SerData1G_0 = tx_data1G[0][19:0] ;
   assign SerData1G_1 = tx_data1G[1][19:0] ;
   assign SerData1G_2 = tx_data1G[2][19:0] ;
   assign SerData1G_3 = tx_data1G[3][19:0] ;
*/

    always@(posedge cdc_fifo_rclk) begin
        SerData1G_0 <= tx_data1G[0][19:0] ;
        SerData1G_1 <= tx_data1G[1][19:0] ;
        SerData1G_2 <= tx_data1G[2][19:0] ;
        SerData1G_3 <= tx_data1G[3][19:0] ;
    end


   //assign SerData5G = tx_data5G ;        // **TODO: remove GWT output




   //----------------------------------    BACKUP RTL SERIALIZERS   ----------------------------------------//

   wire [3:0] backup_en_lane ;

   assign backup_en_lane[0] = DebugEn & SelSerializerType & ActiveLanes[0] ;
   assign backup_en_lane[1] = DebugEn & SelSerializerType & ActiveLanes[1] ;
   assign backup_en_lane[2] = DebugEn & SelSerializerType & ActiveLanes[2] ;
   assign backup_en_lane[3] = DebugEn & SelSerializerType & ActiveLanes[3] ;



   BackupSerializers #( .DATA_WIDTH(20) ) BackupSerializers (

      .DATA_0            (  tx_data1G[0][19:0] ),
      .DATA_1            (  tx_data1G[1][19:0] ),
      .DATA_2            (  tx_data1G[2][19:0] ),
      .DATA_3            (  tx_data1G[3][19:0] ),
      .BackupEnLane      ( backup_en_lane[3:0] ),
      .BackupSerClk      (           CdrDelClk ),    
      .BackupDataClk     (     backup_data_clk ),    // to Aurora/CDC fifo
      .BackupSerOutput_0 (   BackupSerOutput_0 ),
      .BackupSerOutput_1 (   BackupSerOutput_1 ),
      .BackupSerOutput_2 (   BackupSerOutput_2 ),
      .BackupSerOutput_3 (   BackupSerOutput_3 )

      ) ;


   //------------------------------------------------------------------------------

   `ifdef TEST_JTAG_SCAN_CHAIN    // for JTAG RTL simulations purpose only, emulate a scan-chain inserted for GCRs

   wire   ScanClock ;
   assign ScanClock = ( ScanMode == 1'b1 ) ? JtagTck : Clk160 ;

   logic [`SCAN_CHAIN_LENGTH-1:0] shift_reg ;   // SCAN_CHAIN_LENGTH defined in testbench

   always_ff @( posedge ScanClock or negedge asynch_reset_b_deglitched ) begin    // **NOTE: GCR FFs are resetted by deglitched POR reset

      if(  asynch_reset_b_deglitched == 1'b0 )
         shift_reg <= 'b0 ;

      else if( ScanEn )
         shift_reg[`SCAN_CHAIN_LENGTH-1:0] <= { ScanIn , shift_reg[`SCAN_CHAIN_LENGTH-1:1] } ;   // shift-right

   end  // always_ff

   assign ScanOut = shift_reg[0] ;

   `endif

   //------------------------------------------------------------------------------

   `endif   // ABSTRACT

endmodule : DigitalChipBottom

`endif

`default_nettype wire

