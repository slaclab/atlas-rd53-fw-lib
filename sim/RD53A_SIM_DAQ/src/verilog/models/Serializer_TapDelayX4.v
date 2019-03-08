// Verilog HDL and netlist files of
// "RD53_SER_CML_Bonn Serializer_TapDelayX4 schematic"


// Netlisted models

// Library - RD53_SER_CML_Bonn, Cell - Buff_Tree, View - schematic
// LAST TIME SAVED: Mar  2 19:11:26 2017
// NETLIST TIME: Jun 30 19:26:40 2017
`timescale 1ns / 1ps 

module Buff_Tree ( Buff, Buff11, Buff12, OUT0, OUT1, OUT2, OUT3, VDD,
     VSS, IN );

output  Buff, Buff11, Buff12, OUT0, OUT1, OUT2, OUT3;

inout  VDD, VSS;

input  IN;

// List of primary aliased buses


specify 
    specparam CDS_LIBNAME  = "RD53_SER_CML_Bonn";
    specparam CDS_CELLNAME = "Buff_Tree";
    specparam CDS_VIEWNAME = "schematic";
endspecify

INVD24 I23 ( net10, OUT0);
INVD24 I22 ( Buff11, net10);
INVD24 I15 ( net14, Buff11);
INVD24 I14 ( Buff, net14);
INVD24 I21 ( Buff11, net9);
INVD24 I20 ( net9, OUT1);
INVD24 I11 ( net15, Buff);
INVD24 I10 ( net16, net15);
INVD24 I27 ( Buff12, net12);
INVD24 I28 ( net12, OUT2);
INVD24 I17 ( Buff, net13);
INVD24 I16 ( net13, Buff12);
INVD24 I26 ( Buff12, net11);
INVD24 I25 ( net11, OUT3);
INVD8 I7 ( net17, net16);
INVD8 I5 ( IN, net17);

endmodule
// Library - RD53_SER_CML_Bonn, Cell - LoadGen, View - schematic
// LAST TIME SAVED: Mar 23 10:09:33 2017
// NETLIST TIME: Jun 30 19:26:40 2017
`timescale 1ns / 1ps 

module LoadGen ( CLK_WORD, LOAD, VDD, VSS, CLK, RST_B );

output  CLK_WORD, LOAD;

inout  VDD, VSS;

input  CLK, RST_B;

// List of primary aliased buses


specify 
    specparam CDS_LIBNAME  = "RD53_SER_CML_Bonn";
    specparam CDS_CELLNAME = "LoadGen";
    specparam CDS_VIEWNAME = "schematic";
endspecify

DFCNQD4 I199 ( net033, CLK, RST_B, net035);
DFCNQD4 I200 ( net050, CLK, RST_B, net033);
DFCNQD4 I203 ( clk_div_prebuff, CLK, RST_B, net043);
DFCNQD4 I197 ( net037, CLK, RST_B, net039);
DFCNQD4 I201 ( net042, CLK, RST_B, clk_div_prebuff);
DFCNQD4 I198 ( net035, CLK, RST_B, net037);
DFCNQD4 I202 ( net036, CLK, RST_B, LOAD);
DFCNQD4 I196 ( net039, CLK, RST_B, clk_mod5);
NR2XD4 I162 ( net040, net041, net050);
OR2D4 I160 ( net037, net039, net041);
OR2D4 I161 ( net033, net035, net040);
INVD4 I182 ( clk_div_prebuff, net038);
XNR2D4 I206 ( net038, clk_mod5, net042);
INVD2 I184 ( net043, net034);
AN2D2 I186 ( net034, clk_div_prebuff, net036);
INVD12 I185 ( net038, CLK_WORD);

