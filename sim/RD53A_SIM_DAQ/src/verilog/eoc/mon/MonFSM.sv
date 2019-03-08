//----------------------------------------------------------------------------------------------------------------------
// [Filename]       MonFSM.sv [RTL]
// [Project]        RD53A pixel ASIC demonstrator
// [Author]         Roberto Beccherle - Roberto.Beccherle@cern.ch
// [Language]       SystemVerilog 2012 [IEEE Std. 1800-2012]
// [Created]        09/03/2017
// [Description]    State Machine to fill Monitoring Data Fifo
//
// [Clock]          - clk is the 160 MHz clock
// [Reset]          - Reset_b (Synchronous active low) 
// 
// [Change history] 13/03/2017 - Version 1.0
//                               Initial release
// 
//----------------------------------------------------------------------------------------------------------------------
//
// [Dependencies]
//
// $None
//----------------------------------------------------------------------------------------------------------------------
//
// Up to 8 Data words can be sent to an Aurora link (if 4 lanes are active)
// The state machine checks for NewRegData (data coming from a RdRegister command) 
// - If NewRegData = 1 next fifo word can be written if the Fifo is not full (FifoFull)
// - If NewRegData = 1 AND FifoFull --> Generate error flag
// If a SendFrame is detected (we have to send the frame to Aurora) we have to fill the Fifo word with default data
//    but only for the Fifos that do not already have data (FifoEmpty)
//
module MonFSM(
    // Outputs
    output logic [7:0] LoadData,        // Fill corresponding Fifo with regular data
    output logic [7:0] FifoFullError,   // Set when we have to write to a full fifo 
    output logic [7:0] LoadDefaultData, // Fill corresponding Fifo with default data
    output logic [7:0] RdFifo,          // Read back corresponding Fifo
    output logic       WrData,          // Ready to copy Data for Aurora
    // Inputs
    input  wire logic       clk,        // 160 MHz clock
    input  wire logic       Reset_b,    // Synchronous active low
    input  wire logic [7:0] FifoEmpty,  //
    input  wire logic [7:0] FifoFull,   //
    input  wire logic       NewRegData, // New RdReg command -> we can fill fifo
    input  wire logic       SendFrame   // We have to send frame -> fill fifo with default values
    );

////////////////////////////////////////////////////////////////
// Determine LoadData, LoadDefaultData and FifoFullError
////////////////////////////////////////////////////////////////
always_ff @(posedge clk) begin : LoadData_AFF
    if (Reset_b == 1'b0) begin
        LoadData      <= 'b0 ;
        FifoFullError <= 'b0 ;
    end else begin
        if (NewRegData == 1'b1) begin
            LoadData      <= ~FifoFull ; // Write RegData to Fifo's that are not Full
            FifoFullError <=  FifoFull ; // If Fifo's is full set an error
        end else begin 
            LoadData      <= 'b0 ;
            FifoFullError <= 'b0 ; 
        end
    end
end : LoadData_AFF     

always_ff @(posedge clk) begin : LoadDefaultData_AFF
    if (Reset_b == 1'b0) begin
        LoadDefaultData <= 'b0;
        RdFifo          <= 'b0;
    end else begin
        if (SendFrame == 1'b1) begin
            LoadDefaultData <=  FifoEmpty ;  // Write DefaultData to Fifo's that are empty
            RdFifo          <= ~FifoEmpty ;
        end else begin 
            LoadDefaultData <= LoadDefaultData ;
            RdFifo          <= 'b0 ;
        end
    end
end : LoadDefaultData_AFF

// 
// Delay SendFrame
// Needed to write Auto Data in all FIFO's that are empty and read it back
logic [1:0] Dly;
always_ff @(posedge clk) begin : Dly_AFF
    Dly[1:0] <= {Dly[0],SendFrame};
end
//
assign WrData = Dly[1];

endmodule // MonFSM