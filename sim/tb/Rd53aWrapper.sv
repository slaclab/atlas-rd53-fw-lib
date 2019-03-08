//-----------------------------------------------------------------------------
// File       : Rd53aWrapper.vhd
// Company    : SLAC National Accelerator Laboratory
// Created    : 2018-06-18
// Last update: 2018-06-18
//-----------------------------------------------------------------------------
// Description: Simulation Testbed for testing the Rd53a module
//-----------------------------------------------------------------------------
// This file is part of 'ATLAS RD53 DEV'.
// It is subject to the license terms in the LICENSE.txt file found in the 
// top-level directory of this distribution and at: 
//    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
// No part of 'ATLAS RD53 DEV', including this file, 
// may be copied, modified, propagated, or distributed except according to 
// the terms contained in the LICENSE.txt file.
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps


`include "sim/common/cells_models_sim.v"
`include "sim/rd53a/dut/CgWrapper_sim.v"
`include "sim/rd53a/dut/DelayCell_sim.v"
`include "src/verilog/top/RD53A.sv"


module Rd53aWrapper (
   //------------------------------   DIGITAL INTERFACE   ------------------------------//

   // 
   // HIT Interface
   // 
   input [384*400-1:0] HIT,
   output HIT_CLK,   
   //
   // Power-on Resets (POR)
   //
   input  POR_EXT_CAP_PAD,                            // POR external-cap pin, also used to trigger POR signal
   //
   // Clock Data Recovery (CDR) input command/data stream [SLVS]
   //
   input  CMD_P_PAD,
   input  CMD_N_PAD,
   //
   // 4x general-purpose SLVS outputs, including Hit-ORs
   //
   output GPLVDS0_P_PAD,
   output GPLVDS0_N_PAD,

   output GPLVDS1_P_PAD,
   output GPLVDS1_N_PAD,

   output GPLVDS2_P_PAD,
   output GPLVDS2_N_PAD,

   output GPLVDS3_P_PAD,
   output GPLVDS3_N_PAD,   
   //
   // 4x serial output data links @ 1.28 Gb/s [CML]
   //
   output GTX0_P_PAD,             
   output GTX0_N_PAD,

   output GTX1_P_PAD,
   output GTX1_N_PAD,

   output GTX2_P_PAD,
   output GTX2_N_PAD,

   output GTX3_P_PAD,
   output GTX3_N_PAD
);

// Get the clock from the chip
assign CMD_CLK = dut.ACB.CDR_PLL.pll_clk_160MHz;
assign HIT_CLK = CMD_CLK;
// wire [384*400-1:0] HIT;
// assign HIT = 0;

wire STATUS_PAD;
// initial begin
    // #20us
    // $monitor("t=%3d STATUS_PAD=%b \n",$time,STATUS_PAD);  
// end

wire VDD_PLL = 1'b1 ;        // **NOTE: power connectivity is modeled for CDR/PLL block !
wire GND_PLL = 1'b0 ;

wire VDD_CML = 1'b1 ;        // **NOTE: power connectivity is modeled for CML drivers !
wire GND_CML = 1'b0 ;


