/*
 * -------------------------------------------------------------------------
 * Two FF Synchronizer
 * 
 * - We register the input pulse with the incoming clock
 * - We Syncchronize the output pulse using two FF's with the output clock
 *
 * -------------------------------------------------------------------------
 */
`default_nettype none

module TwoFFSync (
    // Outputs
    output logic Pulse_out,
    // Inputs
    input  wire Clk_in,
    input  wire Clk_out,
    input  wire Pulse_in
);

//
// Register input signal
//
logic Pulse_sync;
//
always_ff @(posedge Clk_in) begin : In_Sync
    Pulse_sync <= Pulse_in;
end : In_Sync

//
// 2 FF Synchronizer
//
logic Pulse_sync_dly;
//
always_ff @(posedge Clk_out) begin : Out_Sync
   Pulse_sync_dly <= Pulse_sync;
   Pulse_out      <= Pulse_sync_dly;
end

endmodule // TwoFFSync

`default_nettype wire
