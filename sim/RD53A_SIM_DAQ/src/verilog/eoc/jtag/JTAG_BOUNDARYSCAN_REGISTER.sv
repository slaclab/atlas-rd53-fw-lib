
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_BOUNDARYSCAN_REGISTER.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 26, 2017
// [Modified]       Apr  9, 2017
// [Description]    Generic configurable-width JTAG Boundary Scan Register (BSR).
//
// [Notes]          Use the DATA_WIDTH Verilog parameter to specify the register size (default is set
//                  to one, i.e. just a single boundary scan cell)
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// $RTL_DIR/eoc/jtag/JTAG_BSC.sv


`ifndef JTAG_BOUNDARYSCAN_REGISTER__SV
`define JTAG_BOUNDARYSCAN_REGISTER__SV


`timescale  1ns / 1ps
//`include "timescale.v"

`include "eoc/jtag/JTAG_BSC.sv"


module JTAG_BOUNDARYSCAN_REGISTER  #(parameter DATA_WIDTH = 1 ) (

   input wire RESET,                          // reset signal (asynchronous, active-low)
   input wire CLOCK_DR,                       // scan-FF clock

   input wire SHIFT_DR,                       // input MUX select signal
   input wire SHIFT_EN,                       // additional MUX control since gated-clocks are not adopted

   input wire [DATA_WIDTH-1:0] NDI,           // normal data-in
   input wire TDI,                            // scan input data
   input wire UPDATE_DR,                      // update-FF clock
   input wire MODE,                           // output MUX select signal (set to 1'b1 in EXTEST/INTEST or RUNBIST)

   output wire [DATA_WIDTH-1:0] NDO,          // normal data-out
   output wire TDO                            // scan output data

   ) ;


   `ifndef ABSTRACT

   // replicate single-bit boundary scan cells and make cell-to-cell TDI/TDO interconnections
   wire w[0:DATA_WIDTH] ;

   generate 

      genvar k ;

      for(k = 0; k < DATA_WIDTH; k = k+1) begin : BSC

         JTAG_BSC   BSC (

            .RESET     (     RESET ),
            .CLOCK_DR  (  CLOCK_DR ),
            .SHIFT_DR  (  SHIFT_DR ),
            .SHIFT_EN  (  SHIFT_EN ),
            .NDI       (    NDI[k] ),
            .TDI       (      w[k] ),
            .UPDATE_DR ( UPDATE_DR ),
            .MODE      (      MODE ),
            .NDO       (    NDO[k] ),
            .TDO       (    w[k+1] )

         ) ;

      end

   endgenerate

   assign w[0] = TDI ;
   assign TDO = w[DATA_WIDTH] ;


   `endif

endmodule : JTAG_BOUNDARYSCAN_REGISTER

`endif

