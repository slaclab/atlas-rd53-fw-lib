`timescale 1 ps / 1 ps

module Scrambler(
		 input wire [63:0] DataIn,
		 input wire [1:0] SyncBits,
		 input wire Ena,
		 input wire Clk,
		 input wire Rst,
		 output logic [65:0] DataOut
		 );

   logic [127:0] 		     scrambled_data;

   genvar 			     i;
   generate
      for (i=64; i<128; i++) begin
	 always_comb
	   scrambled_data[i] = DataIn[127-i] ^ scrambled_data[i-58] ^ scrambled_data[i-39];  
      end
   endgenerate

   
   always_ff @(posedge Clk) begin
      if (Rst)
	scrambled_data[63:0] <= '{default:1};
      else
	if (Ena)
		scrambled_data[63:0] <= scrambled_data[127:64];
   end

   logic [65:0] outvec;
   
   assign outvec = {scrambled_data[127:64],SyncBits[0],SyncBits[1]};
   assign DataOut = outvec;
   
endmodule // scrambler
