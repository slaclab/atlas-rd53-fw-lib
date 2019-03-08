
`resetall
`timescale 1ns/1ps

`include "array/interfaces/CoreCBAIf.sv"

/*
// MSB-to-LSB comparator, slower but should have a lower switching activity.
module eq (i1, i2, o);

parameter w = 1;

input wire [w-1:0] i1;
input wire [w-1:0] i2;
output wire o;

wire [w:0] eq;

assign eq[w]= 1;

generate
	genvar k;
	for (k=w-1;k>=0;k--)
		assign eq[k] = eq[k+1] & (i1[k] ~^ i2[k]);
endgenerate

assign o = eq[0];

endmodule
*/



module LatencyMemCell_CBA ( 
	input wire WriteLe,
	input wire L1, 
	input wire Clk, 
	input wire Reset, 
	input wire Read,

	input wire [8:0] LatCntIn, 
	input wire [8:0] LatCntReq,

	input wire [4:0] L1In,
	input wire [4:0] L1Req,
	input wire [`CBA_DATA_BITS-1:0] WriterData,

	output reg ReadyToRead,
	output wire Full,
	output reg [`CBA_DATA_BITS-1:0] Data
);

reg [8:0] counter; 

wire counter_last;
reg start;
reg trig;
wire req_to_read;
    
assign Full = start | trig;

wire counter_match = (counter == LatCntReq);
//eq #(9) counter_match_gen (.i1(counter), .i2(LatCntReq), .o(counter_match));
assign counter_last = counter_match & start & ~trig;


wire sla;
CG_MOD cg_start(.ClkIn(Clk), .Enable(WriteLe | counter_last  | req_to_read | Read ), .ClkOut(sla));

wire triggered;
assign triggered = counter_last & L1;

always @ (posedge sla) begin
	if(counter_last)
	    counter[4:0] <= L1In; 
	else //if (WriteLe)
	    counter <= LatCntIn;
end

//*****Memory FSM states****** 
//           start  trig
//IDLE        0     0
//COUNTING    1     0
//TRIGGERED   1     1
//TOREAD      0     1  
//****************************

always @ (posedge sla or posedge Reset)  // | Reset
    if(Reset)
        start <= 0;
	else if(WriteLe | triggered)
	    start <= 1;
	else
	    start <= 0;

always @ (posedge sla or posedge Reset)  // | Reset
    if(Reset)
        trig <= 0;
	else if(triggered | req_to_read)
	    trig <= 1;
	else
	    trig <= 0;

wire trig_id_match = (counter[4:0] == L1Req);
//eq #(5) trig_id_match_gen (.i1(counter[4:0]), .i2(L1Req), .o(trig_id_match));

assign req_to_read = start & trig & trig_id_match;
    
assign ReadyToRead = trig & !start; 

// Hit Map + TOTs
always @(posedge sla)
	if(WriteLe)
		Data <= WriterData;

endmodule //LatencyMemoryCell

