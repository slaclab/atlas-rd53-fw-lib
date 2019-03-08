//----------------------------------------------------------------------------------------------------------------------
// [Filename]       SelfTrigger.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Roberto Beccherle - Roberto.Beccherle@cern.ch
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        09/03/2017
// [Description]    Self Triggering circuit
//
// [Clock]          - Clk40 is the 40 MHz clock
// [Reset]          - Reset_b (Synchronous active low) 
// 
// [Change history] 05/06/2017 - Version 1.0
//                             Initial release
// 
//----------------------------------------------------------------------------------------------------------------------
//
// [Dependencies]
//
// None
//----------------------------------------------------------------------------------------------------------------------
//
//
`default_nettype none

module SelfTrigger(
    // Ouputs
    output logic      SelfTrigger, // Only enabled HitOr signals contribute 
    //
    // Inputs
    input  wire       Clk40,       // 40 MHz clock
    input  wire       Reset_b,     // Synchronous Active low
    //
    input  wire [3:0] EnSelfTrig,  // True for enabled HitOr signals
    input  wire [3:0] HitOr        // HitOr coming from PixelArray
    );

    //
    // Synchronize HitOr signals that come from the PixelRegion with Clk40
    logic [3:0] sync_hitor, HitOrSync;
    //
    always_ff @(posedge Clk40) begin : SyncHitOr_AFF
        if (Reset_b == 1'b0) begin
            sync_hitor <= 4'b0;
            HitOrSync <= 4'b0;
        end else begin
            sync_hitor <= HitOr;
            HitOrSync <= sync_hitor;
        end
    end : SyncHitOr_AFF

    //
    // Delay and generate a single pulse for each HitOr
    //
    logic [15:0] HitOrDly_0, HitOrDly_1, HitOrDly_2, HitOrDly_3;
    // 
    always_ff @(posedge Clk40) begin : DlyAndPulse_AFF
        if (Reset_b == 1'b0) begin
            HitOrDly_0 <= 'b0;
            HitOrDly_1 <= 'b0;
            HitOrDly_2 <= 'b0;
            HitOrDly_3 <= 'b0;
        end else begin
            HitOrDly_0[15:0] <= {(HitOrDly_0[14] ^ HitOrDly_0[13]), HitOrDly_0[13:0], HitOrSync[0]};
            HitOrDly_0[15:0] <= {(HitOrDly_1[14] ^ HitOrDly_1[13]), HitOrDly_1[13:0], HitOrSync[1]};
            HitOrDly_0[15:0] <= {(HitOrDly_2[14] ^ HitOrDly_2[13]), HitOrDly_2[13:0], HitOrSync[2]};
            HitOrDly_0[15:0] <= {(HitOrDly_3[14] ^ HitOrDly_3[13]), HitOrDly_3[13:0], HitOrSync[3]};
        end
    end : DlyAndPulse_AFF 

    //
    // Select enabled HitOr's
    logic SelfTrigNotSync;
    //
    assign SelfTrigNotSync = (EnSelfTrig[0] & HitOrDly_0[15]) | 
                             (EnSelfTrig[1] & HitOrDly_1[15]) | 
                             (EnSelfTrig[2] & HitOrDly_2[15]) | 
                             (EnSelfTrig[3] & HitOrDly_3[15]) ;

    //
    // Register output
    //
    always_ff @(posedge Clk40) begin : SelfTrigger_AFF
        SelfTrigger <= SelfTrigNotSync;
    end : SelfTrigger_AFF
    
endmodule // SelfTrigger

`default_nettype wire
