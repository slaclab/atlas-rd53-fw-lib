//-----------------------------------------------------------------------------------------------------
// [Filename]       Cmd_FSM.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Roberto Beccherle - Roberto.Beccherle@cern.ch
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        Feb 03, 2017
// [Modified]       Feb 03, 2017
// [Description]    Circuit to generate the Calibration signals
// [Notes]          Reset is Synchronous and active low
// [Version]        2.0
// [Status]         devel
//-----------------------------------------------------------------------------------------------------


// Dependencies:
//
// None
//-----------------------------------------------------------------------------------------------------



`ifndef GENCAL_SV 
`define GENCAL_SV

//
// Generate Cal signals
// Cal Command is: {Cal,Cal}{ChipId[3:0],CalEdgeMode,CalEdgeDelay[2:0],CalEdgeWidth[5:4]}{CalEdgeWidth[3:0],CalAuxMode,CalAuxDly[4:0]}
//                                         0=step     1 to 8 @  40MHz   0 to 63 @ 160MHz  0 to 63 @ 160MHz    SetTo    1 to 32 @ 160MHz
//                                         1=pulse   4 to 32 @ 160MHz     
//
module GenCal (// Inputs
                input wire       clk,
                input wire       Reset_b,   // Syncronous reset active low
                input wire [5:0] EdgeWidth, // from 0 to 63
                input wire [2:0] EdgeDly,   // from 1 to 9
                input wire [4:0] AuxDly,    // from 1 to 32
                input wire       GenCal,
                input wire       EdgeMode,  // Step (EdgeMode = 0) or Pulse (EdgeMode = 1)
                input wire       AuxMode,   // Determines the value of the aux signal
                // Outputs
                output logic      CalEdge,
                output logic      CalAux);
                 
//
// Internal variables
logic [5:0] EdgeWidthCnt;
logic [4:0] EdgeDlyCnt;
logic [4:0] AuxDlyCnt;
logic EdgeDlyCntZero, EdgeWidthCntZero, AuxDlyCntZero;
logic SetEdge, ClearEdge, SetAux, AuxVal;

// Assignments
assign EdgeDlyCntZero    = (EdgeDlyCnt   == 'b0);
assign EdgeWidthCntZero  = (EdgeWidthCnt == 'b0);
assign AuxDlyCntZero     = (AuxDlyCnt    == 'b0);

//
// Generate Edge and Aux pulses
always_ff @(posedge clk) begin : SetEdgeAux_AFF
    if (Reset_b == 1'b0) begin
        CalEdge <= 'b0;
         CalAux <= 'b0;
    end
    else
        // Generate Edge signal
        if (SetEdge && ~ClearEdge) begin   
            CalEdge <= 1;
        end else if (SetEdge && ClearEdge && EdgeMode) begin
            CalEdge <= 0;
        end else begin // keep previous values
            
            CalEdge <= CalEdge;
        end
        // Generate Aux signal
        if (SetAux) begin
            CalAux <= AuxVal;
        end else begin // keep previous values
            CalAux <= CalAux;
        end
    end : SetEdgeAux_AFF

// 
// Edge Delay Counter
always_ff @(posedge clk) begin : EdgeDlyCnt_AFF
    if (Reset_b == 1'b0) begin
        EdgeDlyCnt <= 'b0; 
        SetEdge    <= 0;
    end else 
    if (GenCal == 1'b1) begin
            EdgeDlyCnt <= {EdgeDly,2'b0}; // Set the counter times 4 in order to generate pulses in 40 MHz units (multiply by 4)
            SetEdge    <= 0;
        end // if (GenCal) begin
        else if (EdgeDlyCntZero) begin
            EdgeDlyCnt <= EdgeDlyCnt;
            SetEdge    <= 1;
        end else begin
            EdgeDlyCnt <= EdgeDlyCnt -1;
            SetEdge    <= 0;
        end
    end : EdgeDlyCnt_AFF

// 
// Edge Pulse Counter
always_ff @(posedge clk) begin : EdgeWidthCnt_AFF
    if (Reset_b == 1'b0) begin
        EdgeWidthCnt <= 'b0; 
        ClearEdge    <= 0;
    end
    else 
        if (GenCal == 1'b1) begin
            EdgeWidthCnt <= EdgeWidth;  // Set the counter
            ClearEdge    <= 0;
        end // if (GenCal) begin
        else if (EdgeDlyCntZero && ~EdgeWidthCntZero) begin // We have waited for Edge Delay
            EdgeWidthCnt <= EdgeWidthCnt -1;
            ClearEdge    <= 0;
        end
        else if (EdgeDlyCntZero && EdgeWidthCntZero) begin
            EdgeWidthCnt <= EdgeWidthCnt;
            ClearEdge    <= 1;
        end
        else begin
            EdgeWidthCnt <= EdgeWidthCnt;
            ClearEdge    <= 0;
        end // else
end : EdgeWidthCnt_AFF

//
// Aux Delay Counter
always_ff @(posedge clk) begin : AuxDlyCnt_AFF
    if (Reset_b == 1'b0) begin
        AuxDlyCnt <= 'b0; 
        SetAux    <= 0;
        AuxVal    <= 0;
    end else begin
        if (GenCal == 1'b1) begin
            AuxDlyCnt <= AuxDly;  // Set the counter
            SetAux    <= 0;
            AuxVal    <= AuxMode;
        end else if (AuxDlyCntZero == 1'b1) begin
            AuxDlyCnt <= AuxDlyCnt;
            SetAux    <= 1;
            AuxVal    <= AuxVal;
        end else begin
            AuxDlyCnt <= AuxDlyCnt -1;
            SetAux    <= 0;
            AuxVal    <= AuxVal;
        end
    end // end else
end // AuxDlyCnt_AFF : AuxDlyCnt_AFF

endmodule : GenCal

`endif // GENCAL_SV
