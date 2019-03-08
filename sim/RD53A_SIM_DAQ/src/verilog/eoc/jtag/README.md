# JTAG source tree

```
JTAG_MACRO.sv
  |
  |--------------- JTAG_TAP_FSM.sv
  |                  |
  |                  |--------------- JTAG_TAP_FSM_codes_pkg.sv
  |
  |
  |--------------- JTAG_INSTRUCTION_REGISTER.sv
  |                  |
  |                  |--------------- JTAG_INSTRUCTION_REGISTER_codes_pkg.sv
  |
  |
  |--------------- JTAG_INSTRUCTION_DECODER.sv
  |                  |
  |                  |--------------- JTAG_INSTRUCTION_REGISTER_codes_pkg.sv
  |
  |
  |--------------- JTAG_RX_REGISTER.sv
  |
  |
  |--------------- JTAG_TX_REGISTER.sv
  |
  |
  |--------------- JTAG_BYPASS_REGISTER.sv
  |
  |
  |--------------- JTAG_BOUNDARYSCAN_REGISTER.sv
  |                  |
  |                  |---------------  JTAG_BSC.sv
  |
  |
  |--------------- JTAG_COMMAND_PULSER.sv


```



# TAP FSM outputs

```
   //-------------------------------------------------------------------------------------------------------------------------------------------
   //                    |                                                  State output ( * = TBC )
   //      TAP state     |----------------------------------------------------------------------------------------------------------------------
   //                    |  CLOCK_DR  CAPTURE_DR  SHIFT_DR  UPDATE_DR  |  CLOCK_IR  CAPTURE_IR  SHIFT_IR  UPDATE_IR   |  RESET  SELECT  ENABLE
   //--------------------|----------------------------------------------------------------------------------------------------------------------
   //  Test Logic Reset  |     0          0           0         0      |      0          0          0          0      |    0      1*      0
   //  Run Test/Idle     |     0          0           0         0      |      0          0          0          0      |    1      1*      0
   //-------------------------------------------------------------------------------------------------------------------------------------------
   //  Select  DR Scan   |     0          0           0         0      |      0          0          0          0      |    1      0       0
   //  Capture DR        |     1          1           0         0      |      0          0          0          0      |    1      0       0
   //  Shift   DR        |     1          0           1         0      |      0          0          0          0      |    1      0       1
   //  Exit1   DR        |     0          0           0         0      |      0          0          0          0      |    1      0       0
   //  Pause   DR        |     0          0           0         0      |      0          0          0          0      |    1      0       0
   //  Exit2   DR        |     0          0           0         0      |      0          0          0          0      |    1      0       0
   //  Update  DR        |     0          0           0         1      |      0          0          0          0      |    1      0       0
   //-------------------------------------------------------------------------------------------------------------------------------------------
   //  Select  IR Scan   |     0          0           0         0      |      0          0          0          0      |    1      1       0
   //  Capture IR        |     0          0           0         0      |      1          1          0          0      |    1      1       0
   //  Shift   IR        |     0          0           0         0      |      1          0          1          0      |    1      1       1
   //  Exit1   IR        |     0          0           0         0      |      0          0          0          0      |    1      1       0
   //  Pause   IR        |     0          0           0         0      |      0          0          0          0      |    1      1       0
   //  Exit2   IR        |     0          0           0         0      |      0          0          0          0      |    1      1       0
   //  Update  IR        |     0          0           0         0      |      0          0          0          1      |    1      1       0
   //-------------------------------------------------------------------------------------------------------------------------------------------

```


**NOTE: Gated-clocks CLOCK_DR/CLOCK_IR and UPDATE_DR/UPDATE_IR generated from TAP controller not adopted (IEEE Std. 1149.1-2001 broken)




# JTAG instructions

```
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

```