endmodule
// Library - RD53_SER_CML_Bonn, Cell - DelayTap, View - schematic
// LAST TIME SAVED: May 11 14:37:41 2017
// NETLIST TIME: Jun 30 19:26:41 2017
`timescale 1ns / 1ps 

module DelayTap ( TAP0, TAP1, TAP2, VDD, VSS, CLK_TAP, D, EN_TAP,
     INV_TAP );

output  TAP0, TAP1, TAP2;

inout  VDD, VSS;

input  CLK_TAP, D;

input [2:1]  EN_TAP;
input [2:1]  INV_TAP;

// List of primary aliased buses


specify 
    specparam CDS_LIBNAME  = "RD53_SER_CML_Bonn";
    specparam CDS_CELLNAME = "DelayTap";
    specparam CDS_VIEWNAME = "schematic";
endspecify

DFD4 I21 ( net017, CLK_TAP, TAP1, DN2);
DFD4 I23 ( net020, CLK_TAP, TAP2, DN3);
DFD4 I20 ( D, CLK_TAP, TAP0, DN1);
TIEL I34 ( net025);
TIEL I32 ( net016);
MUX2D4 I26 ( TAP2, DN3, INV_TAP[2], net014);
MUX2D4 I35 ( net025, net019, EN_TAP[2], net020);
MUX2D4 I22 ( TAP1, DN2, INV_TAP[2], net019);
MUX2D4 I33 ( net016, net013, EN_TAP[1], net017);
MUX2D4 I2 ( TAP0, DN1, INV_TAP[1], net013);

endmodule
// Library - RD53_SER_CML_Bonn, Cell - LFSR7, View - schematic
// LAST TIME SAVED: May 12 15:37:02 2017
// NETLIST TIME: Jun 30 19:26:41 2017
`timescale 1ns / 1ps 

module LFSR7 ( OUT, VDD, VSS, CLK, RST_B );

output  OUT;

inout  VDD, VSS;

input  CLK, RST_B;

// Buses in the design

wire  [0:6]  BIT;

// List of primary aliased buses


specify 
    specparam CDS_LIBNAME  = "RD53_SER_CML_Bonn";
    specparam CDS_CELLNAME = "LFSR7";
    specparam CDS_VIEWNAME = "schematic";
endspecify

XNR2D4 I12 ( BIT[5], BIT[6], net8);
DFCNQD4 I198 ( net8, CLK, RST_B, BIT[0]);
DFCNQD4 I17 ( BIT[0], CLK, RST_B, BIT[1]);
DFCNQD4 I20 ( BIT[3], CLK, RST_B, BIT[4]);
DFCNQD4 I19 ( BIT[2], CLK, RST_B, BIT[3]);
DFCNQD4 I22 ( BIT[5], CLK, RST_B, BIT[6]);
DFCNQD4 I21 ( BIT[4], CLK, RST_B, BIT[5]);
DFCNQD4 I18 ( BIT[1], CLK, RST_B, BIT[2]);
CKND6 I68 ( BIT[6], OUT);

endmodule
// Library - RD53_SER_CML_Bonn, Cell - Ser_20to1, View - schematic
// LAST TIME SAVED: Mar 23 10:09:23 2017
// NETLIST TIME: Jun 30 19:26:41 2017
`timescale 1ns / 1ps 

module Ser_20to1 ( OUT, VDD, VSS, CLK, IN, LOAD );

output  OUT;

inout  VDD, VSS;

input  CLK, LOAD;

input [19:0]  IN;

// Buses in the design

wire  [18:19]  D;

wire  [0:19]  Q;

// List of primary aliased buses


specify 
    specparam CDS_LIBNAME  = "RD53_SER_CML_Bonn";
    specparam CDS_CELLNAME = "Ser_20to1";
    specparam CDS_VIEWNAME = "schematic";
endspecify

INVD4 I355 ( LOAD, net053);
INVD4 I358 ( LOAD, net052);
DFQD4 I360 ( D[18], CLK, Q[18]);
DFQD4 I357 ( D[19], CLK, Q[19]);
DFXQD4 I413 ( Q[14], IN[12], LOAD, CLK, Q[12]);
DFXQD4 I411 ( Q[10], IN[8], LOAD, CLK, Q[8]);
DFXQD4 I410 ( Q[8], IN[6], LOAD, CLK, Q[6]);
DFXQD4 I409 ( Q[6], IN[4], LOAD, CLK, Q[4]);
DFXQD4 I408 ( Q[4], IN[2], LOAD, CLK, Q[2]);
DFXQD4 I381 ( Q[19], IN[17], LOAD, CLK, Q[17]);
DFXQD4 I406 ( Q[3], IN[1], LOAD, CLK, Q[1]);
DFXQD4 I412 ( Q[12], IN[10], LOAD, CLK, Q[10]);
DFXQD4 I405 ( Q[5], IN[3], LOAD, CLK, Q[3]);
DFXQD4 I404 ( Q[7], IN[5], LOAD, CLK, Q[5]);
DFXQD4 I403 ( Q[9], IN[7], LOAD, CLK, Q[7]);
DFXQD4 I402 ( Q[11], IN[9], LOAD, CLK, Q[9]);
DFXQD4 I401 ( Q[13], IN[11], LOAD, CLK, Q[11]);
DFXQD4 I400 ( Q[15], IN[13], LOAD, CLK, Q[13]);
DFXQD4 I414 ( Q[16], IN[14], LOAD, CLK, Q[14]);
DFXQD4 I399 ( Q[17], IN[15], LOAD, CLK, Q[15]);
DFXQD4 I407 ( Q[2], IN[0], LOAD, CLK, Q[0]);
DFXQD4 I415 ( Q[18], IN[16], LOAD, CLK, Q[16]);
MUX2D4 I315 ( Q[0], LATCH_OUT, CLK, OUT);
LNQD4 I314 ( Q[1], CLK, LATCH_OUT);
AN2D4 I359 ( IN[18], net052, D[18]);
AN2D4 I356 ( IN[19], net053, D[19]);

endmodule
// Library - RD53_SER_CML_Bonn, Cell - Serializer, View - schematic
// LAST TIME SAVED: May 29 10:31:54 2017
// NETLIST TIME: Jun 30 19:26:42 2017
`timescale 1ns / 1ps 

