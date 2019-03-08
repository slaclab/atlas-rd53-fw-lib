
`timescale 1ps / 1ps

module ColumnReadControl(

    input wire Reset, Clk, Trigger,
    input wire Token, Ready,
    output logic Read, TriggerOut,
    output logic [4:0] TriggerId, TriggerIdReq, TriggerIdReqBin,

    input wire [4:0] TriggerIdGlobal,
    output wire TriggerNextAccpet,
    output wire [4:0] TriggerDistance,

    output wire DataReady,
    input logic [1:0] WaitReadCnfg
);

enum {START, WAIT, DATA} state, next_state;

//synopsys sync_set_reset "Reset"

always@(posedge Clk)
 if(Reset)
     state <= START;
  else
     state <= next_state;

logic [2:0] DelayCnt;
logic [4:0] TriggerIdReqCnt;

logic trigger_eq;
assign trigger_eq = (TriggerIdReqCnt == TriggerIdGlobal);

always@(*) begin : set_next_state
    next_state = state; //default
    case (state)
        START:
            if(!trigger_eq)
                next_state = WAIT;
        WAIT:
            if(DelayCnt == WaitReadCnfg && Ready)
                next_state = DATA;
        DATA:
            if(Token)
                next_state = WAIT;
            else
                next_state = START;

    endcase
end

always@(posedge Clk) begin
    if(Reset || (next_state == WAIT && state != WAIT) )
        DelayCnt <= 0;
    else if( DelayCnt != WaitReadCnfg)
        DelayCnt <= DelayCnt + 1;
end

assign TriggerNextAccpet = TriggerIdGlobal+1 != TriggerIdReqCnt;

logic TriggerReqInc;
assign TriggerReqInc = (state == DATA && next_state == START);

assign TriggerDistance = TriggerIdGlobal - TriggerIdReqCnt;

always@(posedge Clk)
if(Reset)
    TriggerIdReqCnt <= 0;
else if( TriggerReqInc )
    TriggerIdReqCnt <= TriggerIdReqCnt + 1;

assign TriggerId = (TriggerIdGlobal >> 1) ^ TriggerIdGlobal; //TrigL1IdCnt;
assign TriggerIdReq = (TriggerIdReqCnt >> 1) ^ TriggerIdReqCnt; //TrigReqL1IdCnt;
assign TriggerIdReqBin = TriggerIdReqCnt;

always@(posedge Clk)
    TriggerOut <= Trigger ;

assign Read = (state == DATA); 

assign DataReady = Read & Token;

endmodule
