
//-----------------------------------------------------------------------------------------------------
// [Filename]       AnalogMux_40to1.sv [IP/BEHAVIORAL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Mar 20, 2017
// [Modified]       Mar 20, 2017
// [Description]    RNM behavioural description for the 40:1 analog MUX used inside monitoring block.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


`timescale 1ns / 1ps


module AnalogMux_40to1 (

   // 40-lines voltage inputs
   input var real Input [39:0],              // **NOTE: only UNPACKED real ports are supported!

   // 40-bit one-hot selection code
   input wire [39:0] Select,

   // analog output
   output real AnalogOut,

   // power/ground pins, unused in this behavioral description
   inout wire AVDD,
   inout wire AGND,
   inout wire VSS      // **NOTE: connected to VSUB

   ) ;


   always_comb begin

      case( Select )

         40'b0000000000_0000000000_0000000000_0000000001 : AnalogOut = Input[ 0] ; 
         40'b0000000000_0000000000_0000000000_0000000010 : AnalogOut = Input[ 1] ;
         40'b0000000000_0000000000_0000000000_0000000100 : AnalogOut = Input[ 2] ;
         40'b0000000000_0000000000_0000000000_0000001000 : AnalogOut = Input[ 3] ;
         40'b0000000000_0000000000_0000000000_0000010000 : AnalogOut = Input[ 4] ;
         40'b0000000000_0000000000_0000000000_0000100000 : AnalogOut = Input[ 5] ;
         40'b0000000000_0000000000_0000000000_0001000000 : AnalogOut = Input[ 6] ;
         40'b0000000000_0000000000_0000000000_0010000000 : AnalogOut = Input[ 7] ;
         40'b0000000000_0000000000_0000000000_0100000000 : AnalogOut = Input[ 8] ;
         40'b0000000000_0000000000_0000000000_1000000000 : AnalogOut = Input[ 9] ;

         40'b0000000000_0000000000_0000000001_0000000000 : AnalogOut = Input[10] ;
         40'b0000000000_0000000000_0000000010_0000000000 : AnalogOut = Input[11] ;
         40'b0000000000_0000000000_0000000100_0000000000 : AnalogOut = Input[12] ;
         40'b0000000000_0000000000_0000001000_0000000000 : AnalogOut = Input[13] ;
         40'b0000000000_0000000000_0000010000_0000000000 : AnalogOut = Input[14] ;
         40'b0000000000_0000000000_0000100000_0000000000 : AnalogOut = Input[15] ;
         40'b0000000000_0000000000_0001000000_0000000000 : AnalogOut = Input[16] ;
         40'b0000000000_0000000000_0010000000_0000000000 : AnalogOut = Input[17] ;
         40'b0000000000_0000000000_0100000000_0000000000 : AnalogOut = Input[18] ;
         40'b0000000000_0000000000_1000000000_0000000000 : AnalogOut = Input[19] ;

         40'b0000000000_0000000001_0000000000_0000000000 : AnalogOut = Input[20] ;
         40'b0000000000_0000000010_0000000000_0000000000 : AnalogOut = Input[21] ;
         40'b0000000000_0000000100_0000000000_0000000000 : AnalogOut = Input[22] ;
         40'b0000000000_0000001000_0000000000_0000000000 : AnalogOut = Input[23] ;
         40'b0000000000_0000010000_0000000000_0000000000 : AnalogOut = Input[24] ;
         40'b0000000000_0000100000_0000000000_0000000000 : AnalogOut = Input[25] ;
         40'b0000000000_0001000000_0000000000_0000000000 : AnalogOut = Input[26] ;
         40'b0000000000_0010000000_0000000000_0000000000 : AnalogOut = Input[27] ;
         40'b0000000000_0100000000_0000000000_0000000000 : AnalogOut = Input[28] ;
         40'b0000000000_1000000000_0000000000_0000000000 : AnalogOut = Input[29] ;

         40'b0000000001_0000000000_0000000000_0000000000 : AnalogOut = Input[30] ;
         40'b0000000010_0000000000_0000000000_0000000000 : AnalogOut = Input[31] ;
         40'b0000000100_0000000000_0000000000_0000000000 : AnalogOut = Input[32] ;
         40'b0000001000_0000000000_0000000000_0000000000 : AnalogOut = Input[33] ;
         40'b0000010000_0000000000_0000000000_0000000000 : AnalogOut = Input[34] ;
         40'b0000100000_0000000000_0000000000_0000000000 : AnalogOut = Input[35] ;
         40'b0001000000_0000000000_0000000000_0000000000 : AnalogOut = Input[36] ;
         40'b0010000000_0000000000_0000000000_0000000000 : AnalogOut = Input[37] ;
         40'b0100000000_0000000000_0000000000_0000000000 : AnalogOut = Input[38] ;
         40'b1000000000_0000000000_0000000000_0000000000 : AnalogOut = Input[39] ;

         default : AnalogOut = 3.141592 ;    // UNDEFINED !

      endcase
   end

endmodule : AnalogMux_40to1 

