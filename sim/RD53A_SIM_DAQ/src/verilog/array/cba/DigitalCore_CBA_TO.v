
`include "top/RD53A_defines.sv"
`include "array/cba/PixelRegionLogic.v" 
`include "array/cba/DigitalCoreLogic.v"
`include "array/cba/FeControl_TO.v"
`include "models/RD53_AFE_TO.sv"
`include "array/interfaces/CoreCBAIf.sv"
`include "array/interfaces/CoreCommonIf.sv"
`include "array/ProgrammableDelay.v"

module DigitalCore_CBA_TO(

    AnaHit,
    CoreCommonIf,
    CoreCBAIf,
    AnalogBiasIf,
    TopPadframe_VOUT_PREAMP_TO
);

input wire [`REGIONS*4-1:0] AnaHit;
CoreCBAIf.core_logic CoreCBAIf;
CoreCommonIf.core_logic CoreCommonIf;
RD53_AFE_TO_analog_if.afe AnalogBiasIf;
output wire [7:0] TopPadframe_VOUT_PREAMP_TO;

// TO AFE specific: additional global AFE control signals  

`ifndef DIGITAL_CORE_BB

// this could also be re-organized ...mapping included. TO DECIDE!
wire internal_clock_delayed;
wire internal_caledge_delayed;
wire phi_az_delayed;
wire [`REGIONS-1:0][`REG_PIXELS-1:0] fe_input_int;

assign fe_input_int = AnaHit;

wire [`CBA_REGIONS:0] token_int;
assign token_int[0] = 0;

//this just connection for config and HitOr (now per pixel)

wire [`REG_PIXELS-1:0][`REGIONS-1:0] hit_or_int;

wire [`REGIONS-1:0][3:0] pwr_dwn;

wire [`CBA_REGIONS-1:0] token_pos;
wire [`CBA_DATA_BITS-1:0] data_bus [`CBA_REGIONS:0];

wire this_core_read;

wire [`REGIONS:0][2:0] data_conf_reg;
assign data_conf_reg[0] = CoreCommonIf.DataConfRdIn[2:0];
assign CoreCommonIf.DataConfRdOut = {CoreCommonIf.DataConfRdIn[7:3], data_conf_reg[`REGIONS]};

// Core row address adaptation. 
// CoreCommonIf.AddressIn is 47 to 48-ROWS from bottom to top (while addressing scheme has 0 on top, ROWS-1 on bottom)
wire [5:0] core_row_address_user;

  // Assuming regions in core numbering in layout:
   // PR col 0 - PR col 1
   //
    //  0           1   
    //  2           3      
    //  4           5   
    //  6           7   
    //  8           9 
    //  10          11  
    //  12          13  
    //  14          15 
    //
    // Pixels in elongated PR 1x4: 0 1 2 3 
    // HitOr for PR row even --> 0 1 2 3 0 1 2 3 
    //       for PR row odd  --> 2 3 0 1 2 3 0 1 

localparam int hit_or_mapper [`REGIONS][`REG_PIXELS] = '{'{0, 1, 2, 3},'{0, 1, 2, 3},'{2, 3, 0, 1},'{2, 3, 0, 1},'{0, 1, 2, 3},'{0, 1, 2, 3},'{2, 3, 0, 1},'{2, 3, 0, 1},
                                                                                              '{0, 1, 2, 3},'{0, 1, 2, 3}, '{2, 3, 0, 1},'{2, 3, 0, 1}, '{0, 1, 2, 3},'{0, 1, 2, 3}, '{2, 3, 0, 1},'{2, 3, 0, 1}} ;

wire [`REGIONS-1:0] [`REG_PIXELS-1:0] [`CBA_TOT_BITS-1:0] tots_temp ;
reg [`REGIONS-1:0] [`REG_PIXELS-1:0] [`CBA_TOT_BITS-1:0] tots ;
wire [`REGIONS-1:0] [`REG_PIXELS-1:0] tot_save_pulse ;
wire [`REGIONS-1:0] [`REG_PIXELS-1:0] readys;

// Analog calibration injection logic
logic [1:0] S0eo;
logic [1:0] S1eo;
assign S0eo[0] = internal_caledge_delayed | CoreCommonIf.CalAux;
assign S1eo[0] = !internal_caledge_delayed & CoreCommonIf.CalAux;
// Alternating mode mux
assign {S0eo[1], S1eo[1]} = (CoreCommonIf.AnaInjectionMode==0) ? {S0eo[0], S1eo[0]} : {S1eo[0], S0eo[0]};

wire core_common_if_l1_trig_local;
wire [4:0] core_common_if_trig_id_local;
wire [4:0] core_common_if_trig_id_req_local;
wire [8:0] core_common_if_lat_cnt_local;
wire [8:0] core_common_if_lat_cnt_req_local;

wire [2:0] DataConfWr;

generate
    genvar i;
    for  (i = 0; i < 3; i = i +1) begin: data_wr_buf
        CKBD6 wr_data_buf (.I(CoreCommonIf.DataConfWrIn[i]), .Z(DataConfWr[i]));
    end
endgenerate

wire clk_dig;
CG_MOD CG_clk_dighit_gated(.ClkIn(internal_clock_delayed), .Enable(CoreCommonIf.EnDigHit), .ClkOut(clk_dig));

generate
    genvar r;
    genvar p;

    for  (r=0; r<`REGIONS; r=r+1) begin: regions_gen
        wire [3:0][2:0] data_out;
        wire [3:0] this_addr, wr;
        
        for (p=0; p<`REG_PIXELS; p=p+1)  begin:  pixels_gen
            RD53_AFE_TO_dig_if        AnaToDigInf();

    		// Using AnalogBiasIf with 8 lines per signal (one per column of pixels).
            wire clk_pixel;
            wire mask = phi_az_delayed;

			wire tomonitor;

            RD53_AFE_TO AnalogFe (
                .PIXEL_IN_TO(fe_input_int[r][p]), 
                .PHI_AZ_TO(phi_az_delayed),
                .SEL_C2F_TO(CoreCBAIf.SelC2fIn),
                .SEL_C4F_TO(CoreCBAIf.SelC4fIn), 

                .STROBE_TO(clk_pixel),

                .DELAY_IN_TO(AnaToDigInf.DELAY_IN_TO),
                .DELAY_OUT_TO(AnaToDigInf.DELAY_OUT_TO),
                .VOUTP_TO(AnaToDigInf.VOUTP_TO),
                .VOUTN_TO(AnaToDigInf.VOUTN_TO),
                .POWER_DOWN_TO(AnaToDigInf.POWER_DOWN_TO),
                .S0(AnaToDigInf.S0),
                .S1(AnaToDigInf.S1),

                .IBIASP1_TO(AnalogBiasIf.IBIASP1_TO[r[0]*4+p]),
                .IBIASP2_TO(AnalogBiasIf.IBIASP2_TO[r[0]*4+p]),
                .VCASN_TO(AnalogBiasIf.VCASN_TO[r[0]*4+p]),
                .VCASP1_TO(AnalogBiasIf.VCASP1_TO[r[0]*4+p]),
                .IBIAS_SF_TO(AnalogBiasIf.IBIAS_SF_TO[r[0]*4+p]),
                .VREF_KRUM_TO(AnalogBiasIf.VREF_KRUM_TO[r[0]*4+p]),
                .VCAS_KRUM_TO(AnalogBiasIf.VCAS_KRUM_TO[r[0]*4+p]),
                .IBIAS_FEED_TO(AnalogBiasIf.IBIAS_FEED_TO[r[0]*4+p]),
                .IBIAS_DISC_TO(AnalogBiasIf.IBIAS_DISC_TO[r[0]*4+p]),
                .VCASN_DISC_TO(AnalogBiasIf.VCASN_DISC_TO[r[0]*4+p]),
                .VBL_DISC_TO(AnalogBiasIf.VBL_DISC_TO[r[0]*4+p]),
                .VTH_DISC_TO(AnalogBiasIf.VTH_DISC_TO[r[0]*4+p]),
                .CAL_HI(AnalogBiasIf.CAL_HI[r[0]*4+p]),
                .CAL_MI(AnalogBiasIf.CAL_MI[r[0]*4+p]),
                .ICTRL_TOT_TO(AnalogBiasIf.ICTRL_TOT_TO[r[0]*4+p]),
                .VOUT_PREAMP(tomonitor)
            );

            if(r<2)
				assign TopPadframe_VOUT_PREAMP_TO[r*4+p] = tomonitor;

            FeControl_CBA_TO FeControl (
                .AnaToDigInf(AnaToDigInf),
                .DefConf(CoreCommonIf.DefConf),
                .DefCalEn((r<2) ? 1'b1 : 1'b0),
                .Wr(wr[p]), 
                .DataIn(DataConfWr),
                .DataOut(data_out[p]),
                .CalEdge(internal_caledge_delayed),
                .EnDigHit(CoreCommonIf.EnDigHit),
                .HitOr( hit_or_int[ (hit_or_mapper[r][p]) ][r]),
				.TotSavePulse(tot_save_pulse[r][p]),

                .Mask(mask),
                .S0(S0eo[~((r[3:1]%2==0 && p%2==0) || (r[3:1]%2==1 && p%2==1))]),
                .S1(S1eo[~((r[3:1]%2==0 && p%2==0) || (r[3:1]%2==1 && p%2==1))]),

                .Clk(internal_clock_delayed),
				.ClkDig(clk_dig),
                .ClkPixel(clk_pixel),
                .Reset(CoreCommonIf.Reset),
                .FastEn(CoreCBAIf.FastEnIn),

                .ToT(tots_temp[r][p]),
                .PresentPulse(readys[r][p])
            );

			// Tot Latches
			always @(*)
				if(tot_save_pulse[r][p] == 1'b1)
					tots[r][p] <= tots_temp[r][p];

            // Analog control
            assign this_addr[p] = CoreCommonIf.AddressConfIn[11:6] == core_row_address_user & CoreCommonIf.AddressConfIn[5:2] == r[3:0] & CoreCommonIf.AddressConfIn[1:0] == p[1:0]
            								  | (CoreCommonIf.AddressConfIn [11:0] == {12{1'b1}}) ;
            assign wr[p] = CoreCommonIf.ConfWrIn  & this_addr[p];

            // Power down per pixel
            assign pwr_dwn[r][p] = AnaToDigInf.POWER_DOWN_TO;
       
         end // pixels_gen 

         assign data_conf_reg[r+1] = data_conf_reg[r] | ( data_out[0] & {3{this_addr[0]}}) |  (data_out[1] & {3{this_addr[1]}}) | (data_out[2] & {3{this_addr[2]}}) | (data_out[3] & {3{this_addr[3]}} );
    end // regions_gen
endgenerate

//            Refactoring
//
//       4X4               2X8
//
// +------+------+   +------+------+
// |   0  |   1  |   |   0      1  |
// |   2  |   3  |   |   2      3  |
// |   4  |   5  |   +------+------+
// |   6  |   7  |   |   4      5  |
// +------+------+   |   6      7  |
// |   8  |   9  |   +------+------+
// |  10  |  11  |   |   8      9  |
// |  12  |  13  |   |  10     11  |
// |  14  |  15  |   +------+------+
// +------+------+   |  12     13  |
//                   |  14     15  |
//                   +------+------+

// CBA Regions
generate
    genvar k;
    for (k=0; k<`CBA_REGIONS; k=k+1)
    begin: core_gen
        PixelRegionLogic_CBA i_pix_reg_logic (
            .Clk(internal_clock_delayed), // delayed clock going to pixel regions
            .Reset(CoreCommonIf.Reset),
            .L1Trig(core_common_if_l1_trig_local),
            .TrigId(core_common_if_trig_id_local),
            .TrigIdReq(core_common_if_trig_id_req_local),
            .Read(this_core_read & CoreCommonIf.Read),
            .DataToCore(data_bus[k]),

            `ifdef CBA_2X8
                //0      1 0 3 2
                //1      5 4 7 6
                //2      9 8 12 10
                //3      13 12 15 14
                .ToTs( {tots[k*4+1], tots[k*4], tots[k*4+3], tots[k*4+2]} ),
                .Readys( {readys[k*4+1], readys[k*4], readys[k*4+3], readys[k*4+2]} ),
            	.PwrDwn( {pwr_dwn[k*4+1], pwr_dwn[k*4], pwr_dwn[k*4+3], pwr_dwn[k*4+2]} ),
            `else
                //0      0 2 4 6
                //1      1 3 5 7
                //2      8 10 12 14
                //3      9 11 13 15
                .ToTs( {tots[k/2*8+k%2], tots[k/2*8+k%2+2], tots[k/2*8+k%2+4], tots[k/2*8+k%2+6]} ),
                .Readys( {readys[k/2*8+k%2], readys[k/2*8+k%2+2], readys[k/2*8+k%2+4], readys[k/2*8+k%2+6]} ),
            	.PwrDwn( {pwr_dwn[k/2*8+k%2], pwr_dwn[k/2*8+k%2+2], pwr_dwn[k/2*8+k%2+4], pwr_dwn[k/2*8+k%2+6]} ),
            `endif

            .TokIn(token_int[k]), .TokOut(token_int[k+1]),
            .LatCnt(core_common_if_lat_cnt_local), .LatCntReq(core_common_if_lat_cnt_req_local),

            .WriteSyncTime(CoreCBAIf.WriteSyncTimeIn)
        );
    end

endgenerate

wire [`CBA_DATA_BITS-1:0] data_or;
assign data_or = data_bus[0] | data_bus[1] | data_bus[2] | data_bus[3];


// Delay chain for skew adjustment

ProgrammableDelay i_programmable_delay_phi(
    .InToDelay(CoreCBAIf.PhiAzIn), 
    .Select(CoreCommonIf.AddressIn[5:3]), 
    .OutDelayed(phi_az_delayed)
);

ProgrammableDelay i_programmable_delay(
    .InToDelay(CoreCommonIf.ClkOut), 
    .Select(CoreCommonIf.AddressIn[5:3]), 
    .OutDelayed(internal_clock_delayed)
);

// CoreCommonIf.CalEdge
ProgrammableDelay i_programmable_delay_cal(
    .InToDelay(CoreCommonIf.CalEdge),
    .Select(CoreCommonIf.AddressIn[5:3]),
    .OutDelayed(internal_caledge_delayed)
);

assign token_pos = token_int[`CBA_REGIONS:1];
DigitalCoreLogic_CBA i_digital_core_logic (
    .CoreCommonIf (CoreCommonIf),
    .CoreCBAIf (CoreCBAIf),
    .TokenPos(token_pos),
    .TokenLastRegion(token_int[`CBA_REGIONS]),
    .DataLastRegion(data_or),
    .HitOr(hit_or_int),
    .ThisCoreRead(this_core_read),
    .CoreRowAddressUser(core_row_address_user),
    .L1TrigCoreLocal(core_common_if_l1_trig_local),
    .TrigIdCoreLocal(core_common_if_trig_id_local),
    .TrigIdReqCoreLocal(core_common_if_trig_id_req_local),
    .LatCntCoreLocal(core_common_if_lat_cnt_local),
    .LatCntReqCoreLocal(core_common_if_lat_cnt_req_local)
);

`endif

endmodule //DigitalCore_CBA_TO
