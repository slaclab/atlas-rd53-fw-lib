//-----------------------------------------------------------------------------------------------------
// [Filename]       ChannelSync.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Roberto Beccherle - Roberto.Beccherle@cern.ch
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Feb 03, 2017
// [Modified]       Feb 03, 2017
// [Description]    Channel synchronizer
// [Notes]          Reset is Synchronous and active low
//                  revritten from Guido Magazzu code written in vhdl
// [Version]        2.0
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// None
//-----------------------------------------------------------------------------------------------------

//

`ifndef CHANNELSYNC_SV 
`define CHANNELSYNC_SV

module ChannelSync (// Outputs
                    output logic [15:0] SyncData,       // 16 bit parallel output data
                    output logic [15:0] LockLossCnt,    // How many times we lost lock
                    output logic        LockLoss,       // LockLossCnt != 0
                    output logic        SyncDataLoad,   // when to load data
                    output logic        Clk40MHz,       // 40MHz clock signal
                    output logic        Locked,         // Tells if link is locked
                    // Inputs
                    input  wire         clk,            // Clock
                    input  wire         Reset_b,        // Synchronous reset active low
                    input  wire         WrLockLossCnt,  // Reset the Lock Loss Counter (comes from GCR)
                    input  wire   [4:0] ThrLow,         // Low threshold for lock      (comes from GCR)
                    input  wire   [4:0] ThrHigh,        // High threshold for lock     (comes from GCR)
                    input  wire         RxDat           // Input data stream
                    );
//
// Internal signal definition
const bit [15:0] sync     = 16'b10000001_01111110;
logic     [15:0] rx_data, rx_data_reg;
logic     [14:0] load_shreg;
logic      [3:0] phase_cnt;
logic      [3:0] phase_cnt_thrhigh;    
logic      [3:0] phase_cnt_last_sync;
logic      [4:0] sync_cnt;
logic            sync_cnt_eq_thrhigh,
                 sync_cnt_eq_thrhigh_pulse,
                 sync_cnt_eq_thrlow,
                 sync_cnt_eq_thrlow_pulse,
                 sync_data_ld,
                 int_locked, prev_locked,
                 rx_data_eq_sync,
                 rx_data_eq_sync_reg;

// synopsys sync_set_reset "Reset_b"
                  
//
// Assignments
assign              SyncDataLoad = load_shreg[14];

