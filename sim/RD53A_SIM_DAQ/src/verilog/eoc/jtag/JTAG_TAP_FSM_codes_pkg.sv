
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_TAP_FSM_codes_pkg.sv [PACKAGE]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher  pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jul 04, 2016
// [Modified]       Jan 21, 2017
// [Description]    4-bit binary-encoding (4 DFFs, minimum cost) or 15-bit one-hot encoding (15 DFFs,
//                  minimum risk) state assignments for JTAG TAP controller FSM.
//                  Use the ONE_HOT_STATES_ENCODING macro to choose the desired encoding style.
//
// [Notes]          Hamming-encoded states no more supported/required.
//
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


//`define ONE_HOT_STATES_ENCODING


package JTAG_TAP_FSM_codes_pkg ;


   `ifndef ONE_HOT_STATES_ENCODING

   // standard 4-bit binary-encoded FSM states definition (minimum cost)

   typedef enum logic [3:0] {
                                                                      //            STATE name           |  binary code
                                                                      //
      Test_Logic_Reset = 4'b0000 ,                                    //   Test Logic Reset              |    4'b0000
      Run_Test_Idle    = 4'b0001 ,                                    //   Run Test/Idle                 |    4'b0001
                                                                      //
      Select_DR_Scan   = 4'b0010 ,                                    //   Select  Data Register         |    4'b0010
      Capture_DR       = 4'b0011 ,                                    //   Capture Data Register         |    4'b0011
      Shift_DR         = 4'b0100 ,                                    //   Shift   Data Register         |    4'b0100
      Exit1_DR         = 4'b0101 ,                                    //   Exit1   Data Register         |    4'b0101
      Pause_DR         = 4'b0110 ,                                    //   Pause   Data Register         |    4'b0110
      Exit2_DR         = 4'b0111 ,                                    //   Exit2   Data Register         |    4'b0111
      Update_DR        = 4'b1000 ,                                    //   Update  Data Register         |    4'b1000
                                                                      //
      Select_IR_Scan   = 4'b1001 ,                                    //   Select  Instruction Register  |    4'b1001
      Capture_IR       = 4'b1010 ,                                    //   Capture Instruction Register  |    4'b1010
      Shift_IR         = 4'b1011 ,                                    //   Shift   Instruction Register  |    4'b1011
      Exit1_IR         = 4'b1100 ,                                    //   Exit1   Instruction Register  |    4'b1100
      Pause_IR         = 4'b1101 ,                                    //   Pause   Instruction Register  |    4'b1101
      Exit2_IR         = 4'b1110 ,                                    //   Exit2   Instruction Register  |    4'b1110
      Update_IR        = 4'b1111                                      //   Update  Instruction Register  |    4'b1111


   `else


   // standard 15-bit one-hot encoded FSM states definition (minimum risk)

   typedef enum logic [14:0] {
                                                                      //            STATE name           |        one-hot code
                                                                      //
      Test_Logic_Reset = 15'b000000000000000 ,                        //   Test Logic Reset              |   15'b000000000000000
      Run_Test_Idle    = 15'b000000000000001 ,                        //   Run Test/Idle                 |   15'b000000000000001
                                                                      //
      Select_DR_Scan   = 15'b000000000000010 ,                        //   Select  Data Register         |   15'b000000000000010
      Capture_DR       = 15'b000000000000100 ,                        //   Capture Data Register         |   15'b000000000000100
      Shift_DR         = 15'b000000000001000 ,                        //   Shift   Data Register         |   15'b000000000001000
      Exit1_DR         = 15'b000000000010000 ,                        //   Exit1   Data Register         |   15'b000000000010000
      Pause_DR         = 15'b000000000100000 ,                        //   Pause   Data Register         |   15'b000000000100000
      Exit2_DR         = 15'b000000001000000 ,                        //   Exit2   Data Register         |   15'b000000001000000
      Update_DR        = 15'b000000010000000 ,                        //   Update  Data Register         |   15'b000000010000000
                                                                      //
      Select_IR_Scan   = 15'b000000100000000 ,                        //   Select  Instruction Register  |   15'b000000100000000
      Capture_IR       = 15'b000001000000000 ,                        //   Capture Instruction Register  |   15'b000001000000000
      Shift_IR         = 15'b000010000000000 ,                        //   Shift   Instruction Register  |   15'b000010000000000
      Exit1_IR         = 15'b000100000000000 ,                        //   Exit1   Instruction Register  |   15'b000100000000000
      Pause_IR         = 15'b001000000000000 ,                        //   Pause   Instruction Register  |   15'b001000000000000
      Exit2_IR         = 15'b010000000000000 ,                        //   Exit2   Instruction Register  |   15'b010000000000000
      Update_IR        = 15'b100000000000000                          //   Update  Instruction Register  |   15'b100000000000000

   `endif

   } JTAG_TAP_state ; 

endpackage : JTAG_TAP_FSM_codes_pkg

