module CkMux4to1_eoc (in, sel, out);
    input wire [3:0] in;
    input wire [1:0] sel;
    output wire out;
    
    wire mux1_out, mux2_out, mux3_out;
    //wire [1:0] sel_buff;
    //BUFFD16 buffs0 (.I(sel[0]), .Z(sel_buff[0]));
    //BUFFD16 buffs1 (.I(sel[1]), .Z(sel_buff[1]));
    CKMUX2D4 mux1(.I0(in[0]),.I1(in[1]),.S(sel[0] /*sel_buff[0]*/), .Z(mux1_out)),
                       mux2(.I0(in[2]),.I1(in[3]), .S(sel[0] /*sel_buff[0]*/), .Z(mux2_out)),
                       mux3(.I0(mux1_out), .I1(mux2_out), .S(sel[1]/*sel_buff[1]*/),.Z(mux3_out));
                       
     assign out = mux3_out;
    
endmodule //CkMux4to1_eoc 

module CkMux16to1 (in, sel, out);
    input wire [15:0] in;
    input wire [3:0] sel;
    output wire out;
    
    wire mux1_out, mux2_out, mux3_out, mux4_out, mux5_out;
    //wire [3:0] sel_buff;
    
    //BUFFD16 buffs0 (.I(sel[0]), .Z(sel_buff[0]));
    //BUFFD16 buffs1 (.I(sel[1]), .Z(sel_buff[1]));
    //BUFFD16 buffs2 (.I(sel[2]), .Z(sel_buff[2]));
    //BUFFD16 buffs3 (.I(sel[3]), .Z(sel_buff[3]));
    
    CkMux4to1_eoc mux1(.in(in[3:0]),.sel(sel[1:0] /*sel_buff[1:0]*/), .out(mux1_out));
    CkMux4to1_eoc mux2(.in(in[7:4]),.sel(sel[1:0] /*sel_buff[1:0]*/), .out(mux2_out));
    CkMux4to1_eoc mux3(.in(in[11:8]),.sel(sel[1:0] /*sel_buff[1:0]*/), .out(mux3_out));
    CkMux4to1_eoc mux4(.in(in[15:12]),.sel(sel[1:0] /*sel_buff[1:0]*/), .out(mux4_out));   
    
    // Second multiplexing stage
    CkMux4to1_eoc mux5(.in({mux4_out, mux3_out, mux2_out, mux1_out}),.sel(sel[3:2]), .out(mux5_out));                   
    assign out = mux5_out;
    
endmodule //CkMux16to1 


module CmdClkPhaseDelayHardCoded (
    // Input clocks
    input wire CdrCmdClk, CdrDelClk,
    // Clock Phase selection signal
    input wire SelClkPhase,
    // Clock fine delay selection signal
    input wire [3:0] ClkFineDelay, 
   
    // Output 160MHz clock after phase shift and/or fine delay 
    output wire Clk160
    
    );
    
    wire CdrCmdClk_b, CdrCmdClkPhased ;
    wire [15:0] DlyClk                ; // 160 MHz clock delay line
    
    CKND8 InvertCdrCmdClkPhase(.I(CdrCmdClk), .ZN(CdrCmdClk_b));
    wire sel_clk_phase_buff;
    BUFFD16 buff_sel_clk (.I(SelClkPhase), .Z(sel_clk_phase_buff));
    CKMUX2D4 CdrCmdClkPhased_mux(.I0(CdrCmdClk),.I1(CdrCmdClk_b),.S(sel_clk_phase_buff), .Z(CdrCmdClkPhased));
    
    //
    // CmdClk delay
    //
    assign DlyClk[0] = CdrCmdClkPhased ;
    
    generate 
        genvar ff;
        for (ff=0; ff<15; ff=ff+1) begin: fine_delay
        
            DFQD4 ShiftReg (.D(DlyClk[ff]), .CP(CdrDelClk), .Q(DlyClk[ff+1]));
        
        end 
    endgenerate
    wire [3:0] clk_fine_delay_buff;
    BUFFD16 buff_fine_delay0 (.I(ClkFineDelay[0]), .Z(clk_fine_delay_buff[0]));
    BUFFD16 buff_fine_delay1 (.I(ClkFineDelay[1]), .Z(clk_fine_delay_buff[1]));
    BUFFD16 buff_fine_delay2 (.I(ClkFineDelay[2]), .Z(clk_fine_delay_buff[2]));
    BUFFD16 buff_fine_delay3 (.I(ClkFineDelay[3]), .Z(clk_fine_delay_buff[3]));    
    CkMux16to1 mux16to1(.in(DlyClk[15:0]),.sel(clk_fine_delay_buff), .out(Clk160));
    
endmodule //CmdClkPhaseDelayHardCoded 