
//-----------------------------------------------------------------------------------------------------
// [Filename]       RD53A_defines.sv
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         -
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Jan 30, 2017
// [Modified]       Jul 24, 2017
// [Description]    Contains all the defines used in the project
// [Notes]          -
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// n/a

`ifndef RD53A_DEFINES__SV
`define RD53A_DEFINES__SV


`ifndef max
    `define max(a,b) ((a) > (b) ? (a) : (b))
`endif

// Pixel array sizing - COLS and ROWS refer to the 8x8 cores
`define  COLS         50
`define  ROWS         24
`define  REGIONS     4*4
`define  REG_PIXELS    4
`define  SYNC_COLS    16 // Number of columns of SYNC FE flavour
`define  LIN_COLS     17 // Number of columns of  LIN FE flavour
`define  DIFF_COLS    17 // Number of columns of DIFF FE flavour


// enable/disable clock jitter simulation in PLL
//`define ADD_PLL_JITTER


// scan-chain length
`define SCAN_CHAIN_LENGTH  3426   // **NOTE: the actual total scan-chain length is 3426 + 1 due to extra hookup tail flip-flop added by synthesizer during DFT flow,
                                  //         (define_dft scan_chain ... -terminal_lockup edge_sensitive -non_shared_output) 


// Distributed Buffer Architecture (DBA)
`define DBA_DATA_BITS 16
`define DBA_ROW_BITS 10


// Centralized Buffer Architecture (CBA)

`ifndef max
	`define max(a,b) ((a) > (b) ? (a) : (b))
`endif

`define CBA_REGIONS 4
`define CBA_REG_PIXELS 16
`define CBA_TOT_BITS 4
`define CBA_TOT_SLOTS 8
`define CBA_SG_LATENCY_BITS 5
//`define CBA_2X8 1
`define CBA_ROW_BITS 8

// Computed CBA macros
`define CBA_DATA_BITS `CBA_REG_PIXELS+`CBA_TOT_SLOTS*`CBA_TOT_BITS

// CBA Staging Buffer
`define CBA_SG_DEPTH 3

// CBA Latency and ToT Buffer
`define CBA_LB_DEPTH 16

// CBA Pixel Ordering
`ifndef CBA_2X8
`define CBA_PIX_ORDER {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
`else
`define CBA_PIX_ORDER {1, 5, 9, 13, 15, 11, 7, 3, 0, 4, 8, 12, 14, 10, 6, 2}
`endif


// Pixel Array Wire Widths
`define PA_DATA_BITS `max(`CBA_DATA_BITS, `DBA_DATA_BITS)
`define PA_ROW_BITS  `max(`CBA_ROW_BITS, `DBA_ROW_BITS)

//
// Aurora K-Words
const logic [2:9] KWordMM = 8'hD2;
const logic [2:9] KWordMA = 8'h99;
const logic [2:9] KWordAM = 8'h55;
const logic [2:9] KWordAA = 8'hB4;
const logic [2:9] KWordEE = 8'hCC;
const logic [2:9] KWord6  = 8'h66;
const logic [2:9] KWord7  = 8'h33;
const logic [2:9] KWord8  = 8'h4B;
const logic [2:9] KWord9  = 8'h87;


`endif
