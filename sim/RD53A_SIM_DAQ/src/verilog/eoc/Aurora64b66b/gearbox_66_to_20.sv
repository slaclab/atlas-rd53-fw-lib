`timescale 1ns/1ps

module Gearbox66to20(
	input wire Rst,
	input wire Clk,
	input wire [65:0] Data66,
			
	output logic [19:0] Data20,
        output logic DataNext
       );

   logic [5:0] 	     counter;
   logic [19:0]      selected_data_20;
   logic [131:0]     buffer_132;
   logic 	     upper;
   
   always_ff @(posedge Clk) begin
      if(Rst)
	counter <= '{default:0};
      else
	if (counter[5])
		counter <= '{default:0};
	else
		counter <= counter + 1;
   end


   always_ff @(posedge Clk) begin
      if(Rst) 
	 buffer_132 <= {Data66,Data66};
      else
	if (DataNext)
	  if (upper)
	    buffer_132 <= {Data66,buffer_132[65:0]};
	  else
	    buffer_132 <= {buffer_132[131:66],Data66};
   end

   assign DataNext = ((counter%3) == 2) & (counter != 5'h2);
   assign upper = ~((counter%6) == 5);

   function logic [19:0] slice( logic [131:0] vector, logic [6:0] seg);
      logic [131:0] vector_rot;
      vector_rot = (vector >> ((seg*20)%132)) | (vector << (132-(seg*20)%132));
      return vector_rot[19:0];
   endfunction // slice

   always_comb begin
      selected_data_20 = 'z;
      for (int i = 0; i<33; i++)
	if (counter == i)
	  selected_data_20 = slice(buffer_132,i);
   end

   always_ff @(posedge Clk) begin
      Data20 <= selected_data_20;
   end
endmodule
