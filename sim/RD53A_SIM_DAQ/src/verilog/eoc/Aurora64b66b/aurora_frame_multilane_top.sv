`timescale 1ns/1ps

`include "eoc/Aurora64b66b/aurora_definitions.sv"

`include "eoc/Aurora64b66b/aurora_periodic_fsm.sv"
`include "eoc/Aurora64b66b/scrambler_64b_58_39_1.sv"
`include "eoc/Aurora64b66b/gearbox_66_to_20.sv"
`include "eoc/Aurora64b66b/aurora_multilane_data_frame_fsm.sv"
`include "eoc/Aurora64b66b/aurora_multilane_userk_fsm.sv"
`include "eoc/Aurora64b66b/gearbox_66_to_32.sv"
`include "eoc/Aurora64b66b/aurora_multilane_priority_mux.sv"
`include "eoc/Aurora64b66b/aurora_PRBS15_generator.sv"

module Aurora64b66b_Frame_Multilane_top
#(
    parameter IW_WIDTH = 4,
    parameter CCW_WIDTH = 4,
    parameter CCS_WIDTH = 4,
    parameter CBW_WIDTH = 20,
    parameter CBS_WIDTH = 4
) (
    input wire EnableSingle32bitSerializer,
    input wire [3:0] ActiveLanes,
    input wire EnablePRBS,

    input wire [7:0][31:0] DataEOC,
    input wire [7:0] DataMask,
    input wire DataEOC_empty,
    input wire DataEOC_EOF,
    output logic DataEOC_read,

    input wire [3:0][63:0] Monitor,
    input wire Monitor_empty,
    output logic Monitor_read,

    output logic [3:0][19:0] ToSerializer20,
    output logic [31:0] ToSerializer32,

    input wire SerializerLock,

    input wire [IW_WIDTH-1:0] InitWait,
    input wire [CCW_WIDTH-1:0] CCWait,
    input wire [CBW_WIDTH-1:0] CBWait,
    input wire [CBS_WIDTH-1:0] CBSend,
    input wire [CCS_WIDTH-1:0] CCSend,

    input wire Clk,
    input wire Rst
);

    logic [19:0]             prbs20;
    logic [31:0]             prbs32;
    logic [3:0][19:0]        auroraToSerializer20;
    logic [31:0]             auroraToSerializer32;

    enum                     {INIT_LANE, SEND_IDLE, SEND_CB, LANE_READY} lane_fsm_state;

    logic                    lane_ready;


    logic [`NPRIORITIES-1:0] block_to_send;
    logic [`NPRIORITIES-1:0] block_sent;
    logic [`NPRIORITIES-1:0] block_sending;

    logic [3:0][63:0]        data_word;
    logic [3:0][63:0]        data_to_send;
    logic [3:0][3:0]         data_bytes;
    logic [3:0]              data_fill;
    logic [3:0]              data_busy;

    logic [3:0][63:0]        monitor_userk;

    logic                    init_cb_send;
    logic                    periodic_cb_send;

    // FSMs send signals ORs
    logic [4:0] periodic_cb_send_cooldown;
    assign block_to_send[`CHANNEL_BONDING] = init_cb_send | (periodic_cb_send & !periodic_cb_send_cooldown);
    
    //synopsys sync_set_reset "Rst"
    
    // lane initialization FSM
    always_ff @(posedge Clk) begin
        logic [IW_WIDTH-1:0] init_counter;
        logic [2:0]      init_block_counter;

        if (Rst) begin
            init_counter <= '0;
            init_block_counter <= '0;
            lane_fsm_state <= INIT_LANE;
            periodic_cb_send_cooldown <= 4'h0;
            init_cb_send <= 1'b0;
            block_to_send[`IDLE] <= 1'b0;
            block_to_send[`NOT_READY] <= 1'b0;
            block_to_send[`NATIVE_FLOW_CONTROL] <= 1'b0;
            block_to_send[`USER_FLOW_CONTROL] <= 1'b0;
        end else begin
            block_to_send[`NOT_READY] <= 1'b0;
            block_to_send[`NATIVE_FLOW_CONTROL] <= 1'b0;
            block_to_send[`USER_FLOW_CONTROL] <= 1'b0;
            case(lane_fsm_state)
            INIT_LANE : begin
                if (init_block_counter == '0) begin
                    init_cb_send <= 1'b1;
                    if (block_sent[`CHANNEL_BONDING] && SerializerLock) begin
                        if (init_counter < InitWait) begin
                            init_counter <= init_counter + 1;
                            init_block_counter <= init_block_counter + 1;
                        end else begin
                            init_cb_send <= 1'b0;
                            lane_fsm_state <= LANE_READY;
                        end
                    end
                end else begin
                    init_cb_send <= 1'b0;
                    block_to_send[`IDLE] <= 1'b1;
                    if (block_sent[`IDLE] && SerializerLock) begin
                        init_block_counter <= init_block_counter + 1;
                    end
                end
            end
            LANE_READY : begin
