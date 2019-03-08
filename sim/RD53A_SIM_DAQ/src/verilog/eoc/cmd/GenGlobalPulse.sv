  //-----------------------------------------------------------------------------------------------------
// [Filename]       Cmd_FSM.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Roberto Beccherle - Roberto.Beccherle@cern.ch
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Feb 03, 2017
// [Modified]       Feb 03, 2017
// [Description]    Circuit to generate the GlobalPulse signal
// [Notes]          Reset is Synchronous and active low
// [Version]        2.0
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// None
//-----------------------------------------------------------------------------------------------------



`ifndef GENGLOBALPULSE_SV 
`define GENGLOBALPULSE_SV

//
// Generate GlobalPulse signals
//
module GenGlobalPulse (// Inputs
                       input wire       clk,
                       input wire       Reset_b,        // Syncronous reset active low
                       input wire [3:0] GlobalPulseWidth,
                       input wire       GenGlobalPulse,
                       // Outputs
                       output logic      GlobalPulse);
                 
//
// Internal variables
logic [10:0] GlobalPulseCnt, GlobalPulseWidthValue;
logic        GlobalPulseCntZero;

// Assignments
assign GlobalPulseCntZero    = (GlobalPulseCnt == 'b0);
assign GlobalPulseWidthValue = (GlobalPulseWidth >= 9) ? 10_0000_0000 : (1'b1 << GlobalPulseWidth); // [2^GlobalPulseWidth]

//
// Generate GlobalPulse
always_ff @(posedge clk) begin : GlobalPulseCnt_AFF
    if (Reset_b == 1'b0) begin
        GlobalPulseCnt <= 'b0;
        GlobalPulse    <= 'b0;
    end
    else
        if (GenGlobalPulse) begin
            GlobalPulseCnt <= GlobalPulseWidthValue;
            GlobalPulse    <= 'b0;
        end
        else if (!GlobalPulseCntZero) begin
            GlobalPulseCnt <= GlobalPulseCnt - 1;
            GlobalPulse    <= 'b1;
        end
        else if (GlobalPulseCntZero) begin
            GlobalPulseCnt <= GlobalPulseCnt;
            GlobalPulse    <= 'b0;
        end
    end : GlobalPulseCnt_AFF

endmodule : GenGlobalPulse

`endif // GENGLOBALPULSE_SV 

