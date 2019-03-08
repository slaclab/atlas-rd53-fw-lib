
`timescale 1ns/1ps

`ifndef CG_WRAPPER
`define CG_WRAPPER

//module CG_MOD_pos (ClkIn, Enable, test, ClkOut);
//input ClkIn,Enable,test;
//output ClkOut;
//wire tm_out, ck_inb;
//reg enl;
//
//	assign tm_out = Enable | test;
//	assign ck_inb = ~ClkIn;
//	always @ (ck_inb or tm_out)
//	if (ck_inb)
//		enl = tm_out;
//	assign ClkOut = ClkIn & enl;
//	
//endmodule

//module CG_MOD_neg (ClkIn, Enable, test, ClkOut);
//	input ClkIn,Enable,test;
//	output ClkOut;
//	wire tm_out;
//	reg enl;
//		assign tm_out = Enable | test;
//		always @ (ClkIn or tm_out )
//		if (ClkIn)
//			enl = tm_out;
//		assign ClkOut = ClkIn | ~enl;
//endmodule


module CG_MOD (ClkIn, Enable, ClkOut);
input wire ClkIn,Enable;
output wire ClkOut;
//wire ck_inb;
//reg enl;
    CKLNQD1 cg_cell (.TE (1'b0), .E (Enable), .CP (ClkIn), .Q(ClkOut));

	//assign ck_inb = ~ClkIn;
	//always @ (ck_inb or Enable )
	//if (ck_inb)
	//	enl = Enable;
	//assign ClkOut = ClkIn & enl;
	
endmodule

/*
module CG_MOD_neg (ClkIn, Enable, ClkOut);
	input wire ClkIn,Enable;
	output wire ClkOut;
	//reg enl;
        
        CKLHQD1 cg_cell_neg (.TE(1'b0), .E (Enable), .CPN (ClkIn),.Q(ClkOut));
		//always @ (ClkIn or Enable)
		//if (ClkIn)
			//enl = Enable ;
		//assign ClkOut = ClkIn | ~enl;
endmodule
*/

`endif
