
//-----------------------------------------------------------------------------------------------------
//                                        VLSI Design Laboratory
//                               Istituto Nazionale di Fisica Nucleare (INFN)
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       JTAG_INSTRUCTION_REGISTER_codes_pkg.sv [PACKAGE]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jul  6, 2016
// [Modified]       Apr 12, 2017
// [Description]    Definition of implemented JTAG Instruction Register (IR) operating codes.
//                  Unused codes must be equivalent to a BYPASS instruction.
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a


// Common IEEE Std. 1149.1-2001 JTAG instructions are:
//
// BYPASS             - select BYPASS register                                       [mandatory]
// SAMPLE/PRELOAD     - sample/preload I/O pins through Boundary-Scan Register       [mandatory]
// EXTEST             - select Boundary-Scan Register and set MODE = 1'b1            [mandatory]
// INTEST             - select Boundary-Scan Register and set MODE = 1'b1
// RUNBIST            - run Built-In Self Test (BIST)
// CLAMP              - drive selected output signals to a constant level
// IDCODE             - access Device Identification Register with manufacturer ID and part number
// USERCODE           - access user-programmable internal data
// HIGHZ              - put all output pins into high-impedance state


// RD53A-specific instructions to bypass command-decoder FSM and Aurora are:
//
// ADDRESS            - select 14-bit ADDRESS register         =>  bypass [8:0] RegAddr and [3:0] ChipID outputs from command-decoder FSM and set the normal/autoincrement mode
// CONFIGURATION      - select 16-bit CONFIGURATION register   =>  bypass [15:0] RegData outputs from command-decoder FSM
// CALIBRATION        - select 16-bit CALIBRATION register     =>  bypass [2:0] EdgeDly, [5:0] EdgeWidth, [4:0] AuxDly, EdgeMode and AuxMode outputs from command-decoder FSM
// GLOBALPULSE        - select  4-bit GLOBALPULSE register     =>  bypass [3:0] GlobalPulseWidth outputs from command-decoder FSM
// READOUT            - select 33-bit READOUT register
// WRREG              - write-register command
// RDREG              - read-register command
// ECR                - Event Counter Reset command
// BCR                - Bunch Crossing Reset command 
// GENGLOBALPULSE     - generate global-pulse command
// GENCAL             - generate-calibration command
// INSCAN             - access internal scan-chain

// Torino-only registers and commands for autozeroing
//
// AUTOZEROING        - select 27-bit AUTOZEROING register to program free-running autozeroing PWM generator 
// STARTAZ            - global start-autozeroing JTAG command
// STOPAZ             - global stop-autozeroing JTAG command


package JTAG_IR_codes_pkg ;

   typedef enum logic [4:0] {

      DEPRECATED     = 5'b00000 ,               // according to IEEE Std. 1149.1-2001 revision, an all-zeroes EXTEST instruction has been **deprecated**
      RESERVED       = 5'b00001 ,               // this is the default instruction loaded into the IR when a CAPTURE_IR is generated from TAP controller
      //---------------------------------
      ADDRESS        = 5'b00010 ,               // select 14-bit ADDRESS register
      CONFIGURATION  = 5'b00011 ,               // select 16-bit CONFIGURATION register
      WRREG          = 5'b00100 ,               // generate JtagWrReg command pulse
      RDREG          = 5'b00101 ,               // generate JtagRdReg command pulse
      CALIBRATION    = 5'b00110 ,               // select 16-bit CALIBRATION register
      GENCAL         = 5'b00111 ,               // generate JtagGenCal command pulse
      GLOBALPULSE    = 5'b01000 ,               // select 4-bit GLOBALPULSE register
      GENGLOBALPULSE = 5'b01001 ,               // generate JtagGenGlobalPulse command pulse
      ECR            = 5'b01010 ,               // generate JtagECR command pulse
      BCR            = 5'b01011 ,               // generate JtagBCR command pulse
      READBACK       = 5'b01100 ,               // select READBACK register to read-back user-selected chip configuration data
      AUTOZEROING    = 5'b01101 ,               // select AUTOZEROING register (Torino-only)
      STARTAZ        = 5'b01110 ,               // start PWM generator         (Torino-only)
      STOPAZ         = 5'b01111 ,               // stop PWM generator          (Torino-only)
      //---------------------------------
      EXTESTSER      = 5'b10000 ,               // EXTEST instruction for SER BSR (select SER BOUNDARYSCAN register and set MODE = 1'b1 for BSC)
      EXTESTDAC      = 5'b10001 ,               // EXTEST instruction for DAC BSR (select DAC BOUNDARYSCAN register and set MODE = 1'b1 for BSC)
      BSCANSER       = 5'b10010 ,               // SAMPLE/PRELOAD instruction for SER BSR (select SER BOUNDARYSCAN register, but keep MODE = 1'b0 for BSC)
      BSCANDAC       = 5'b10011 ,               // SAMPLE/PRELOAD instruction for DAC BSR (select DAC BOUNDARYSCAN register, but keep MODE = 1'b0 for BSC)
      ADCDATA        = 5'b10100 ,               // select ADCDATA register to read-back monitoring ADC data 
      UNUSED_0       = 5'b10101 , 
      UNUSED_1       = 5'b10110 ,
      UNUSED_2       = 5'b10111 ,
      UNUSED_3       = 5'b11000 ,
      UNUSED_4       = 5'b11001 ,
      UNUSED_5       = 5'b11010 ,
      UNUSED_6       = 5'b11011 , 
      UNUSED_7       = 5'b11100 ,
      UNUSED_8       = 5'b11101 ,
      INSCAN         = 5'b11110 ,                // select internal scan-chain
      BYPASS         = 5'b11111                  // all-ones according to IEEE Std. 1149.1-2001 

   } JTAG_IR_opcode ;

endpackage : JTAG_IR_codes_pkg

