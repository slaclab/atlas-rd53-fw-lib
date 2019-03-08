//-----------------------------------------------------------------------------------------------------
// [Filename]       Cmd_FSM.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Roberto Beccherle - Roberto.Beccherle@cern.ch
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Feb 03, 2017
// [Modified]       Feb 03, 2017
// [Description]    Finite state machine of the command decoder
// [Notes]          Reset is Synchronous and active low
// [Version]        2.0
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/eoc/cmd/Commands.sv
//-----------------------------------------------------------------------------------------------------


`ifndef CMD_FSM_SV 
`define CMD_FSM_SV

//
// Timescale directive
// `include "./Timescale.v"
// `default_nettype none

// 
// Command Decoder FSM
// These are the commands supported and their format
// BCR:         {Bcr,Bcr} --> Generate BCR pulse
// ECR:         {Ecr,Ecr} --> Generate ECR pulse
// CAL:         {Cal,Cal}{ChipId[3:0],CalEdgeMode,CalEdgeDelay[2:0],CalEdgeWidth[5:4]}{CalEdgeWidth[3:0],CalAuxMode,CalAuxDly[4:0]}  [Cal +DD +DD] --> Genrate CalEdge, CalAux
//                                  0=step 1=pulse,1 to 8 @  40MHz , 0 to 63 @ 160MHz, 0 to 63 @ 160MHz ,  SetTo   ,1 to 32 @ 160MHz
// GlobalPulse: {GlobalPulse,GlobalPulse}{ChipId[3:0],0, GlobalPulseWidth[3:0],0} Generate GlobalPulse signal and GlobalPulseWidth bus. [widths are 1,2,4,8,16,32,64,128,256,512]
// WrReg: (0)   {WrReg,WrReg} {{ChipId[3:0],WrRegMode,Addr[8:4]} {Addr[3:0],Data[15:10]} {Data[9:0]} [WrReg +DD +DD +DD]
//  ...   (1)   {Data[15:6]} {Data[5:0],Data[15:12]} {Data[11:2]} {Data[1:0],Data[15:7]} {Data[6:0],Data[15:8]} {Data[7:0],Data[15:9]} {Data[8:0],Data[15:10]} {Data[9:0]} [+DD +DD +DD +DD +DD +DD +DD +DD]
// Rrdeg:       {RdReg,RdReg} {{ChipId[3:0],0,Addr[8:4]} {Addr[3:0],0_0000} {Data[9:0]} [RdReg +DD +DD]
// Null:        {Null, Null} No command, just ignore it
//
// ERROR / WARNING handling:
//
// BitFlip handling of Trigger commands:
//              BF_H: Cannot be distinguished from DD   => No Trigger issued, Frame dropped => BitFlipError
//              BF_L: Cannot determine Tag              => Trigger issued, Tag == 0         => BitFlipError
// BitFlip during standard commands and Sync:
//      BF_H or BF_L: Can be corrected                  => Command issued                   => BitFlipWarning
// BitFlip during Data transmission:
//      BF_H or BF_L: Can NOT be corrected              => Frame is dropped                 => BitFlipError
// Data in SYNC or wrong symbol:
//                    Received Frame is dropped                                             => Error
//
//-----------------------------------------------------------------------------------------------------
//
module Cmd_FSM (
       // 
       // Command Decoder FSM
       //
       // Outputs are all registered
       output logic [15:0] RegData,
       output logic  [8:0] RegAddr,
       output logic  [3:0] GlobalPulseWidth,
       output logic  [5:0] EdgeWidth,       // Used for Cal command
       output logic  [2:0] EdgeDly,         // Used for Cal command
       output logic  [4:0] AuxDly,          // Used for Cal command
       output logic  [4:0] TriggerTag,
       output logic  [3:0] ChipId,
       output logic        EdgeMode,        // Used for Cal command
       output logic        AuxMode,         // Used for Cal command
       output logic        Trigger1, Trigger2, Trigger3, Trigger4,
                           ECR, BCR, RdReg, WrReg,
                           GenGlobalPulse,  // Signal that generates the Cal command
                           GenCal,          // Signal that generates the Cal command
                           BitFlipWarning,  // True if there has been a BitFlip and it has been corrected
                           BitFlipError,    // True if there has been a Bit Flip in any Symbol (and it has not been corrected)
                           Error,           // True if nothing matched in SYNC or DATA states or if a Command Counter has a wrong vaulue
       // Inputs
       input wire  [15:0]  Input,           // Input data (stable for 16 clk cycles)
       input wire          clk, 
       input wire          Reset_b,         // Synchronous active low 
       input wire          Sample,          // NOT USED ??? 
       input wire          Enable           // Active one clock cycle every 16
       );

