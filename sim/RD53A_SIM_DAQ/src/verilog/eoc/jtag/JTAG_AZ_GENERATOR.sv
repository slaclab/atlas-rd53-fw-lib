
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]	    JTAG_AZ_GENERATOR.sv
// [Project]	    RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]	    SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]	    Mar 17, 2017
// [Modified]	    Apr 13, 2017
// [Description]    Internal programmable PWM generator for the Torino-only autozeroing signal.
//
// [Notes]          Code derived from CHIPIX65 demonstrator. 5-bit Digital-controlled Delay Line (DDL)
//                  moved here.
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`ifndef JTAG_AZ_GENERATOR__SV
`define JTAG_AZ_GENERATOR__SV


`timescale 1ns / 1ps
//`include "timescale.v"


module JTAG_AZ_GENERATOR (

   input  RESET,                   // asynchronous, active-low
   input  TCK,
   input  STARTAZ,                 // start/stop commands
   input  STOPAZ,

   input  [ 4:0] NDELAY,           //  5-bit programmable delay     (from AUTOZEROING_reg[ 4: 0] )
   input  [ 7:0] NHIGH,            //  8-bit high-level trimming    (from AUTOZEROING_reg[12: 5] )
   input  [13:0] NLOW,             // 14-bit low-level trimming     (from AUTOZEROING_reg[26:13] )

   output JTAG_PHI_AZ              // distributed to Torino-only macro-columns

   ) ;


   `ifndef ABSTRACT

   // start/stop register

   logic enable ;

   always_ff @( posedge TCK or negedge RESET ) begin 

      if( RESET == 1'b0 )
         enable <= 1'b0 ;

      else begin

         if( STARTAZ == 1'b1 )
            enable <= 1'b1 ;

         if( STOPAZ == 1'b1 )
            enable <= 1'b0 ;

      end   // else
   end   // always_ff



   // clock gating

   logic enable_latch ;

   always_latch begin
      if( TCK == 1'b0 )
         enable_latch = enable ; 
   end

   wire   tck_gated ;
   assign tck_gated = enable_latch & TCK ;



   // counters for pulse widths
   logic [13:0] count_low ;
   logic [ 7:0] count_high ;


   // PHI_AZ logic level
   logic level ;


   // implement counters
   always_ff @(negedge RESET or negedge enable or posedge tck_gated) begin

      if( (RESET == 1'b0) || (enable == 1'b0)  ) begin
         count_high <= 14'b0 ;
         count_low  <=  8'b0 ;
         level      <=  1'b1 ;    // keep PHI_AZ high, i.e. autozeroing is performed in Torino synchronous pixels
      end

      else begin
      
         if( level == 1'b1 ) begin 

            if( count_high == NHIGH -1 ) begin
               count_high <= 14'b0 ;
               level      <=  1'b0 ;
            end
            else
               count_high <= count_high + 1 ;
         end

         if( level == 1'b0 ) begin

            if( count_low == NLOW -1 ) begin
               count_low  <= 8'b0 ;
               level      <= 1'b1 ;
            end
            else
               count_low <= count_low + 1 ;
         end

      end    // else begin
   end    // always_ff



   wire phi_az ;
   assign phi_az = level ;


   // feed the resulting toggle to a 5-bit Digital-controlled Delay Line (DDL)

   wire d[0:31] ;   // delay nodes fed to multiplexer

   assign d[0] = phi_az ;

   generate
      genvar k ;

      for( k = 0 ; k < 31 ; k = k+1) begin : delay_chain

         DEL0   del( .I( d[k] ), .Z( d[k+1] ) ) ;   // ~400ps delay for each DEL0 cell added to the delay chain
         //DEL1   del( .I( d[k] ), .Z( d[k+1] ) ) ;   // ~800ps delay for each DEL1 cell added to the delay chain

      end // for
   endgenerate

   // synopsys dc_script_begin
   // set_dont_touch delay_chain*
   // synopsys dc_script_end


   // delays multiplexer

   logic phi_az_delayed ;

   always_comb begin

      unique case( NDELAY[4:0] )

          0 : phi_az_delayed = d[ 0] ;
          1 : phi_az_delayed = d[ 1] ;
          2 : phi_az_delayed = d[ 2] ;
          3 : phi_az_delayed = d[ 3] ;
          4 : phi_az_delayed = d[ 4] ;
          5 : phi_az_delayed = d[ 5] ;
          6 : phi_az_delayed = d[ 6] ;
          7 : phi_az_delayed = d[ 7] ;
          8 : phi_az_delayed = d[ 8] ;
          9 : phi_az_delayed = d[ 9] ;
         10 : phi_az_delayed = d[10] ;
         11 : phi_az_delayed = d[11] ;
         12 : phi_az_delayed = d[12] ;
         13 : phi_az_delayed = d[13] ;
         14 : phi_az_delayed = d[14] ;
         15 : phi_az_delayed = d[15] ;
         16 : phi_az_delayed = d[16] ;
         17 : phi_az_delayed = d[17] ;
         18 : phi_az_delayed = d[18] ;
         19 : phi_az_delayed = d[19] ;
         20 : phi_az_delayed = d[20] ;
         21 : phi_az_delayed = d[21] ;
         22 : phi_az_delayed = d[22] ;
         23 : phi_az_delayed = d[23] ;
         24 : phi_az_delayed = d[24] ;
         25 : phi_az_delayed = d[25] ;
         26 : phi_az_delayed = d[26] ;
         27 : phi_az_delayed = d[27] ;
         28 : phi_az_delayed = d[28] ;
         29 : phi_az_delayed = d[29] ;
         30 : phi_az_delayed = d[30] ;
         31 : phi_az_delayed = d[31] ;

      endcase
   end   // always_comb

   assign  JTAG_PHI_AZ = phi_az_delayed ;


   `endif

endmodule : JTAG_AZ_GENERATOR

`endif

