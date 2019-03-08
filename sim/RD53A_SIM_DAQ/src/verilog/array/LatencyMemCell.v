`ifndef  LATENCY_MEM_CELL__V
`define  LATENCY_MEM_CELL__V

`resetall
`timescale 1ns/1ps

module LatencyMemCell( 
                    Clk, 
                    Reset, 
                    WriteLe, 
                    L1, 
                    Full, 
                    ReadyToRead, 
                    Read,
                    L1In,
                    L1Req,
                    LatCntIn,
                    LatCntReq
                    );
                    
input wire WriteLe, L1, Clk, Reset, Read;

input wire [8:0] LatCntIn, LatCntReq;

input wire [4:0] L1In;
input wire [4:0] L1Req;

output reg ReadyToRead;
output wire Full;

reg [8:0] counter; 

wire counter_last;
reg start;
reg trig;
wire req_to_read;
    
assign Full = start | trig;

assign counter_last = (counter==LatCntReq) & start & !trig;

wire la;
CG_MOD cg_start(.ClkIn(Clk), .Enable(WriteLe | counter_last  | req_to_read | Read ), .ClkOut(la)); // | Reset

wire triggered;
assign triggered = counter_last & L1;

always@(posedge la) begin
    if(counter_last)
        counter[4:0] <= L1In; 
    else //if (WriteLe)
        counter <= LatCntIn;
    //else 
    //    counter <= counter;
end

//*****Memory FSM states****** 
//           start  trig
//IDLE        0     0
//COUNTING    1     0
//TRIGGERED   1     1
//TOREAD      0     1  
//****************************

always @ (posedge la or posedge Reset)  // | Reset
    if(Reset)
        start <= 0;
    else if(WriteLe | triggered)
        start <= 1;
    else
        start <= 0;

always @ (posedge la or posedge Reset)
    if(Reset)
        trig <= 0;
    else if(triggered | req_to_read)
        trig <= 1;
    else
        trig <= 0;
        
assign req_to_read = start & trig & ( counter[4:0] == L1Req );
    
assign ReadyToRead = trig & !start; 

endmodule //LatencyMemoryCell

`endif