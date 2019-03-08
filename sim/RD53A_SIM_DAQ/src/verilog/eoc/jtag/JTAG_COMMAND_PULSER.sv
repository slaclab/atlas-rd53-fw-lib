
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_COMMAND_PULSER.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 18, 2016
// [Modified]       Apr 21, 2017
// [Description]    Generates single-pulse flags at nominal 160 MHz from IR command flags. BCR is the
//                  only single-pulse at 40 MHz instead.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef JTAG_COMMAND_PULSER__SV
`define JTAG_COMMAND_PULSER__SV


`timescale 1ns / 1ps
//`include "timescale.v"


module JTAG_COMMAND_PULSER (

   input wire JtagTck,                                      // JTAG 40 MHz clock
   input wire Clk160,                                       // core-logic 160 MHz master clock

   // command flags from JTAG Instruction Decoder 
   input wire WRREG_cmd,                                    // WRREG instruction decoded from IR or from CONFIGURATION register in auto-increment mode 
   input wire RDREG_cmd,                                    // RDREG instruction decoded from IR 
   input wire ECR_cmd,                                      // ECR instruction decoded from IR
   input wire BCR_cmd,                                      // BCR instruction decoded from IR
   input wire GENGLOBALPULSE_cmd,                           // GENGLOBALPULSE instruction decoded from IR
   input wire GENCAL_cmd,                                   // GENCAL instruction decoded from IR

   // single-pulse output strobes
   output wire JtagWrReg,
   output wire JtagRdReg,
   output wire JtagECR,
   output wire JtagBCR,
   output wire JtagGenGlobalPulse,
   output wire JtagGenCal

   ) ;


   //-----------------------------   JTAG/CORE TIMING INTERFACE   ----------------------------------------//


   // re-synchronize all JTAG command flags except BCR at 160 MHz clock 
   logic           WRREG_cmd_synch ;
   logic           RDREG_cmd_synch ;
   logic             ECR_cmd_synch ;
   logic  GENGLOBALPULSE_cmd_synch ;
   logic          GENCAL_cmd_synch ;

   logic             BCR_cmd_synch ;

   always_ff @(posedge Clk160) begin

                  WRREG_cmd_synch <= WRREG_cmd ; 
                  RDREG_cmd_synch <= RDREG_cmd ;
                    ECR_cmd_synch <= ECR_cmd ;
         GENGLOBALPULSE_cmd_synch <= GENGLOBALPULSE_cmd ;
                 GENCAL_cmd_synch <= GENCAL_cmd ;

   end // always_ff


   



   //-------------------------------   SINGLE-PULSE GENERATORS   -----------------------------------------//

   logic jtag_WrReg_q0 ;
   logic jtag_WrReg_q1 ; 
   logic jtag_WrReg_q2 ; assign JtagWrReg = jtag_WrReg_q2 ;

   logic jtag_RdReg_q0 ;
   logic jtag_RdReg_q1 ; 
   logic jtag_RdReg_q2 ; assign JtagRdReg = jtag_RdReg_q2 ;

   logic jtag_ECR_q0 ;
   logic jtag_ECR_q1 ;
   logic jtag_ECR_q2 ; assign JtagECR = jtag_ECR_q2 ; 

   logic jtag_BCR_q0 ;
   logic jtag_BCR_q1 ;
   logic jtag_BCR_q2 ; assign JtagBCR = jtag_BCR_q2  ;

   logic jtag_GenGlobalPulse_q0 ;
   logic jtag_GenGlobalPulse_q1 ;
   logic jtag_GenGlobalPulse_q2 ; assign JtagGenGlobalPulse = jtag_GenGlobalPulse_q2 ;

   logic jtag_GenCal_q0 ;
   logic jtag_GenCal_q1 ;
   logic jtag_GenCal_q2 ; assign JtagGenCal = jtag_GenCal_q2 ;



   // single-pulse generators
   always_ff @(posedge Clk160) begin


      jtag_WrReg_q0 <= WRREG_cmd_synch ;
      jtag_WrReg_q1 <= jtag_WrReg_q0 ;
      jtag_WrReg_q2 <= jtag_WrReg_q0 & (~jtag_WrReg_q1) ;

      jtag_RdReg_q0 <= RDREG_cmd_synch ;
      jtag_RdReg_q1 <= jtag_RdReg_q0 ;
      jtag_RdReg_q2 <= jtag_RdReg_q0 & (~jtag_RdReg_q1) ;

      jtag_ECR_q0 <= ECR_cmd_synch ;
      jtag_ECR_q1 <= jtag_ECR_q0 ;
      jtag_ECR_q2 <= jtag_ECR_q0 & (~jtag_ECR_q1) ;

      jtag_GenGlobalPulse_q0 <= GENGLOBALPULSE_cmd_synch ; 
      jtag_GenGlobalPulse_q1 <= jtag_GenGlobalPulse_q0 ;
      jtag_GenGlobalPulse_q2 <= jtag_GenGlobalPulse_q0 & (~jtag_GenGlobalPulse_q1) ;

      jtag_GenCal_q0 <= GENCAL_cmd_synch ;
      jtag_GenCal_q1 <= jtag_GenCal_q0 ;
      jtag_GenCal_q2 <= jtag_GenCal_q0 & (~jtag_GenCal_q1) ;

   end // always_ff


   always_ff @(posedge JtagTck) begin

      BCR_cmd_synch <= BCR_cmd ;

      jtag_BCR_q0 <= BCR_cmd_synch ;
      jtag_BCR_q1 <= jtag_BCR_q0 ;
      jtag_BCR_q2 <= jtag_BCR_q0 & (~jtag_BCR_q1) ;

   end // always_ff


endmodule : JTAG_COMMAND_PULSER

`endif

