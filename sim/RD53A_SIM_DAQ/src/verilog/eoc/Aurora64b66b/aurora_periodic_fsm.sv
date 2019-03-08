`timescale 1ns/1ps

`include "eoc/Aurora64b66b/aurora_definitions.sv"


module AuroraPeriodicFSM
  #(
    parameter WTS_WIDTH = 4,
    parameter BTS_WIDTH = 4)
   (
    input wire LaneReady,
    
    output logic SendBlock,
    input wire BlockSent,

    input wire [WTS_WIDTH-1:0] WaitToSend,
    input wire [BTS_WIDTH-1:0] BlocksToSend,

    input wire Clk,
    input wire Rst
    );

   enum        {NOT_READY, WAIT, SEND} fsm_state;

   always_ff @(posedge Clk) begin
      logic [WTS_WIDTH-1:0] wait_counter;
      logic [BTS_WIDTH-1:0] send_counter;
      if (Rst) begin
	 wait_counter <= 0;
	 send_counter <= 0;
	 fsm_state <= NOT_READY;
	 SendBlock <= 1'b0;
      end else begin
	 case(fsm_state)
	   NOT_READY : begin
	      SendBlock <= 1'b0;
	      wait_counter <= 0;
	      send_counter <= 0;
	      if (LaneReady)
		fsm_state <= WAIT;
	   end
	   WAIT : begin
	      SendBlock <= 1'b0;
	      send_counter <= 0;
	      if (~LaneReady)
		fsm_state <= NOT_READY;
	      else if (wait_counter < WaitToSend | WaitToSend == {WTS_WIDTH{1'b1}}) begin
		 wait_counter <= wait_counter + 1;
	      end else begin
		fsm_state <= SEND;
	      end
	   end
	   SEND : begin
	      wait_counter <= 0;
	      SendBlock <= 1'b1;
	      if (~LaneReady)
		fsm_state <= NOT_READY;
	      else if (send_counter < BlocksToSend) begin
		 if (BlockSent)
		   send_counter <= send_counter + 1;
	      end else begin
		fsm_state <= WAIT;
	      end	      
	   end
	 endcase
      end // else: !if(Rst)      
   end // always_ff @ (posedge Clk or posedge Rst)

endmodule // AuroraPeriodicFSM
