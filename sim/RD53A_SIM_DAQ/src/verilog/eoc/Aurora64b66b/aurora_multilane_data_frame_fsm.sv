`timescale 1ns/1ps

`include "eoc/Aurora64b66b/aurora_definitions.sv"

module AuroraDataFrameMultilaneFSM(
				   input wire LaneReady,
				   input wire FIFO_Empty,
				   input wire [7:0][31:0] FIFO_Data,
				   input wire [7:0] FIFO_DataMask,
				   input wire EndOfFrame,
				   input wire BlockSent,
				   
				   input wire [7:0] CompleteDataMask,

				   input wire Clk,
				   input wire Rst,

				   output logic FIFO_Read,
				   output logic [3:0][63:0] DataToSend,
				   output logic SendBlock,
				   output logic [3:0][3:0] BytesToSend);

   enum 				{NOT_READY, NO_DATA, PREPARE_READ, READ_DATA, SEND_EOF, STORE_TO_SEND} data_fsm_state;
   logic 				data_good;
   logic [3:0][63:0] 			stored_datatosend;
   logic [3:0][3:0] 			stored_bytestosend;
   logic [7:0] 				stored_datamask;
   logic 				stored_eof;
   

   always_ff @(posedge Clk) begin
      if (Rst) begin
	 data_fsm_state <= NOT_READY;
	 FIFO_Read <= 1'b0;
	 DataToSend <= {4{64'h0}};
	 SendBlock <= 1'b0;
	 BytesToSend <= {4{4'h0}};
	 data_good <= 1'b0;
	 
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
		    SendBlock <= 1'b0;
		 end
	      end

	      PREPARE_READ : begin
		 data_fsm_state <= READ_DATA;
		 FIFO_Read <= 1'b1;
		 if (BlockSent) begin
		    SendBlock <= 1'b0;
		 end
	      end

	      SEND_EOF : begin
		 if (BlockSent) begin
		    SendBlock <= 1'b0;
		 end
		 if (~SendBlock | BlockSent) begin
		    SendBlock <= 1'b1;
		    DataToSend <= '0;
		    BytesToSend[0] <= 4'h0;
		    BytesToSend[1] <= `DISABLE_DATA;
		    BytesToSend[2] <= `DISABLE_DATA;
		    BytesToSend[3] <= `DISABLE_DATA;
		    if (~FIFO_Empty) begin
		       FIFO_Read <= 1'b1;
		       if (data_good) begin
			  data_fsm_state <= READ_DATA;
		       end else begin
			  data_fsm_state <= PREPARE_READ;
		       end
		    end else begin
		       FIFO_Read <= 1'b0;
		       if (data_good) begin
			  data_good <= 1'b0;
			  data_fsm_state <= STORE_TO_SEND;
			  stored_datatosend <= FIFO_Data;
			  stored_bytestosend[0][1:0] <= FIFO_DataMask[0] ? 2'b11 : 2'b00;
			  stored_bytestosend[0][3:2] <= FIFO_DataMask[1] ? 2'b11 : 2'b00;
			  stored_bytestosend[1][1:0] <= FIFO_DataMask[2] ? 2'b11 : 2'b00;
			  stored_bytestosend[1][3:2] <= FIFO_DataMask[3] ? 2'b11 : 2'b00;
			  stored_bytestosend[2][1:0] <= FIFO_DataMask[4] ? 2'b11 : 2'b00;
			  stored_bytestosend[2][3:2] <= FIFO_DataMask[5] ? 2'b11 : 2'b00;
			  stored_bytestosend[3][1:0] <= FIFO_DataMask[6] ? 2'b11 : 2'b00;
			  stored_bytestosend[3][3:2] <= FIFO_DataMask[7] ? 2'b11 : 2'b00;
			  stored_datamask <= FIFO_DataMask;
			  stored_eof <= EndOfFrame;
		       end else begin
			  data_fsm_state <= NO_DATA;
		       end // else: !if(data_good)
		    end // else: !if(~FIFO_Empty)
		 end // if (~SendBlock | BlockSent)
	      end // case: SEND_EOF

	      STORE_TO_SEND : begin
		 if (BlockSent) begin
		    SendBlock <= 1'b0;
		 end
		 if (~SendBlock | BlockSent) begin
		    if (stored_eof & (stored_datamask == CompleteDataMask)) begin
		       data_fsm_state <= SEND_EOF;
		    end else begin
		       if (~FIFO_Empty) begin
			  FIFO_Read <= 1'b1;
			  if (data_good) begin
			     data_fsm_state <= READ_DATA;
			  end else begin
			     data_fsm_state <= PREPARE_READ;
			  end
		       end else begin
			  FIFO_Read <= 1'b0;
			  if (data_good) begin
			     data_good <= 1'b0;
			     data_fsm_state <= STORE_TO_SEND;
			     stored_datatosend <= FIFO_Data;
			     stored_datamask <= FIFO_DataMask;
			     stored_eof <= EndOfFrame;
			  end else begin
			     data_fsm_state <= NO_DATA;
			  end
		       end
		    end // else: !if(EndOfFrame & (FIFO_DataMask == CompleteDataMask))
		    BytesToSend[0] <= stored_datamask[1] ? `FULL_DATA :
				     (stored_datamask[0] ? 4'b0100 : 4'h0000);
		    BytesToSend[1] <= stored_datamask[3] ? `FULL_DATA :
				     (stored_datamask[2] ? 4'b0100 : 
				      (stored_datamask[1] == 1'b0 ? `DISABLE_DATA : 4'h0000));
		    BytesToSend[2] <= stored_datamask[5] ? `FULL_DATA :
				     (stored_datamask[4] ? 4'b0100 : 
				      (stored_datamask[3] == 1'b0 ? `DISABLE_DATA : 4'h0000));
		    BytesToSend[3] <= stored_datamask[7] ? `FULL_DATA :
				     (stored_datamask[6] ? 4'b0100 : 
				      (stored_datamask[5] == 1'b0 ? `DISABLE_DATA : 4'h0000));
		    SendBlock <= 1'b1;
		    DataToSend <= stored_datatosend;
		    
		 end else begin // if (~SendBlock | BlockSent)
		    data_fsm_state <= STORE_TO_SEND;		    
		 end
	      end

	      READ_DATA : begin	 
		 if (BlockSent) begin
		    SendBlock <= 1'b0;
		 end
		 if (~SendBlock | BlockSent) begin
		    if (EndOfFrame & (FIFO_DataMask == CompleteDataMask)) begin
		       data_fsm_state <= SEND_EOF;
		       FIFO_Read <= 1'b0;
		       if (~FIFO_Empty) begin
			  data_good <= 1'b1;
		       end
		    end else begin
		       if (~FIFO_Empty) begin
			  FIFO_Read <= 1'b1;
			  data_fsm_state <= READ_DATA;
		       end else begin
			  FIFO_Read <= 1'b0;
			  data_fsm_state <= NO_DATA;
		       end
		    end // else: !if(EndOfFrame & (FIFO_DataMask == CompleteDataMask))
		    DataToSend <= FIFO_Data;
		    SendBlock <= 1'b1;
		    BytesToSend[0] <= FIFO_DataMask[1] ? `FULL_DATA :
				     (FIFO_DataMask[0] ? 4'b0100 : 4'h0000);
		    BytesToSend[1] <= FIFO_DataMask[3] ? `FULL_DATA :
				     (FIFO_DataMask[2] ? 4'b0100 : 
				      (FIFO_DataMask[1] == 1'b0 ? `DISABLE_DATA : 4'h0000));
		    BytesToSend[2] <= FIFO_DataMask[5] ? `FULL_DATA :
				     (FIFO_DataMask[4] ? 4'b0100 : 
				      (FIFO_DataMask[3] == 1'b0 ? `DISABLE_DATA : 4'h0000));
		    BytesToSend[3] <= FIFO_DataMask[7] ? `FULL_DATA :
				     (FIFO_DataMask[6] ? 4'b0100 : 
				      (FIFO_DataMask[5] == 1'b0 ? `DISABLE_DATA : 4'h0000));

		 end else begin // if (~SendBlock | BlockSent)
		    data_fsm_state <= STORE_TO_SEND;
		    FIFO_Read <= 1'b0;
		    if (~FIFO_Empty) begin
		       data_good <= 1'b1;
		    end
		    stored_datatosend <= FIFO_Data;
		    stored_datamask <= FIFO_DataMask;
		    stored_eof <= EndOfFrame;
		    
		 end
	      end

	    endcase
	 end else begin
	    data_fsm_state <= NOT_READY;
	 end
      end
   end // always_ff @ (posedge Clk or posedge Rst)

endmodule // AuroraDataFSM
