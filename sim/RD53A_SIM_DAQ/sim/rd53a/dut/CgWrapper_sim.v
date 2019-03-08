//-------------------------------------------------------------------------------
// Just can be used for RTL simulation (to not force to use models from foundry) 
//-------------------------------------------------------------------------------

`timescale 1ns/1ps

module CKLNQD1 (TE, E , CP, Q);
input wire CP,E, TE;
output wire Q;
wire ck_inb;
reg enl;
	assign ck_inb = ~CP;
	always @ (ck_inb or E)
	if (ck_inb)
		enl = E;
	assign Q = CP & enl;	
endmodule


module CKLHQD1 (TE, E, CPN, Q);
	input wire CPN,E, TE;
	output wire Q;
	reg enl;
        
        always @ (CPN or E)
		if (CPN)
			enl = E ;
		assign Q = CPN | ~enl;
endmodule


