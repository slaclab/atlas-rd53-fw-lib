
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_INSTRUCTION_DECODER.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jul 14, 2016
// [Modified]       Jul 14, 2017
// [Description]    Decodes 5-bit instruction word OPCODE loaded into IR shadow register and generates 
//                  control flags
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/eoc/jtag/JTAG_INSTRUCTION_REGISTER_codes_pkg.sv   **NOTE: package source file included at top-level


`ifndef JTAG_INSTRUCTION_DECODER__SV
`define JTAG_INSTRUCTION_DECODER__SV


`timescale  1ns / 1ps
//`include "timescale.v"


module JTAG_INSTRUCTION_DECODER (

   // 5-bit instruction word loaded into IR shadow register
   input wire [4:0] OPCODE,

   // JTAG clock
   input wire TCK,

   // selection flags for user-defined registers
   output logic  ADDRESS_sel,                          // select ADDRESS register
   output logic  CONFIGURATION_sel,                    // select CONFIGURATION register
   output logic  CALIBRATION_sel,                      // select CALIBRATION register
   output logic  GLOBALPULSE_sel,                      // select GLOBALPULSE register
   output logic  ADCDATA_sel,                          // select ADCDATA register
   output logic  READBACK_sel,                         // select READBACK register

   // selection flags for JTAG-specific registers
   output logic  BYPASS_sel,                           // select BYPASS register

   output logic  BOUNDARYSCAN_SER_sel,                 // select SER BOUNDARYSCAN register 
   output logic  BOUNDARYSCAN_SER_mode,                // control signal for SER BCS output multiplexer
   output logic  BOUNDARYSCAN_DAC_sel,                 // select DAC BOUNDARYSCAN register
   output logic  BOUNDARYSCAN_DAC_mode,                // control signal for DAC BCS output multiplexer

   output logic  INSCAN_sel,                           // select internal scan chain

   // command flags
   output logic  WRREG_cmd,                            // generate JtagWrReg command pulse
   output logic  RDREG_cmd,                            // generate JtagRdReg command pulse
   output logic  ECR_cmd,                              // generate JtagECR command pulse
   output logic  BCR_cmd,                              // generate JtagBCR command pulse
   output logic  GENGLOBALPULSE_cmd,                   // generate JtagGenGlobalPulse command pulse
   output logic  GENCAL_cmd,                           // generate JtagGenCal command pulse

   // Torino-only flags
   output logic  AUTOZEROING_sel,                      // select AUTOZEROING register
   output logic  STARTAZ_cmd,                          // global start-autozeroing
   output logic  STOPAZ_cmd                            // global stop-autozeroing

   ) ;


   `ifndef  ABSTRACT

   import JTAG_IR_codes_pkg::* ;

   always_ff @(posedge TCK) begin

                ADDRESS_sel <= 1'b0 ;
          CONFIGURATION_sel <= 1'b0 ;
            CALIBRATION_sel <= 1'b0 ;
            GLOBALPULSE_sel <= 1'b0 ;
                ADCDATA_sel <= 1'b0 ;
               READBACK_sel <= 1'b0 ;

                 BYPASS_sel <= 1'b0 ;

       BOUNDARYSCAN_SER_sel <= 1'b0 ;
      BOUNDARYSCAN_SER_mode <= 1'b0 ;

       BOUNDARYSCAN_DAC_sel <= 1'b0 ;
      BOUNDARYSCAN_DAC_mode <= 1'b0 ;

                 INSCAN_sel <= 1'b0 ;  
 
                  WRREG_cmd <= 1'b0 ;
                  RDREG_cmd <= 1'b0 ;
                    ECR_cmd <= 1'b0 ;
                    BCR_cmd <= 1'b0 ;
         GENGLOBALPULSE_cmd <= 1'b0 ;
                 GENCAL_cmd <= 1'b0 ;

            AUTOZEROING_sel <= 1'b0 ;
                STARTAZ_cmd <= 1'b0 ;
                 STOPAZ_cmd <= 1'b0 ;


      case( OPCODE )

         ADDRESS         :              ADDRESS_sel <= 1'b1 ;
         CONFIGURATION   :        CONFIGURATION_sel <= 1'b1 ;
         CALIBRATION     :          CALIBRATION_sel <= 1'b1 ;
         GLOBALPULSE     :          GLOBALPULSE_sel <= 1'b1 ;
         ADCDATA         :              ADCDATA_sel <= 1'b1 ;
         READBACK        :             READBACK_sel <= 1'b1 ;

         BYPASS          :               BYPASS_sel <= 1'b1 ;

         BSCANSER        :     BOUNDARYSCAN_SER_sel <= 1'b1 ;
         BSCANDAC        :     BOUNDARYSCAN_DAC_sel <= 1'b1 ;

         EXTESTSER       : begin
                               BOUNDARYSCAN_SER_sel <= 1'b1 ;
                              BOUNDARYSCAN_SER_mode <= 1'b1 ;
                           end

         EXTESTDAC       : begin
                               BOUNDARYSCAN_DAC_sel <= 1'b1 ;
                              BOUNDARYSCAN_DAC_mode <= 1'b1 ;
                           end

         INSCAN          :               INSCAN_sel <= 1'b1 ;

         WRREG           :                WRREG_cmd <= 1'b1 ;
         RDREG           :                RDREG_cmd <= 1'b1 ;
         ECR             :                  ECR_cmd <= 1'b1 ;
         BCR             :                  BCR_cmd <= 1'b1 ;
         GENGLOBALPULSE  :       GENGLOBALPULSE_cmd <= 1'b1 ;
         GENCAL          :               GENCAL_cmd <= 1'b1 ;

         AUTOZEROING     :          AUTOZEROING_sel <= 1'b1 ;
         STARTAZ         :              STARTAZ_cmd <= 1'b1 ;
         STOPAZ          :               STOPAZ_cmd <= 1'b1 ;

         default         :               BYPASS_sel <= 1'b1 ;    // catch-all, always select the BYPASS register otherwise

      endcase

   end

   `endif   // ABSTRACT

endmodule : JTAG_INSTRUCTION_DECODER

`endif

