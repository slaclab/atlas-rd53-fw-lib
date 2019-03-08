
`include "top/RD53A_defines.sv"

`ifndef CoreCBAIf
`define CoreCBAIf

interface CoreCBAIf  ;

	wire [`CBA_ROW_BITS-1:0] RowIn;
	wire [`CBA_ROW_BITS-1:0] RowOut;

	wire [`CBA_DATA_BITS-1:0] DataIn;
	wire [`CBA_DATA_BITS-1:0] DataOut;
	
	wire PhiAzIn;
	wire PhiAzOut; 

	wire SelC2fIn;
	wire SelC2fOut; 

	wire SelC4fIn;
	wire SelC4fOut; 

	wire FastEnIn;
	wire FastEnOut;

	wire [`CBA_SG_LATENCY_BITS-1:0] WriteSyncTimeIn;
	wire [`CBA_SG_LATENCY_BITS-1:0] WriteSyncTimeOut;
	
	modport core_logic (
		input  RowIn,
		output RowOut,

		input DataIn,
		output  DataOut,

		input PhiAzIn,
		output PhiAzOut,
	
		input SelC2fIn,
		output SelC2fOut,

		input SelC4fIn,
		output SelC4fOut,

		input FastEnIn,
		output FastEnOut,

		input WriteSyncTimeIn,
		output WriteSyncTimeOut
	);

endinterface: CoreCBAIf
`endif
