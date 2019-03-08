
//-----------------------------------------------------------------------------------------------------
// [Filename]       BackupSerializers.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         -
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Apr 13, 2017
// [Modified]       Apr 13, 2017
// [Description]    Just a simple bunch of configurable-width Parallel-In Serial-Out (PISO) shift
//                  registers.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------



// Dependencies:
//
// n/a


`ifndef BACKUP_SERIALIZERS__SV
`define BACKUP_SERIALIZERS__SV


`timescale  1ns / 1ps
//`include "timescale.v"


module BackupSerializersDiv(input logic BackupSerClk, output logic BackupDataClk, output logic DivCountTwo);

   // free-running 20-bit counter to generate a load-data strobe
   //
   logic [4:0] count = 5'b0000 ;   // only for simulation purposes

   always @( posedge BackupSerClk ) begin

      if( count == 19 )
         count <= 5'b0 ;
      else
         count <= count + 1 ;  
   end

   always @( posedge BackupSerClk )
        BackupDataClk <= count[3];
   
   always @( posedge BackupSerClk )
        DivCountTwo <= (count == 2);
   
endmodule


module BackupSerializers #(parameter DATA_WIDTH = 20) (

   input  wire [DATA_WIDTH-1:0] DATA_0,
   input  wire [DATA_WIDTH-1:0] DATA_1,
   input  wire [DATA_WIDTH-1:0] DATA_2,
   input  wire [DATA_WIDTH-1:0] DATA_3,

   input  wire [3:0] BackupEnLane,

   input  wire BackupSerClk,
   output wire BackupDataClk,             // output clock for Aurora

   output logic BackupSerOutput_0,
   output logic BackupSerOutput_1,
   output logic BackupSerOutput_2,
   output logic BackupSerOutput_3

   ) ;

   logic div_count_two;
   BackupSerializersDiv BackupSerializersDiv ( .BackupSerClk(BackupSerClk), .BackupDataClk(BackupDataClk), .DivCountTwo(div_count_two));

   //
   // load-data strobe
   //
   logic [3:0] Load ;

   always_ff @( posedge BackupSerClk ) begin

      if( BackupEnLane[0] == 1'b1 )
         Load[0] <= ( div_count_two ) ;
      else
         Load[0] <= 1'b0 ;

      if( BackupEnLane[1] == 1'b1 )
         Load[1] <= ( div_count_two ) ;
      else
         Load[1] <= 1'b0 ;

      if( BackupEnLane[2] == 1'b1 )
         Load[2] <= ( div_count_two ) ;
      else
         Load[2] <= 1'b0 ;

      if( BackupEnLane[3] == 1'b1 )
         Load[3] <= ( div_count_two ) ;
      else
         Load[3] <= 1'b0 ;

   end

   /*
   //
   // data synchronization
   //
   logic [DATA_WIDTH-1:0] DATA_0_reg ;
   logic [DATA_WIDTH-1:0] DATA_1_reg ;
   logic [DATA_WIDTH-1:0] DATA_2_reg ;
   logic [DATA_WIDTH-1:0] DATA_3_reg ;

   always_ff @( posedge BackupDataClk ) begin

      DATA_0_reg <= DATA_0 ; 
      DATA_1_reg <= DATA_1 ; 
      DATA_2_reg <= DATA_2 ; 
      DATA_3_reg <= DATA_3 ; 

   end
    */
    
   //
   // serializers (just simple PISO shift registers)
   //
   logic [DATA_WIDTH-1:0] shift_reg_0 ;
   logic [DATA_WIDTH-1:0] shift_reg_1 ;
   logic [DATA_WIDTH-1:0] shift_reg_2 ;
   logic [DATA_WIDTH-1:0] shift_reg_3 ;

   always_ff @( posedge BackupSerClk ) begin

      if( Load[0] == 1'b1 )
         shift_reg_0 <= DATA_0 ;
      else 
         shift_reg_0 <= { 1'b0 , shift_reg_0[DATA_WIDTH-1:1] } ;    // shift-right using concatenation

      if( Load[1] == 1'b1 )
         shift_reg_1 <= DATA_1 ;
      else 
         shift_reg_1 <= { 1'b0 , shift_reg_1[DATA_WIDTH-1:1] } ;

      if( Load[2] == 1'b1 )
         shift_reg_2 <= DATA_2 ;
      else 
         shift_reg_2 <= { 1'b0 , shift_reg_2[DATA_WIDTH-1:1] } ;

      if( Load[3] == 1'b1 )
         shift_reg_3 <= DATA_3 ;
      else 
         shift_reg_3 <= { 1'b0 , shift_reg_3[DATA_WIDTH-1:1] } ;

   end   // always


   //
   // output data synchronization
   //
   always_ff @( posedge BackupSerClk ) begin

      if( BackupEnLane[0] == 1'b1 )
         BackupSerOutput_0 <= shift_reg_0[0] ;
      else
         BackupSerOutput_0 <= 1'b0 ;
 
      if( BackupEnLane[1] == 1'b1 )
         BackupSerOutput_1 <= shift_reg_1[0] ;
      else
         BackupSerOutput_1 <= 1'b0 ;

      if( BackupEnLane[2] == 1'b1 )
         BackupSerOutput_2 <= shift_reg_2[0] ;
      else
         BackupSerOutput_2 <= 1'b0 ;

      if( BackupEnLane[3] == 1'b1 )
         BackupSerOutput_3 <= shift_reg_3[0] ;
      else
         BackupSerOutput_3 <= 1'b0 ;

   end  // always_ff


   //assign BackupSerOutput_0 = ( BackupEnLane[0] == 1'b1 ) ? shift_reg_0[0] : 1'b0 ;
   //assign BackupSerOutput_1 = ( BackupEnLane[1] == 1'b1 ) ? shift_reg_1[0] : 1'b0 ;
   //assign BackupSerOutput_2 = ( BackupEnLane[2] == 1'b1 ) ? shift_reg_2[0] : 1'b0 ;
   //assign BackupSerOutput_3 = ( BackupEnLane[3] == 1'b1 ) ? shift_reg_3[0] : 1'b0 ;

endmodule : BackupSerializers

`endif

