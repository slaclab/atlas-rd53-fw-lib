//`include "CoreCBAIf.v"

//`ifndef DIGITAL_CORE_BB
//    `include "array/RowAddressDec.v"
//`endif

`include "array/interfaces/CoreCBAIf.sv"
`include "array/sigfork.v"

module DigitalCoreLogic_CBA (
	CoreCommonIf,
	CoreCBAIf,
	TokenPos,
	TokenLastRegion,
	DataLastRegion,
	HitOr,
	ThisCoreRead,
    CoreRowAddressUser,
    L1TrigCoreLocal,
    TrigIdCoreLocal,
    TrigIdReqCoreLocal,
    LatCntCoreLocal,
    LatCntReqCoreLocal
);

CoreCommonIf.core_logic CoreCommonIf;
CoreCBAIf.core_logic CoreCBAIf;
input wire [`CBA_REGIONS-1:0] TokenPos; //added to interface to regions
input wire TokenLastRegion;
input wire [`CBA_DATA_BITS-1:0] DataLastRegion;
input wire [`REG_PIXELS-1:0][`REGIONS-1:0] HitOr;
output wire ThisCoreRead; //added to interface to regions
output wire [5:0] CoreRowAddressUser;
output wire L1TrigCoreLocal;
output wire [4:0] TrigIdCoreLocal;
output wire [4:0] TrigIdReqCoreLocal;
output wire [8:0] LatCntCoreLocal;
output wire [8:0] LatCntReqCoreLocal;

`ifndef DIGITAL_CORE_BB


// Fork global signals

SigFork i_l1_trig_id_fork (.I(CoreCommonIf.L1Trig), .L(L1TrigCoreLocal), .O(CoreCommonIf.L1TrigOut));

generate
    genvar trig_id_index;
    for  (trig_id_index= 0; trig_id_index < 5; trig_id_index=trig_id_index+1) begin : trig_id_fork
        SigFork i_trig_id_fork (.I(CoreCommonIf.TrigId[trig_id_index]), .L(TrigIdCoreLocal[trig_id_index]), .O(CoreCommonIf.TrigIdOut[trig_id_index]));
        SigFork i_trig_id_req_fork (.I(CoreCommonIf.TrigIdReq[trig_id_index]), .L(TrigIdReqCoreLocal[trig_id_index]), .O(CoreCommonIf.TrigIdReqOut[trig_id_index]));
    end
endgenerate 

generate
    genvar lat_cnt_index;
    for  (lat_cnt_index= 0; lat_cnt_index < 9; lat_cnt_index=lat_cnt_index+1) begin : lat_cnt_fork
        SigFork i_lat_cnt_id_fork (.I(CoreCommonIf.LatCnt[lat_cnt_index]), .L(LatCntCoreLocal[lat_cnt_index]), .O(CoreCommonIf.LatCntOut[lat_cnt_index]));
        SigFork i_lat_cnt_req_fork (.I(CoreCommonIf.LatCntReq[lat_cnt_index]), .L(LatCntReqCoreLocal[lat_cnt_index]), .O(CoreCommonIf.LatCntReqOut[lat_cnt_index]));
    end
endgenerate 


//assign CoreCommonIf.L1TrigOut = CoreCommonIf.L1Trig; // SigFork
assign CoreCommonIf.ResetOut = CoreCommonIf.Reset;
assign CoreCommonIf.ClkOut = CoreCommonIf.Clk;
assign CoreCommonIf.ReadOut = CoreCommonIf.Read;
//assign CoreCommonIf.TrigIdOut = CoreCommonIf.TrigId;
//assign CoreCommonIf.TrigIdReqOut = CoreCommonIf.TrigIdReq;

//assign CoreCommonIf.LatCntOut = CoreCommonIf.LatCnt;
//assign CoreCommonIf.LatCntReqOut = CoreCommonIf.LatCntReq;


assign CoreCommonIf.ConfWrOut = CoreCommonIf.ConfWrIn;
assign CoreCommonIf.DataConfWrOut = CoreCommonIf.DataConfWrIn;
assign CoreCommonIf.AddressConfOut = CoreCommonIf.AddressConfIn;

assign CoreCommonIf.EnDigHitOut = CoreCommonIf.EnDigHit;
assign CoreCommonIf.CalEdgeOut = CoreCommonIf.CalEdge;
assign CoreCommonIf.CalAuxOut = CoreCommonIf.CalAux;
assign CoreCommonIf.AnaInjectionModeOut = CoreCommonIf.AnaInjectionMode;
assign CoreCommonIf.DefConfOut = CoreCommonIf.DefConf;

assign CoreCommonIf.AddressOut = CoreCommonIf.AddressIn -1;

//assign CoreCommonIf.OutLo = 1'b0; 
// synopsys dc_script_begin
// set_dont_touch LTIELO_OUTLO
// synopsys dc_script_end 
TIEL LTIELO_OUTLO (.ZN(CoreCommonIf.OutLo)); 


// CBA and AFE_TO signals
assign CoreCBAIf.PhiAzOut = CoreCBAIf.PhiAzIn ; 
assign CoreCBAIf.SelC2fOut = CoreCBAIf.SelC2fIn ; 
assign CoreCBAIf.SelC4fOut = CoreCBAIf.SelC4fIn ; 
assign CoreCBAIf.FastEnOut = CoreCBAIf.FastEnIn ; 
assign CoreCBAIf.WriteSyncTimeOut = CoreCBAIf.WriteSyncTimeIn ;





assign CoreCommonIf.TokOut = CoreCommonIf.TokIn | TokenLastRegion;

assign ThisCoreRead = (CoreCommonIf.TokIn==0 && CoreCommonIf.TokOut==1);

wire [3:0] hit_or_four_int;
genvar p_or ;//,b;
for  (p_or =0; p_or<`REG_PIXELS; p_or=p_or+1)  
    assign hit_or_four_int [p_or] =  (|HitOr[p_or]) | CoreCommonIf.HitOrIn[p_or]; // OR pixels from different regions (with same hitOr pixel index, after remapping: hit_or_mapper) 
assign CoreCommonIf.HitOrOut = hit_or_four_int;

logic [1:0] row_int;

always_comb begin
	row_int <= 2'bxx;

	if(TokenPos[0])
		row_int <= 2'b00;
	else if(TokenPos[1])
		row_int <= 2'b01;
	else if(TokenPos[2])
		row_int <= 2'b10;
	else if(TokenPos[3])
		row_int <= 2'b11;
end

// Core row address adaptation. 
// CoreCommonIf.AddressIn is 47 to 48-ROWS from bottom to top (while addressing scheme has 0 on top, ROWS-1 on bottom)
wire [5:0] core_row_address_user;
assign core_row_address_user = CoreCommonIf.AddressIn - (48 - `ROWS) ;
assign CoreRowAddressUser = core_row_address_user;
assign CoreCBAIf.RowOut = (ThisCoreRead) ? {core_row_address_user, row_int} :  CoreCBAIf.RowIn;

assign CoreCBAIf.DataOut =  (ThisCoreRead) ? DataLastRegion :  CoreCBAIf.DataIn;

`endif

endmodule // DigitalCoreLogic
