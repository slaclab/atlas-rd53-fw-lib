`timescale 1ns/1ps

`include "eoc/Aurora64b66b/aurora_definitions.sv"

module AuroraDataFrameFSM(
		     input wire LaneReady,
		     input wire FIFO_Empty,
		     input wire [31:0] FIFO_Data,
		     input wire EndOfFrame,
		     input wire BlockSent,

		     input wire Clk,
		     input wire Rst,

		     output logic FIFO_Read,
		     output logic [63:0] DataToSend,
		     output logic SendBlock,
		     output logic [3:0] BytesToSend);

   enum 				{NOT_READY, NO_DATA, PREPARE_READ, READ_DATA_UPPER, READ_DATA_LOWER, SEND_EOF, WAIT_TO_SEND, STORE_TO_SEND} data_fsm_state;
   logic [63:0] 			data_word, data_next;
   logic [3:0] 				bytes_next;
   logic 				data_fill;
   logic 				data_busy;
   logic 				eof_to_send;
   

     always_ff @(posedge Clk ) begin
      if (Rst) begin
	 data_fsm_state <= NOT_READY;
	 FIFO_Read <= 1'b0;
	 data_busy <= 1'b0;
	 data_fill <= 1'b0;
	 data_word <= 64'h0;
	 data_next <= 64'h0;
	 DataToSend <= 64'h0;
	 SendBlock <= 1'b0;
	 BytesToSend <= 4'h0;
	 eof_to_send <= 1'b0;
	 
      end else begin
	 if (LaneReady) begin
	    case(data_fsm_state)
	      NOT_READY : begin
		 if (FIFO_Empty) begin
		    data_fsm_state <= NO_DATA;
		 end else begin
		    data_fsm_state <= PREPARE_READ;
		    FIFO_Read <= 1'b1;
		 end
	      end

	      NO_DATA : begin
		 if (~FIFO_Empty) begin
		    data_fsm_state <= PREPARE_READ;
		    FIFO_Read <= 1'b1;
		 end
		 if (BlockSent) begin
		    data_busy <= 1'b0;
		    SendBlock <= 1'b0;
		 end
	      end

	      PREPARE_READ : begin
		 if (data_fill) begin
		    data_fsm_state <= READ_DATA_LOWER;
		 end else begin
		    data_fsm_state <= READ_DATA_UPPER;
		 end
		 FIFO_Read <= 1'b1;
		 if (BlockSent) begin
		    data_busy <= 1'b0;
		    SendBlock <= 1'b0;
		 end
	      end

	      SEND_EOF : begin
		 if (~data_busy | BlockSent) begin
		    eof_to_send <= 1'b0;
		    SendBlock <= 1'b1;
		    DataToSend <= {32'h0,32'h0};
		    BytesToSend <= 4'h0;
		    data_busy <= 1'b1;
		    data_fsm_state <= NO_DATA;
		 end
		 if (BlockSent) begin
		    data_busy <= 1'b0;
		    SendBlock <= 1'b0;
		 end
	      end

	      WAIT_TO_SEND : begin
		 if (~data_busy | BlockSent) begin
		    DataToSend <= data_next;
		    BytesToSend <= bytes_next;
		    SendBlock <= 1'b1;
		    data_busy <= 1'b1;
		    if (eof_to_send) begin
		       data_fsm_state <= SEND_EOF;	       
		    end else if (FIFO_Empty) begin	
		       data_fsm_state <= NO_DATA;	       
		    end else begin
		       data_fsm_state <= PREPARE_READ;
		       FIFO_Read <= 1'b1;
		    end
		 end
	      end

	      STORE_TO_SEND : begin
		 if (~data_busy | BlockSent) begin
		    DataToSend <= data_next;
		    BytesToSend <= bytes_next;
		    data_busy <= 1'b1;
		    SendBlock <= 1'b1;
		    if (eof_to_send) begin
		       data_fsm_state <= SEND_EOF;	       
		    end else if (FIFO_Empty) begin	
		       data_fsm_state <= READ_DATA_UPPER;	       
		       FIFO_Read <= 1'b0;
		    end else begin
		       data_fsm_state <= READ_DATA_UPPER;
		       FIFO_Read <= 1'b1;
		    end
		 end
	      end

	      
	      READ_DATA_UPPER : begin
		 data_fill <= 1'b0;
		 if (EndOfFrame) begin
		    if (data_busy) begin
		       data_next <= {32'h0,FIFO_Data};
		       bytes_next <= 4'h4;
		       FIFO_Read <= 1'b0;
		       if (~FIFO_Read | FIFO_Empty) begin
			  data_fsm_state <= WAIT_TO_SEND;
		       end else begin
			  data_fsm_state <= STORE_TO_SEND;
		       end
		    end else begin
		       DataToSend <= {32'h0,FIFO_Data};
		       BytesToSend <= 4'h4;
		       data_busy <= 1'b1;
		       SendBlock <= 1'b1;
		       if (FIFO_Empty) begin
			  FIFO_Read <= 1'b0;
			  data_fsm_state <= NO_DATA;
		       end else begin
			  data_fsm_state <= READ_DATA_UPPER;
		       end
		    end
		 end else begin
		    data_word[63:32] <= FIFO_Data;
		    data_fill <= 1'b1;
		    if (FIFO_Empty) begin
		       data_fsm_state <= NO_DATA;
		       FIFO_Read <= 1'b0;		       
		    end else begin
		       if (~FIFO_Read) begin
			  data_fsm_state <= PREPARE_READ;
		       end else begin
			  data_fsm_state <= READ_DATA_LOWER;
		       end
		       FIFO_Read <= 1'b1;
		    end
		 end		 
		 if (BlockSent) begin
		    data_busy <= 1'b0;
		    SendBlock <= 1'b0;
		 end
	      end

	      READ_DATA_LOWER : begin
		 data_fill <= 1'b0;		 
		 if (EndOfFrame) begin
		    if (data_busy) begin
		       data_next <= {data_word[63:32],FIFO_Data};
		       bytes_next <= `FULL_DATA;
		       FIFO_Read <= 1'b0;
		       eof_to_send <= 1'b1;
		       if (FIFO_Empty) begin
			  data_fsm_state <= WAIT_TO_SEND;
		       end else begin
			  data_fsm_state <= STORE_TO_SEND;
		       end
		    end else begin
		       DataToSend <= {data_word[63:32],FIFO_Data};
		       BytesToSend <= `FULL_DATA;
		       data_busy <= 1'b1;
		       SendBlock <= 1'b1;
		       data_fsm_state <= SEND_EOF;
		    end
		 end else begin // if (EndOfFrame)
		    if (data_busy) begin
		       data_next <= {data_word[63:32],FIFO_Data};
		       bytes_next <= `FULL_DATA;
		       FIFO_Read <= 1'b0;
		       if (FIFO_Empty) begin
			  data_fsm_state <= WAIT_TO_SEND;
		       end else begin
			  data_fsm_state <= STORE_TO_SEND;
		       end
		    end else begin
		       DataToSend <= {data_word[63:32],FIFO_Data};
		       BytesToSend <= `FULL_DATA;
		       data_busy <= 1'b1;
		       SendBlock <= 1'b1;
		       if (FIFO_Empty) begin
			  FIFO_Read <= 1'b0;
			  data_fsm_state <= SEND_EOF;
		       end else begin
			  FIFO_Read <= 1'b1;
			  data_fsm_state <= READ_DATA_UPPER;
		       end
		    end
		 end // else: !if(EndOfFrame)
		 if (BlockSent) begin
		    data_busy <= 1'b0;
		    SendBlock <= 1'b0;
		 end
	      end
	    endcase
	 end else begin
	    data_fsm_state <= NOT_READY;
	 end
      end
   end // always_ff @ (posedge Clk or posedge Rst)

endmodule // AuroraDataFSM
