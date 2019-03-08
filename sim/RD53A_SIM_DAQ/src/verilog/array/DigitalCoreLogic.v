//`include "CoreCommonIf.v"

`ifndef DIGITAL_CORE_BB
    `include "array/RowAddressDec.v"
`endif

`include "array/sigfork.v"

`ifndef DIGITAL_CORE_LOGIC
`define DIGITAL_CORE_LOGIC

module DigitalCoreLogic(
	CoreCommonIf,
	CoreDBAIf,
	TokenPos,
	TokenLastRegion,
    DataLastRegion,
    DataConfRegions,
    //DataRegions, // Data Bus "fast" OR
	HitOr,
	ThisCoreRead,
    CoreRowAddressUser,
    L1TrigCoreLocal,
    TrigIdCoreLocal,
    TrigIdReqCoreLocal,
    LatCntCoreLocal,
    LatCntReqCoreLocal
	);

localparam REGIONS = 4*4;
localparam REG_PIXELS = 4;

CoreCommonIf.core_logic CoreCommonIf;
CoreDBAIf.core_logic CoreDBAIf;
input wire [REGIONS-1:0] TokenPos; //added to interface to regions
input wire TokenLastRegion;
input wire [15:0] DataLastRegion;
input wire [7:0] DataConfRegions;
//input wire [15:0] DataRegions [REGIONS-1:0]; // Data Bus "fast" OR
input wire [REG_PIXELS-1:0][REGIONS-1:0] HitOr;
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
//assign CoreCommonIf.TrigIdOut = CoreCommonIf.TrigId; // SigFork
//assign CoreCommonIf.TrigIdReqOut = CoreCommonIf.TrigIdReq; // SigFork

//assign CoreCommonIf.LatCntOut = CoreCommonIf.LatCnt; // SigFork
//assign CoreCommonIf.LatCntReqOut = CoreCommonIf.LatCntReq; // SigFork


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

assign CoreCommonIf.TokOut = CoreCommonIf.TokIn | TokenLastRegion;

assign ThisCoreRead = (CoreCommonIf.TokIn==0 && CoreCommonIf.TokOut==1);

//wire [15:0] [REGIONS-1:0] data_region_swapped ;
//wire [15:0]                         data_or_int;

wire [3:0] hit_or_four_int;
genvar p_or ;//,b;
for  (p_or =0; p_or <REG_PIXELS; p_or=p_or+1)  
    assign hit_or_four_int [p_or] =  (|HitOr[p_or]) | CoreCommonIf.HitOrIn[p_or]; // OR pixels from different regions (with same hitOr pixel index, after remapping: hit_or_mapper) 
assign CoreCommonIf.HitOrOut = hit_or_four_int;

// Data Bus "fast" OR - post P&R seems like making it worse (long routing?)
/*for (b = 0; b < 16; b=b+1) begin
    for  (r=0; r<REGIONS; r=r+1) 
        assign data_region_swapped[b][r ]= 
        [r][b]; 
    assign data_or_int[b] = |data_region_swapped[b];
end */
 
wire [3:0] row_int;
RowAddressDec i_row_address_dec ( .Token(TokenPos), .RowAddr(row_int) );

// Core row address adaptation. 
// CoreCommonIf.AddressIn is 47 to 48-ROWS from bottom to top (while addressing scheme has 0 on top, ROWS-1 on bottom)
wire [5:0] core_row_address_user;
assign core_row_address_user = CoreCommonIf.AddressIn - (48 - `ROWS) ;
assign CoreRowAddressUser = core_row_address_user;

wire [9:0] this_core_address;
assign this_core_address = {core_row_address_user, row_int};

assign CoreDBAIf.RowOut = (ThisCoreRead) ? this_core_address :  CoreDBAIf.RowIn;
//assign CoreCommonIf.DataOut =  (ThisCoreRead) ? data_or_int :  CoreCommonIf.DataIn; // Data Bus "fast" OR
assign CoreDBAIf.DataOut =  (ThisCoreRead) ? DataLastRegion :  CoreDBAIf.DataIn;
assign CoreCommonIf.DataConfRdOut = DataConfRegions | CoreCommonIf.DataConfRdIn;
// or: assign CoreCommonIf.DataConfRdOut = (CoreCommonIf.AddressConfIn[11:6] == core_row_address_user) ? DataConfRegions : CoreCommonIf.DataConfRdIn;
`endif

endmodule // DigitalCoreLogic

`endif