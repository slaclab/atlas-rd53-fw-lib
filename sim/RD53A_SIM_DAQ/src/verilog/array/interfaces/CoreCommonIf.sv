
`ifndef CoreCommonIf
`define CoreCommonIf

interface CoreCommonIf  ;

    wire L1Trig, Reset ,Clk, Read;
    wire [4:0] TrigId, TrigIdReq;

    wire L1TrigOut, ResetOut ,ClkOut, ReadOut;
    wire [4:0] TrigIdOut, TrigIdReqOut;

    wire TokIn;
    wire TokOut;

    wire [8:0] LatCnt, LatCntReq;

    wire [8:0] LatCntOut, LatCntReqOut;
    
    wire CalEdge; // Global signal for analog injection. First injection. Fine timing.
    wire CalAux; // Global signal for analog injection. Second injection. Not critical timing.
    wire AnaInjectionMode; // uniform or alternating injection mode selection.
    wire EnDigHit;
    wire DefConf;

    wire EnDigHitOut;
    wire CalEdgeOut; 
    wire CalAuxOut;
    wire AnaInjectionModeOut; 
    wire DefConfOut;
    
    wire [11:0] AddressConfIn;
    wire [11:0] AddressConfOut;
    
    wire [7:0] DataConfWrIn;
    wire [7:0] DataConfWrOut;
    
    wire [7:0] DataConfRdIn;
    wire [7:0] DataConfRdOut;
    
    wire ConfWrIn;
    wire ConfWrOut;

    wire [3:0] HitOrIn;
    wire [3:0] HitOrOut;

    wire [5:0] AddressIn; 
    wire [5:0] AddressOut;

    wire OutLo;

    modport core_logic (
        input L1Trig, Reset ,Clk, Read,
        input  TrigId, TrigIdReq,

        output L1TrigOut, ResetOut ,ClkOut, ReadOut,
        output TrigIdOut, TrigIdReqOut,

        input  TokIn,
        output TokOut,

        input   LatCnt, LatCntReq,

        output   LatCntOut, LatCntReqOut,
    
        input CalEdge, CalAux, AnaInjectionMode,
        input EnDigHit, 
        input DefConf,
    
        output CalEdgeOut, CalAuxOut, AnaInjectionModeOut,
    
        output EnDigHitOut, 
        output DefConfOut,
    
        input AddressConfIn,
        output AddressConfOut,
    
        input DataConfWrIn,
        output DataConfWrOut,
    
        input DataConfRdIn,
        output DataConfRdOut,
    
        input ConfWrIn,
        output ConfWrOut,
    
        input  HitOrIn,
        output HitOrOut,

        input AddressIn,
        output  AddressOut,

        output  OutLo
    );
endinterface: CoreCommonIf
`endif

