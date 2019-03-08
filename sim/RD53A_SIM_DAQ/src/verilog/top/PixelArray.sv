
//-----------------------------------------------------------------------------------------------------
// [Filename]       PixelArray.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         -
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 21, 2017
// [Modified]       Mar 11, 2017
// [Description]    Contains generators for the multi-FE pixel array. This is just a logical hierarchy,
//                  replicated Column Readout Controller (CRC) modules are not part of the pixel array
// [Notes]i         -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/top/RD53A_defines.sv
// $RTL_DIR/array/interfaces/CoreCommonIf.sv
// $RTL_DIR/array/interfaces/CoreCBAIf.sv
// $RTL_DIR/array/interfaces/CoreDBAIf.sv
// $RTL_DIR/array/interfaces/RD53_AFE_LBNL_inf.sv
// $RTL_DIR/array/interfaces/RD53_AFE_BGPV_inf.sv
// $RTL_DIR/array/interfaces/RD53_AFE_TO_inf.sv
// $RTL_DIR/array/CgWrapper.v
// $RTL_DIR/array/DigitalCore_BGPV.v
// $RTL_DIR/array/cba/DigitalCore_CBA_TO.v
// $RTL_DIR/eoc/ColumnReadControl.sv
// $RTL_DIR/eoc/CBAOutputAdapter.sv


`ifndef PIXEL_ARRAY__SV
`define PIXEL_ARRAY__SV

`timescale  1ns / 1ps
//`include "timescale.v"


`include "top/RD53A_defines.sv"
`include "array/interfaces/CoreCommonIf.sv"
`include "array/interfaces/CoreCBAIf.sv"
`include "array/interfaces/CoreDBAIf.sv"
`include "array/interfaces/RD53_AFE_TO_inf.sv"
`include "array/interfaces/RD53_AFE_LBNL_inf.sv"
`include "array/interfaces/RD53_AFE_BGPV_inf.sv"
`include "array/CgWrapper.v"

`ifndef TOP_SYNTHESIS
    `include "array/DigitalCore_BGPV.v"
    `include "array/cba/DigitalCore_CBA_TO.v"
    `include "array/DigitalCore_LBNL.v"
