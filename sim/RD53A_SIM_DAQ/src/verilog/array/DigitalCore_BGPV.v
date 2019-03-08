`include "top/RD53A_defines.sv"
`include "array/DigitalCoreLogic.v"
`include "array/FeControl_BGPV.v"
`include "models/RD53_AFE_BGPV.v"
`include "array/PixelRegionLogic.v"
`include "array/interfaces/CoreCommonIf.sv"
`include "array/interfaces/CoreDBAIf.sv"
`include "array/ProgrammableDelay.v"

module DigitalCore_BGPV(

    AnaHit,
    CoreCommonIf,
    CoreDBAIf,
    AnalogBiasIf,
    TopPadframe_PA_OUT_BG

);

localparam REGIONS = 4*4;
localparam REG_PIXELS = 4;

//input wire [REGIONS-1:0][REG_PIXELS-1:0] AnaHit;
input wire [REGIONS*REG_PIXELS-1:0] AnaHit;
CoreCommonIf.core_logic CoreCommonIf;
CoreDBAIf.core_logic CoreDBAIf;
RD53_AFE_BGPV_analog_if AnalogBiasIf;
output wire [7:0] TopPadframe_PA_OUT_BG;

`ifndef DIGITAL_CORE_BB

wire internal_clock_delayed;
wire internal_caledge_delayed;
wire [REGIONS-1:0][REG_PIXELS-1:0] fe_input_int;
wire [REGIONS-1:0][REG_PIXELS-1:0] region_hit_int;

assign fe_input_int = AnaHit;

wire [REGIONS:0] token_int;
assign token_int[0] = 0;

//this just connection for config and HitOr (now per pixel)

wire [REG_PIXELS-1:0][REGIONS-1:0] hit_or_int;

wire [REGIONS-1:0][REG_PIXELS-1:0] pwr_dwn;

wire [REGIONS-1:0] token_pos;
wire [REGIONS-1:0] data_bus [REGIONS-1:0];


//assign data_bus[0] = 0;
wire this_core_read;

wire [REGIONS-1:0][7:0] data_conf_reg;
//assign data_conf_reg[0] = CoreCommonIf.DataConfRdIn;

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

localparam int hit_or_mapper [REGIONS][REG_PIXELS] = '{'{0, 1, 2, 3},'{0, 1, 2, 3},'{2, 3, 0, 1},'{2, 3, 0, 1},'{0, 1, 2, 3},'{0, 1, 2, 3},'{2, 3, 0, 1},'{2, 3, 0, 1},
                                                                                              '{0, 1, 2, 3},'{0, 1, 2, 3}, '{2, 3, 0, 1},'{2, 3, 0, 1}, '{0, 1, 2, 3},'{0, 1, 2, 3}, '{2, 3, 0, 1},'{2, 3, 0, 1}} ;

  // Analog calibration injection logic
    logic S0_even;
    logic S1_even;
    logic S0_odd;
    logic S1_odd;
    assign S0_even = internal_caledge_delayed | CoreCommonIf.CalAux;
    assign S1_even = !internal_caledge_delayed & CoreCommonIf.CalAux;
    always@(*) 
        if(CoreCommonIf.AnaInjectionMode==0) begin// default mode
            S0_odd = S0_even;
            S1_odd = S1_even;
        end
        else  begin // alternating mode
            S0_odd = S1_even;
            S1_odd = S0_even;
        end

wire core_common_if_l1_trig_local;
wire [4:0] core_common_if_trig_id_local;
wire [4:0] core_common_if_trig_id_req_local;
wire [8:0] core_common_if_lat_cnt_local;
wire [8:0] core_common_if_lat_cnt_req_local;


wire [7:0] DataConfWr;

generate
    genvar i;
    for  (i = 0; i < 8; i = i +1) begin: data_wr_buf
        CKBD6 wr_data_buf (.I(CoreCommonIf.DataConfWrIn[i]), .Z(DataConfWr[i]));
    end
endgenerate


generate
    genvar r;
    genvar p;
    
    for  (r=0; r<REGIONS; r=r+1) begin: regions_gen
        wire [3:0][7:0] data_out;
        wire [3:0] this_addr, wr;
        
        for (p=0; p<REG_PIXELS; p=p+1)  begin:  pixels_gen
            RD53_AFE_BGPV_dig_if        AnaToDigInf();
    // Using AnalogBiasIf with 8 lines per signal (one per column of pixels).
            if (r<2) 
                RD53_AFE_BGPV AnalogFe (
                    .PIXEL_IN_BG(fe_input_int[r][p]), 
                    .S0(AnaToDigInf.S0), .S1(AnaToDigInf.S1), 
                    .GAIN_SEL(AnaToDigInf.GAIN_SEL),
                    .HIT(AnaToDigInf.HIT), .POWER_DOWN(AnaToDigInf.POWER_DOWN),
                    .TH_DAC(AnaToDigInf.TH_DAC),
                    .IFC_BIAS_BG(AnalogBiasIf.IFC_BIAS_BG[r[0]*4+p]),
                    .IPA_IN_BIAS_BG(AnalogBiasIf.IPA_IN_BIAS_BG[r[0]*4+p]),
                    .VRIF_KRUM_BG(AnalogBiasIf.VRIF_KRUM_BG[r[0]*4+p]),
                    .IHU_KRUM_BG(AnalogBiasIf.IHU_KRUM_BG[r[0]*4+p]),
                    .IHD_KRUM_BG(AnalogBiasIf.IHD_KRUM_BG[r[0]*4+p]),
                    .COMP_BIAS_BG(AnalogBiasIf.COMP_BIAS_BG[r[0]*4+p]),
                    .VTH_BG(AnalogBiasIf.VTH_BG[r[0]*4+p]), // to be connected to VDDA from MacroColBias
                    .ILDAC_MIR1_BG(AnalogBiasIf.ILDAC_MIR1_BG[r[0]*4+p]),
                    .ILDAC_MIR2_BG(AnalogBiasIf.ILDAC_MIR2_BG[r[0]*4+p]),
                    .CAL_HI(AnalogBiasIf.CAL_HI[r[0]*4+p]),
                    .CAL_MI(AnalogBiasIf.CAL_MI[r[0]*4+p]),
                    .PA_OUT_BG(TopPadframe_PA_OUT_BG[r*4+p])
                );
            else 
                RD53_AFE_BGPV AnalogFe (
                    .PIXEL_IN_BG(fe_input_int[r][p]), 
                    .S0(AnaToDigInf.S0), .S1(AnaToDigInf.S1), 
                    .GAIN_SEL(AnaToDigInf.GAIN_SEL),
                    .HIT(AnaToDigInf.HIT), .POWER_DOWN(AnaToDigInf.POWER_DOWN),
                    .TH_DAC(AnaToDigInf.TH_DAC),
                    .IFC_BIAS_BG(AnalogBiasIf.IFC_BIAS_BG[r[0]*4+p]),
                    .IPA_IN_BIAS_BG(AnalogBiasIf.IPA_IN_BIAS_BG[r[0]*4+p]),
                    .VRIF_KRUM_BG(AnalogBiasIf.VRIF_KRUM_BG[r[0]*4+p]),
                    .IHU_KRUM_BG(AnalogBiasIf.IHU_KRUM_BG[r[0]*4+p]),
                    .IHD_KRUM_BG(AnalogBiasIf.IHD_KRUM_BG[r[0]*4+p]),
                    .COMP_BIAS_BG(AnalogBiasIf.COMP_BIAS_BG[r[0]*4+p]),
                    .VTH_BG(AnalogBiasIf.VTH_BG[r[0]*4+p]), // to be connected to VDDA from MacroColBias
                    .ILDAC_MIR1_BG(AnalogBiasIf.ILDAC_MIR1_BG[r[0]*4+p]),
                    .ILDAC_MIR2_BG(AnalogBiasIf.ILDAC_MIR2_BG[r[0]*4+p]),
                    .CAL_HI(AnalogBiasIf.CAL_HI[r[0]*4+p]),
                    .CAL_MI(AnalogBiasIf.CAL_MI[r[0]*4+p]),
                    .PA_OUT_BG(/* top_padframe_unconnected*/)
                );
             
            // Pixel row in core even and pixel even OR pixel row in core odd and pixel odd -> pixel even
            if( (r[3:1]%2==0 && p%2==0) || (r[3:1]%2==1 && p%2==1))
                FeControl_BGPV FeControl (
                    .AnaToDigInf(AnaToDigInf),
                    .DefConf(CoreCommonIf.DefConf),
                    .DefCalEn((r<2) ? 1'b1 : 1'b0),
                    .Wr(wr[p]), 
                    .DataIn(DataConfWr),
                    .DataOut(data_out[p]),
                    .S0(S0_even), 
                    .S1(S1_even), 
                    .EnDigHit(CoreCommonIf.EnDigHit),
                    .CalEdge(internal_caledge_delayed),
                    .HitOut(region_hit_int[r][p]), .HitOr( hit_or_int[ (hit_or_mapper[r][p]) ][r])
                );
            else 
                 FeControl_BGPV FeControl (
                    .AnaToDigInf(AnaToDigInf),
                    .DefConf(CoreCommonIf.DefConf),
                    .DefCalEn((r<2) ? 1'b1 : 1'b0),
                    .Wr(wr[p]), 
                    .DataIn(DataConfWr),
                    .DataOut(data_out[p]),
                    .S0(S0_odd), 
                    .S1(S1_odd), 
                    .EnDigHit(CoreCommonIf.EnDigHit),
                    .CalEdge(internal_caledge_delayed),
                    .HitOut(region_hit_int[r][p]), .HitOr( hit_or_int[ (hit_or_mapper[r][p]) ][r])
                ); 
                
            // Analog control
            assign this_addr[p] = CoreCommonIf.AddressConfIn[11:6] == core_row_address_user & CoreCommonIf.AddressConfIn[5:2] == r[3:0] & CoreCommonIf.AddressConfIn[1:0] == p[1:0]
            								| (CoreCommonIf.AddressConfIn [11:0] == {12{1'b1}}) ;
            assign wr[p] = CoreCommonIf.ConfWrIn  & this_addr[p];
            // Power down per pixel
            assign pwr_dwn[r][p]= AnaToDigInf.POWER_DOWN;
       
         end // pixels_gen 
    
         assign data_conf_reg[r] = ( data_out[0] & {8{this_addr[0]}}) |  (data_out[1] & {8{this_addr[1]}}) | (data_out[2] & {8{this_addr[2]}}) | (data_out[3] & {8{this_addr[3]}} );

         PixelRegionLogic i_pix_reg_logic (
            .Clk(internal_clock_delayed), // delayed clock going to pixel regions
            .Reset(CoreCommonIf.Reset),
            .L1Trig(core_common_if_l1_trig_local),
            .TrigId(core_common_if_trig_id_local),
            .TrigIdReq(core_common_if_trig_id_req_local),
            .Read(this_core_read & CoreCommonIf.Read),
            .DataToCore(data_bus[r]), 
            .Hit(region_hit_int [r]),
            .TokIn(token_int[r]), .TokOut(token_int[r+1]),
            .LatCnt(core_common_if_lat_cnt_local), .LatCntReq(core_common_if_lat_cnt_req_local),
            .PwrDwn(pwr_dwn[r])
        );
    end// regions_gen
    
endgenerate

// If useful similar could be used for token (with some priority between stages)
wire [3:0] [15:0] data_or_stage_one;
wire [15:0] data_or_stage_two;

assign data_or_stage_one[0]  = data_bus[0] | data_bus[1] | data_bus[2] | data_bus[3];
assign data_or_stage_one[1] = data_bus[4] | data_bus[5] | data_bus[6] | data_bus[7];
assign data_or_stage_one[2]  = data_bus[8] | data_bus[9] | data_bus[10] | data_bus[11];
assign data_or_stage_one[3] = data_bus[12] | data_bus[13] | data_bus[14] | data_bus[15];

assign data_or_stage_two = data_or_stage_one[0] | data_or_stage_one[1] | data_or_stage_one[2] | data_or_stage_one[3];

wire [3:0] [7:0] conf_data_or_stage_one;
wire       [7:0] conf_data_or_stage_two;

assign conf_data_or_stage_one[0]  = data_conf_reg[0]  | data_conf_reg[1]  | data_conf_reg[2]  | data_conf_reg[3] ; //synopsys keep_signal_name "conf_data_or_stage_one"
assign conf_data_or_stage_one[1]  = data_conf_reg[4]  | data_conf_reg[5]  | data_conf_reg[6]  | data_conf_reg[7] ; //synopsys keep_signal_name "conf_data_or_stage_one"
assign conf_data_or_stage_one[2]  = data_conf_reg[8]  | data_conf_reg[9]  | data_conf_reg[10] | data_conf_reg[11]; //synopsys keep_signal_name "conf_data_or_stage_one"
assign conf_data_or_stage_one[3]  = data_conf_reg[12] | data_conf_reg[13] | data_conf_reg[14] | data_conf_reg[15]; //synopsys keep_signal_name "conf_data_or_stage_one"

assign conf_data_or_stage_two     = conf_data_or_stage_one[0] | conf_data_or_stage_one[1] | conf_data_or_stage_one[2] | conf_data_or_stage_one[3];

//// Delay chains for skew adjustment
// CoreCommonIf.Clk
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

assign token_pos = token_int[REGIONS:1];
DigitalCoreLogic i_digital_core_logic (
    .CoreCommonIf (CoreCommonIf),
    .CoreDBAIf (CoreDBAIf),
    .TokenPos(token_pos),
    .TokenLastRegion(token_int[REGIONS]),
    .DataLastRegion(data_or_stage_two),
    .DataConfRegions(conf_data_or_stage_two), 
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

endmodule //DigitalCore_BGPV
