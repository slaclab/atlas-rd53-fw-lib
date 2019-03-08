`timescale 1ns/1ps

`include "eoc/Aurora64b66b/aurora_definitions.sv"


module Aurora66b64bMultilanePriorityMux
  (input wire [63:0] Data,
   input wire [3:0] DataBytes,
   input wire [7:0] ToSend,

   input wire [63:0] UserK,
   
   input wire AuroraAck,

   input wire Clk,
   input wire Rst,

   output logic [7:0] Sent,
//   output logic [7:0] Sending,
   output logic [65:0] AuroraBlock
   );

   logic [0:65]	       int_aurora_block;
   // logic 	       busy;
   logic [7:0] 	       sending;
   
   
   always_ff @(posedge Clk) begin
      if (Rst) begin
        int_aurora_block <= {2'b10,`IDLE_BLOCK,8'h10,48'h0};
        sending <= 0;
      end else begin
	 if (sending == 8'h0) begin
	    priority if (ToSend[`CLOCK_COMPENSATION]) begin
	       int_aurora_block <= {2'b10,`CC_BLOCK,8'h80,48'h0};
	       sending[`CLOCK_COMPENSATION] <= 1'b1;
	    end else if (ToSend[`NOT_READY]) begin
	       int_aurora_block <= {2'b10,`NR_BLOCK,8'h20,48'h0};
	       sending[`NOT_READY] <= 1'b1;	 
	    end else if (ToSend[`CHANNEL_BONDING]) begin
	       int_aurora_block <= {2'b10,`CB_BLOCK,8'h40,48'h0};
	       sending[`CHANNEL_BONDING] <= 1'b1;
	    end else if (ToSend[`NATIVE_FLOW_CONTROL]) begin
	       int_aurora_block <= {2'b10,`NFC_BLOCK,56'h0};
	       sending[`NATIVE_FLOW_CONTROL] <= 1'b1;
	    end else if (ToSend[`USER_FLOW_CONTROL]) begin
	       int_aurora_block <= {2'b10,`UFC_BLOCK,56'h0};
	       sending[`USER_FLOW_CONTROL] <= 1'b1;	  
	    end else if (ToSend[`USER_KBLOCKS]) begin
	       int_aurora_block <= {2'b10,UserK};
	       sending[`USER_KBLOCKS] <= 1'b1;	    
	    end else if (ToSend[`USER_DATA]) begin
	       if (DataBytes == `DISABLE_DATA) begin
		  int_aurora_block <= {2'b10,`IDLE_BLOCK,8'h10,48'hADA0000};
	       end else if (DataBytes == `FULL_DATA) begin
		  int_aurora_block <= {2'b01,Data};
	       end else if (DataBytes == 4'd7) begin
		  int_aurora_block <= {2'b10,`SEP7_BLOCK,Data[55:0]};
	       end else begin
		  int_aurora_block <= {2'b10,`SEP_BLOCK,5'b0,DataBytes[2:0],Data[47:0]};
	       end
	       sending[`USER_DATA] <= 1'b1;
	    end else if (ToSend[`IDLE]) begin
	       int_aurora_block <= {2'b10,`IDLE_BLOCK,8'h10,48'h0};
	       sending[`IDLE] <= 1'b1;	    
	    end else begin
	       int_aurora_block <= {2'b10,`IDLE_BLOCK,8'h10,48'hADA};
	       sending[`IDLE] <= 1'b1;	    
	    end
	 end else begin // if (sending == 8'h0)
	    if (AuroraAck)
	      sending <= 8'h00;
	 end
      end
   end // always_ff @ (posedge Clk or posedge Rst)

//   logic sent_sig;
//   assign Sending = sending;
   assign Sent = AuroraAck ? sending : 8'h00;
//   always_ff @ (posedge Clk)
//     Sent <= sent_sig;
   
   
   assign AuroraBlock = int_aurora_block;
   
endmodule // aurora_priority_mux