RD53A  dut (
   //------------------------------   DIGITAL INTERFACE   ------------------------------//

   //
   // Power-On Resets (POR)
   //
   .POR_EXT_CAP_PAD     ( POR_EXT_CAP_PAD ),
   .POR_OUT_B_PAD       (                 ),
   .PLL_RST_B_PAD       ( POR_EXT_CAP_PAD ), // PLL_RST_B and POR_OUT_B connected to each other with 2-pin jumper

   //
   // Clock Data Recovery (CDR) input command/data stream [SLVS]
   //
   .CMD_P_PAD           ( CMD_P_PAD ),
   .CMD_N_PAD           ( CMD_N_PAD ),


   //
   // 4x general-purpose SLVS outputs, including Hit-ORs
   //
   .GPLVDS0_P_PAD       ( GPLVDS0_P_PAD ),
   .GPLVDS0_N_PAD       ( GPLVDS0_N_PAD ),

   .GPLVDS1_P_PAD       ( GPLVDS1_P_PAD ),
   .GPLVDS1_N_PAD       ( GPLVDS1_N_PAD ),

   .GPLVDS2_P_PAD       ( GPLVDS2_P_PAD ),
   .GPLVDS2_N_PAD       ( GPLVDS2_N_PAD ),

   .GPLVDS3_P_PAD       ( GPLVDS3_P_PAD ),
   .GPLVDS3_N_PAD       ( GPLVDS3_N_PAD ),

   //
   // general purpose monitor output [CMOS]
   //
   .STATUS_PAD          (           STATUS_PAD  ),

   //
   // 4x serial output data links @ 1.28 Gb/s [CML]
   //
   .GTX0_P_PAD          ( GTX0_P_PAD ),
   .GTX0_N_PAD          ( GTX0_N_PAD ),

   .GTX1_P_PAD          ( GTX1_P_PAD ),
   .GTX1_N_PAD          ( GTX1_N_PAD ),

   .GTX2_P_PAD          ( GTX2_P_PAD ),
   .GTX2_N_PAD          ( GTX2_N_PAD ),

   .GTX3_P_PAD          ( GTX3_P_PAD ),
   .GTX3_N_PAD          ( GTX3_N_PAD ),

   //
   // single serial output data link @ 5 Gb/s [GWT]
   //
   //.GWTX_P_PAD          (                       ),
   //.GWTX_N_PAD          (                       ),

   //
   // external 3-bit hard-wired local chip address [CMOS]
   //
   .CHIPID0_PAD         (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !
   .CHIPID1_PAD         (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !
   .CHIPID2_PAD         (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !

   //
   // **BACKUP: single 1.28 Gb/s output line [SLVS]
   //
   .GTX0LVDS_P_PAD      (                       ),
   .GTX0LVDS_N_PAD      (                       ),

   //
   // **BACKUP: bypass/debug MUX controls [CMOS]
   //
   .BYPASS_CMD_PAD      (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !
   .BYPASS_CDR_PAD      ( 1'b0                  ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !
   .DEBUG_EN_PAD        ( 1'b0                  ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !

   //
   // **BACKUP: external clocks [SLVS]
   //
   .EXT_CMD_CLK_P_PAD   (  CMD_CLK              ),
   .EXT_CMD_CLK_N_PAD   ( ~CMD_CLK              ),

   .EXT_SER_CLK_P_PAD   ( 1'b0), // CMD_CLK ), //CLK_DATAX20          ),
   .EXT_SER_CLK_N_PAD   ( 1'b1), //~CMD_CLK ), //~CLK_DATAX20          ),

   //
   // **BACKUP: JTAG [CMOS]
   //
   .JTAG_TRST_B_PAD     (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !
   .JTAG_TCK_PAD        (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !
   .JTAG_TMS_PAD        (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-UP   CONFIGURATION IN CMOS PADS !
   .JTAG_TDI_PAD        (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-UP   CONFIGURATION IN CMOS PADS !
   .JTAG_TDO_PAD        (                       ),

   //
   // **BACKUP: external trigger [CMOS]
   //
   .EXT_TRIGGER_PAD     (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !

   //
   // **BACKUP: auxiliary external CalEdge/CalDly injection signals [CMOS]
   //
   .INJ_STRB0_PAD       (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !
   .INJ_STRB1_PAD       (                       ),                    // **NOTE: LEAVE UNCONNECTED TO CHECK PULL-DOWN CONFIGURATION IN CMOS PADS !

   //
   // spares [CMOS]
   //
   //.SPARE0_PAD          (                       ),
   //.SPARE1_PAD          (                       ),


   //------------------------------   ANALOG INTERFACE   ------------------------------//

   //
   // pixel inputs
   //
   .ANA_HIT             ( HIT /*AnalogHitInt */),

   //
   // external calibration
   //
   .IREF_TRIM0_PAD      (                  1'b0 ),
   .IREF_TRIM1_PAD      (                  1'b0 ),
   .IREF_TRIM2_PAD      (                  1'b0 ),
   .IREF_TRIM3_PAD      (                  1'b1 ),

   //
   // **BACKUP: external DC calibration levels
   //
   .VINJ_HI_PAD         (                       ),
   .VINJ_MID_PAD        (                       ),

   //
   // monitoring
   //
   .IMUX_OUT_PAD        (                       ),
   .VMUX_OUT_PAD        (                       ),

   //
   // **BACKUP: external ADC reference voltages
   //
   .VREF_ADC_IN_PAD     (                       ),
   .VREF_ADC_OUT_PAD    (                       ),

   //
   // **BACKUP: bias currents
   //
   .IREF_IN_PAD         (                       ),
   .IREF_OUT_PAD        (                       ),


   //---------------------------   POWER/GROUND INTERFACE   ---------------------------//

   //
   // ANALOG Shunt-LDO
   //
   .SLDO_REXT_A_PAD     (                       ),
   .SLDO_RINT_A_PAD     (                       ),
   .SLDO_VREF_A_PAD     (                       ),
   .SLDO_VOFFSET_A_PAD  (                       ),
   .SLDO_VDDSHUNT_A_PAD (                       ),

   //
   // DIGITAL Shunt-LDO
   //
   .SLDO_REXT_D_PAD     (                       ),
   .SLDO_RINT_D_PAD     (                       ),
   .SLDO_VREF_D_PAD     (                       ),
   .SLDO_VOFFSET_D_PAD  (                       ),
   .SLDO_VDDSHUNT_D_PAD (                       ),

   //
   // ANALOG core power/ground
   //
   //.VDDA                (                       ),
   //.GNDA                (                       ),
   .VINA_PAD            (                       ),

   //
   // DIGITAL core power/ground
   //
   //.VDDD                (                       ),
   //.GNDD                (                       ),
   .VIND_PAD            (                       ),

   //
   // global substrate
   //
   //.VSUB                (                       ),

   //
   // dedicated PLL power/ground rails
   //
   .VDD_PLL_PAD         (               VDD_PLL ),                    // **NOTE: power connectivity is modeled for CDR/PLL block !
   .GND_PLL_PAD         (               GND_PLL ),

   //
   // dedicated CML driver power/ground rails
   //
   .VDD_CML_PAD         (               VDD_CML ),                    // **NOTE: power connectivity is modeled for CML drivers !
   .GND_CML_PAD         (               GND_PLL ),

   //
   // dedicated 5 Gb/s SER power/ground rails
   //
   //.GWT_VDD_PAD         (                       ),
   //.GWT_VSS_PAD         (                       ),
   //.GWT_VDDHS_PAD       (                       ),
   //.GWT_GNDHS_PAD       (                       ),
   //.GWT_VDDHS_CORE_PAD  (                       ),
   //.GWT_GNDHS_CORE_PAD  (                       ),

   //
   // ground for detector guard-ring pads
   //
   .DET_GRD0_PAD        (                       ),
   .DET_GRD1_PAD        (                       )

   ) ;

endmodule