// All definitions of signals relative to the Command Decoder
`include "eoc/cmd/Commands.sv"
localparam DELAYCYCLE = 2;

//
//enum logic {SYNC = 1'b0, DATA=1'b1} state, next_state;
enum logic {SYNC = 1'b0, DATA=1'b1} state, next_state;

//
logic [15:0] reg_data_comb;
logic  [9:0] reg_data_tmp, reg_data_tmp_comb;
logic  [8:0] reg_addr_comb;
logic  [4:0] data_cnt, DataCnt;
logic  [9:0] dataword;            // Holds the values of two Data pairs: {DATA??,DATA??} 
             // All signals named name_comb are registered in a dedicated always_ff block
logic  [3:0] globalpulsewidth_comb;
logic  [5:0] edgewidth_comb;
logic  [2:0] edgedly_comb;
logic  [4:0] auxdly_comb;
logic  [4:0] tag_comb;            // Holds the Tag associated to the Trigger
logic  [3:0] ChipId_comb;
logic  [3:0] trigger_comb; 
logic        bcr_comb, ecr_comb,
             genglobalpulse_comb, gencal_comb, edgemode_comb, auxmode_comb, rdreg_comb, wrreg_comb, 
             bitflipwarning_comb, // A BitFlip has been detected and corrected.    
             bitfliperror_comb,   // A BitFlip has been detected, but it was not possible to correct it. [Can be generated in SYNC or DATA states]
             error_comb;          // Nothing matched in SYNC or DATA state.                              [Can be generated in SYNC or DATA states]
             // All signals named name_int are used to know wether you are still in a Command that has data to process
logic        wrreg_int, next_wrreg_int,
             wrregmode_int, next_wrregmode_int, // True if WrReg command is in repetition mode (6 data fields instead of one)
             rdreg_int, next_rdreg_int,
             globalpulse_int, next_globalpulse_int,
             cal_int, next_cal_int,
             set_data_cnt, enable_data_cnt;

////////////////////////////////////////////////////////////////
// FSM next state definition and internally registered signals
////////////////////////////////////////////////////////////////
//
// #######   #####   ##   ##
// ##       ##   ##  ##   ##
// ##       ##       ### ###
// #####     #####   ## # ##
// ##            ##  ## # ##
// ##       ##   ##  ##   ##
// ##        #####   ##   ##
//
always_ff @(posedge clk) begin: fsm_next_state
    if (Reset_b == 1'b0) begin
        state           <= SYNC;
        // 
        cal_int         <= 'b0; 
        globalpulse_int <= 'b0;
        rdreg_int       <= 'b0;
        wrreg_int       <= 'b0;
        wrregmode_int   <= 'b0;
    end else if (Enable == 1'b1) begin
        state           <= next_state;
        // 
        cal_int         <= next_cal_int;
        globalpulse_int <= next_globalpulse_int;
        rdreg_int       <= next_rdreg_int;
        wrreg_int       <= next_wrreg_int;
        wrregmode_int   <= next_wrregmode_int;
    end else begin  
        state           <= state;
        // 
        cal_int         <= cal_int;
        globalpulse_int <= globalpulse_int;
        rdreg_int       <= rdreg_int;
        wrreg_int       <= wrreg_int;
        wrregmode_int   <= next_wrregmode_int;
    end
end : fsm_next_state            

////////////////////////////////////////////////////////////////
// Fsm: State transitions
////////////////////////////////////////////////////////////////
always_comb begin : fsm_comb
    next_state           = SYNC;
    //
    bitflipwarning_comb  = 'b0;
    bitfliperror_comb    = 'b0;
    error_comb           = 'b0;
    //
    trigger_comb         = 'b0;
    tag_comb             = 'b0;
    //
    bcr_comb             = 'b0;
    ecr_comb             = 'b0;
    gencal_comb          = 'b0;
    genglobalpulse_comb  = 'b0;
    rdreg_comb           = 'b0;
    wrreg_comb           = 'b0;
    //
    ChipId_comb          = ChipId;
    reg_addr_comb        = RegAddr;
    reg_data_comb        = RegData;
    reg_data_tmp_comb    = reg_data_tmp;
    globalpulsewidth_comb = GlobalPulseWidth;
    edgewidth_comb       = EdgeWidth;
    edgedly_comb         = EdgeDly;
    edgemode_comb        = EdgeMode;
    auxdly_comb          = AuxDly;
    auxmode_comb         = AuxMode;
    //
    // Reset following signals when in SYNC state, set if the corresponding command has been detected
    next_cal_int         = cal_int; 
    next_globalpulse_int = globalpulse_int; 
    next_rdreg_int       = rdreg_int;
    next_wrreg_int       = wrreg_int;
    next_wrregmode_int   = wrregmode_int;
    //
    set_data_cnt         = 'b0;
    enable_data_cnt      = 'b0;
    data_cnt             = 'b0;
    //
    // State Machine Definition
    // it only get activated if the Enable is high
    if (Enable) begin 
        case (state)
        // This is the default state of the state machine
        // Here we can only detect the start of a new command and therefore we have a unique if
        // There is no priority encoder
        //                                                                                                               ##
        //  #####   ##  ##   ##   ##    ####            ######                                                           ##
        // ##   ##  ##  ##   ###  ##   ##  ##           ##   ##
        // ##        ####    ###  ##  ##                ##   ##  ## ###    #####    #####    #####    #####    #####   ####     ## ###    ######
        //  #####     ##     ## # ##  ##                ######   ###      ##   ##  ##       ##   ##  ##       ##         ##     ###  ##  ##   ##
        //      ##    ##     ## # ##  ##                ##       ##       ##   ##  ##       #######   ####     ####      ##     ##   ##  ##   ##
        // ##   ##    ##     ##  ###   ##  ##           ##       ##       ##   ##  ##       ##           ##       ##     ##     ##   ##  ##   ##
        //  #####     ##     ##   ##    ####            ##       ##        #####    #####    #####   #####    #####    ######   ##   ##   ######
        //                                                                                                                                    ##
        //                                                                                                                                #####
        SYNC   : begin
            next_state           = SYNC;
            // reset all signals that tell you which command has been detected
            next_cal_int         = 'b0;
            next_rdreg_int       = 'b0;
            next_globalpulse_int = 'b0;
            next_wrreg_int       = 'b0;
            //
            // We have detected a Sync command
            unique if(Sync) begin        // Sync = (Sync_OK) or (Sync_BF)
                //Debug $display($stime,"Sync detected");
                if (Sync_BF) bitflipwarning_comb = 1;
            end // unique if(Sync)
            //
            // We have detected a Trigger command
            else if (Trigger01Cmd) begin // [000T]
                trigger_comb = 4'b0001;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger01Cmd)
            else if (Trigger02Cmd) begin // [00T0]
                trigger_comb = 4'b0010;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger02Cmd)
            else if (Trigger03Cmd) begin // [00TT]
                trigger_comb = 4'b0011;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger03Cmd)
            else if (Trigger04Cmd) begin // [0T00]
                trigger_comb = 4'b0100;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger04Cmd)
            else if (Trigger05Cmd) begin // [0T0T]
                trigger_comb = 4'b0101;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger05Cmd)
            else if (Trigger06Cmd) begin // [0TT0]
                trigger_comb = 4'b0110;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger06Cmd)
            else if (Trigger07Cmd) begin // [0TTT]
                trigger_comb = 4'b0111;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger07Cmd)
            else if (Trigger08Cmd) begin // [T000]
                trigger_comb = 4'b1000;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger08Cmd)
            else if (Trigger09Cmd) begin // [T00T]
                trigger_comb = 4'b1001;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger09Cmd)
            else if (Trigger10Cmd) begin // [T0T0]
                trigger_comb = 4'b1010;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger10Cmd)
            else if (Trigger11Cmd) begin // [T0TT]
                trigger_comb = 4'b1011;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger11Cmd)
            else if (Trigger12Cmd) begin // [TT00]
                trigger_comb = 4'b1100;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger12Cmd)
            else if (Trigger13Cmd) begin // [TT0T]
                trigger_comb = 4'b1101;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger13Cmd)
            else if (Trigger14Cmd) begin // [TTT0]
                trigger_comb = 4'b1110;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger14Cmd)
            else if (Trigger15Cmd) begin // [TTTT]
                trigger_comb = 4'b1111;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger15Cmd)
            //                                                            ##                                                ##    ##
            //   ####                                                     ##       #####                                    ##    ##
            //  ##  ##                                                    ##       ##  ##                                   ##
            // ##        #####   ### ##   ### ##    ######  ## ###    ######       ##   ##   #####    #####    #####    ######  ####     ## ###    ######
            // ##       ##   ##  ## # ##  ## # ##  ##   ##  ###  ##  ##   ##       ##   ##  ##   ##  ##       ##   ##  ##   ##    ##     ###  ##  ##   ##
            // ##       ##   ##  ## # ##  ## # ##  ##   ##  ##   ##  ##   ##       ##   ##  #######  ##       ##   ##  ##   ##    ##     ##   ##  ##   ##
            //  ##  ##  ##   ##  ## # ##  ## # ##  ##  ###  ##   ##  ##   ##       ##  ##   ##       ##       ##   ##  ##   ##    ##     ##   ##  ##   ##
            //   ####    #####   ##   ##  ##   ##   ### ##  ##   ##   ######       #####     #####    #####    #####    ######  ######   ##   ##   ######
            //                                                                                                                                         ##
            //                                                                                                                                     #####
            else if (BB) begin // {BCR,BCR}
                //Debug display($stime,"BCR Command detected");
                bcr_comb = 1;
                if (BB_BF) bitflipwarning_comb = 1;
            end // else if (BB)
            else if (CC) begin // CAL:         {Cal,Cal}{ChipId[3:0],CalEdgeMode,CalEdgeDelay[2:0],CalEdgeWidth[5:4]}{CalEdgeWidth[3:0],CalAuxMode,CalAuxDly[4:0]}  [Cal +DD +DD] --> Genrate CalEdge, CalAux
                               //                                  0=step 1=pulse,1 to 8 @  40MHz , 0 to 63 @ 160MHz, 0 to 63 @ 160MHz ,  SetTo   ,1 to 32 @ 160MHz
                //Debug $display($stime,"Cal Command detected");
                next_state      = DATA;
                next_cal_int    = 1'b1; // A Cal command has been detected
                data_cnt        = 5'd1; // Data fields in the command
                set_data_cnt    = 1'b1; // Copy value of data_cnt in the data counter
                if (CC_BF) bitflipwarning_comb = 1;
            end // else if (CC)
            // DD can only happen in DATA state, so there is an Error
            else if (DD) begin // Should never happen 
                //Debug $display($stime,"### ERROR: Data detected in SYNC state");
                error_comb = 1;
            end // else if (DD)
            else if (EE) begin // {ECR,ECR}
                //Debug $display($stime,"ECR Command detected");
                ecr_comb = 1;
                if (EE_BF) bitflipwarning_comb = 1;
            end // else if (EE)
            else if (GG) begin // {GlobalPulse,GlobalPulse}{ChipId[3:0],0, GlobalPulseWidth[3:0],0}
                //Debug $display($stime,"GlobalPulse Command detected");
                next_state           = DATA;
                next_globalpulse_int = 1'b1; // A GlobalPulse command has been detected
                data_cnt             = 5'd0;
                set_data_cnt         = 1'b1;
                if (GG_BF) bitflipwarning_comb = 1;
            end // else if (GG)
            else if (NN) begin // {Null,Null}[01101001]
                //Debug $display($stime,"Null Command detected");
                if (NN_BF) bitflipwarning_comb = 1;
            end // else if (NN)
            else if (RR) begin // Rrdeg: {RdReg,RdReg} {ChipId[3:0],0,Addr[8:4]} {Addr[3:0],0_0000} [RdReg +DD +DD]
                next_state      = DATA;
                next_rdreg_int  = 1'b1; // A RdReg command has been detected
                data_cnt        = 5'd1;
                set_data_cnt    = 1'b1;
                if (RR_BF) bitflipwarning_comb = 1;
            end // else if (RR)
            else if (WW) begin // {WrReg,WrReg},{ChipId[3:0],WrRegMode,Addr[8:0],Data[15:0]} [WrReg + DD + DD + DD (+ DD + DD + DD + DD + DD + DD + DD + DD)]
                next_state         = DATA;
                next_wrreg_int     = 1'b1; // A WrReg command has been detected
                data_cnt           = 5'd2; 
                next_wrregmode_int = 1'b0; // We assume (but do not know yet) WrRegMode = 0
                set_data_cnt       = 1'b1;
                if (WW_BF) bitflipwarning_comb = 1;
            end // else if (WW)
            //
            // No correct SymbolPair detected: There is an Error
            else begin
                next_state = SYNC;
                error_comb = 1;
                //Debug $display($stime," ERROR: State is SYNC");
            end // else
            //
            // Check to see if there has been a BitFlip (even if a command has ben detected)
            // This if block is always executed, after command/data matching
            if (BitFlip && !CMD_BF) begin // There has been a BitFlip in any Symbol
                                          // Can also happen if ther is a BitFlip in the first Symbol of a Trigger Frame
                bitfliperror_comb = 1;
            end // if (BitFlip && !CMD_BF)
        end // SYNC
        //
        // DATA is the state in which we process DATA associated to a Command.
        // We can either detect new DATA or one of the Commands that have higer priority
        // We use the unique if construct, i.e. we do NOT build a priority encoder
        //
        //                     ##
        // #####               ##                        #####   ######     ##     ######   #######
        // ##  ##              ##                       ##   ##    ##       ##       ##     ##
        // ##   ##   ######  ######    ######           ##         ##      ####      ##     ##
        // ##   ##  ##   ##    ##     ##   ##            #####     ##      ## #      ##     #####
        // ##   ##  ##   ##    ##     ##   ##                ##    ##     ######     ##     ##
        // ##  ##   ##  ###    ##     ##  ###           ##   ##    ##     ##   #     ##     ##
        // #####     ### ##     ###    ### ##            #####     ##    ###   ##    ##     #######
        //
        //
        DATA   : begin
            next_state = DATA;
            //
            // We have detected a Sync command
            unique if(Sync) begin        // Sync = (Sync_OK) or (Sync_BF)
                if (Sync_BF) bitflipwarning_comb = 1;
            end // unique if(Sync)
            //
            // We have detected a Trigger command
            else if (Trigger01Cmd) begin // [000T]
                trigger_comb = 4'b0001;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger01Cmd)
            else if (Trigger02Cmd) begin // [00T0]
                trigger_comb = 4'b0010;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger02Cmd)
            else if (Trigger03Cmd) begin // [00TT]
                trigger_comb = 4'b0011;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger03Cmd)
            else if (Trigger04Cmd) begin // [0T00]
                trigger_comb = 4'b0100;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger04Cmd)
            else if (Trigger05Cmd) begin // [0T0T]
                trigger_comb = 4'b0101;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger05Cmd)
            else if (Trigger06Cmd) begin // [0TT0]
                trigger_comb = 4'b0110;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger06Cmd)
            else if (Trigger07Cmd) begin // [0TTT]
                trigger_comb = 4'b0111;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger07Cmd)
            else if (Trigger08Cmd) begin // [T000]
                trigger_comb = 4'b1000;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger08Cmd)
            else if (Trigger09Cmd) begin // [T00T]
                trigger_comb = 4'b1001;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger09Cmd)
            else if (Trigger10Cmd) begin // [T0T0]
                trigger_comb = 4'b1010;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger10Cmd)
            else if (Trigger11Cmd) begin // [T0TT]
                trigger_comb = 4'b1011;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger11Cmd)
            else if (Trigger12Cmd) begin // [TT00]
                trigger_comb = 4'b1100;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger12Cmd)
            else if (Trigger13Cmd) begin // [TT0T]
                trigger_comb = 4'b1101;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger13Cmd)
            else if (Trigger14Cmd) begin // [TTT0]
                trigger_comb = 4'b1110;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger14Cmd)
            else if (Trigger15Cmd) begin // [TTTT]
                trigger_comb = 4'b1111;
                unique if (BitFlip_L) tag_comb = 'b0; // Data can not be reconstructed
                else                  tag_comb = dataword[4:0];
            end // else if (Trigger15Cmd)
            //
            // #####      ##     ######     ##              ######                                                           ##
            // ##  ##     ##       ##       ##              ##   ##
            // ##   ##   ####      ##      ####             ##   ##  ## ###    #####    #####    #####    #####    #####   ####     ## ###    ######
            // ##   ##   ## #      ##      ## #             ######   ###      ##   ##  ##       ##   ##  ##       ##         ##     ###  ##  ##   ##
            // ##   ##  ######     ##     ######            ##       ##       ##   ##  ##       #######   ####     ####      ##     ##   ##  ##   ##
            // ##  ##   ##   #     ##     ##   #            ##       ##       ##   ##  ##       ##           ##       ##     ##     ##   ##  ##   ##
            // #####   ###   ##    ##    ###   ##           ##       ##        #####    #####    #####   #####    #####    ######   ##   ##   ######
            //                                                                                                                                    ##
            //                                                                                                                                #####
            else if (BB) begin // {BCR,BCR}
                //Debug display($stime,"BCR Command detected");
                bcr_comb = 1;
                if (BB_BF) bitflipwarning_comb = 1;
            end // else if (BB)
            else if (EE) begin // {ECR,ECR}
                //Debug $display($stime,"ECR Command detected");
                ecr_comb = 1;
                if (EE_BF) bitflipwarning_comb = 1;
            end // else if (EE)
            else if (NN) begin // {Null,Null}[01101001]
                //Debug $display($stime,"Null Command detected");
                if (NN_BF) bitflipwarning_comb = 1;
            end
            //
            // Data processing
            else if ( DD ) begin // {Data,Data} 
                if (cal_int) begin // CAL:         {Cal,Cal}{ChipId[3:0],CalEdgeMode,CalEdgeDelay[2:0],CalEdgeWidth[5:4]}{CalEdgeWidth[3:0],CalAuxMode,CalAuxDly[4:0]}  [Cal +DD +DD] --> Genrate CalEdge, CalAux
                                   //                                  0=step 1=pulse,1 to 8 @  40MHz , 0 to 63 @ 160MHz, 0 to 63 @ 160MHz ,  SetTo   ,1 to 32 @ 160MHz
                    unique if (DataCnt == 5'd1) begin // {ChipId[3:0],CalEdgeMode,CalEdgeDelay[2:0],CalEdgeWidth[5:4]} 
                        next_state          = DATA;
                        enable_data_cnt     = 1'b1;
                        ChipId_comb[3:0]    = dataword[9:6];
                        edgemode_comb       = dataword[5];
                        edgedly_comb[2:0]   = dataword[4:2];
                        edgewidth_comb[5:4] = dataword[1:0];
                    end else if   (DataCnt == 5'd0) begin // {CalEdgeWidth[3:0],CalAuxMode,CalAuxDly[4:0]} 
                        next_state          = SYNC; // We read all data associated to the command
                        gencal_comb         = 1'b1; // set Cal output signal
                        edgewidth_comb[3:0] = dataword[9:6];
                        auxmode_comb        = dataword[5];
                        auxdly_comb         = dataword[4:0];
                    end else begin // Can but Should never happen [Error in sent command]
                        next_state = SYNC;
                        error_comb = 1;
                        //Debug $display($stime,"### ERROR: State is DATA, wrong counter value, command is Cal");
                    end 
                    end // if (cal_int)
                else if (rdreg_int) begin // Rrdeg: {RdReg,RdReg} {ChipId[3:0],0,Addr[8:4]} {Addr[3:0],00_0000} [RdReg +DD +DD]
                    unique if (DataCnt == 5'd1) begin // {ChipId[3:0],0,Addr[8:4]}
                        //Debug $display($stime," RdReg: DataCnt = 1");
                        next_state          = DATA;
                        enable_data_cnt     = 1'b1;
                        ChipId_comb[3:0]    = dataword[9:6];
                        reg_addr_comb[8:4]  = dataword[4:0];
                    end else if   (DataCnt == 5'd0) begin // {Addr[3:0],0_0000}
                        //Debug $display($stime," RdReg: DataCnt = 0");
                        next_state         = SYNC; // We read all data associated to the command
                        reg_addr_comb[3:0] = dataword[9:6];
                        rdreg_comb         = 1'b1; // set RdReg output signal
                    end else begin // Can but Should never happen [Error in sent command]
                        //Debug $display($stime,"### ERROR: State is DATA, wrong counter value, command is RdReg");
                        next_state = SYNC;
                        error_comb = 1;
                    end
                end // else if (rdreg_int)
                // ({WrReg,WrReg},{ChipId[3:0],WrRegMode,Addr[8:4]}{Addr[3:0],Data[15:10]}{Data[9:0} [WrReg + DD + DD + DD (+ DD + DD + DD + DD + DD + DD + DD + DD)]
                // WrReg can be issued in continuous WrReg mode (WrRegMode = 1). In this case we will have additional 8 fields.
                // (wrregmode_int = 0) DD DD DD : {ChipId[3:0],WrRegMode,Addr[8:4]} {Addr[3:0],Data[15:10]} {Data[9:0}
                // (wrregmode_int = 1)          DD DD DD DD DD DD DD DD : {Data[15:6]} {Data[5:0],Data[15:12]} {Data[11:2]} {Data[1:0],Data[15:8]} {Data[7:0],Data[15:14]} {Data[13:4]} {Data[3:0],Data[15:10]} {Data[9:0]}
                else if (wrreg_int) begin       // {WrReg,WrReg},{ChipId[3:0],WrRegMode,Addr[8:0],Data[15:0]} [WrReg +DD +DD +DD (+DD +DD +DD +DD +DD +DD +DD +DD)]
                    enable_data_cnt     = 1'b1;
                    unique if (DataCnt == 5'd2) begin // COUNTER == 2 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = XXX, DataCnt = 2");
                        // {ChipId[3:0],WrRegMode,Addr[8:4]}
                        ChipId_comb[3:0]   = dataword[9:6];
                        next_wrregmode_int = dataword[5];
                        reg_addr_comb[8:4] = dataword[4:0];
                    end // (DataCnt == 5'd2) begin
                    else if   (DataCnt == 5'd1) begin // COUNTER == 1 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = %b, DataCnt = 1", wrregmode_int);
                        // {Addr[3:0],Data[15:10]}     
                        reg_addr_comb[3:0]   = dataword[9:6];
                        reg_data_comb[15:10] = dataword[5:0];
                    end // (DataCnt == 5'd1) begin
                    else if   (DataCnt == 5'd0) begin // COUNTER == 0 [two possible modes]
                        wrreg_comb         = 1'b1; // set WrReg output signal
                        //  
                        enable_data_cnt    = 1'b0;
                        reg_data_comb[9:0] = dataword[9:0];
                        if (wrregmode_int == 1) begin
                            //Debug $display($stime," WrReg: WrRegMode = 0, DataCnt = 0");
                            set_data_cnt   = 1'b1;
                            data_cnt       = 5'd10;
                        end else begin // wrregmode_int == 0
                            //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 0");
                            next_state         = SYNC; // Finished with the single WrReg command
                        end
                        //
                    end // (DataCnt == 5'd0) begin
                    else if (DataCnt == 5'd10) begin // COUNTER == 10 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 10");
                        // {Data[15:6]} 
                        reg_data_comb[15:6]    = dataword[9:0];
                    end // (DataCnt == 5'd10) begin
                    else if  (DataCnt == 5'd9) begin // COUNTER == 9 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 9");
                        wrreg_comb             = 1'b1;   // set WrReg output signal
                        // {Data[5:0],Data[15:12]}     
                        reg_data_comb[5:0]     = dataword[9:4];
                        reg_data_tmp_comb[3:0] = dataword[3:0];
                    end // (DataCnt == 5'd9) begin
                    else if  (DataCnt == 5'd8) begin // COUNTER == 8 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 8");
                        // {Data[11:2]} 
                        reg_data_comb[15:12]   = reg_data_tmp_comb[3:0];
                        reg_data_comb[11:2]    = dataword[9:0];
                    end // (DataCnt == 5'd8) begin
                    else if  (DataCnt == 5'd7) begin // COUNTER == 7 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 7");
                        wrreg_comb             = 1'b1;   // set WrReg output signal
                        // {Data[1:0],Data[15:8]} 
                        reg_data_comb[1:0]     = dataword[9:8];
                        reg_data_tmp_comb[7:0] = dataword[7:0];
                    end // (DataCnt == 5'd7) begin
                    else if  (DataCnt == 5'd6) begin // COUNTER == 6 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 6");
                        wrreg_comb             = 1'b1;   // set WrReg output signal
                        // {Data[7:0],Data[15:14]} 
                        reg_data_comb[15:8]    = reg_data_tmp_comb[7:0];
                        reg_data_comb[7:0]     = dataword[9:2];
                        reg_data_tmp_comb[9:8] = dataword[1:0];
                    end // (DataCnt == 5'd6) begin
                    else if  (DataCnt == 5'd5) begin // COUNTER == 5 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 5");
                        // {Data[13:4]}
                        reg_data_comb[15:14]   = reg_data_tmp_comb[9:8];
                        reg_data_comb[13:4]    = dataword[9:0];
                    end // (DataCnt == 5'd5) begin
                    else if  (DataCnt == 5'd4) begin // COUNTER == 4 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 4");
                        wrreg_comb             = 1'b1;   // set WrReg output signal
                        // {Data[3:0],Data[15:10]} 
                        reg_data_comb[3:0]     = dataword[9:6];
                        reg_data_tmp_comb[5:0] = dataword[5:0];
                    end // (DataCnt == 5'd4) begin
                    else if  (DataCnt == 5'd3) begin // COUNTER == 3 [one possible mode]
                        //Debug $display($stime," WrReg: WrRegMode = 1, DataCnt = 3");
                        next_state = SYNC; // We read all data associated to the command
                        wrreg_comb             = 1'b1;   // set WrReg output signal
                        set_data_cnt           = 1'b1;
                        data_cnt               = 5'd0;
                        enable_data_cnt        = 1'b0;
                        // {Data[9:5],Data[4:0]} 
                        reg_data_comb[15:10]   = reg_data_tmp_comb[5:0];
                        reg_data_comb[9:0]     = dataword[9:0];
                    end // end // (DataCnt == 5'd3)
                    else begin // Can but Should never happen [Error in sent command]
                        //Debug $display($stime,"### ERROR: State is DATA, wrong counter value, command is WrReg");
                        next_state = SYNC;
                        error_comb = 1;
                    end // else
                end // end     // else if (wrreg_int)
                else if (globalpulse_int) begin // {GlobalPulse,GlobalPulse}{ChipId[3:0],0, GlobalPulseWidth[3:0],0} [GlobalPulse + DD]
                    next_state = SYNC; // We read all data associated to the command
                    unique if ((DataCnt == 5'd0) && DD) begin // {ChipId[3:0],0, GlobalPulseWidth[3:0],0}
                        ChipId_comb[3:0]           = dataword[9:6];
                        genglobalpulse_comb        = 1'b1; // set GlobalPulse output signal
                        globalpulsewidth_comb[3:0] = dataword[4:1];
                    end else begin // Can but Should never happen [Error in sent command]
                        //Debug $display($stime,"### ERROR: State is DATA, wrong counter value, command is GlobalPulse");
                        next_state = SYNC;
                        error_comb = 1;
                    end // unique if ((DataCnt == 5'd0) && DD)
                end // else if (globalpulse_int)
                //
                // No correct SymbolPair detected 
                else begin
                    //Debug $display($stime,"### ERROR: State is DATA");
                    next_state = SYNC;  // In case of Error we go back to the deafult state
                    error_comb = 1;
                end // else
            end // else if ( DD )
            else begin
                //Debug $display($stime,"### ERROR: State is DATA");
                next_state = SYNC;  // In case of Error we go back to the deafult state
                error_comb = 1;
            end // else
            //
            // Check to see if there has been a BitFlip (even if a command has ben detected)
            // This if block is always executed, after command/data matching
            if (BitFlip && !CMD_BF) begin // There has been a BitFlip in any Symbol and it has NOT been corrected
                bitfliperror_comb = 1;
            end // if (BitFlip && !CMD_BF) // CMD_BF = (Sync_BF || BB_BF || CC_BF || EE_BF || GG_BF || NN_BF || RR_BF || WW_BF);
        end // DATA   :
    endcase // state
    end // if (Enable)
end : fsm_comb

//
// Decode dataword
always_comb begin : decode_dataword
   // First 8 bit
    unique if (Data00_OK_H) dataword[9:5] = 5'd0;
    else if   (Data01_OK_H) dataword[9:5] = 5'd1;
    else if   (Data02_OK_H) dataword[9:5] = 5'd2;
    else if   (Data03_OK_H) dataword[9:5] = 5'd3;
    else if   (Data04_OK_H) dataword[9:5] = 5'd4;
    else if   (Data05_OK_H) dataword[9:5] = 5'd5;
    else if   (Data06_OK_H) dataword[9:5] = 5'd6;
    else if   (Data07_OK_H) dataword[9:5] = 5'd7;
    else if   (Data08_OK_H) dataword[9:5] = 5'd8;
    else if   (Data09_OK_H) dataword[9:5] = 5'd9;
    else if   (Data10_OK_H) dataword[9:5] = 5'd10;
    else if   (Data11_OK_H) dataword[9:5] = 5'd11;
    else if   (Data12_OK_H) dataword[9:5] = 5'd12;
    else if   (Data13_OK_H) dataword[9:5] = 5'd13;
    else if   (Data14_OK_H) dataword[9:5] = 5'd14;
    else if   (Data15_OK_H) dataword[9:5] = 5'd15;
    else if   (Data16_OK_H) dataword[9:5] = 5'd16;
    else if   (Data17_OK_H) dataword[9:5] = 5'd17;
    else if   (Data18_OK_H) dataword[9:5] = 5'd18;
    else if   (Data19_OK_H) dataword[9:5] = 5'd19;
    else if   (Data20_OK_H) dataword[9:5] = 5'd20;
    else if   (Data21_OK_H) dataword[9:5] = 5'd21;
    else if   (Data22_OK_H) dataword[9:5] = 5'd22;
    else if   (Data23_OK_H) dataword[9:5] = 5'd23;
    else if   (Data24_OK_H) dataword[9:5] = 5'd24;
    else if   (Data25_OK_H) dataword[9:5] = 5'd25;
    else if   (Data26_OK_H) dataword[9:5] = 5'd26;
    else if   (Data27_OK_H) dataword[9:5] = 5'd27;
    else if   (Data28_OK_H) dataword[9:5] = 5'd28;
    else if   (Data29_OK_H) dataword[9:5] = 5'd29;
    else if   (Data30_OK_H) dataword[9:5] = 5'd30;
    else if   (Data31_OK_H) dataword[9:5] = 5'd31;
    else                    dataword[9:5] = 5'd0;
   // Second 8 bit
    unique if (Data00_OK_L) dataword[4:0] = 5'd0;
    else if   (Data01_OK_L) dataword[4:0] = 5'd1;
    else if   (Data02_OK_L) dataword[4:0] = 5'd2;
    else if   (Data03_OK_L) dataword[4:0] = 5'd3;
    else if   (Data04_OK_L) dataword[4:0] = 5'd4;
    else if   (Data05_OK_L) dataword[4:0] = 5'd5;
    else if   (Data06_OK_L) dataword[4:0] = 5'd6;
    else if   (Data07_OK_L) dataword[4:0] = 5'd7;
    else if   (Data08_OK_L) dataword[4:0] = 5'd8;
    else if   (Data09_OK_L) dataword[4:0] = 5'd9;
    else if   (Data10_OK_L) dataword[4:0] = 5'd10;
    else if   (Data11_OK_L) dataword[4:0] = 5'd11;
    else if   (Data12_OK_L) dataword[4:0] = 5'd12;
    else if   (Data13_OK_L) dataword[4:0] = 5'd13;
    else if   (Data14_OK_L) dataword[4:0] = 5'd14;
    else if   (Data15_OK_L) dataword[4:0] = 5'd15;
    else if   (Data16_OK_L) dataword[4:0] = 5'd16;
    else if   (Data17_OK_L) dataword[4:0] = 5'd17;
    else if   (Data18_OK_L) dataword[4:0] = 5'd18;
    else if   (Data19_OK_L) dataword[4:0] = 5'd19;
    else if   (Data20_OK_L) dataword[4:0] = 5'd20;
    else if   (Data21_OK_L) dataword[4:0] = 5'd21;
    else if   (Data22_OK_L) dataword[4:0] = 5'd22;
    else if   (Data23_OK_L) dataword[4:0] = 5'd23;
    else if   (Data24_OK_L) dataword[4:0] = 5'd24;
    else if   (Data25_OK_L) dataword[4:0] = 5'd25;
    else if   (Data26_OK_L) dataword[4:0] = 5'd26;
    else if   (Data27_OK_L) dataword[4:0] = 5'd27;
    else if   (Data28_OK_L) dataword[4:0] = 5'd28;
    else if   (Data29_OK_L) dataword[4:0] = 5'd29;
    else if   (Data30_OK_L) dataword[4:0] = 5'd30;
    else if   (Data31_OK_L) dataword[4:0] = 5'd31;
    else                    dataword[4:0] = 5'd0;
end : decode_dataword

////////////////////////////////////////////////////////////////
// Fsm: Register all Output signals
////////////////////////////////////////////////////////////////
//                              ##                ##                                                    ##                         ##
// ######                       ##                ##                                  ###               ##                         ##
// ##   ##                                        ##                                 ## ##              ##                         ##
// ##   ##   #####    ######  ####      #####   ######    #####   ## ###            ##   ##  ##   ##  ######   ######   ##   ##  ######    #####
// ######   ##   ##  ##   ##    ##     ##         ##     ##   ##  ###               ##   ##  ##   ##    ##     ##   ##  ##   ##    ##     ##
// ## ##    #######  ##   ##    ##      ####      ##     #######  ##                ##   ##  ##   ##    ##     ##   ##  ##   ##    ##      ####
// ##  ##   ##       ##   ##    ##         ##     ##     ##       ##                 ## ##   ##  ###    ##     ##   ##  ##  ###    ##         ##
// ##   ##   #####    ######  ######   #####       ###    #####   ##                  ###     ### ##     ###   ######    ### ##     ###   #####
//                        ##                                                                                   ##
//                    #####                                                                                    ##
//
always_ff @(posedge clk) begin: fsm_reg_outputs
    if (Reset_b == 1'b0) begin
        BitFlipWarning   <= 'b0;
        BitFlipError     <= 'b0;
        Error            <= 'b0;
        Trigger1         <= 'b0;
        Trigger2         <= 'b0;
        Trigger3         <= 'b0;
        Trigger4         <= 'b0;
        TriggerTag       <= 'b0;
        BCR              <= 'b0;
        ECR              <= 'b0;
        GenCal           <= 'b0;
        EdgeMode         <= 'b0;
        EdgeWidth        <= 'b0;
        EdgeDly          <= 'b0;
        AuxMode          <= 'b0; 
        AuxDly           <= 'b0; 
        RegAddr          <= 'b0;
        RegData          <= 'b0;
        GenGlobalPulse   <= 'b0;
        GlobalPulseWidth <= 'b0;
        ChipId           <= 'b0;
        RdReg            <= 'b0;
        WrReg            <= 'b0;
        reg_data_tmp     <= 'b0;
    end // if (Reset_b == 1'b0)
    else if (Enable == 1'b1) /**/ begin
        BitFlipWarning   <= bitflipwarning_comb;
        BitFlipError     <= (bitfliperror_comb && !CMD_BF);     // Set only if it has not been corrected 
        Error            <= (error_comb && !bitfliperror_comb); // If the error is due to a BitFlip don't set Error
        Trigger1         <= trigger_comb[0];
        Trigger2         <= trigger_comb[1];
        Trigger3         <= trigger_comb[2];
        Trigger4         <= trigger_comb[3];
        TriggerTag       <= tag_comb;
        BCR              <= bcr_comb; 
        ECR              <= ecr_comb; 
        RdReg            <= rdreg_comb;
        WrReg            <= wrreg_comb;
        RegAddr          <= reg_addr_comb;
        RegData          <= reg_data_comb;
        GenGlobalPulse   <= genglobalpulse_comb;
        GlobalPulseWidth <= globalpulsewidth_comb;
        ChipId           <= ChipId_comb;
        GenCal           <= gencal_comb;
        EdgeMode         <= edgemode_comb;
        EdgeWidth        <= edgewidth_comb;
        EdgeDly          <= edgedly_comb;
        AuxMode          <= auxmode_comb; 
        AuxDly           <= auxdly_comb; 
        reg_data_tmp     <= reg_data_tmp_comb;
    end // if (Enable)
    else begin // If Var <= Var;      the output signal lasts 16 clock cycles (needed to select correct timing in Cmd)
               // If Var <= Var_comb; the output signal lasts 1 clock cycle 
        BitFlipWarning   <= bitflipwarning_comb;
        BitFlipError     <= bitfliperror_comb;
        Error            <= error_comb;
        Trigger1         <= Trigger1;
        Trigger2         <= Trigger2;
        Trigger3         <= Trigger3;
        Trigger4         <= Trigger4;
        TriggerTag       <= TriggerTag;
        BCR              <= BCR;
        ECR              <= ECR;
        RegAddr          <= RegAddr;
        RegData          <= RegData;
        GenGlobalPulse   <= GenGlobalPulse;
        GlobalPulseWidth <= GlobalPulseWidth;
        GenCal           <= gencal_comb;
        EdgeMode         <= EdgeMode;
        EdgeWidth        <= EdgeWidth;
        EdgeDly          <= EdgeDly;
        AuxMode          <= AuxMode;
        AuxDly           <= AuxDly;
        reg_data_tmp     <= reg_data_tmp;
    end // else 
end : fsm_reg_outputs

//
// Data counter counter [5 bit wide, max value is ten]
// value is set by set_data_cnt, then it decrements until it reaches zero
//
//synopsys sync_set_reset "reset"
always_ff @(posedge clk) begin :counter
    if (Reset_b == 1'b0)                  DataCnt <= 'b0;
    else if (Enable == 1'b1) begin
        if         (set_data_cnt == 1'b1) DataCnt[4:0] <= data_cnt[4:0];
        else if (enable_data_cnt == 1'b1) DataCnt[4:0] <= DataCnt[4:0] - 5'b1;
        else                              DataCnt[4:0] <= DataCnt[4:0];
    end // else if (Enable == 1'b1)
end : counter

endmodule : Cmd_FSM
// `default_nettype wire

`endif // CMD_FSM_SV