assign           rx_data_eq_sync = ( rx_data[15:0] == sync ) ? 1'b1 : 1'b0;
assign              sync_data_ld = ( (int_locked == 1'b1) && (phase_cnt == phase_cnt_thrhigh) ) ? 1'b1 : 1'b0;
assign       sync_cnt_eq_thrhigh = ( sync_cnt == ThrHigh ) ? 1'b1 : 1'b0;
assign        sync_cnt_eq_thrlow = ( sync_cnt == ThrLow  ) ? 1'b1 : 1'b0;
assign  sync_cnt_eq_thrlow_pulse = ( sync_cnt_eq_thrlow  && rx_data_eq_sync_reg );
assign sync_cnt_eq_thrhigh_pulse = ( sync_cnt_eq_thrhigh && rx_data_eq_sync_reg );
    

//
// SyncData generation
always_ff @(posedge clk) begin : SyncData_aff
    rx_data[15:0]       <= {rx_data[14:0],RxDat}; // Shift register
    rx_data_reg         <= rx_data;
    rx_data_eq_sync_reg <= rx_data_eq_sync; 
    if( (int_locked == 1'b1) && (phase_cnt == phase_cnt_thrhigh) ) begin
        SyncData <= rx_data_reg[15:0];
//        SyncData <= rx_data[15:0];
    end
end // SyncData_aff

//
// phase_cnt generation
always_ff @(posedge clk) begin : phase_cnt_aff
    if((Reset_b == 1'b0) || (phase_cnt == 4'b1111)) begin
        phase_cnt <= 'b0;
    end else begin
        phase_cnt <= phase_cnt + 1;
    end
end // phase_cnt_aff

//
// sync_cnt generation
always_ff @(posedge clk) begin : sync_cnt_aff
    if(Reset_b == 1'b0) begin
        sync_cnt            <= 'b0;
        phase_cnt_last_sync <= 'b0;
    end // if(Reset_b == 1'b0)
    else if(rx_data_eq_sync == 1'b1) begin
        if ( phase_cnt == phase_cnt_last_sync) begin
            if(sync_cnt == 5'b1_1111) begin
                sync_cnt <= sync_cnt;
                phase_cnt_last_sync <= phase_cnt_last_sync;
            end // if(sync_cnt == 5'b1_1111)     
            else begin
                sync_cnt <= sync_cnt + 1;
                phase_cnt_last_sync <= phase_cnt_last_sync;
            end // else
        end // if ( phase_cnt == phase_cnt_last_sync)
        else begin
            sync_cnt            <= 5'b0_0001;
            phase_cnt_last_sync <= phase_cnt;
        end // else
    end // else if(rx_data_eq_sync == 1'b1)
end // sync_cnt_aff

//
// phase_reg definition
always_ff @(posedge clk) begin : phase_reg_aff
    if (Reset_b == 1'b0) begin
        int_locked        <= 1'b0;
        phase_cnt_thrhigh <=  'b0;
    end else begin
        if (sync_cnt_eq_thrhigh_pulse == 1'b1) begin
            phase_cnt_thrhigh <= phase_cnt;
       end
       if (sync_cnt_eq_thrhigh_pulse == 1'b1) begin
            int_locked <= 1'b1;
       end else if ( (sync_cnt_eq_thrlow_pulse == 1'b1) && (phase_cnt != phase_cnt_thrhigh) ) begin
            int_locked <= 1'b0;
       end
   end
end // phase_reg_aff

//
// SyncDataLoad generation shift register
always_ff @(posedge clk) begin : load_shreg_aff
    load_shreg[14:0] <= {load_shreg[13:0],sync_data_ld};
end

//
// register output signals
always_ff @(posedge clk) begin : regout_aff
    if(Reset_b == 1'b0) begin
        Locked       <= 'b0;
//        SyncDataLoad <= 1'b0;
    end else begin
        Locked       <= int_locked;   // Is an Output
//        SyncDataLoad <= sync_data_ld;
    end
end // regout_aff

//
// 40MHz clock generation 
// Being a Clock one has to use continuous assignment
//
// Counter based clock divider
// Clk40MHz is always running, even if there is no channel lock.
// Once a new lock has been determined, or a reset detected, 
// the counter will be initialized to the correct value to provide the correct clock phase relationship
//
logic sync_load_ff;
always_ff @(posedge clk) begin
    sync_load_ff <= SyncDataLoad;
end

logic      [1:0] clk_40MHz;

always_ff @(posedge clk) begin : proc_Clk40MHz
    if ( sync_load_ff == 1'b1 ) begin
        clk_40MHz = 2'b00;
    end else begin
        clk_40MHz = clk_40MHz + 1'b1;
    end
end : proc_Clk40MHz

assign Clk40MHz = clk_40MHz[1]; // Is an Output

//
// store previous val of lock
always_ff @(posedge clk) begin : store_lock_aff
    prev_locked <= int_locked;
end

//
// Count how many times lock signal was lost
always_ff @(posedge clk) begin : LockLossCnt_aff
    if(Reset_b == 1'b0 || WrLockLossCnt == 1'b1 ) begin
        LockLossCnt <= 0;
    end else begin
        if({prev_locked,int_locked} == 2'b10) begin // There has been a falling edge of int_locked
            LockLossCnt <= LockLossCnt + 1;
        end else begin
            LockLossCnt <= LockLossCnt;
        end
    end
end // LockLossCnt_aff

//
// Set LockLoss
always_ff @(posedge clk) begin : LockLoss_AFF
    if (LockLossCnt == 16'b0) LockLoss <= 1'b0; 
    else                      LockLoss <= 1'b1;
end : LockLoss_AFF


endmodule // ChannelSync

`endif // CHANNELSYNC_SV