module Serializer ( CLK_TAP, D_OUT, LOAD_INT_B, SER_CLK_DIV2_INT, VDD,
     VSS, DATA, EN_LANE, EXT_RST_B, LOAD, SER_CLK, SER_CLK_DIV2,
     SER_SEL_OUT, WORD_CLK );

output  CLK_TAP, D_OUT, LOAD_INT_B, SER_CLK_DIV2_INT;

inout  VDD, VSS;

input  EN_LANE, EXT_RST_B, LOAD, SER_CLK, SER_CLK_DIV2, WORD_CLK;

input [19:0]  DATA;
input [1:0]  SER_SEL_OUT;

// Buses in the design

wire  [19:0]  IN_SAMPLED;

// List of primary aliased buses


specify 
    specparam CDS_LIBNAME  = "RD53_SER_CML_Bonn";
    specparam CDS_CELLNAME = "Serializer";
    specparam CDS_VIEWNAME = "schematic";
endspecify

DFQD4 I5 ( LOAD, SER_CLK_INT, net024);
DFQD4 I8 ( SER_CLK_DIV2, SER_CLK_INT, SER_CLK_DIV2_SYN );
DFQD4 DF[19:0] ( DATA[19:0], WORD_CLK_INT, IN_SAMPLED[19:0]);
CKND8 I41 ( net010, net09);
CKND8 I42 ( net014, net015);
CKND8 I43 ( net021, net022);
CKND8 I44 ( net022, net027);
CKND8 I45 ( net027, net023);
CKND8 I46 ( net025, net013);
CKND8 I47 ( net023, net025);
CKND8 I48 ( net013, net016);
CKND8 I39 ( SER_CLK_INT, net021);
CKND8 I9 ( net024, net014);
CKND8 I49 ( net016, net026);
CKND8 I20 ( SER_CLK_DIV2_SYN, net010);
LFSR7 LFSR7 ( .VDD(VDD), .VSS(VSS), .OUT(LFSR7_OUT), .CLK(CLK_TAP),
     .RST_B(EXT_RST_LFSR7_B));
Ser_20to1 Ser ( .CLK(SER_CLK_DIV2_INT), .VDD(VDD),
     .IN(IN_SAMPLED[19:0]), .LOAD(LOAD_INT_B), .VSS(VSS),
     .OUT(SER_OUT));
TIEL I3 ( tieL);
CKBD12 I21 ( net05, SER_CLK_INT);
AN2D4 I7 ( WORD_CLK, EN_LANE, WORD_CLK_INT);
AN2D4 I4 ( SER_CLK, EN_LANE, net05);
AN2D4 I28 ( SER_SEL_OUT[1], EXT_RST_B, EXT_RST_LFSR7_B);

CKND24 I38 ( net026, net012);
CKND24 I361 ( net015, LOAD_INT_B);
CKND24 I19 ( net09, SER_CLK_DIV2_INT);
CKND24 I40 ( net012, CLK_TAP);

MUX4D4 Mux ( SER_CLK_DIV2_INT, SER_OUT, LFSR7_OUT, tieL,
     SER_SEL_OUT[0], SER_SEL_OUT[1], D_OUT);

