

`include "array/CgWrapper.v"


`ifndef PIXEL_LOGIC
`define PIXEL_LOGIC

module T_ff_SN(q, clk, set); 

output reg q;
input wire clk, set;

always @ (negedge clk or posedge set)
    if(set)
        q <= 1'b1;
    else
        q <= !q;

endmodule


module PixelLogic(Clk, Reset, Disc, WriteLe, LeAddr, LE, Read, Data /* sLe, clk_le, */ ); 

input wire Clk, Reset, Disc, LE;
output wire WriteLe;

input wire [`MEM-1:0] Read;
input wire [`MEM-1:0] LeAddr;
output wire [3:0] Data;

wire [3:0] tot_cnt;
reg [2:0] clk_delay;// tot_count (needed one cycle for cnt reset)

wire clk_en;

assign clk_en =  /*Reset |*/ Disc | (|clk_delay) ; //TO THINK

wire clk_gated;
//clk_pos_gating clk_gate_clk( Clk, clk_en, clk_gated);
CG_MOD CG_clk(.ClkIn(Clk), .Enable(clk_en  | LE), .ClkOut(clk_gated));

always @ (posedge clk_gated or posedge Reset) 
begin: shift_delay
    if(Reset)
        clk_delay[2:0] <= 3'b0; 
    else  
        clk_delay[2:0] <= { Disc, clk_delay[2:1] }; 
end

wire write_le_int;
assign write_le_int = clk_delay[1:0] == 2'b10;

wire write_te_int;
assign write_te_int = clk_delay[1:0] == 2'b01;


wire cnt_clk; 
wire cnt_en;
assign cnt_en = (clk_delay[1] & !(tot_cnt == 4'd14));
//assign cnt_clk = (~clk_gated & cnt_en);
CG_MOD CG_cnt_en(.ClkIn(clk_gated), .Enable(cnt_en), .ClkOut(cnt_clk));
    
wire cnt_rst;
assign cnt_rst = clk_delay[2:1] == 2'b10;

T_ff_SN ff0(.q(tot_cnt[0]), .clk(cnt_clk), .set(cnt_rst)); 
T_ff_SN ff1(.q(tot_cnt[1]), .clk(tot_cnt[0]), .set(cnt_rst)); 
T_ff_SN ff2(.q(tot_cnt[2]), .clk(tot_cnt[1]), .set(cnt_rst)); 
T_ff_SN ff3(.q(tot_cnt[3]), .clk(tot_cnt[2]), .set(cnt_rst)); 

assign WriteLe = write_le_int;

wire mem_clk;
assign mem_clk = clk_gated; 
//assign mem_clk  = (!clk_gated & write_te_int) | clk_le;
//wire mem_g_clk;
//CG_MOD_neg CG_mem(.ClkIn(Clk), .Enable(write_te_int | LE),.ClkOut(mem_clk)); 
//assign mem_clk = mem_g_clk | clk_le;

reg [`MEM-1:0] mem_addr;
//wire store_addr;
//assign store_addr = clk_le & WriteLe;

//always @ (store_addr or LeAddr)
//if(store_addr)
//      mem_addr = LeAddr;

always @ (posedge clk_gated)
if(WriteLe)
    mem_addr <= LeAddr;

reg [3:0] tot_mem [`MEM-1:0];

// generate: tot_count
generate
    genvar k;
    for (k=0; k<`MEM; k=k+1)
    begin : mem_tot
      
        wire rst, en;
        assign rst = LeAddr[k] & LE; 
        assign en = mem_addr[k] & write_te_int;
        
        always@(*) begin // latch on neg-level of mem_clk, same en.
            if(!mem_clk) begin
                if(en)
                    tot_mem[k] = tot_cnt; 
                else if(rst & (~write_le_int)) begin 
                    tot_mem[k] = 4'd15; //NO HIT
                end
            end
        end
    end : mem_tot
endgenerate 

//wire mem_clk;
//assign mem_clk  = (!clk_gated & write_te_int) | clk_le;


/*generate
    genvar k;
    for (k=0; k<`MEM; k=k+1)
    begin : mem_tot

        wire rst, en;
        assign rst = LeAddr[k] & LE; 
        assign en = mem_addr[k] & write_te_int;
        
        reg [3:0] store_data;
        
        always@(*) begin
            if(!mem_clk) begin
                if(en)
                    tot_mem[k] = tot_in[k];
                else if(rst) begin
                        tot_mem[k] = 4'd0; //NO HIT
                end
            end
        end

    end
endgenerate */

wire [3:0] mem_out [`MEM-1:0];

generate
    genvar m;
    for (m=0; m<`MEM; m=m+1)
    begin : out_data
        if( m==0 )
            assign mem_out[m] = tot_mem[m] & {4{Read[m]}};
        else
            assign mem_out[m] = ( tot_mem[m] & {4{Read[m]}} ) | mem_out[m-1];
    end
endgenerate 

assign Data = mem_out[`MEM-1];

endmodule //PixelLogic
    
  
`endif
