`timescale 1ns/1ps

`include "eoc/Aurora64b66b/aurora_definitions.sv"

`include "eoc/Aurora64b66b/aurora_periodic_fsm.sv"
`include "eoc/Aurora64b66b/aurora_data_frame_fsm.sv"
`include "eoc/Aurora64b66b/aurora_userk_fsm.sv"
`include "eoc/Aurora64b66b/aurora_priority_mux.sv"
`include "eoc/Aurora64b66b/scrambler_64b_58_39_1.sv"
`include "eoc/Aurora64b66b/gearbox_66_to_20.sv"


module Aurora64b66b_Frame_top(
			input wire [31:0] DataEOC,
			input wire DataEOC_empty,
			input wire DataEOC_EOF,
			output logic DataEOC_read,

			input wire [15:0] Monitor,
			input wire Monitor_empty,
			output logic Monitor_read,

			output logic [19:0] ToSerializer,
			input wire SerializerLock,

			input wire Clk,
			input wire Rst
			);

   parameter INIT_WAIT = 1280;
   parameter CC_WAIT = 128;
   parameter CC_SEND = 4;

   enum 			   {INIT_LANE, LANE_READY} lane_fsm_state;


   logic 			   lane_ready;
   
   
   logic [7:0] 			   block_to_send;
   logic [7:0] 			   block_sent;
   logic [7:0] 			   block_sending;
   
   logic [63:0] 		   data_word;
   logic [63:0] 		   data_to_send;
   logic [3:0] 			   data_bytes;
   logic  			   data_fill;
   logic 			   data_busy;

   logic [55:0] 		   monitor_userk;
   
   
   // lane initialization FSM
   
   always_ff @(posedge Clk) begin
      logic [17:0] init_counter;
      if (Rst) begin
	 init_counter <= 8'h00;
	 lane_fsm_state <= INIT_LANE;
      end else begin
	 case(lane_fsm_state)
	   INIT_LANE : begin
	      block_to_send[`IDLE] <= 1'b1;
	      if (block_sent[`IDLE] && SerializerLock) begin
		 if (init_counter < INIT_WAIT) begin
		    init_counter <= init_counter + 1;
		 end else begin
		    lane_fsm_state <= LANE_READY;
		 end
	      end
	   end
	   LANE_READY : begin
	      if (~SerializerLock) begin
		 lane_fsm_state <= INIT_LANE;
	      end
	   end
	 endcase
      end // else: !if(Rst)
   end // always_ff @ (posedge Clk or posedge Rst)
   assign lane_ready = (lane_fsm_state == LANE_READY);
   
   // Clock Compensation FSM

   AuroraPeriodicFSM cc_fsm(.LaneReady(lane_ready),
			    .SendBlock(block_to_send[`CLOCK_COMPENSATION]),
			    .BlockSent(block_sent[`CLOCK_COMPENSATION]),
			    .Clk(Clk),
			    .Rst(Rst));
   
   // data FSM

   AuroraDataFrameFSM eoc_fsm (.LaneReady(lane_ready),
		 .FIFO_Empty(DataEOC_empty),
		 .FIFO_Data(DataEOC),
		 .EndOfFrame(DataEOC_EOF),
		 .BlockSent(block_sent[`USER_DATA]),
		 .Clk(Clk),
		 .Rst(Rst),
		 .FIFO_Read(DataEOC_read),
		 .DataToSend(data_to_send),
		 .SendBlock(block_to_send[`USER_DATA]),
		 .BytesToSend(data_bytes));

   AuroraUserKFSM userk_fsm(.LaneReady(lane_ready),
			    .FIFO_Empty(Monitor_empty),
			    .FIFO_UserK({40'h0,Monitor}),
			    .BlockSent(block_sent[`USER_KBLOCKS]),
			    .Clk(Clk),
			    .Rst(Rst),
			    .FIFO_Read(Monitor_read),
			    .UserKToSend(monitor_userk),
			    .SendBlock(block_to_send[`USER_KBLOCKS]));
   
   
   logic [65:0] aurora_block;
   logic 	aurora_ack;
   
   Aurora66b64bPriorityMux priority_mux (.Data(data_to_send),
					 .DataBytes(data_bytes),
					 .UserK0(monitor_userk),
					 .ToSend(block_to_send),
					 .AuroraAck(aurora_ack),
					 .Clk(Clk),
					 .Rst(Rst),
					 .Sent(block_sent),
					 .Sending(block_sending),
					 .AuroraBlock(aurora_block));


   logic [65:0] aurora_scrambled;
   
   Scrambler scrambler (.DataIn(aurora_block[63:0]),
			.SyncBits(aurora_block[65:64]),
			.Ena(aurora_ack),
			.Clk(Clk),
			.Rst(Rst),
			.DataOut(aurora_scrambled));



   Gearbox66to20 gearbox (.Rst(Rst),
			  .Clk(Clk),
			  .Data66(aurora_scrambled),
			  .Data20(ToSerializer),
			  .DataNext(aurora_ack));



endmodule // aurora_64b66b_top