endmodule
// Library - RD53_SER_CML_Bonn, Cell - Serializer_TapDelay, View -
//schematic
// LAST TIME SAVED: Jun  2 18:25:36 2017
// NETLIST TIME: Jun 30 19:26:42 2017
`timescale 1ns / 1ps 

module Serializer_TapDelay ( LOAD_INT_B, SER_CLK_DIV2_INT, TAP0, TAP1,
     TAP2, VDD, VSS, DATA, EN_LANE, EN_TAP, EXT_RST_B, INV_TAP, LOAD,
     SER_CLK, SER_CLK_DIV2, SER_SEL_OUT, WORD_CLK );

output  LOAD_INT_B, SER_CLK_DIV2_INT, TAP0, TAP1, TAP2;

inout  VDD, VSS;

input  EN_LANE, EXT_RST_B, LOAD, SER_CLK, SER_CLK_DIV2, WORD_CLK;

input [19:0]  DATA;
input [2:1]  INV_TAP;
input [2:1]  EN_TAP;
input [1:0]  SER_SEL_OUT;

// List of primary aliased buses


specify 
    specparam CDS_LIBNAME  = "RD53_SER_CML_Bonn";
    specparam CDS_CELLNAME = "Serializer_TapDelay";
    specparam CDS_VIEWNAME = "schematic";
endspecify

DelayTap I1 ( .TAP0(TAP0), .INV_TAP(INV_TAP[2:1]),
     .EN_TAP(EN_TAP[2:1]), .CLK_TAP(CLK_TAP), .TAP1(TAP1), .VDD(VDD),
     .VSS(VSS), .TAP2(TAP2), .D(SER_OUT));
//DCAP I2[5:0] ( VDD, VSS);
//DCAP4 I3[4:0] ( VDD, VSS);
//DCAP16 I4[111:0] ( VDD, VSS);
//DCAP16 I6[52:0] ( VDD, VSS);
//DCAP8 I5[2:0] ( VDD, VSS);
Serializer I0 ( .EN_LANE(EN_LANE), .SER_CLK_DIV2(SER_CLK_DIV2),
     .WORD_CLK(WORD_CLK), .SER_CLK_DIV2_INT(SER_CLK_DIV2_INT),
     .SER_SEL_OUT(SER_SEL_OUT[1:0]), .DATA(DATA[19:0]),
     .SER_CLK(SER_CLK), .CLK_TAP(CLK_TAP), .LOAD_INT_B(LOAD_INT_B),
     .VDD(VDD), .VSS(VSS), .D_OUT(SER_OUT), .EXT_RST_B(EXT_RST_B),
     .LOAD(LOAD));

endmodule

// Library - RD53_SER_CML_Bonn, Cell - Serializer_TapDelayX4, View -
//schematic
// LAST TIME SAVED: May 30 17:09:37 2017
// NETLIST TIME: Jun 30 19:26:43 2017
`timescale 1ns / 1ps 

module Serializer_TapDelayX4 ( LOAD_INT_B, SER_CLK_DIV2_INT, TAP0,
     TAP1, TAP2, WORD_CLK, VDD, VSS, DATA_SER0, DATA_SER1, DATA_SER2,
     DATA_SER3, EN_LANE, EXT_RST_B, SER_CLK, SER_EN_TAP_SER0,
     SER_EN_TAP_SER1, SER_EN_TAP_SER2, SER_EN_TAP_SER3,
     SER_INV_TAP_SER0, SER_INV_TAP_SER1, SER_INV_TAP_SER2,
     SER_INV_TAP_SER3, SER_SEL_OUT_SER0, SER_SEL_OUT_SER1,
     SER_SEL_OUT_SER2, SER_SEL_OUT_SER3 );

output  WORD_CLK;

inout  VDD, VSS;

input  EXT_RST_B, SER_CLK;

output [3:0]  TAP0;
output [3:0]  TAP2;
output [3:0]  LOAD_INT_B;
output [3:0]  TAP1;
output [3:0]  SER_CLK_DIV2_INT;

input [19:0]  DATA_SER0;
input [19:0]  DATA_SER3;
input [19:0]  DATA_SER1;
input [1:0]  SER_SEL_OUT_SER0;
input [1:0]  SER_SEL_OUT_SER1;
input [1:0]  SER_SEL_OUT_SER2;
input [1:0]  SER_SEL_OUT_SER3;
input [2:1]  SER_EN_TAP_SER1;
input [2:1]  SER_EN_TAP_SER2;
input [2:1]  SER_EN_TAP_SER3;
input [2:1]  SER_INV_TAP_SER0;
input [2:1]  SER_INV_TAP_SER1;
input [2:1]  SER_INV_TAP_SER2;
input [2:1]  SER_INV_TAP_SER3;
input [3:0]  EN_LANE;
input [2:1]  SER_EN_TAP_SER0;
input [19:0]  DATA_SER2;

// Buses in the design

