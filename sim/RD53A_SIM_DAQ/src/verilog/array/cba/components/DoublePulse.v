module DoublePulse (clk, reset, enable, p1, p2, pw);

input wire clk;
input wire reset;
input wire enable;
output wire p1;
output wire p2;
output wire pw;

reg npulsew, ppulsew;

always @(posedge clk or posedge reset)
	if(reset == 1'b1)
		npulsew <= 1'b0;
	else
		npulsew <= enable & ~npulsew;


always @(posedge clk or posedge reset)
	if(reset == 1'b1)
		ppulsew <= 1'b0;
	else
		ppulsew <= npulsew;

//CG_MOD CG_clk_gated(.ClkIn(clk), .Enable(enable), .ClkOut(p1));
assign p1 = npulsew & ~clk;
assign p2 = (ppulsew & ~clk) | reset;

assign pw = ppulsew | npulsew;

endmodule
