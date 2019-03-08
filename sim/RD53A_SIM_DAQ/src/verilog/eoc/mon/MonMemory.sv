//
// Memory block to be used for the Monitoring FIFO
// OutData always contains the last word pointed by RdAddr
//
module MonMem #(parameter DataWidth = 16,
                          AddrWidth = 5
                          )
               (
               // Outputs
               output logic [DataWidth-1:0] OutData ,
               // Inputs
               input   wire [DataWidth-1:0] InData  ,
               input   wire                 Write   ,
               input   wire                 clk     ,
               input   wire [AddrWidth-1:0] WrAddr  ,
               input   wire [AddrWidth-1:0] RdAddr
               );

// Parameters
parameter RamSize = (1 << AddrWidth);
// Declarations
logic [DataWidth-1:0] memory[0:RamSize-1];
// logic [RamSize-1:0][DataWidth-1:0] memory;
   
always_ff @(posedge clk) begin : MonMemWrt_AFF
   if (Write)
     memory[WrAddr] <= InData;
   //
   OutData <= memory[RdAddr];
end : MonMemWrt_AFF

// assign OutData = memory[RdAddr];

endmodule : MonMem
