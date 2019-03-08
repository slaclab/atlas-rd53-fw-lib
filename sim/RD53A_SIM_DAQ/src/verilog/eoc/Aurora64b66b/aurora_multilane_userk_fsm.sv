`timescale 1ns/1ps

`include "eoc/Aurora64b66b/aurora_definitions.sv"

module AuroraMultilaneUserKFSM(
		     input wire LaneReady,
		     input wire FIFO_Empty,
		     input wire [3:0][63:0] FIFO_UserK,
		     input wire BlockSent,

		     input wire Clk,
		     input wire Rst,

		     output logic FIFO_Read,
		     output logic [3:0][63:0] UserKToSend,
		     output logic SendBlock);

   enum 				{NOT_READY, NO_DATA, PREPARE_READ, READ_DATA} userk_fsm_state;
   logic [3:0][63:0] 			userk_word;
   logic 				userk_fill;
   logic 				userk_busy;

   //synopsys sync_set_reset "Rst"
   
     always_ff @(posedge Clk) begin
      if (Rst) begin
	 userk_fsm_state <= NOT_READY;
	 FIFO_Read <= 1'b0;
	 userk_busy <= 1'b0;
	 userk_fill <= 1'b0;
	 userk_word <= '0;
	 UserKToSend <= '0;
	 SendBlock <= 1'b0;
      end else begin
	 if (LaneReady) begin
	    case(userk_fsm_state)
	      NOT_READY : begin
		 if (FIFO_Empty) begin
		    userk_fsm_state <= NO_DATA;
		 end else begin
		    userk_fsm_state <= PREPARE_READ;
		    FIFO_Read <= 1'b1;
		 end
	      end

	      NO_DATA : begin
		 if (~FIFO_Empty) begin
		    userk_fsm_state <= PREPARE_READ;
		    FIFO_Read <= 1'b1;
		 end else if (userk_fill & (~userk_busy | BlockSent)) begin
		    SendBlock <= 1'b1;
		    UserKToSend <= userk_word;
		    userk_fill <= 1'b0;
		    userk_busy <= 1'b1;
		    FIFO_Read <= 1'b0;
		 end
		 if (BlockSent) begin
		    userk_busy <= 1'b0;
		    SendBlock <= 1'b0;
		 end
	      end

	      PREPARE_READ : begin
		 userk_fsm_state <= READ_DATA;
		 FIFO_Read <= 1'b1;
		 if (BlockSent) begin
		    userk_busy <= 1'b0;
		    SendBlock <= 1'b0;
		 end
	      end	      

	      READ_DATA : begin
		 if (FIFO_Empty & (~userk_busy | BlockSent)) begin
		    SendBlock <= 1'b1;
		    if (userk_fill) begin
		       UserKToSend <= userk_word;
		       userk_fill <= 1'b0;
		    end else begin
		       UserKToSend <= FIFO_UserK;
		       userk_fsm_state <= NO_DATA;
		    end		       
		    userk_busy <= 1'b1;
		    FIFO_Read <= 1'b0;
		 end else if (~FIFO_Empty & (~userk_busy | BlockSent)) begin
		    SendBlock <= 1'b1;
		    if (userk_fill) begin
		       UserKToSend <= userk_word;
		       userk_word <= FIFO_UserK;
		       userk_fill <= 1'b1;
		    end else begin
		       UserKToSend <= FIFO_UserK;
		       userk_fsm_state <= READ_DATA;
		    end		       
		    userk_busy <= 1'b1;
		    FIFO_Read <= 1'b1;
		 end else begin // if (~FIFO_Empty & (~userk_busy | BlockSent))
		    if (~userk_fill) begin
		       userk_word <= FIFO_UserK;
		       userk_fill <= 1'b1;
		    end
		    if (FIFO_Empty)
		      userk_fsm_state <= NO_DATA;
		    FIFO_Read <= 1'b0;
		 end
	      end	      
	    endcase
	 end else begin
	    userk_fsm_state <= NOT_READY;
	 end
      end
   end // always_ff @ (posedge Clk or posedge Rst)

endmodule // AuroraUserKFSM
