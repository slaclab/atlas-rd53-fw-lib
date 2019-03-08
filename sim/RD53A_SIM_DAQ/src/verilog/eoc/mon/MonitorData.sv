//----------------------------------------------------------------------------------------------------------------------
// [Filename]       MonitorData.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Roberto Beccherle - Roberto.Beccherle@cern.ch
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        09/03/2017
// [Description]    Send Monitoring data to the Aurora block
//
// [Clock]          - Clk160 is the 160 MHz clock
// [Reset]          - Reset_b (Synchronous active low) 
// 
// [Change history] 09/03/2017 - Version 1.0
//                             Initial release
// 
//----------------------------------------------------------------------------------------------------------------------
//
// [Dependencies]
//
// $RTL_DIR/RD53A_defines.sv
//
// $RTL_DIR/eoc/CdcResetSync.v
//
// $RTL_DIR/eoc/mon/MonMemory.sv
// $RTL_DIR/eoc/mon/MonFSM.sv
// $RTL_DIR/eoc/mon/MonCDCSync.sv
//----------------------------------------------------------------------------------------------------------------------
//
// Data Format
//
// [255:0]      MonData = {4{FrameData[63:0]}}
//  [63:0]    FrameData = {AuroraKWord[7:0],Status[3:0],Data[1][25:0],Data[0][25:0]}
//   [7:0]  AuroraKWord = One of the available Aurora K-Words
//                        We can send MonData (M) or AutoRdeadData (A)
//                        Use K-Words to distinguish between MM, MA, AM, AA
//                        K-Words (taken from Aurora specification document) in RD53A_defines
//                        const logic [2:9] KWordMM = 8'hD2;
//                        const logic [2:9] KWordMA = 8'h99;
//                        const logic [2:9] KWordAM = 8'h55;
//                        const logic [2:9] KWordAA = 8'hB4;
//                        const logic [2:9] KWordEE = 8'hCC; 
//   [3:0]       Status = 0  --> Ready
//                        1  --> Error since last read
//                        2  --> Warning since last read
//                        3  --> Wng+Err since last read
//                        4  --> Ready
//                        5  --> Trigger queue is full
//                        6  --> ChannelSync out of lock
//                        7-15 --> Not implemented
//  [25:0]         Data = {AddrFlag,Addr[8:0],Data[15:0]}
//             AddrFlag = 1 --> Data belongs to Pixels           --> Addr[8:0] = RegionRowAddr
//                        0 --> Data is from GlobalConfiguration --> Addr[8:0] = GC_Address
//  [15:0]         Data = Data to be sent out
//
// Each time we have to send out data:
//                       1) We prepare a 256bit word, depending on MultiLane settings, while we wait to send Data
//                       2) Set the MonitorEmpty signal (until we receive the MonitorRead signal)
//  
// How Data is Written:
// - There are 8 Fifo's to store data coming from up to 8 registers
// - Data stored in each Fifo comes from a RdRegister command
// - Each time we detect a RdRegister command we write to one Fifo, based on enabled output lanes (LoadDataMask)
// - If we have to send out a Data Frame: 
//   - Data forming the Frame comes from the FIFO if it is not empty or from AutoRegData
//   - We generate the correct DataFrame 
// - We construct DataToBeSent and write it to the cdc 
//   the cdc fifo to readback values
// - Once the data is written to the Fifo's we turn off the FifoEmpty flag. ==> This will trigger an Aurora ReadFifo
// - Once data is read from the Fifo and formatted according to the Data Format we go back waiting for a RdRegister or SendFrame request
//
`default_nettype none

`include "eoc/mon/MonMemory.sv"
`include "eoc/OutputCdcFifo.sv"
`include "eoc/CdcResetSync.v"
`include "eoc/mon/MonFifo.sv"
`include "eoc/mon/MonFSM.sv"
`include "eoc/mon/MonCdcSync.sv"

module MonitorData(
    // Ouputs
    output logic    [255:0] MonData,        // Data to be sent to Aurora
    output logic            MonitorEmpty,   // Active when there is no data to send
    //
    output logic [7:0][7:0] FifoFullCnt,    // Conters that hold the # of Writes when fifo was full
    output logic      [1:0] NumActiveLanes, // Number of active Lanes
    // Inputs
    input  wire             ReadClk,        // Clock used by Aurora to read data
    input  wire             MonitorRead,    // Data request by Aurora (Active when reading data, can last multiple clock cycles)
    //
    input  wire             Clk160,         // 160 MHz clock
    input  wire             Reset_b,        // Synchronous Active low
    input  wire          LoadDataMaskRst_b, // Reset (Synchronous Active low) for LoadDataMask
    input  wire             EnMon,          // If true Monitoring data is active
    input  wire       [3:0] ActiveLanes,    // Lanes active in the Aurora link
    input  wire       [7:0] FrameSkip,      // # of Frames to skip before sending next data
    input  wire             NewRegData,     // There is data to add to the Fifo
    input  wire       [3:0] WrWngFifoFullCntRst, // Reset for the WngFifoFullCnt counter   [in Monitor Data]
    input  wire      [25:0] RegData,        // Data to be added to the Fifo
    input  wire [7:0][25:0] AutoReadData,   // Data coming from default selected registers [from Global Configuration Register]
    // for calculating Status
    input  wire      [13:0] ErrWngMask,     // Error and Warning mask bits                 [from Global Configuration Register]
    input  wire       SkippedTriggerCntErr, // There has been at least one Skipped Trigger [Pixel Config]
    input  wire             CmdErr,         // Error in Command Decoder, since last read   [Command Decoder]
    input  wire             BitFlipErr,     // Error in BitFlip, since last read           [Command Decoder]
    input  wire             BitFlipWng,     // Warning in BitFlip, since last read         [Command Decoder]
    // input  wire             TrigQueueFull, TBD
    input  wire             LockLoss,       // There has been a channel loss, since last read
    input  wire             ChSyncOutOfLock // True when the Channel Sync is not locked
    );

//----------------------------------------------------------
//
// Data and FIFO control signal generation
//                                                          
// NewRegData       generates a WrFifo signal -> FifoIn  
//  SendFrame       generates a RdFifo signal -> FifoOut
//    FifoOut and 
// AutoRegData      generate DataToBeSent   
//  SendFrame       generates a WrData signal 
//     WrData       copies DataToBeSent to MonData
// When MonData     is copied (WrDataDone) FifoEmpty goes low
// MonitorRead      is generated by Aurora           
// MonitorReadSync  detects MonitorRead and clears FifoEmpty 
//                                                          
//                   0                   1                   2              
//                   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
//                     _                           _              
//       NewRegData: _|1|____________________...__|4|____________ 
//                         _                           _          
//           WrFifo: _____|3|________________...______|6|________ 
//                   _____ __________________...______ __________ 
//           FifoIn: _____X__________________...______X__________ 
//                                                             
//                     _                           _              
//        SendFrame: _|1|____________________...__|4|____________ 
//                       _                           _         
//           RdFifo: ___|2|__________________...____|5|__________ 
//                   ______ _________________..._______ _________
//          FifoOut: ______X_________________..._______X_________
//                         _                                 _       
//           WrData: _____|3|________        ...____________|6|__ 
//                   ____________ ___________...____________ ____
//          MonData: ____________X___________...____________X____
//                   _____________        __ ...____________ 
//     MonitorEmpty:              |______|0                 |____  
//                                    _____                       
//      MonitorRead: ________________|     |_..._________________ 
//                                      _                         
//  MonitorReadSync: __________________|9|___..._________________ 
//                                                          
//-----------------------------------------------------------------           

//
// If no lane is active keep the FSM reset
logic  ResetFSM_b;
assign ResetFSM_b = (ActiveLanes == 4'b0000) ? 1'b0 : Reset_b; 


 //               ##                                                                                     ##
 //   ####        ##            #####                              ######                                ##
 //  ##  ##       ##           ##   ##                             ##   ##                               ##
 // ##        ######   #####   ##       ##  ##   ## ###    #####   ##   ##   #####    #####    #####   ######
 // ##       ##   ##  ##        #####   ##  ##   ###  ##  ##       ######   ##   ##  ##       ##   ##    ##
 // ##       ##   ##  ##            ##  ##  ##   ##   ##  ##       ## ##    #######   ####    #######    ##
 //  ##  ##  ##   ##  ##       ##   ##  ##  ##   ##   ##  ##       ##  ##   ##           ##   ##         ##
 //   ####    ######   #####    #####    #####   ##   ##   #####   ##   ##   #####   #####     #####      ###
 //                                         ##
 //                                      ####

//
// Cross Domain Clocking Synchronization
//
// Following signals have to be synchronized:
// 
// ResetFSM_b:      Originating clock  Clk160   --->    Destination clock ReadClk   : CdcSyncReset
// MonitorRead:     Originating clock ReadClk   --->    Destination clock Clk160       : MonitorReadSync
// DataToBeSent:    Originating clock ReadClk   --->    Destination clock Clk160       : MonData
// 
//
// CDC Reset synchronizer
//
//                  Synchronized using MUX recirculation synchronizer
logic  CdcSyncReset;
//
CdcResetSync CdcResetSync(
    // Outputs
    .pulse_out  (  CdcSyncReset ), // Reset is Active high
    // Inputs
    .clk_in     (        Clk160 ), // 160 MHz System clock
    .clk_out    (       ReadClk ), // Clock used by Aurora to read data
    .pulse_in   (   ~ResetFSM_b )  // Works only for active high signals
    );

//
// CDC MonitorRead synchronizer
//
//                  Synchronized using MUX recirculation synchronizer
logic  MonitorReadSync;
//
CdcResetSync CdcMonitorReadSync(
    // Outputs
    .pulse_out ( MonitorReadSync ), // Synced signal
    // Inputs   
    .clk_in    (         ReadClk ), // Clock used by Aurora
    .clk_out   (          Clk160 ), // 160 MHz System clock
    .pulse_in  (     MonitorRead )  // Signal to sync
    );

//
// CDC Synchronizer for Data to be sent to Aurora [MUX recirculation synchronizer]
// Returns WriteDone (synchronous with 160MHz clock) once data is copied
//
logic [255:0] DataToBeSent;   // Stores data to be sent to Aurora
logic WrData, WrDataDly, WrDataDone;
//
MonCDCSync #( .DSIZE(256) ) MonCDCSync(
    // Outputs
    .OutData   (      MonData ), // Signal ready for Aurora [Synced with Aurora clock]
    .WriteDone (   WrDataDone ), // We have written data    [Synced with 160MHz clock]
    // Inputs
    .RdClk     (      ReadClk ), // Synced with Aurora clock
    .RdRst     ( CdcSyncReset ), // Reset in sync with Aurora clock
    .WrRst     (  ~ResetFSM_b ), // Reset in sync with 160MHZ clock
    .Write     (       WrData ), // When to write
    .WrClk     (       Clk160 ), // 160 MHz clock
    .InData    ( DataToBeSent )
    );

// ========================================================================== //
//
// Set the number of active Lanes
always_comb begin : NumActiveLanes_comb
    unique case (ActiveLanes)        
        4'b0000, 4'b0001, 4'b0010, 4'b0100, 4'b1000: begin
            NumActiveLanes = 2'b00; // One lane active
        end 
        4'b0011, 4'b0101, 4'b0110, 
        4'b1001, 4'b1010, 4'b1100: begin
            NumActiveLanes = 2'b01; // Two lanes active
        end 
        4'b0111, 4'b1011, 4'b1101, 4'b1110: begin
            NumActiveLanes = 2'b10; // Three lanes active (Should never happen) Will set to one lane active
        end
        4'b1111: begin
            NumActiveLanes = 2'b11; // Four lanes active
        end
        default: begin
            NumActiveLanes = 2'b00; // One lane active
        end            
    endcase // ActiveLanes
end // NumActiveLanes_comb

//
// Count 160 MHz clocks: Every 64 we have an Aurora Frame
// MONITOR_FRAME_SKIP is 8 bit --> ClkCnt is 14 bit wide
//
logic [13:0] ClkCnt;
logic  [7:0] CmpClkCnt;
assign CmpClkCnt = ClkCnt[13:6];
//
always_ff @(posedge Clk160) begin : ClkCnt_AFF
    if(~Reset_b) begin
        ClkCnt  <= 'b0;
    end else begin
        if (CmpClkCnt == FrameSkip) begin // reset the counter 
            ClkCnt <= 'b0;
        end else begin // increment the counter
            ClkCnt <= ClkCnt + 1;
        end
    end
end // ClkCnt_AFF

//
// SendFrame means we have to send out Monitor Data
//
logic         SendFrame;
//
always_ff @(posedge Clk160) begin : SendFrame_AFF
    if(~Reset_b) begin
        SendFrame  <= 'b0;
    end else begin
        if (CmpClkCnt == FrameSkip) begin       // We have to send a Monitor frame 
            SendFrame <= EnMon & MonitorEmpty;  // Active when the Monitoring block is enabled and we are NOT waiting for Aurora to readback data
        end else begin // No Data was processed by Aurora
            SendFrame <= 'b0;
        end
    end
end // SendFrame_AFF

//
// Set MonitorEmpty signal
//
always_ff @(posedge Clk160) begin : MonitorEmpty_AFF
    if(Reset_b == 1'b0) begin
        MonitorEmpty <= 1'b1; // No Data
    end else unique case ({WrDataDone,MonitorReadSync})
        2'b00: begin
            MonitorEmpty <= MonitorEmpty;
        end // 2'b00:
        2'b01: begin
            MonitorEmpty <= 1'b1;
        end // 2'b01:
        2'b10, 2'b11: begin
            MonitorEmpty <= 1'b0; // <=== There is Data
        end // 2'b10, 2'b11:
        default: begin
            MonitorEmpty <= 1'b1;
        end
    endcase
end : MonitorEmpty_AFF

//
// Generate signals to increment Fifo full Warning counters
logic [7:0] FifoFullError   ; // MonitorFSM had a request to write with a full fifo
logic [7:0] FFW_Reset_b     ;
logic [7:0] WngFifoFullCnt  ; // True if the corresponding counter is != 0
logic [7:0] WngFifoFullCntMask ;
logic       WngFifoFull     ; // True if one of the counters is is != 0
//
assign FFW_Reset_b[0]  = ( ~Reset_b | WrWngFifoFullCntRst[0]);
assign FFW_Reset_b[1]  = ( ~Reset_b | WrWngFifoFullCntRst[0]);
assign FFW_Reset_b[2]  = ( ~Reset_b | WrWngFifoFullCntRst[1]);
assign FFW_Reset_b[3]  = ( ~Reset_b | WrWngFifoFullCntRst[1]);
assign FFW_Reset_b[4]  = ( ~Reset_b | WrWngFifoFullCntRst[2]);
assign FFW_Reset_b[5]  = ( ~Reset_b | WrWngFifoFullCntRst[2]);
assign FFW_Reset_b[6]  = ( ~Reset_b | WrWngFifoFullCntRst[3]);
assign FFW_Reset_b[7]  = ( ~Reset_b | WrWngFifoFullCntRst[3]);
//
generate
    genvar FFWi;
    for (FFWi = 0; FFWi < 8; FFWi++) begin : FFW
        // Fifo Full Counters
        always_ff @(posedge Clk160) begin : FifoFullCnt_AFF
            if(FFW_Reset_b[FFWi]) begin
                FifoFullCnt[FFWi]  <= 'b0;
            end else begin
                if (FifoFullError[FFWi] == 1'b1) begin // increment the counter 
                    FifoFullCnt[FFWi] <= FifoFullCnt[FFWi] + 1;
                end else begin // increment the counter
                    FifoFullCnt[FFWi] <= FifoFullCnt[FFWi];
                end
            end
        end // FifoFullCnt_AFF
        // Fifo Full Warning signals
        always_ff @(posedge Clk160) begin : WngFifoFullCnt_AFF
            if(FifoFullCnt[FFWi] == 8'b0) WngFifoFullCnt[FFWi] <= 1'b0;
            else                          WngFifoFullCnt[FFWi] <= ~WngFifoFullCntMask[FFWi];
        end // FifoFullCnt_AFF
    end // FFW
endgenerate
//
assign WngFifoFull = |WngFifoFullCnt;

//
// Generate LoadDataMask, based on NumActiveLanes, using a circular shift register
// - In case we rewrite the ActiveLanes register we generate a rest signal
// - We have to fill all Fifo's even in case a single lane is active
// - Based on ActiveLanes we write different data to different Fifo's
// - ActiveLanes = 4: Different data to all 8 Fifo's
// - Activelanes = 2: Only 4 Fifo's are readback but we duplicate data on all Fifo's
// - ActiveLanes = 1: Only 2 Fifo's are readback but we duplicate data on all Fifo's
// Note: also in case of 0 or 3 active lanes we write data as in case ActiveLanes = 1
logic[7:0] LoadDataMask;
always_ff @(posedge Clk160) begin : LoadDataMask_AFF
    if(LoadDataMaskRst_b == 1'b0) begin
        if      (ActiveLanes == 4'b1111) LoadDataMask <= 8'b0000_0001; // Single Lane
        else if (ActiveLanes == 4'b0011) LoadDataMask <= 8'b0001_0001; //   Two Lanes
        else if (ActiveLanes == 4'b0101) LoadDataMask <= 8'b0001_0001; //   Two Lanes
        else if (ActiveLanes == 4'b0110) LoadDataMask <= 8'b0001_0001; //   Two Lanes
        else if (ActiveLanes == 4'b1001) LoadDataMask <= 8'b0001_0001; //   Two Lanes
        else if (ActiveLanes == 4'b1010) LoadDataMask <= 8'b0001_0001; //   Two Lanes
        else if (ActiveLanes == 4'b1100) LoadDataMask <= 8'b0001_0001; //   Two Lanes
        else                             LoadDataMask <= 8'b0101_0101; //  Four Lanes
    end else begin
        if (NewRegData == 1'b1)
            LoadDataMask <= {LoadDataMask[6:0],LoadDataMask[7]};
        else 
            LoadDataMask <= LoadDataMask ;
    end
end : LoadDataMask_AFF

// 
// AuroraKWord generation
//
// InData[26] = 1'b1 --> We have RegData        [M]
// InData[26] = 1'b0 --> We have AutoReadData   [A]
//
//  [63:0]    FrameData = {AuroraKWord[7:0],Status[3:0],Data[1][25:0],Data[0][25:0]}
//
// KWord definitions
const logic [2:9] KWordAA = 8'hB4;
const logic [2:9] KWordAM = 8'h55;
const logic [2:9] KWordMA = 8'h99;
const logic [2:9] KWordMM = 8'hD2;
const logic [2:9] KWordEE = 8'hCC; // Error, no K-Word to assign
//
logic [3:0] [7:0] AuroraKWord; // One K-Word for each Frame
logic [7:0][25:0] FifoOut;
logic       [7:0] FifoEmpty;

generate
    genvar AKWi;
    for (AKWi = 0; AKWi < 4; AKWi++) begin : AKW
        always_comb begin : AuroraKWord_comb
            // unique case ({Fifo[(2*AKWi)+1].MonFifo.OutData[26],Fifo[2*AKWi].MonFifo.OutData[26]})
            // case ({FifoOut[(2*AKWi)+1][26],FifoOut[2*AKWi][26]})
            case ({FifoEmpty[(2*AKWi)+1],FifoEmpty[2*AKWi]})
            2'b00:   AuroraKWord[AKWi] = KWordMM;
            2'b01:   AuroraKWord[AKWi] = KWordMA;
            2'b10:   AuroraKWord[AKWi] = KWordAM;
            2'b11:   AuroraKWord[AKWi] = KWordAA;
            default: AuroraKWord[AKWi] = KWordEE; // Should never happen
            endcase
        end // AuroraKWord_comb
    end // AKW
endgenerate

//
// Status Generation (Multiple bits can be on at the same time)
// To clear a status bit one has to write to the affected register, that will be reset 
// [3:0] Status = 0000  --> Ready
//                0001  --> Error since last read   [E] 
//                0010  --> Warning since last read [W] 
//                0100  --> Trigger skipped         [T] (to be implemented)
//                1000  --> ChannelSync out of lock [C] 
//                1000  --> There has been a lock loss since last read [C]
//
// All Status flags can be masked off using ErrWngMask register
//
//  [63:0]    FrameData = {AuroraKWord[7:0],Status[3:0],Data[1][25:0],Data[0][25:0]}
//
logic       CmdErrMask, BitFlipErrMask, BitFlipWngMask, SkippedTriggerCntMask, LockLossMask, ChSyncOutOfLockMask;
//
assign             CmdErrMask = ErrWngMask[0];
assign         BitFlipErrMask = ErrWngMask[1];
assign         BitFlipWngMask = ErrWngMask[2];
assign  WngFifoFullCntMask[0] = ErrWngMask[3];
assign  WngFifoFullCntMask[1] = ErrWngMask[4];
assign  WngFifoFullCntMask[2] = ErrWngMask[5];
assign  WngFifoFullCntMask[3] = ErrWngMask[6];
assign  WngFifoFullCntMask[4] = ErrWngMask[7];
assign  WngFifoFullCntMask[5] = ErrWngMask[8];
assign  WngFifoFullCntMask[6] = ErrWngMask[9];
assign  WngFifoFullCntMask[7] = ErrWngMask[10];
assign  SkippedTriggerCntMask = ErrWngMask[11];
assign           LockLossMask = ErrWngMask[12];
assign    ChSyncOutOfLockMask = ErrWngMask[13];

//
logic [3:0][3:0] Status; // One Status for each Frame
//
assign Status[0] = ((CmdErr & ~CmdErrMask) | (BitFlipErr & ~BitFlipErrMask))              ? 4'b1111 : 4'b0;  
assign Status[1] = ((BitFlipWng & ~BitFlipWngMask) | (WngFifoFull & ~WngFifoFullCntMask)) ? 4'b1111 : 4'b0;    
assign Status[2] = (SkippedTriggerCntErr & ~SkippedTriggerCntMask)                        ? 4'b1111 : 4'b0;     
assign Status[3] = ((LockLoss & ~LockLossMask) | (ChSyncOutOfLock & ~ChSyncOutOfLockMask))? 4'b1111 : 4'b0;    

//
// Generate aurora FrameData
//  [63:0]    FrameData = {AuroraKWord[7:0],Status[3:0],Data[1][25:0],Data[0][25:0]}
// 
// Data[26] = 1'b1 --> We have RegData
// Data[26] = 1'b0 --> We have AutoReadData
// {1'b1,(RegData & {26{LoadData[MFi]}})}
// {1'b0,(AutoReadData[MFi] & {26{LoadDefaultData[MFi]}})}
//
logic [3:0][63:0] FrameData, FrameDataDly;
logic [7:0][25:0] Data;
logic       [7:0] LoadDefaultData;

//
generate
    genvar FDi;
    for (FDi = 0; FDi < 4; FDi++) begin : FD
        // assign FrameData[FDi] = {AuroraKWord[FDi],Status[FDi],Fifo[(2*FDi)+1].MonFifo.OutData[25:0],Fifo[2*FDi].MonFifo.OutData[25:0]};
        // assign FrameData[FDi]  = {AuroraKWord[FDi],Status[FDi],FifoOut[(2*FDi)+1][25:0],FifoOut[2*FDi][25:0]};
        assign Data[(2*FDi)]   = (FifoEmpty[(2*FDi)] == 1'b1) ? (AutoReadData[(2*FDi)] & {25{LoadDefaultData[(2*FDi)]}}) : FifoOut[(2*FDi)];
        assign Data[(2*FDi)+1] = (FifoEmpty[(2*FDi)+1] == 1'b1) ? (AutoReadData[(2*FDi)+1] & {25{LoadDefaultData[(2*FDi)+1]}}) : FifoOut[(2*FDi)+1];
        assign FrameData[FDi] = {AuroraKWord[FDi],Status[FDi],Data[(2*FDi)+1],Data[(2*FDi)]};
    end // FD
endgenerate

//
// Add a pipeline to avoid timing issues (no reset needed)
//
always_ff @(posedge Clk160) begin : proc_FrameDataDly
    FrameDataDly <= FrameData;
       WrDataDly <= WrData;
end

//
// [255:0]      MonData = {4{FrameData[63:0]}}
//
// Prepare data to be sent out
//      If the GCFifo has data use them to fill the word
//      Otherwise use Auto generated data
//
always_ff @(posedge Clk160) begin : DataToBeSent_AFF
    if(~Reset_b) begin
        DataToBeSent <= 'b0;
    end else begin // Decide what data to send out
        if (WrDataDly == 1'b1) begin
            case (ActiveLanes)
                //
                // No Output active, we send 4 copies of FrameData[0]
                //
                4'b0000: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                //
                // Single Lane, we send 4 copies of FrameData[0]
                //
                4'b0001: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                4'b0010: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                4'b0100: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                4'b1000: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                //
                // Two Lanes, we send 2 copies of {FrameData[1],FrameData[0]}
                //
                4'b0011: DataToBeSent <= {FrameDataDly[1],FrameDataDly[0],FrameDataDly[1],FrameDataDly[0]};
                4'b0101: DataToBeSent <= {FrameDataDly[1],FrameDataDly[0],FrameDataDly[1],FrameDataDly[0]};
                4'b0110: DataToBeSent <= {FrameDataDly[1],FrameDataDly[0],FrameDataDly[1],FrameDataDly[0]};
                4'b1001: DataToBeSent <= {FrameDataDly[1],FrameDataDly[0],FrameDataDly[1],FrameDataDly[0]};
                4'b1010: DataToBeSent <= {FrameDataDly[1],FrameDataDly[0],FrameDataDly[1],FrameDataDly[0]};
                4'b1100: DataToBeSent <= {FrameDataDly[1],FrameDataDly[0],FrameDataDly[1],FrameDataDly[0]};
                //
                // Three Lanes (Not allowed), we send 4 copies of FrameData[0]
                //
                4'b0111: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                4'b1011: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                4'b1101: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                4'b1110: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
                //
                // Four Lanes, we send all 4 FrameData
                //
                4'b1111: DataToBeSent <= {FrameDataDly[3],FrameDataDly[2],FrameDataDly[1],FrameDataDly[0]};
                //
                // default: we send 4 copies of FrameData[0]
                //
                default: DataToBeSent <= {FrameDataDly[0],FrameDataDly[0],FrameDataDly[0],FrameDataDly[0]};
            endcase // ActiveLanes
        end // if (WrDataDly == 1'b1) 
    end // end else
end : DataToBeSent_AFF

 //                              ##       ##                         ##
 // ##   ##                      ##       ##                         ##                                #######   #####   ##   ##
 // ##   ##                               ##                                                           ##       ##   ##  ##   ##
 // ### ###   #####   ## ###   ####     ######    #####   ## ###   ####     ## ###    ######           ##       ##       ### ###
 // ## # ##  ##   ##  ###  ##    ##       ##     ##   ##  ###        ##     ###  ##  ##   ##           #####     #####   ## # ##
 // ## # ##  ##   ##  ##   ##    ##       ##     ##   ##  ##         ##     ##   ##  ##   ##           ##            ##  ## # ##
 // ##   ##  ##   ##  ##   ##    ##       ##     ##   ##  ##         ##     ##   ##  ##   ##           ##       ##   ##  ##   ##
 // ##   ##   #####   ##   ##  ######      ###    #####   ##       ######   ##   ##   ######           ##        #####   ##   ##
 //                                                                                       ##
 //                                                                                   #####
//----------------------------------------------------------------------------------------------------------------------
//
// FSM to fill the Fifos with data
//
logic [7:0] LoadData;
logic [7:0] FifoFull;
logic [7:0] RdFifo;
//

//
MonFSM MonFSM(
              // Outputs
              .LoadData        (        LoadData[7:0] ), // Fill corresponding Fifo with regular data
              .LoadDefaultData ( LoadDefaultData[7:0] ), // Fill corresponding Fifo with default data (only true when SendFrame)
              .FifoFullError   (   FifoFullError[7:0] ), // Tried to wirite a full fifo
              .RdFifo          (          RdFifo[7:0] ), // Read the Fifo
              .WrData          (          WrData      ), // 
              // Inputs                              
              .clk             (          Clk160      ),
              .Reset_b         (      ResetFSM_b      ), // Synchronous active low --> enabled only if EnMon = 1
              .FifoEmpty       (       FifoEmpty[7:0] ), // 
              .FifoFull        (        FifoFull[7:0] ), // 
              .NewRegData      (      NewRegData      ), // New RdReg command -> we can fill fifo
              .SendFrame       (       SendFrame      )  // We have to send frame -> fill fifo with default values
              ); 

 //                              ##       ##                         ##
 // ##   ##                      ##       ##                         ##                                #######  ######   #######    ###
 // ##   ##                               ##                                                           ##         ##     ##        ## ##
 // ### ###   #####   ## ###   ####     ######    #####   ## ###   ####     ## ###    ######           ##         ##     ##       ##   ##
 // ## # ##  ##   ##  ###  ##    ##       ##     ##   ##  ###        ##     ###  ##  ##   ##           #####      ##     #####    ##   ##
 // ## # ##  ##   ##  ##   ##    ##       ##     ##   ##  ##         ##     ##   ##  ##   ##           ##         ##     ##       ##   ##
 // ##   ##  ##   ##  ##   ##    ##       ##     ##   ##  ##         ##     ##   ##  ##   ##           ##         ##     ##        ## ##
 // ##   ##   #####   ##   ##  ######      ###    #####   ##       ######   ##   ##   ######           ##       ######   ##         ###
 //                                                                                       ##
 //                                                                                   #####

//
// Instanciate Fifos to hold data for Aurora
// There are 8 fifos holding a 25 bit data word each
// Two words have to be combined for a single aurora frame
// Data to be sent is always formed by 4 Frames
// Depending on ActiveLanes, Data is coming from different Fifo's
// Only Data coming from a RdRegister command is stored in the Fifo's
// 
//  [25:0]         Data = {AddrFlag,Addr[8:0],Data[15:0]}
//             AddrFlag = 1 --> Data belongs to Pixels           --> Addr[8:0] = RegionRowAddr
//                        0 --> Data is from GlobalConfiguration --> Addr[8:0] = GC_Address
//  [15:0]         Data = Data to be sent out
// 
// WrFifo: masked with LoadDataMask if LoadData is selected
logic [7:0] WrFifo;
assign WrFifo[7:0] = (LoadData[7:0] & LoadDataMask[7:0]);

logic [7:0][25:0] FifoIn;
// assign FifoIn[7:0] = ( ({8{RegData}} & {26{LoadData[7:0]}})  );
assign FifoIn[0] = ( RegData & {26{LoadData[0]}} );
assign FifoIn[1] = ( RegData & {26{LoadData[1]}} );
assign FifoIn[2] = ( RegData & {26{LoadData[2]}} );
assign FifoIn[3] = ( RegData & {26{LoadData[3]}} );
assign FifoIn[4] = ( RegData & {26{LoadData[4]}} );
assign FifoIn[5] = ( RegData & {26{LoadData[5]}} );
assign FifoIn[6] = ( RegData & {26{LoadData[6]}} );
assign FifoIn[7] = ( RegData & {26{LoadData[7]}} );

//
// WrFifo is masked with LoadDataMask if LoadData is selected
generate
    genvar MFi;
    for (MFi = 0; MFi < 8; MFi++) begin : Fifo
        MonFifo #( .DataWidth(26), .AddrWidth(4) ) MonFifo ( // FifoDepth is (1 << AddrWidth)
                // Inputs
                .InData   (    FifoIn[MFi] ),
                .clk      (         Clk160 ), // 160 MHz clock
                .reset    (    ~ResetFSM_b ), // Syncronous reset active high
                .Write    (    WrFifo[MFi] ),
                .Read     (    RdFifo[MFi] ),
                // Outputs
                .OutData  (   FifoOut[MFi] ),
                .Full     (  FifoFull[MFi] ),
                .Empty    ( FifoEmpty[MFi] )
                );

    end // for (int MFi = 0; MFi < 8; MFi++)
endgenerate

endmodule // MonitorData

`default_nettype wire

