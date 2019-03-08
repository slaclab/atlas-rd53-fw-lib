`include "array/cba/LatencyMemCell.v"

module PixelRegionLatencyMem_CBA (LE, L1, Reset ,Clk, TokIn, TokOut, ReadData, L1In, L1Req, EnOut,
LatCnfg, LatCnfg2, PixOffCnfg, WriterData, TriggeredData); 

input wire LE, L1, Reset, Clk, ReadData;


input PixOffCnfg;

input wire TokIn;
output wire TokOut;

output wire EnOut;

input wire [4:0] L1In;
input wire [4:0] L1Req;
input wire [8:0] LatCnfg, LatCnfg2;

input wire [`CBA_DATA_BITS-1:0] WriterData;
output reg [`CBA_DATA_BITS-1:0] TriggeredData;

wire [`CBA_LB_DEPTH-1:0] ready_to_read;
wire [`CBA_LB_DEPTH-1:0] full;

wire [`CBA_LB_DEPTH-1:0] demux_le;

wire [`CBA_LB_DEPTH-1:0] read_lat_mem;

wire [`CBA_DATA_BITS-1:0] output_data [0:`CBA_LB_DEPTH-1];
wire [`CBA_DATA_BITS-1:0] output_data_mux [0:`CBA_LB_DEPTH-1];
wire [`CBA_DATA_BITS-1:0] output_data_mux_or [0:`CBA_LB_DEPTH-1];
generate
	genvar k;
	for (k=0; k<`CBA_LB_DEPTH; k=k+1)
	begin: latency_mem
	  LatencyMemCell_CBA mem( 
					.Clk(Clk), 
					.Reset(Reset), 
					.WriteLe(demux_le[k]), 
					.L1(L1), 
					.Full(full[k]), 
					.ReadyToRead(ready_to_read[k]), 
                    .Read(read_lat_mem[k]),
					.L1In(L1In), 
					.L1Req(L1Req),
                    .LatCntIn(LatCnfg),
                    .LatCntReq(LatCnfg2),
					.WriterData(WriterData),
					.Data(output_data[k])
					);
	 end 
endgenerate		

// -------------  TE  storeage  &  adress calc---------------------

wire [`CBA_LB_DEPTH-1:0] free_le_addr;

generate
	genvar m;
	for (m=0; m<`CBA_LB_DEPTH; m=m+1)
	begin : addr_dec	
		if( m==0 )
			assign free_le_addr[m] = (full[m]==0);
		else
			assign free_le_addr[m] = (full[m]==0 & ( &full[m-1:0] ));
	end 
endgenerate 

assign demux_le = {`CBA_LB_DEPTH{LE}} & free_le_addr ;
//assign LeAddr = free_le_addr;

// -------------Read and Output  ---------------------
logic is_triggered_to_read;
assign is_triggered_to_read = (ready_to_read != 0);

wire token_rise; //synopsys keep_signal_name "token_rise"
assign token_rise = (is_triggered_to_read & ~PixOffCnfg); 

assign TokOut = token_rise | TokIn;

assign EnOut = (TokIn == 0 && is_triggered_to_read );

// apaterno: Map/TotValues (combined: Data) multiplexer
/*
generate
	genvar t,mbit;
	for (t=0; t<`CBA_LB_DEPTH; t=t+1) begin: read_dec	
		if( t==0 ) begin
			assign output_data_mux_or[t] = output_data_mux[t];
		end else begin
			for (mbit=0; mbit<`CBA_DATA_BITS; mbit=mbit+1)
				assign output_data_mux_or[t][mbit] = output_data_mux[t][mbit] | output_data_mux_or[t-1][mbit];
		end

		assign output_data_mux[t] = (ready_to_read[t] == 1 ) ? output_data[t] : 0;
	end 
endgenerate

assign TriggeredData = output_data_mux_or[`CBA_LB_DEPTH-1];
*/

// Mux
always @(*) begin
	int i;
	TriggeredData <= 'b0;
	for(i=0;i<`CBA_LB_DEPTH;i++) begin
		if(ready_to_read[i] == 1'b1) begin
			TriggeredData <= output_data[i];
			break;
		end
	end
end

assign Read = EnOut ? ready_to_read : 0 ;

assign read_lat_mem = (EnOut & ReadData) ? ready_to_read : 0 ;

// -------------END Read and Output  ---------------------

// Synthesizer will remove this
wire buffer_full = (&full);

endmodule //PixelRegionLatencyMem

