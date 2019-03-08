/**
 * ------------------------------------------------------------
 * Copyright (c) All rights reserved 
 * SiLab, Institute of Physics, University of Bonn
 * ------------------------------------------------------------
 */
`timescale 1ps/1ps
`default_nettype none

`ifndef CDC_RESET_SYNC
`define CDC_RESET_SYNC

// Closed loop solution

module CdcResetSync (
    input  wire clk_in,
    input  wire pulse_in,
    input  wire clk_out,
    output wire pulse_out
);

wire ack_sync;

reg [1:0] in_pre_sync;
always@(posedge clk_in) begin
    in_pre_sync[0] <= pulse_in;
    in_pre_sync[1] <= in_pre_sync[0];
end

reg in_sync_pulse;
initial in_sync_pulse = 0; //works only in FPGA
always@(posedge clk_in) begin
    if (in_pre_sync[1])
        in_sync_pulse <= 1;
    else if (ack_sync)
        in_sync_pulse <= 0;
end

reg [2:0] out_sync;
always@(posedge clk_out) begin
    out_sync[0] <= in_sync_pulse;
    out_sync[1] <= out_sync[0];
    out_sync[2] <= out_sync[1];
end

assign pulse_out = out_sync[2];	
    
reg [1:0] ack_sync_ff;
always@(posedge clk_in) begin
    ack_sync_ff[0] <= out_sync[2];
    ack_sync_ff[1] <= ack_sync_ff[0];
end

assign ack_sync = ack_sync_ff[1];

endmodule

`default_nettype wire

`endif