wire  [3:0]  SER_CLK_DIV2_LANE;

wire  [3:0]  LOAD_BUF;

wire  [3:0]  WORD_CLK_BUF_LANE;

wire  [3:0]  SER_CLK_BUF_LANE;

// List of primary aliased buses


specify 
    specparam CDS_LIBNAME  = "RD53_SER_CML_Bonn";
    specparam CDS_CELLNAME = "Serializer_TapDelayX4";
    specparam CDS_VIEWNAME = "schematic";
endspecify

DFQD4 I8 ( net029, SER_CLK_PRE_BUF, net014);

// initial begin
     // $deposit(I8.D, 1'b0);
// end

Buff_Tree ClkWordTree ( .Buff12(net021), .Buff11(net027),
     .Buff(net025), .VDD(VDD), .VSS(VSS), .OUT0(WORD_CLK_BUF_LANE[0]),
     .OUT1(WORD_CLK_BUF_LANE[1]), .OUT2(WORD_CLK_BUF_LANE[2]),
     .OUT3(WORD_CLK_BUF_LANE[3]), .IN(WORD_CLK));
Buff_Tree ClkFastTree ( .Buff12(net06), .Buff11(net04), .Buff(net05),
     .VDD(VDD), .VSS(VSS), .OUT0(SER_CLK_BUF_LANE[0]),
     .OUT1(SER_CLK_BUF_LANE[1]), .OUT2(SER_CLK_BUF_LANE[2]),
     .OUT3(SER_CLK_BUF_LANE[3]), .IN(SER_CLK_BUF));
Buff_Tree ClkTree ( .Buff12(net03), .Buff11(net015), .Buff(net012),
     .VDD(VDD), .VSS(VSS), .OUT0(SER_CLK_DIV2_LANE[0]),
     .OUT1(SER_CLK_DIV2_LANE[1]), .OUT2(SER_CLK_DIV2_LANE[2]),
     .OUT3(SER_CLK_DIV2_LANE[3]), .IN(SER_CLK_DIV2));
Buff_Tree LoadTree ( .Buff12(net010), .Buff11(net08), .Buff(net09),
     .VDD(VDD), .VSS(VSS), .OUT0(LOAD_BUF[0]), .OUT1(LOAD_BUF[1]),
     .OUT2(LOAD_BUF[2]), .OUT3(LOAD_BUF[3]), .IN(LOAD));
CKND4 I24 ( net014, net029);
LoadGen LoadGen ( .RST_B(EXT_RST_B), .CLK(SER_CLK_DIV2), .LOAD(LOAD),
     .VDD(VDD), .VSS(VSS), .CLK_WORD(WORD_CLK));
CKBD16 I72 ( SER_CLK_PRE_BUF, SER_CLK_BUF);
CKBD16 I58 ( SER_CLK, SER_CLK_PRE_BUF);
CKBD16 I57 ( net014, SER_CLK_DIV2);
Serializer_TapDelay Ser[3:0] ( .LOAD_INT_B(LOAD_INT_B[3:0]),
     .SER_CLK_DIV2_INT(SER_CLK_DIV2_INT[3:0]), .TAP0(TAP0[3:0]),
     .TAP1(TAP1[3:0]), .TAP2(TAP2[3:0]), .VDD(VDD), .VSS(VSS),
     .DATA({DATA_SER3[19:0], DATA_SER2[19:0], DATA_SER1[19:0],
     DATA_SER0[19:0]}), .EN_LANE(EN_LANE[3:0]),
     .EN_TAP({SER_EN_TAP_SER3[2:1], SER_EN_TAP_SER2[2:1],
     SER_EN_TAP_SER1[2:1], SER_EN_TAP_SER0[2:1]}),
     .EXT_RST_B(EXT_RST_B), .INV_TAP({SER_INV_TAP_SER3[2:1],
     SER_INV_TAP_SER2[2:1], SER_INV_TAP_SER1[2:1],
     SER_INV_TAP_SER0[2:1]}), .LOAD(LOAD_BUF[3:0]),
     .SER_CLK(SER_CLK_BUF_LANE[3:0]),
     .SER_CLK_DIV2(SER_CLK_DIV2_LANE[3:0]),
     .SER_SEL_OUT({SER_SEL_OUT_SER3[1:0], SER_SEL_OUT_SER2[1:0],
     SER_SEL_OUT_SER1[1:0], SER_SEL_OUT_SER0[1:0]}),
     .WORD_CLK(WORD_CLK_BUF_LANE[3:0]));

endmodule


// End HDL models