//        init_cb_send <= 1'b0;
                block_to_send[`IDLE] <= 1'b0;
                if (periodic_cb_send | periodic_cb_send_cooldown)
                    periodic_cb_send_cooldown <= periodic_cb_send_cooldown + 1;
                    if (~SerializerLock) begin
                        lane_fsm_state <= INIT_LANE;
                    end
                end
            endcase
        end // else: !if(Rst)
    end // always_ff @ (posedge Clk or posedge Rst)

    assign lane_ready = (lane_fsm_state == LANE_READY);

    // Clock Compensation FSM
    AuroraPeriodicFSM #(CCW_WIDTH, CCS_WIDTH) cc_fsm(.LaneReady(lane_ready),
                .SendBlock(block_to_send[`CLOCK_COMPENSATION]),
                .BlockSent(block_sent[`CLOCK_COMPENSATION]),
                .WaitToSend(CCWait),
                .BlocksToSend(CCSend),
                .Clk(Clk),
                .Rst(Rst));

    // Channel Bonding FSM
    AuroraPeriodicFSM #(CBW_WIDTH, CBS_WIDTH) cb_fsm(.LaneReady(lane_ready),
                .SendBlock(periodic_cb_send),
                .BlockSent(block_sent[`CHANNEL_BONDING]),
                .WaitToSend(CBWait),
                .BlocksToSend(CBSend),
                .Clk(Clk),
                .Rst(Rst));

    // data FSM
    logic [7:0] completedatamask;

    assign completedatamask[1:0] = EnableSingle32bitSerializer ?
                  2'b11 : ( ActiveLanes[0] ?
                        2'b11 : 2'b00);
    assign completedatamask[3:2] = EnableSingle32bitSerializer ?
                  2'b00 : ( ActiveLanes[1] ?
                        2'b11 : 2'b00);
    assign completedatamask[5:4] = EnableSingle32bitSerializer ?
                  2'b00 : ( ActiveLanes[2] ?
                        2'b11 : 2'b00);
    assign completedatamask[7:6] = EnableSingle32bitSerializer ?
                  2'b00 : ( ActiveLanes[3] ?
                        2'b11 : 2'b00);


    AuroraDataFrameMultilaneFSM eoc_fsm (.LaneReady(lane_ready),
            .FIFO_Empty(DataEOC_empty),
            .FIFO_Data(DataEOC),
            .FIFO_DataMask(DataMask),
            .EndOfFrame(DataEOC_EOF),
            .CompleteDataMask(completedatamask),
            .BlockSent(block_sent[`USER_DATA]),
            .Clk(Clk),
            .Rst(Rst),
            .FIFO_Read(DataEOC_read),
            .DataToSend(data_to_send),
            .SendBlock(block_to_send[`USER_DATA]),
            .BytesToSend(data_bytes));

    AuroraMultilaneUserKFSM userk_fsm(.LaneReady(lane_ready),
            .FIFO_Empty(Monitor_empty),
            .FIFO_UserK(Monitor),
            .BlockSent(block_sent[`USER_KBLOCKS]),
            .Clk(Clk),
            .Rst(Rst),
            .FIFO_Read(Monitor_read),
            .UserKToSend(monitor_userk),
            .SendBlock(block_to_send[`USER_KBLOCKS]));


    logic [3:0][65:0] aurora_block;
    logic [3:0][65:0] aurora_scrambled;
    logic         aurora_ack32;

    logic [3:0][`NPRIORITIES-1:0] local_block_sent;

    genvar prio;
    generate
        for (prio = 0; prio < `NPRIORITIES; prio = prio+1) begin
            assign block_sent[prio] = local_block_sent[0][prio] |
                    ((
                    local_block_sent[1][prio] |
                    local_block_sent[2][prio] |
                    local_block_sent[3][prio] )
                    & ~EnableSingle32bitSerializer);
        end
    endgenerate

    genvar i;
    generate
        for (i = 0; i < 4; i=i+1) begin
            logic   aurora_ack, aurora_ack20;


            Aurora66b64bMultilanePriorityMux priority_mux (.Data(data_to_send[i]),
                    .DataBytes(data_bytes[i]),
                    .UserK(monitor_userk[i]),
                    .ToSend(block_to_send),
                    .AuroraAck(aurora_ack),
                    .Clk(Clk),
                    .Rst(Rst),
                    .Sent(local_block_sent[i]),
                    //.Sending(block_sending),
                    .AuroraBlock(aurora_block[i]));

            Scrambler scrambler (.DataIn(aurora_block[i][63:0]),
                    .SyncBits(aurora_block[i][65:64]),
                    .Ena(aurora_ack),
                    .Clk(Clk),
                    .Rst(Rst),
                    .DataOut(aurora_scrambled[i]));



            Gearbox66to20 gearbox20 (.Rst(Rst),
                    .Clk(Clk),
                    .Data66(aurora_scrambled[i]),
                    .Data20(auroraToSerializer20[i]),
                    .DataNext(aurora_ack20));

            assign aurora_ack = EnableSingle32bitSerializer ? aurora_ack32 : aurora_ack20;

            assign ToSerializer20[i] = EnablePRBS ? prbs20 : auroraToSerializer20[i];
        end
    endgenerate

    Gearbox66to32 gearbox32 (.Rst(Rst),
            .Clk(Clk),
            .Data66(aurora_scrambled[0]),
            .Data32(auroraToSerializer32),
            .DataNext(aurora_ack32));

    //PRBS15Generate20 prbsgen20 (.PRBS_Out(prbs20), .Clk(Clk), .Rst(Rst));
    PRBSWideGenerate #(20,15,14) prbsgen20 (.PRBS_Out(prbs20), .Clk(Clk), .Rst(~EnablePRBS));
    PRBSWideGenerate #(32,15,14) prbsgen32 (.PRBS_Out(prbs32), .Clk(Clk), .Rst(~EnablePRBS));

    assign ToSerializer32 = EnablePRBS ? prbs32 : auroraToSerializer32;
endmodule // Aurora64b66b_Frame_top
