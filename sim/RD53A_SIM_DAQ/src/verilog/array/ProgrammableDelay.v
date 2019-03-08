
`ifndef PROGRAMMABLE_DELAY
`define PROGRAMMABLE_DELAY

module CkMux4to1 (in, sel, out);
    input wire [3:0] in;
    input wire [1:0] sel;
    output wire out;
    
    wire mux1_out, mux2_out, mux3_out;
    
    CKMUX2D0 mux1(.I0(in[0]),.I1(in[1]),.S(sel[0]), .Z(mux1_out)),
                       mux2(.I0(in[2]),.I1(in[3]), .S(sel[0]), .Z(mux2_out)),
                       mux3(.I0(mux1_out), .I1(mux2_out), .S(sel[1]),.Z(mux3_out));
                       
     assign out = mux3_out;
    
endmodule //CkMux4to1 

module CkMux6to1 (in, sel, out);
    input wire [5:0] in;
    input wire [2:0] sel;
    output wire out;
    
    wire mux1_out, mux2_out, mux3_out;
    
    CkMux4to1 mux1(.in(in[3:0]),.sel(sel[1:0]), .out(mux1_out));
    
    CKMUX2D0 mux2(.I0(in[4]),.I1(in[5]),.S(sel[0]), .Z(mux2_out)),    
                       mux3(.I0(mux1_out), .I1(mux2_out), .S(sel[2]),.Z(mux3_out));
                       
     assign out = mux3_out;
    
endmodule //CkMux6to1 

module ProgrammableDelay (InToDelay, Select, OutDelayed);

    input wire InToDelay;
    input wire [2:0] Select; 
    output wire OutDelayed;

    wire input_int, output_int;
    wire  [5:0] chains_output_int;
   
    assign chains_output_int[0] = InToDelay;
    
    // Delay chain  DEL0
    /*
    DEL0 delay_chain_5_cell1(.I(chains_output_int[0]),.Z(chains_output_int[1]) );
    DEL0 delay_chain_5_cell2(.I(chains_output_int[1]),.Z(chains_output_int[2]) );
    DEL0 delay_chain_5_cell3(.I(chains_output_int[2]),.Z(chains_output_int[3]) );
    DEL0 delay_chain_5_cell4(.I(chains_output_int[3]),.Z(chains_output_int[4]) );
    DEL0 delay_chain_5_cell5(.I(chains_output_int[4]),.Z(chains_output_int[5]) );
    */
    
  
    // Delay chain  DEL0 + DEL01 
    
    wire  [4:0] del0_output_int;
    DEL0 delay_chain_5_cell1(.I(chains_output_int[0]),.Z(del0_output_int[0]) );
    DEL01 delay_chain_5_cell1_1(.I(del0_output_int[0]),.Z(chains_output_int[1]) );
    DEL0 delay_chain_5_cell2(.I(chains_output_int[1]),.Z(del0_output_int[1]) );
    DEL01 delay_chain_5_cell2_1(.I(del0_output_int[1]),.Z(chains_output_int[2]) );
    DEL0 delay_chain_5_cell3(.I(chains_output_int[2]),.Z(del0_output_int[2]) );
    DEL01 delay_chain_5_cell3_1(.I(del0_output_int[2]),.Z(chains_output_int[3]) );
    DEL0 delay_chain_5_cell4(.I(chains_output_int[3]),.Z(del0_output_int[3]) );
    DEL01 delay_chain_5_cell4_1(.I(del0_output_int[3]),.Z(chains_output_int[4]) );
    DEL0 delay_chain_5_cell5(.I(chains_output_int[4]),.Z(del0_output_int[4]) );
    DEL01 delay_chain_5_cell5_1(.I(del0_output_int[4]),.Z(chains_output_int[5]) );
   
      
    // Multiplexer for Delay chains
    CkMux6to1 MuxProgramDelay(.in(chains_output_int[5:0]), .sel(Select), .out(output_int));

    assign OutDelayed = output_int;
		
endmodule

`endif