`endif

`include "eoc/ColumnReadControl.sv"
`include "eoc/CBAOutputAdapter.sv"

module PixelArray (

   `ifdef USE_VAMS

   inout wire VDDA,
   inout wire GNDA,
   inout wire VDDD,
   inout wire GNDD,
   inout wire VSUB,

   `endif

   // inputs
   input  wire [`COLS-1:0][`ROWS-1:0][`REGIONS-1:0][`REG_PIXELS-1:0] AnaHit,
   input  wire  Clk40,
   input  wire  Reset,
   input  wire  Trigger,

   input  wire  [8:0] LatencyCnfg,
   input  wire  [1:0] WaitReadCnfg,
   input  wire  DefaultPixelConf,
   input  wire  EnDigHit,
   input  wire  CalEdge,
   input  wire  CalAux,
   input  wire  AnaInjectionMode,
   input  wire  [`COLS-1:0] EnCoreCol,
   input  wire  [2:0] EnCoreColBroadcast, // 0 SYNC, 1 LIN, 3 DIFF
   input  wire  [63:0] EnCal_TO,   //**NOTE 4 per core column - To re-sync? (if CalEdge/Aux false path not )
   input  wire  [67:0] EnCal_BG,   //**NOTE 4 per core column - To re-sync? (if CalEdge/Aux false path not )
   input  wire  [67:0] EnCal_LBNL, //**NOTE 4 per core column - To re-sync? (if CalEdge/Aux false path not )
   input  wire  [3:0][`COLS-1:0] HitOrMask,
   
   input  wire  [11:0] AddressConfCore,
   input  wire  [5:0] AddressConfCol,
   input  wire  [7:0] DataConfWr,
   input  wire  [`COLS-1:0] ReadyCol,
   input  wire  ConfWr,
   output logic  [7:0] DataConfRd,
   //
   // to/ from DCB
   output logic [15:0] SkippedTriggerCnt,
   output logic        SkippedTriggerCntErr,
   input  wire         WrSkippedTriggerCntRst, 

   // outputs
   output  wire [3:0] HitOr,
   
   output wire  [`COLS-1:0][15:0] DataCol,
   output wire  [`COLS-1:0][9:0] RowCol,
   output wire  [`COLS-1:0] DataReadyCol,
   output logic [`COLS-1:0][4:0] TrigIdReqColBin,
   output logic [5:0] TriggerIdCnt,
   output logic [5:0] TriggerIdCurrentReq,
   output logic TriggerAccept,
   
   input wire [63:0] AnalogBiasIf_IBIASP1_TO, AnalogBiasIf_IBIASP2_TO, AnalogBiasIf_IBIAS_DISC_TO, AnalogBiasIf_IBIAS_FEED_TO,
                     AnalogBiasIf_IBIAS_SF_TO, AnalogBiasIf_ICTRL_TOT_TO, AnalogBiasIf_VCASN_TO, 
                     AnalogBiasIf_VCASP1_TO, AnalogBiasIf_VREF_KRUM_TO, AnalogBiasIf_VCAS_KRUM_TO, AnalogBiasIf_VCASN_DISC_TO,
                     AnalogBiasIf_VBL_DISC_TO, AnalogBiasIf_VTH_DISC_TO, AnalogBiasIf_CAL_HI_TO, AnalogBiasIf_CAL_MI_TO,
                
   input wire [67:0] AnalogBiasIf_COMP_BIAS_BG, AnalogBiasIf_IFC_BIAS_BG, AnalogBiasIf_IHD_KRUM_BG, AnalogBiasIf_IHU_KRUM_BG,
                     AnalogBiasIf_ILDAC_MIR1_BG, AnalogBiasIf_ILDAC_MIR2_BG, AnalogBiasIf_IPA_IN_BIAS_BG, AnalogBiasIf_VRIF_KRUM_BG,
                     AnalogBiasIf_VTH_BG, AnalogBiasIf_CAL_HI_BG, AnalogBiasIf_CAL_MI_BG,
   // TODO: Connectivity to toplevel: top-row
   // CBA_TO
   output wire [15:0][7:0]  TopPadframe_VOUT_PREAMP_TO, 
   // BGPV
   output wire [16:0][7:0]  TopPadframe_PA_OUT_BG, 
   // LBNL     
   output wire [16:0][7:0]  TopPadframe_out1,
   output wire [16:0][7:0]  TopPadframe_out2,
   output wire [16:0][7:0]  TopPadframe_out2b,
   
   input wire [67:0]  AnalogBiasIf_PrmpVbnFol_LBNL, AnalogBiasIf_PrmpVbp_LBNL, 
                      AnalogBiasIf_VctrCF0_R_LBNL, AnalogBiasIf_VctrCF0_L_LBNL,
                      AnalogBiasIf_VctrLCC_R_LBNL, AnalogBiasIf_VctrLCC_L_LBNL,
                      AnalogBiasIf_compVbn_LBNL, AnalogBiasIf_preCompVbn_LBNL, 
                      AnalogBiasIf_vbnLcc_LBNL, AnalogBiasIf_vff_LBNL, AnalogBiasIf_vthin1_LBNL, AnalogBiasIf_vthin2_LBNL,
                      AnalogBiasIf_CAL_HI_R_LBNL, AnalogBiasIf_CAL_MI_R_LBNL, AnalogBiasIf_CAL_HI_L_LBNL, AnalogBiasIf_CAL_MI_L_LBNL,

   // TODO: same for TO and LBNL
   input wire PHI_AZ_TO, 
   input wire SELC2F_TO, 
   input wire SELC4F_TO,
   input wire FastEnTo,
   input wire [`CBA_SG_LATENCY_BITS-1:0] WriteSyncTimeTo
   ) ;



   `ifndef ABSTRACT

   wire EcrCmd40 ;
   assign EcrCmd40 = Reset ;    // actually not only a command, also startup reset contributes

   wire TriggerCmd40 ;
   //assign TriggerCmd40 = Trigger ;  // actually not only a command, can be also an external trigger


    wire [`COLS-1:0] CRCReadyCol;

   // **NOTE: start copy-and-paste "as it is" from previous file

   
   logic  [11:0] AddressConfCore_ff;
   logic  [5:0] AddressConfCol_ff;
   logic  [7:0] DataConfWr_ff;
   logic  [`COLS-1:0] ReadyCol_ff;
   logic  ConfWr_ff;
   always@(posedge Clk40) AddressConfCore_ff <= AddressConfCore;
   always@(posedge Clk40) AddressConfCol_ff <= AddressConfCol;
   always@(posedge Clk40) DataConfWr_ff <= DataConfWr;
   
   //always@(posedge Clk40) ReadyCol_ff <= ReadyCol; 
   always_comb ReadyCol_ff = ReadyCol; //This is bad for timing but will not work other way need to rethink
   
   always@(posedge Clk40) ConfWr_ff <= ConfWr;
   
   
   
logic [49:0][4:0] trigger_distance_col;
logic [`COLS-1:0] trigger_next_accpet_col;
     
logic [`COLS-1:0] EnCoreColBX;
always@(posedge Clk40)
     EnCoreColBX <= EnCoreCol;

logic [2:0] EnCoreColBroadcastBX;
always@(posedge Clk40)
     EnCoreColBroadcastBX <= EnCoreColBroadcast;

logic en_digital_hit_bx;
always@(posedge Clk40)
     en_digital_hit_bx <= EnDigHit;
     

wire [3:0] [`COLS-1:0] HitOrInt;
genvar p_or ;
for  (p_or =0; p_or <`REG_PIXELS; p_or=p_or+1) begin 
    assign HitOr[p_or] = |HitOrInt[p_or]; 
end

logic [`COLS-1:0][7:0] DataConfRdCol;
always@(posedge Clk40) //BUG: This needs to be different
    DataConfRd <= DataConfRdCol[AddressConfCol_ff];

wire [`COLS-1:0][`ROWS-1:0][`REGIONS-1:0][`REG_PIXELS-1:0] AnalogHitInt;
assign AnalogHitInt = AnaHit;

//Latency
logic [8:0] LatCnt, LatCntReq, LatCntReqCBA;

reg [8:0] LatCntBin;
wire [8:0] LatCntReqBin;
wire [8:0] LatCntReqCBABin;

logic [`CBA_SG_LATENCY_BITS-1:0] write_sync_time_to_bx;
always@(posedge Clk40)
    write_sync_time_to_bx <= WriteSyncTimeTo;

logic [8:0] latency_cnfg_bx;
always@(posedge Clk40)
    latency_cnfg_bx <= LatencyCnfg;
    
always@(posedge Clk40)
    if(EcrCmd40)
        LatCntBin <= 0;
    else
        LatCntBin <= LatCntBin + 1;

assign LatCntReqBin = LatCntBin - latency_cnfg_bx;
assign LatCntReqCBABin = LatCntBin - latency_cnfg_bx + write_sync_time_to_bx - 1;

always@(posedge Clk40)
    LatCnt <= (LatCntBin >> 1) ^ LatCntBin;

always@(posedge Clk40)
    LatCntReqCBA <= (LatCntReqCBABin >> 1) ^ LatCntReqCBABin;

always@(posedge Clk40)
    LatCntReq <= (LatCntReqBin >> 1) ^ LatCntReqBin;

logic [1:0] wait_read_confg_bx;
always@(posedge Clk40)
    wait_read_confg_bx <= WaitReadCnfg;
    
generate
    genvar k;
    genvar coreinx;
    for (k=0; k<`COLS; k=k+1)
    begin: chip_gen

    `ifdef TEST_DC
    if(k != `TEST_DC)
        begin : column
        wire TokCol = 0;
        
        assign DataCol[k] = 0;
        assign RowCol[k] = 0;
        assign DataReadyCol[k] = 0;
        assign TrigIdReqColBin[k] = TrigIdReqColBin[`TEST_DC];
        assign trigger_distance_col[k] = trigger_distance_col[`TEST_DC];
        assign trigger_next_accpet_col[k] = 1;
        assign DataConfRdCol[k] = 0;
        for  (p_or =0; p_or <`REG_PIXELS; p_or=p_or+1) begin 
            assign HitOrInt[p_or][k]= 0; // avoid undefined output on HitOr on TEST_DC simulations
        end
    end else
    `endif

     begin : column
        //
        // Wire declarations
        //

        logic EnCol;

        logic ReadCol;
        wire TokCol;
        wire L1ChipCol;
        logic [4:0] TrigIdCol, TrigIdReqCol;

        wire [`ROWS-1:0] OutLoInt;
        logic [`ROWS:0] L1TrigInt, resetInt, clkInt, ReadInt ;
        logic [`ROWS:0][4:0] TrigIdInt;
        logic [`ROWS:0][4:0] TrigIdReqInt;

        wire [`ROWS:0] TokInt;

        logic [`ROWS:0] EnDigHitInt , DefConfInt;
        wire [`ROWS:0] CalEdgeInt, CalAuxInt, AnaInjectionModeInt;
        wire [`ROWS:0] [3:0] HitOrIntCol;
        logic [`ROWS:0][8:0] LatCntInt, LatCntReqInt;


        wire [`ROWS:0][5:0] AddressInt;
        
        logic [`ROWS:0][11:0] AddressConfInt;
        logic [`ROWS:0][7:0] DataConfWrInt;
        logic [`ROWS:0][7:0] DataConfRdInt;
        logic [`ROWS:0] ConfWrInt;
        
        wire this_conf;

        // Max-width wires. If unused, the synthesizer will delete them.
        logic [`ROWS:0][`PA_DATA_BITS-1:0] DataInt;
        logic [`ROWS:0][`PA_ROW_BITS-1:0] RowInt;

        wire [`PA_DATA_BITS-1:0] this_data;
        wire [`PA_ROW_BITS-1:0] this_row;

        // CBA_TO-specific wires. If unused, the synthesizer will delete them.
        wire [`ROWS:0] phi_az_int;
        wire [`ROWS:0] sel_c2f_int;
        wire [`ROWS:0] sel_c4f_int;
        wire [`ROWS:0] fast_en_int;
        wire [`ROWS:0] [`CBA_SG_LATENCY_BITS-1:0] writesynctime_int;

        //
        // Assignments
        //

        always@(negedge Clk40) 
            EnCol <= EnCoreColBX[k];
        
        assign this_conf = (AddressConfCol_ff == k);

        always@(negedge Clk40) 
            L1TrigInt[0] <= L1ChipCol & EnCol;
            
        assign resetInt[0] = EcrCmd40;
       
        `ifndef USE_VAMS
 
        // Avoid clock gating hold violations 
        CG_MOD cg_col_clk_en(.ClkIn(Clk40), .Enable(EnCol ), .ClkOut(clkInt[0]));      // this contains STD cells, but no power connections are provided. M/S issues

        `else        

        assign clkInt[0] = (EnCol == 1'b1) ? Clk40 : 1'b0 ;

        `endif

        always@(negedge Clk40)  
            ReadInt[0] <= ReadCol & EnCol;

        always@(negedge Clk40) begin
            TrigIdInt[0] <= TrigIdCol & {5{EnCol}};
            TrigIdReqInt[0] <= TrigIdReqCol & {5{EnCol}};
        end

        assign TokInt[`ROWS] = OutLoInt[`ROWS-1];
        assign TokCol = TokInt[0];

        always@(negedge Clk40)
            EnDigHitInt[0] <= en_digital_hit_bx & EnCol; 
            
        assign AnaInjectionModeInt[0] = AnaInjectionMode; 
        
        assign DefConfInt[0] = DefaultPixelConf;
        
        for  (p_or =0; p_or <`REG_PIXELS; p_or=p_or+1)  begin
            assign HitOrIntCol[`ROWS][p_or] = OutLoInt[`ROWS-1];
            assign HitOrInt[p_or][k] = HitOrIntCol[0][p_or] & (~HitOrMask [p_or][k]);
        end

        always@(negedge Clk40)
            LatCntInt[0] <= LatCnt & {9{EnCol}};
        
        // Address propagation for clock skew compensation starting from the bottom
        // aim: same skew compensation (WC) in the bottom independent on number or rows.
        assign AddressInt[0] = 6'b101111; //47    
                    
        always@(posedge Clk40)
            DataConfRdCol[k] <= DataConfRdInt[0];
            
        assign DataConfRdInt[`ROWS] = {8{OutLoInt[`ROWS-1]}};

        assign DataInt[`ROWS] = {`PA_DATA_BITS {OutLoInt[`ROWS-1]}};
        assign RowInt[`ROWS] = {`PA_ROW_BITS {OutLoInt[`ROWS-1]}};

        RD53_AFE_TO_analog_if AnalogBiasIf_TO();
        RD53_AFE_BGPV_analog_if  AnalogBiasIf_BGPV();
        RD53_AFE_LBNL_analog_if  AnalogBiasIf_LBNL();
        //
        // FE and Architecture-specific assignments
        //

        if(k<16) begin
            // TODO: Biases

            assign phi_az_int[0] = PHI_AZ_TO ;
            assign sel_c2f_int[0] = SELC2F_TO ;
            assign sel_c4f_int[0] = SELC4F_TO ;
            assign fast_en_int [0] = FastEnTo ;
            assign writesynctime_int[0] = write_sync_time_to_bx;

            assign AnalogBiasIf_TO.IBIASP1_TO = {AnalogBiasIf_IBIASP1_TO[3+k*4], AnalogBiasIf_IBIASP1_TO[3+k*4], AnalogBiasIf_IBIASP1_TO[2+k*4], AnalogBiasIf_IBIASP1_TO[2+k*4], AnalogBiasIf_IBIASP1_TO[1+k*4], AnalogBiasIf_IBIASP1_TO[1+k*4], AnalogBiasIf_IBIASP1_TO[0+k*4], AnalogBiasIf_IBIASP1_TO[0+k*4]};
            assign AnalogBiasIf_TO.IBIASP2_TO  = {AnalogBiasIf_IBIASP2_TO[3+k*4], AnalogBiasIf_IBIASP2_TO[3+k*4], AnalogBiasIf_IBIASP2_TO[2+k*4], AnalogBiasIf_IBIASP2_TO[2+k*4], AnalogBiasIf_IBIASP2_TO[1+k*4], AnalogBiasIf_IBIASP2_TO[1+k*4], AnalogBiasIf_IBIASP2_TO[0+k*4], AnalogBiasIf_IBIASP2_TO[0+k*4]};
            assign AnalogBiasIf_TO.VCASN_TO = {AnalogBiasIf_VCASN_TO[3+k*4], AnalogBiasIf_VCASN_TO[3+k*4], AnalogBiasIf_VCASN_TO[2+k*4], AnalogBiasIf_VCASN_TO[2+k*4], AnalogBiasIf_VCASN_TO[1+k*4], AnalogBiasIf_VCASN_TO[1+k*4], AnalogBiasIf_VCASN_TO[0+k*4], AnalogBiasIf_VCASN_TO[0+k*4]};
            assign AnalogBiasIf_TO.VCASP1_TO = {AnalogBiasIf_VCASP1_TO[3+k*4], AnalogBiasIf_VCASP1_TO[3+k*4], AnalogBiasIf_VCASP1_TO[2+k*4], AnalogBiasIf_VCASP1_TO[2+k*4], AnalogBiasIf_VCASP1_TO[1+k*4], AnalogBiasIf_VCASP1_TO[1+k*4], AnalogBiasIf_VCASP1_TO[0+k*4], AnalogBiasIf_VCASP1_TO[0+k*4]};
            assign AnalogBiasIf_TO.IBIAS_SF_TO = {AnalogBiasIf_IBIAS_SF_TO[3+k*4], AnalogBiasIf_IBIAS_SF_TO[3+k*4], AnalogBiasIf_IBIAS_SF_TO[2+k*4], AnalogBiasIf_IBIAS_SF_TO[2+k*4], AnalogBiasIf_IBIAS_SF_TO[1+k*4], AnalogBiasIf_IBIAS_SF_TO[1+k*4], AnalogBiasIf_IBIAS_SF_TO[0+k*4], AnalogBiasIf_IBIAS_SF_TO[0+k*4]};
            assign AnalogBiasIf_TO.VREF_KRUM_TO = {AnalogBiasIf_VREF_KRUM_TO[3+k*4], AnalogBiasIf_VREF_KRUM_TO[3+k*4], AnalogBiasIf_VREF_KRUM_TO[2+k*4], AnalogBiasIf_VREF_KRUM_TO[2+k*4], AnalogBiasIf_VREF_KRUM_TO[1+k*4], AnalogBiasIf_VREF_KRUM_TO[1+k*4], AnalogBiasIf_VREF_KRUM_TO[0+k*4], AnalogBiasIf_VREF_KRUM_TO[0+k*4]};
            assign AnalogBiasIf_TO.VCAS_KRUM_TO = {AnalogBiasIf_VCAS_KRUM_TO[3+k*4], AnalogBiasIf_VCAS_KRUM_TO[3+k*4], AnalogBiasIf_VCAS_KRUM_TO[2+k*4], AnalogBiasIf_VCAS_KRUM_TO[2+k*4], AnalogBiasIf_VCAS_KRUM_TO[1+k*4], AnalogBiasIf_VCAS_KRUM_TO[1+k*4], AnalogBiasIf_VCAS_KRUM_TO[0+k*4], AnalogBiasIf_VCAS_KRUM_TO[0+k*4]};
            assign AnalogBiasIf_TO.IBIAS_FEED_TO = {AnalogBiasIf_IBIAS_FEED_TO[3+k*4], AnalogBiasIf_IBIAS_FEED_TO[3+k*4], AnalogBiasIf_IBIAS_FEED_TO[2+k*4], AnalogBiasIf_IBIAS_FEED_TO[2+k*4], AnalogBiasIf_IBIAS_FEED_TO[1+k*4], AnalogBiasIf_IBIAS_FEED_TO[1+k*4], AnalogBiasIf_IBIAS_FEED_TO[0+k*4], AnalogBiasIf_IBIAS_FEED_TO[0+k*4]};
            assign AnalogBiasIf_TO.IBIAS_DISC_TO = {AnalogBiasIf_IBIAS_DISC_TO[3+k*4], AnalogBiasIf_IBIAS_DISC_TO[3+k*4], AnalogBiasIf_IBIAS_DISC_TO[2+k*4], AnalogBiasIf_IBIAS_DISC_TO[2+k*4], AnalogBiasIf_IBIAS_DISC_TO[1+k*4], AnalogBiasIf_IBIAS_DISC_TO[1+k*4], AnalogBiasIf_IBIAS_DISC_TO[0+k*4], AnalogBiasIf_IBIAS_DISC_TO[0+k*4]};
            assign AnalogBiasIf_TO.VBL_DISC_TO = {AnalogBiasIf_VBL_DISC_TO[3+k*4], AnalogBiasIf_VBL_DISC_TO[3+k*4], AnalogBiasIf_VBL_DISC_TO[2+k*4], AnalogBiasIf_VBL_DISC_TO[2+k*4], AnalogBiasIf_VBL_DISC_TO[1+k*4], AnalogBiasIf_VBL_DISC_TO[1+k*4], AnalogBiasIf_VBL_DISC_TO[0+k*4], AnalogBiasIf_VBL_DISC_TO[0+k*4]};
            assign AnalogBiasIf_TO.VTH_DISC_TO = {AnalogBiasIf_VTH_DISC_TO[3+k*4], AnalogBiasIf_VTH_DISC_TO[3+k*4], AnalogBiasIf_VTH_DISC_TO[2+k*4], AnalogBiasIf_VTH_DISC_TO[2+k*4], AnalogBiasIf_VTH_DISC_TO[1+k*4], AnalogBiasIf_VTH_DISC_TO[1+k*4], AnalogBiasIf_VTH_DISC_TO[0+k*4], AnalogBiasIf_VTH_DISC_TO[0+k*4]};
            assign AnalogBiasIf_TO.ICTRL_TOT_TO = {AnalogBiasIf_ICTRL_TOT_TO[3+k*4], AnalogBiasIf_ICTRL_TOT_TO[3+k*4], AnalogBiasIf_ICTRL_TOT_TO[2+k*4], AnalogBiasIf_ICTRL_TOT_TO[2+k*4], AnalogBiasIf_ICTRL_TOT_TO[1+k*4], AnalogBiasIf_ICTRL_TOT_TO[1+k*4], AnalogBiasIf_ICTRL_TOT_TO[0+k*4], AnalogBiasIf_ICTRL_TOT_TO[0+k*4]};
            assign AnalogBiasIf_TO.VCASN_DISC_TO = {AnalogBiasIf_VCASN_DISC_TO[3+k*4], AnalogBiasIf_VCASN_DISC_TO[3+k*4], AnalogBiasIf_VCASN_DISC_TO[2+k*4], AnalogBiasIf_VCASN_DISC_TO[2+k*4], AnalogBiasIf_VCASN_DISC_TO[1+k*4], AnalogBiasIf_VCASN_DISC_TO[1+k*4], AnalogBiasIf_VCASN_DISC_TO[0+k*4], AnalogBiasIf_VCASN_DISC_TO[0+k*4]};

            assign AnalogBiasIf_TO.CAL_HI = {AnalogBiasIf_CAL_HI_TO[3+k*4], AnalogBiasIf_CAL_HI_TO[3+k*4], AnalogBiasIf_CAL_HI_TO[2+k*4], AnalogBiasIf_CAL_HI_TO[2+k*4], AnalogBiasIf_CAL_HI_TO[1+k*4], AnalogBiasIf_CAL_HI_TO[1+k*4], AnalogBiasIf_CAL_HI_TO[0+k*4], AnalogBiasIf_CAL_HI_TO[0+k*4]};
            assign AnalogBiasIf_TO.CAL_MI = {AnalogBiasIf_CAL_MI_TO[3+k*4], AnalogBiasIf_CAL_MI_TO[3+k*4], AnalogBiasIf_CAL_MI_TO[2+k*4], AnalogBiasIf_CAL_MI_TO[2+k*4], AnalogBiasIf_CAL_MI_TO[1+k*4], AnalogBiasIf_CAL_MI_TO[1+k*4], AnalogBiasIf_CAL_MI_TO[0+k*4], AnalogBiasIf_CAL_MI_TO[0+k*4]};

            assign this_data[`CBA_DATA_BITS-1:0] = DataInt[0][`CBA_DATA_BITS-1:0];
            assign this_row[`CBA_ROW_BITS-1:0] = RowInt[0][`CBA_ROW_BITS-1:0];

            always@(negedge Clk40)
                LatCntReqInt[0] <= LatCntReqCBA & {9{EnCol}};    

            always@(posedge Clk40)
                if(EnCoreColBroadcastBX[0]) 
                    AddressConfInt[0] <= {12{1'b1}}; // Last address (unused) used to match all cores in the column (broadcast) 
                else 
                    AddressConfInt[0] <= AddressConfCore_ff & {12{this_conf}};

            always@(posedge Clk40)
                DataConfWrInt[0] <= DataConfWr_ff & {8{(this_conf | EnCoreColBroadcastBX[0])}};

            logic ConfWrInt0;
            always@(posedge Clk40)
                 ConfWrInt0 <= ConfWr_ff & (this_conf | EnCoreColBroadcastBX[0]);
            
            CG_MOD cg_wr_pixel(.ClkIn(Clk40), .Enable(ConfWrInt0), .ClkOut(ConfWrInt[0])); 
            
        
            assign CalEdgeInt[0] = CalEdge & |EnCal_TO[k*4+3:k*4]; //** NOTE: enable Cal signals to core column if any of (4x)EnCal_TO = 1
            assign CalAuxInt[0]  = CalAux  & |EnCal_TO[k*4+3:k*4];       
    

        end else if (k<33) begin


            assign AnalogBiasIf_BGPV.COMP_BIAS_BG = {AnalogBiasIf_COMP_BIAS_BG[3+(k-16)*4], AnalogBiasIf_COMP_BIAS_BG[3+(k-16)*4], AnalogBiasIf_COMP_BIAS_BG[2+(k-16)*4], AnalogBiasIf_COMP_BIAS_BG[2+(k-16)*4], AnalogBiasIf_COMP_BIAS_BG[1+(k-16)*4],AnalogBiasIf_COMP_BIAS_BG[1+(k-16)*4], AnalogBiasIf_COMP_BIAS_BG[0+(k-16)*4], AnalogBiasIf_COMP_BIAS_BG[0+(k-16)*4]};
            assign AnalogBiasIf_BGPV.IFC_BIAS_BG = {AnalogBiasIf_IFC_BIAS_BG[3+(k-16)*4], AnalogBiasIf_IFC_BIAS_BG[3+(k-16)*4], AnalogBiasIf_IFC_BIAS_BG[2+(k-16)*4], AnalogBiasIf_IFC_BIAS_BG[2+(k-16)*4], AnalogBiasIf_IFC_BIAS_BG[1+(k-16)*4], AnalogBiasIf_IFC_BIAS_BG[1+(k-16)*4], AnalogBiasIf_IFC_BIAS_BG[0+(k-16)*4], AnalogBiasIf_IFC_BIAS_BG[0+(k-16)*4]};
            assign AnalogBiasIf_BGPV.IHD_KRUM_BG = {AnalogBiasIf_IHD_KRUM_BG[3+(k-16)*4], AnalogBiasIf_IHD_KRUM_BG[3+(k-16)*4], AnalogBiasIf_IHD_KRUM_BG[2+(k-16)*4], AnalogBiasIf_IHD_KRUM_BG[2+(k-16)*4], AnalogBiasIf_IHD_KRUM_BG[1+(k-16)*4], AnalogBiasIf_IHD_KRUM_BG[1+(k-16)*4], AnalogBiasIf_IHD_KRUM_BG[0+(k-16)*4], AnalogBiasIf_IHD_KRUM_BG[0+(k-16)*4]};
            assign AnalogBiasIf_BGPV.IHU_KRUM_BG = {AnalogBiasIf_IHU_KRUM_BG[3+(k-16)*4], AnalogBiasIf_IHU_KRUM_BG[3+(k-16)*4], AnalogBiasIf_IHU_KRUM_BG[2+(k-16)*4], AnalogBiasIf_IHU_KRUM_BG[2+(k-16)*4], AnalogBiasIf_IHU_KRUM_BG[1+(k-16)*4], AnalogBiasIf_IHU_KRUM_BG[1+(k-16)*4], AnalogBiasIf_IHU_KRUM_BG[0+(k-16)*4], AnalogBiasIf_IHU_KRUM_BG[0+(k-16)*4]};
            assign AnalogBiasIf_BGPV.ILDAC_MIR1_BG = {AnalogBiasIf_ILDAC_MIR1_BG[3+(k-16)*4], AnalogBiasIf_ILDAC_MIR1_BG[3+(k-16)*4], AnalogBiasIf_ILDAC_MIR1_BG[2+(k-16)*4], AnalogBiasIf_ILDAC_MIR1_BG[2+(k-16)*4], AnalogBiasIf_ILDAC_MIR1_BG[1+(k-16)*4], AnalogBiasIf_ILDAC_MIR1_BG[1+(k-16)*4], AnalogBiasIf_ILDAC_MIR1_BG[0+(k-16)*4], AnalogBiasIf_ILDAC_MIR1_BG[0+(k-16)*4]} ;
            assign AnalogBiasIf_BGPV.ILDAC_MIR2_BG = {AnalogBiasIf_ILDAC_MIR2_BG[3+(k-16)*4], AnalogBiasIf_ILDAC_MIR2_BG[3+(k-16)*4], AnalogBiasIf_ILDAC_MIR2_BG[2+(k-16)*4], AnalogBiasIf_ILDAC_MIR2_BG[2+(k-16)*4], AnalogBiasIf_ILDAC_MIR2_BG[1+(k-16)*4], AnalogBiasIf_ILDAC_MIR2_BG[1+(k-16)*4], AnalogBiasIf_ILDAC_MIR2_BG[0+(k-16)*4], AnalogBiasIf_ILDAC_MIR2_BG[0+(k-16)*4]} ;
            assign AnalogBiasIf_BGPV.IPA_IN_BIAS_BG = {AnalogBiasIf_IPA_IN_BIAS_BG[3+(k-16)*4], AnalogBiasIf_IPA_IN_BIAS_BG[3+(k-16)*4], AnalogBiasIf_IPA_IN_BIAS_BG[2+(k-16)*4], AnalogBiasIf_IPA_IN_BIAS_BG[2+(k-16)*4], AnalogBiasIf_IPA_IN_BIAS_BG[1+(k-16)*4], AnalogBiasIf_IPA_IN_BIAS_BG[1+(k-16)*4], AnalogBiasIf_IPA_IN_BIAS_BG[0+(k-16)*4], AnalogBiasIf_IPA_IN_BIAS_BG[0+(k-16)*4]} ;
            assign AnalogBiasIf_BGPV.VRIF_KRUM_BG = {AnalogBiasIf_VRIF_KRUM_BG[3+(k-16)*4], AnalogBiasIf_VRIF_KRUM_BG[3+(k-16)*4], AnalogBiasIf_VRIF_KRUM_BG[2+(k-16)*4], AnalogBiasIf_VRIF_KRUM_BG[2+(k-16)*4], AnalogBiasIf_VRIF_KRUM_BG[1+(k-16)*4], AnalogBiasIf_VRIF_KRUM_BG[1+(k-16)*4], AnalogBiasIf_VRIF_KRUM_BG[0+(k-16)*4], AnalogBiasIf_VRIF_KRUM_BG[0+(k-16)*4]} ;
            assign AnalogBiasIf_BGPV.VTH_BG = {AnalogBiasIf_VTH_BG[3+(k-16)*4], AnalogBiasIf_VTH_BG[3+(k-16)*4], AnalogBiasIf_VTH_BG[2+(k-16)*4], AnalogBiasIf_VTH_BG[2+(k-16)*4], AnalogBiasIf_VTH_BG[1+(k-16)*4], AnalogBiasIf_VTH_BG[1+(k-16)*4], AnalogBiasIf_VTH_BG[0+(k-16)*4], AnalogBiasIf_VTH_BG[0+(k-16)*4]} ;
          
            assign AnalogBiasIf_BGPV.CAL_HI = {AnalogBiasIf_CAL_HI_BG[3+(k-16)*4], AnalogBiasIf_CAL_HI_BG[3+(k-16)*4], AnalogBiasIf_CAL_HI_BG[2+(k-16)*4], AnalogBiasIf_CAL_HI_BG[2+(k-16)*4], AnalogBiasIf_CAL_HI_BG[1+(k-16)*4], AnalogBiasIf_CAL_HI_BG[1+(k-16)*4], AnalogBiasIf_CAL_HI_BG[0+(k-16)*4], AnalogBiasIf_CAL_HI_BG[0+(k-16)*4]} ;
            assign AnalogBiasIf_BGPV.CAL_MI ={AnalogBiasIf_CAL_MI_BG[3+(k-16)*4], AnalogBiasIf_CAL_MI_BG[3+(k-16)*4], AnalogBiasIf_CAL_MI_BG[2+(k-16)*4], AnalogBiasIf_CAL_MI_BG[2+(k-16)*4], AnalogBiasIf_CAL_MI_BG[1+(k-16)*4], AnalogBiasIf_CAL_MI_BG[1+(k-16)*4], AnalogBiasIf_CAL_MI_BG[0+(k-16)*4], AnalogBiasIf_CAL_MI_BG[0+(k-16)*4]};
          
            
            assign this_data[`DBA_DATA_BITS-1:0] = DataInt[0][`DBA_DATA_BITS-1:0];
            assign this_row[`DBA_ROW_BITS-1:0] = RowInt[0][`DBA_ROW_BITS-1:0];
        
            always@(negedge Clk40)
                LatCntReqInt[0] <= LatCntReq & {9{EnCol}};
                
            always@(posedge Clk40)
                if(EnCoreColBroadcastBX[1]) 
                    AddressConfInt[0] <= {12{1'b1}}; // Last address (unused) used to match all cores in the column (broadcast) 
                else 
                    AddressConfInt[0] <= AddressConfCore_ff & {12{this_conf}};

            
            always@(posedge Clk40)
                DataConfWrInt[0] <= DataConfWr_ff & {8{(this_conf | EnCoreColBroadcastBX[1])}};

            logic ConfWrInt0;
            always@(posedge Clk40)
                 ConfWrInt0 <= ConfWr_ff & (this_conf | EnCoreColBroadcastBX[1]);
            
            CG_MOD cg_wr_pixel(.ClkIn(Clk40), .Enable(ConfWrInt0), .ClkOut(ConfWrInt[0])); 
            
            assign CalEdgeInt[0] = CalEdge & |EnCal_BG[(k-16)*4+3:(k-16)*4]; //** NOTE: enable Cal signals to core column if any of (4x)EnCal_BG = 1
            assign CalAuxInt[0]  = CalAux   & |EnCal_BG[(k-16)*4+3:(k-16)*4]; 
        
        end else begin

            assign AnalogBiasIf_LBNL.PrmpVbnFol = {AnalogBiasIf_PrmpVbnFol_LBNL[3+(k-33)*4], AnalogBiasIf_PrmpVbnFol_LBNL[3+(k-33)*4], AnalogBiasIf_PrmpVbnFol_LBNL[2+(k-33)*4], AnalogBiasIf_PrmpVbnFol_LBNL[2+(k-33)*4], AnalogBiasIf_PrmpVbnFol_LBNL[1+(k-33)*4],AnalogBiasIf_PrmpVbnFol_LBNL[1+(k-33)*4], AnalogBiasIf_PrmpVbnFol_LBNL[0+(k-33)*4],AnalogBiasIf_PrmpVbnFol_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.PrmpVbp = {AnalogBiasIf_PrmpVbp_LBNL[3+(k-33)*4], AnalogBiasIf_PrmpVbp_LBNL[3+(k-33)*4], AnalogBiasIf_PrmpVbp_LBNL[2+(k-33)*4], AnalogBiasIf_PrmpVbp_LBNL[2+(k-33)*4], AnalogBiasIf_PrmpVbp_LBNL[1+(k-33)*4], AnalogBiasIf_PrmpVbp_LBNL[1+(k-33)*4], AnalogBiasIf_PrmpVbp_LBNL[0+(k-33)*4], AnalogBiasIf_PrmpVbp_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.VctrCF0 = {AnalogBiasIf_VctrCF0_R_LBNL[3+(k-33)*4], AnalogBiasIf_VctrCF0_L_LBNL[3+(k-33)*4], AnalogBiasIf_VctrCF0_R_LBNL[2+(k-33)*4], AnalogBiasIf_VctrCF0_L_LBNL[2+(k-33)*4], AnalogBiasIf_VctrCF0_R_LBNL[1+(k-33)*4], AnalogBiasIf_VctrCF0_L_LBNL[1+(k-33)*4], AnalogBiasIf_VctrCF0_R_LBNL[0+(k-33)*4], AnalogBiasIf_VctrCF0_L_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.VctrLCC = {AnalogBiasIf_VctrLCC_R_LBNL[3+(k-33)*4], AnalogBiasIf_VctrLCC_L_LBNL[3+(k-33)*4], AnalogBiasIf_VctrLCC_R_LBNL[2+(k-33)*4], AnalogBiasIf_VctrLCC_L_LBNL[2+(k-33)*4], AnalogBiasIf_VctrLCC_R_LBNL[1+(k-33)*4], AnalogBiasIf_VctrLCC_L_LBNL[1+(k-33)*4], AnalogBiasIf_VctrLCC_R_LBNL[0+(k-33)*4], AnalogBiasIf_VctrLCC_L_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.compVbn = {AnalogBiasIf_compVbn_LBNL[3+(k-33)*4], AnalogBiasIf_compVbn_LBNL[3+(k-33)*4], AnalogBiasIf_compVbn_LBNL[2+(k-33)*4], AnalogBiasIf_compVbn_LBNL[2+(k-33)*4], AnalogBiasIf_compVbn_LBNL[1+(k-33)*4], AnalogBiasIf_compVbn_LBNL[1+(k-33)*4], AnalogBiasIf_compVbn_LBNL[0+(k-33)*4], AnalogBiasIf_compVbn_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.preCompVbn = {AnalogBiasIf_preCompVbn_LBNL[3+(k-33)*4], AnalogBiasIf_preCompVbn_LBNL[3+(k-33)*4], AnalogBiasIf_preCompVbn_LBNL[2+(k-33)*4], AnalogBiasIf_preCompVbn_LBNL[2+(k-33)*4], AnalogBiasIf_preCompVbn_LBNL[1+(k-33)*4], AnalogBiasIf_preCompVbn_LBNL[1+(k-33)*4], AnalogBiasIf_preCompVbn_LBNL[0+(k-33)*4], AnalogBiasIf_preCompVbn_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.vbnLcc = {AnalogBiasIf_vbnLcc_LBNL[3+(k-33)*4], AnalogBiasIf_vbnLcc_LBNL[3+(k-33)*4], AnalogBiasIf_vbnLcc_LBNL[2+(k-33)*4], AnalogBiasIf_vbnLcc_LBNL[2+(k-33)*4], AnalogBiasIf_vbnLcc_LBNL[1+(k-33)*4], AnalogBiasIf_vbnLcc_LBNL[1+(k-33)*4], AnalogBiasIf_vbnLcc_LBNL[0+(k-33)*4], AnalogBiasIf_vbnLcc_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.vff = {AnalogBiasIf_vff_LBNL[3+(k-33)*4], AnalogBiasIf_vff_LBNL[3+(k-33)*4], AnalogBiasIf_vff_LBNL[2+(k-33)*4], AnalogBiasIf_vff_LBNL[2+(k-33)*4], AnalogBiasIf_vff_LBNL[1+(k-33)*4], AnalogBiasIf_vff_LBNL[1+(k-33)*4], AnalogBiasIf_vff_LBNL[0+(k-33)*4], AnalogBiasIf_vff_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.vthin1 = {AnalogBiasIf_vthin1_LBNL[3+(k-33)*4], AnalogBiasIf_vthin1_LBNL[3+(k-33)*4], AnalogBiasIf_vthin1_LBNL[2+(k-33)*4], AnalogBiasIf_vthin1_LBNL[2+(k-33)*4], AnalogBiasIf_vthin1_LBNL[1+(k-33)*4], AnalogBiasIf_vthin1_LBNL[1+(k-33)*4], AnalogBiasIf_vthin1_LBNL[0+(k-33)*4], AnalogBiasIf_vthin1_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.vthin2 = {AnalogBiasIf_vthin2_LBNL[3+(k-33)*4], AnalogBiasIf_vthin2_LBNL[3+(k-33)*4], AnalogBiasIf_vthin2_LBNL[2+(k-33)*4], AnalogBiasIf_vthin2_LBNL[2+(k-33)*4], AnalogBiasIf_vthin2_LBNL[1+(k-33)*4], AnalogBiasIf_vthin2_LBNL[1+(k-33)*4], AnalogBiasIf_vthin2_LBNL[0+(k-33)*4], AnalogBiasIf_vthin2_LBNL[0+(k-33)*4]};

            assign AnalogBiasIf_LBNL.CAL_HI = {AnalogBiasIf_CAL_HI_R_LBNL[3+(k-33)*4], AnalogBiasIf_CAL_HI_L_LBNL[3+(k-33)*4], AnalogBiasIf_CAL_HI_R_LBNL[2+(k-33)*4], AnalogBiasIf_CAL_HI_L_LBNL[2+(k-33)*4], AnalogBiasIf_CAL_HI_R_LBNL[1+(k-33)*4], AnalogBiasIf_CAL_HI_L_LBNL[1+(k-33)*4], AnalogBiasIf_CAL_HI_R_LBNL[0+(k-33)*4], AnalogBiasIf_CAL_HI_L_LBNL[0+(k-33)*4]};
            assign AnalogBiasIf_LBNL.CAL_MI = {AnalogBiasIf_CAL_MI_R_LBNL[3+(k-33)*4], AnalogBiasIf_CAL_MI_L_LBNL[3+(k-33)*4], AnalogBiasIf_CAL_MI_R_LBNL[2+(k-33)*4], AnalogBiasIf_CAL_MI_L_LBNL[2+(k-33)*4], AnalogBiasIf_CAL_MI_R_LBNL[1+(k-33)*4], AnalogBiasIf_CAL_MI_L_LBNL[1+(k-33)*4], AnalogBiasIf_CAL_MI_R_LBNL[0+(k-33)*4], AnalogBiasIf_CAL_MI_L_LBNL[0+(k-33)*4]};
    
            assign this_data[`DBA_DATA_BITS-1:0] = DataInt[0][`DBA_DATA_BITS-1:0];
            assign this_row[`DBA_ROW_BITS-1:0] = RowInt[0][`DBA_ROW_BITS-1:0];
        
            always@(negedge Clk40)
                LatCntReqInt[0] <= LatCntReq & {9{EnCol}};
                
            always@(posedge Clk40)
                if(EnCoreColBroadcastBX[2]) 
                    AddressConfInt[0] <= {12{1'b1}}; // Last address (unused) used to match all cores in the column (broadcast) 
                else 
                    AddressConfInt[0] <= AddressConfCore_ff & {12{this_conf}};

            always@(posedge Clk40)
                DataConfWrInt[0] <= DataConfWr_ff & {8{(this_conf | EnCoreColBroadcastBX[2])}};

            logic ConfWrInt0;
            always@(posedge Clk40)
                 ConfWrInt0 <= ConfWr_ff & (this_conf | EnCoreColBroadcastBX[2]);
            
            CG_MOD cg_wr_pixel(.ClkIn(Clk40), .Enable(ConfWrInt0), .ClkOut(ConfWrInt[0])); 
                
            assign CalEdgeInt[0] = CalEdge & |EnCal_LBNL[(k-33)*4+3:(k-33)*4];  //** NOTE: enable Cal signals to core column if any of (4x)EnCal_LBNL = 1
            assign CalAuxInt[0]  = CalAux   & |EnCal_LBNL[(k-33)*4+3:(k-33)*4];
        
          end

        
        for (coreinx = 0; coreinx < `ROWS; coreinx = coreinx + 1)
        begin: core_gen
            CoreCommonIf CoreCommonIf();

            assign CoreCommonIf.L1Trig = L1TrigInt[coreinx];
            assign CoreCommonIf.Reset = resetInt[coreinx];
            assign CoreCommonIf.Clk = clkInt[coreinx];
            assign CoreCommonIf.Read = ReadInt[coreinx];

            assign CoreCommonIf.TrigId = TrigIdInt[coreinx];
            assign CoreCommonIf.TrigIdReq = TrigIdReqInt[coreinx];

            assign L1TrigInt[coreinx+1] = CoreCommonIf.L1TrigOut;
            assign resetInt[coreinx+1]  = CoreCommonIf.ResetOut;
            assign clkInt[coreinx+1] = CoreCommonIf.ClkOut;
            assign ReadInt[coreinx+1] = CoreCommonIf.ReadOut;
            assign TrigIdInt[coreinx+1] = CoreCommonIf.TrigIdOut;
            assign TrigIdReqInt[coreinx+1] = CoreCommonIf.TrigIdReqOut;

            assign CoreCommonIf.TokIn = TokInt[coreinx+1] ;
            assign TokInt[coreinx] = CoreCommonIf.TokOut ;

            assign CoreCommonIf.EnDigHit = EnDigHitInt[coreinx];
            assign CoreCommonIf.CalEdge = CalEdgeInt[coreinx];
            assign CoreCommonIf.CalAux = CalAuxInt[coreinx];
            assign CoreCommonIf.AnaInjectionMode = AnaInjectionModeInt[coreinx];
            assign CoreCommonIf.DefConf = DefConfInt[coreinx];
        
            assign EnDigHitInt[coreinx+1] = CoreCommonIf.EnDigHitOut;
            assign CalEdgeInt[coreinx+1] = CoreCommonIf.CalEdgeOut;
            assign CalAuxInt[coreinx+1] = CoreCommonIf.CalAuxOut;
            assign AnaInjectionModeInt[coreinx+1] = CoreCommonIf.AnaInjectionModeOut;
            assign DefConfInt[coreinx+1] = CoreCommonIf.DefConfOut;
                
            for  (p_or =0; p_or <`REG_PIXELS; p_or=p_or+1)  begin
                assign CoreCommonIf.HitOrIn[p_or] = HitOrIntCol[coreinx+1][p_or];
                assign HitOrIntCol[coreinx][p_or] = CoreCommonIf.HitOrOut[p_or];
            end

            assign CoreCommonIf.LatCnt = LatCntInt[coreinx];
            assign CoreCommonIf.LatCntReq = LatCntReqInt[coreinx];

            assign LatCntInt[coreinx+1] = CoreCommonIf.LatCntOut;
            assign LatCntReqInt[coreinx+1] = CoreCommonIf.LatCntReqOut;
   
            assign CoreCommonIf.AddressIn = AddressInt[coreinx];
            assign AddressInt[coreinx+1]= CoreCommonIf.AddressOut;

            assign OutLoInt[coreinx]  = CoreCommonIf.OutLo;

            assign CoreCommonIf.AddressConfIn = AddressConfInt[coreinx];
            assign AddressConfInt[coreinx+1] = CoreCommonIf.AddressConfOut;
        
            assign CoreCommonIf.DataConfWrIn = DataConfWrInt[coreinx];
            assign DataConfWrInt[coreinx+1] = CoreCommonIf.DataConfWrOut;
            
            assign CoreCommonIf.ConfWrIn = ConfWrInt[coreinx];
            assign ConfWrInt[coreinx+1] = CoreCommonIf.ConfWrOut;

            assign CoreCommonIf.DataConfRdIn = DataConfRdInt[coreinx+1];
            assign DataConfRdInt[coreinx] = CoreCommonIf.DataConfRdOut;

            if(k<16) begin : core
                CoreCBAIf CoreCBAIf();
                wire [7:0] top_padframe_tomonitor;
                
                // CBA_TO-specifig Signals
                assign CoreCBAIf.PhiAzIn = phi_az_int[coreinx];
                assign phi_az_int[coreinx+1] = CoreCBAIf.PhiAzOut; 
                     
                assign CoreCBAIf.SelC2fIn = sel_c2f_int[coreinx];
                assign sel_c2f_int[coreinx+1] = CoreCBAIf.SelC2fOut; 

                assign CoreCBAIf.SelC4fIn = sel_c4f_int[coreinx];
                assign sel_c4f_int[coreinx+1] = CoreCBAIf.SelC4fOut; 

                assign CoreCBAIf.FastEnIn = fast_en_int[coreinx];
                assign fast_en_int[coreinx+1] = CoreCBAIf.FastEnOut;

                assign CoreCBAIf.WriteSyncTimeIn = writesynctime_int[coreinx];
                assign writesynctime_int[coreinx+1] = CoreCBAIf.WriteSyncTimeOut;

                assign CoreCBAIf.DataIn = DataInt[coreinx+1][`CBA_DATA_BITS-1:0];
                assign CoreCBAIf.RowIn = RowInt[coreinx+1][`CBA_ROW_BITS-1:0];
                assign DataInt[coreinx][`CBA_DATA_BITS-1:0] = CoreCBAIf.DataOut;
                assign RowInt[coreinx][`CBA_ROW_BITS-1:0] = CoreCBAIf.RowOut;

                DigitalCore_CBA_TO i_digital_core(
                    .CoreCBAIf(CoreCBAIf),
                    .CoreCommonIf(CoreCommonIf),
                    .AnaHit(AnalogHitInt[k][coreinx]),
                    .AnalogBiasIf(AnalogBiasIf_TO),
                    // NB: example, not yet defined which k!
                    .TopPadframe_VOUT_PREAMP_TO(top_padframe_tomonitor) 
                );
                
                if(coreinx == (`ROWS-1))
                    assign TopPadframe_VOUT_PREAMP_TO[k] = top_padframe_tomonitor;


            end else if(k<33) begin : core 
                CoreDBAIf CoreDBAIf();
                wire [7:0] top_padframe_tomonitor;

                // DBA-specific signals
                assign CoreDBAIf.DataIn = DataInt[coreinx+1][`DBA_DATA_BITS-1:0];
                assign CoreDBAIf.RowIn = RowInt[coreinx+1][`DBA_ROW_BITS-1:0];
                assign DataInt[coreinx][`DBA_DATA_BITS-1:0] = CoreDBAIf.DataOut;
                assign RowInt[coreinx][`DBA_ROW_BITS-1:0] = CoreDBAIf.RowOut;

                DigitalCore_BGPV i_digital_core(
                    .CoreCommonIf(CoreCommonIf),
                    .CoreDBAIf(CoreDBAIf),
                    .AnaHit(AnalogHitInt[k][coreinx]),
                    .AnalogBiasIf(AnalogBiasIf_BGPV),
                    .TopPadframe_PA_OUT_BG(top_padframe_tomonitor) 
                );
                if(coreinx == (`ROWS-1))
                    assign TopPadframe_PA_OUT_BG[k-16] = top_padframe_tomonitor;

            end else begin : core // end else if(k<33) begin : core
                CoreDBAIf CoreDBAIf();
                wire [2:0][7:0] top_padframe_tomonitor;
                
                // DBA-specific signals
                assign CoreDBAIf.DataIn = DataInt[coreinx+1][`DBA_DATA_BITS-1:0];
                assign CoreDBAIf.RowIn = RowInt[coreinx+1][`DBA_ROW_BITS-1:0];
                assign DataInt[coreinx][`DBA_DATA_BITS-1:0] = CoreDBAIf.DataOut;
                assign RowInt[coreinx][`DBA_ROW_BITS-1:0] = CoreDBAIf.RowOut;


                        
                DigitalCore_LBNL i_digital_core(
                    .CoreCommonIf(CoreCommonIf),
                    .CoreDBAIf(CoreDBAIf),
                    .AnaHit(AnalogHitInt[k][coreinx]),
                    .AnalogBiasIf(AnalogBiasIf_LBNL),
                    .TopPadframe_out1(top_padframe_tomonitor[0]),
                    .TopPadframe_out2(top_padframe_tomonitor[1]),
                    .TopPadframe_out2b(top_padframe_tomonitor[2])
                );
                
                if(coreinx == (`ROWS-1)) begin
                    assign TopPadframe_out1[k-33] = top_padframe_tomonitor[0];
                    assign TopPadframe_out2[k-33] = top_padframe_tomonitor[1];
                    assign TopPadframe_out2b[k-33] = top_padframe_tomonitor[2];                    
                end

            end // if(k<33) begin ... end else begin
        end // begin: core_gen

        wire data_ready_col;
        
        logic trigger_ff_col;
        always@(posedge Clk40)
            trigger_ff_col <= Trigger;

        //TODO: THIS SHOULD BE SYNCHORINZES SOMEHOW (SEU)
        logic [5:0] trigger_id_cnt_col;  
        always@(posedge Clk40) begin
            if(EcrCmd40)
                trigger_id_cnt_col <= 0;
            else if(trigger_ff_col & TriggerAccept) 
                trigger_id_cnt_col <= trigger_id_cnt_col + 1;
        end
        
        ColumnReadControl iColumnReadControl(
            .Reset(EcrCmd40), .Clk(Clk40), .Trigger(TriggerCmd40),
            .Token(TokCol), .Ready(CRCReadyCol[k]),
            .Read(ReadCol), .TriggerOut(L1ChipCol),
            .TriggerId(TrigIdCol), .TriggerIdReq(TrigIdReqCol),
            .TriggerIdReqBin(TrigIdReqColBin[k]),
            .TriggerIdGlobal(trigger_id_cnt_col[4:0]),
            .TriggerNextAccpet(trigger_next_accpet_col[k]),
            .TriggerDistance(trigger_distance_col[k]),
            .DataReady(data_ready_col),
            .WaitReadCnfg(wait_read_confg_bx)
        );

        if(k<16) begin : adapter_gen
            wire [`DBA_ROW_BITS-1:0] adapted_row;
            wire [`DBA_DATA_BITS-1:0] adapted_data;
            wire adapted_ready;
            wire adapted_busy;
    
            OutputAdapter i_output_adapter (
                .Clk(Clk40),
                .Reset(EcrCmd40),
                .RowIdIn(this_row[`CBA_ROW_BITS-1:0]),
                .DataReadyIn(data_ready_col),
                .DataIn(this_data),
                .RowIdOut(adapted_row),
                .DataReadyOut(adapted_ready),
                .DataOut(adapted_data),
                .Busy(adapted_busy)
            );
            assign CRCReadyCol[k] = ~adapted_busy & ReadyCol_ff[k];

            assign DataReadyCol[k] = adapted_ready;
            assign DataCol[k] = adapted_data;
            assign RowCol[k] = adapted_row;

        end else begin
            assign CRCReadyCol[k] = ReadyCol_ff[k];

            assign DataReadyCol[k] = data_ready_col;
            assign DataCol[k] = this_data;
            assign RowCol[k] = this_row;
        end

        end
        
    end // chip_gen
    
endgenerate

logic skip_trigger;
logic trigger_ff;
assign TriggerAccept = !(~&trigger_next_accpet_col);
assign skip_trigger = trigger_ff & !TriggerAccept;

assign TriggerCmd40 = Trigger & TriggerAccept;

always@(posedge Clk40)
    trigger_ff <= Trigger;

always@(posedge Clk40)
    if(EcrCmd40)
        TriggerIdCnt <= 0;
    else if(trigger_ff & TriggerAccept) 
        TriggerIdCnt <= TriggerIdCnt + 1;

//
// SkippedTrigger counter
logic  SkippedTriggerCntFull;
assign SkippedTriggerCntFull = (SkippedTriggerCnt == 16'hffff) ? 1'b1 : 1'b0 ;
always@(posedge Clk40)
    if ((EcrCmd40 == 1'b1) || ( WrSkippedTriggerCntRst == 1'b1))     
        SkippedTriggerCnt <= 0;
    else if((skip_trigger == 1'b1)&& !(SkippedTriggerCntFull == 1'b1)) 
        SkippedTriggerCnt <= SkippedTriggerCnt + 1;
    else                          
        SkippedTriggerCnt <= SkippedTriggerCnt;
//
// SkippedTriggerCntErr generator
always_ff @(posedge Clk40) begin: CmdErrGenerator
    if (SkippedTriggerCnt == 16'b0) SkippedTriggerCntErr <= 1'b0;
    else                            SkippedTriggerCntErr <= 1'b1;
end: CmdErrGenerator


//For the DataConcentrator to wait for triggers (this should be delayed ta consider the delay for data path)
//Distance calculation in 2 steps
logic [4:0] max_trigger_distance, max_trigger_distance_comb;
logic [9:0][4:0] max_trigger_distance_one;
logic [1:0][5:0] trigger_id_dly;
genvar colInx;
generate
    for (colInx=0; colInx<10; colInx=colInx+1) begin : l1_gen
        logic [4:0] max_trigger_distance_one_comb;
        always_comb begin
            max_trigger_distance_one_comb = trigger_distance_col[colInx*5];
            for (int cl = 0; cl < 5; cl++) begin
                if (trigger_distance_col[cl+colInx*5] > max_trigger_distance_one_comb)
                    max_trigger_distance_one_comb  = trigger_distance_col[cl+colInx*5];
            end
        end
        
        always_ff@(posedge Clk40)
            max_trigger_distance_one[colInx] <= max_trigger_distance_one_comb;
    end
endgenerate

always_comb begin
    max_trigger_distance_comb = max_trigger_distance_one[0];
    for (int c = 0; c < 10; c++) begin
        if (max_trigger_distance_one[c] > max_trigger_distance_comb)
            max_trigger_distance_comb  = max_trigger_distance_one[c];
    end
end

always_ff@(posedge Clk40)
    max_trigger_distance <= max_trigger_distance_comb;

always_ff@(posedge Clk40) begin
    trigger_id_dly[0] <= TriggerIdCnt[5:0];
    trigger_id_dly[1] <= trigger_id_dly[0];
    TriggerIdCurrentReq = trigger_id_dly[1] - max_trigger_distance;
end



   `endif   // ABSTRACT

endmodule : PixelArray

`endif


