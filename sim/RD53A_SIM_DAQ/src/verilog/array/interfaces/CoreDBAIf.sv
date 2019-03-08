
`include "top/RD53A_defines.sv"

`ifndef CoreDBAIf
`define CoreDBAIf

interface CoreDBAIf  ;

	wire [`DBA_ROW_BITS-1:0] RowIn;
	wire [`DBA_ROW_BITS-1:0] RowOut;

	wire [`DBA_DATA_BITS-1:0] DataIn;
	wire [`DBA_DATA_BITS-1:0] DataOut;
	
	modport core_logic (
		input  RowIn,
		output RowOut,

		input DataIn,
		output  DataOut
	);

endinterface: CoreDBAIf
`endif
