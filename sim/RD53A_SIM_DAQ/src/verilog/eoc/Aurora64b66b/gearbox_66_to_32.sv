

module Gearbox66to32 (
	input wire Rst,
	input wire Clk,
	input wire [65:0] Data66,
			
	output logic [31:0] Data32,
        output logic DataNext
       );

   logic [7:0] 	     counter;
   logic [31:0]      selected_data_32;
   logic [131:0]     buffer_132;
   logic 	     upper;
   
   always_ff @(posedge Clk) begin
      if(Rst)
	counter <= '{default:0};
      else
	if (counter == 7'd64)
	  counter <= 7'd00;
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

   assign data_next = counter[0];
   assign upper = ~counter[1];

   function logic [31:0] slice( logic [131:0] vector, logic [6:0] seg);
      logic [131:0] vector_rot;
      vector_rot = (vector >> ((seg*32)%132)) | (vector << (132-(seg*32)%132));
      return vector_rot[31:0];
   endfunction // slice

   always_comb begin
      selected_data_32 = 'z;
      for (int i = 0; i<65; i++)
	if (counter == i)
	  selected_data_32 = slice(buffer_132,i);
   end

   always_ff @(posedge Clk) begin
      Data32 <= selected_data_32;
   end
endmodule