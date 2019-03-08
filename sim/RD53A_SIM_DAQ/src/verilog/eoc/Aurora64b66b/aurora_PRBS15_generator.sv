`timescale 1ns/ 1ps 
module PRBSWideGenerate
	#(
   parameter      WIDTH =20,
                  TAP1 = 15,
                  TAP2 = 14
   ) (
   // Outputs
   PRBS_Out,
   // Input
   Clk, Rst
   );


   output reg [WIDTH - 1:0] PRBS_Out;
   input              Clk, Rst;

   reg [WIDTH-1:0]    prbs;
   reg [WIDTH-1:0]    d;
   wire Clk, Rst;
 

   genvar                            i;
   generate
     for (i=0; i<WIDTH; i++) begin
       always_comb
         PRBS_Out[i] <= prbs[WIDTH-i-1];
       end
   endgenerate

   always @ (posedge Clk)
     begin
     if (Rst)
        begin
        prbs <= {WIDTH{1'b1}};
        end
     else
       begin
          prbs <= d;// les nouvelles valeurs des registres des polynomes
       end // else: !if(Rst)
     end

   always @ (negedge Clk)
     begin
          d = prbs;  
          repeat (WIDTH)begin
		  d= {d,d[TAP1-1]^d[TAP2-1]};
		  //d= {d[TAP1-1]^d[TAP2-1],d[WIDTH-1:1]};
		end          
       end
endmodule 


