//Verilog fot top cell block oscill
//This module will be used for cern - RD53a


//Createded on 5 mar 2017 by maurice c.-s.

module ringosc_counter4b (	Reset,
				Clk,
				Count				
						 );
                         
 timeunit 100ps;
 timeprecision 1ps;

input 		Reset;
input 		Clk;

output [3:0]	Count;

//*************************************	Declaration
reg [3:0]	tmp;
//*************************************	Code start here

assign Count = tmp;

always @(posedge Clk or posedge Reset)
		if (Reset)
		begin
		tmp <= 4'b0000;
		end
		
				else 	if (tmp == 4'b1111)
				begin
				tmp <= tmp;
		end
	
				else 	begin
				tmp <= tmp + 1'b1;
		end
				endmodule

				
module ringosc_counter12b (	Reset,
				Clk_osc,
				Count				
						  );

input 		Reset;
input 		Clk_osc;

output [11:0]	Count;

//*************************************	Declaration
reg [11:0]	tmp;
//*************************************	Code start here

assign Count = tmp;

always @(posedge Clk_osc or posedge Reset)
		if (Reset)
		begin
		tmp <= 12'b000000000000;
		end
		
				else 	if (tmp == 12'b111111111111)
				begin
				tmp <= tmp;
		end
	
				else 	begin
				tmp <= tmp + 1'b1;
		end
				endmodule

				
module ringosc_counters12b_4b (	Reset,
				Clk,
				Clk_osc,
				Count				
							  );

input 		Reset;
input 		Clk;
input 		Clk_osc;

output [15:0]	Count;

//*************************************	Declaration
wire [3:0]	Count_4b;
wire [11:0]	Count_12b;
//*************************************	Code start here


assign Count[15:12]= Count_4b;
assign Count[11:0] = Count_12b;

// Instantiation of counter 4 bits with Clk
ringosc_counter4b ringosc_counter_4b_inst (Reset,Clk,Count_4b);

// Instantiation of counter 12 bits with Clk_osc
ringosc_counter12b ringosc_counter_12b_inst (Reset,Clk_osc,Count_12b);


endmodule


module RD53_RINGOSC_LAL (
   count_cknd0,
   count_cknd4, 
   count_invd0,
   count_invd4,
   count_nand0,
   count_nand4, 
   count_nord0,
   count_nord4,
   en_cknd0,
   en_cknd4, 
   en_invd0,
   en_invd4, 
   en_nand0,
   en_nand4, 
   en_nord0,
   en_nord4,
   reset,
   start_stopN,
   GND, VDD, VSUB ) ;


input 		reset;
input 		start_stopN;
input				en_cknd0, en_cknd4; 
input				en_invd0, en_invd4;
input				en_nand0, en_nand4;			
input				en_nord0, en_nord4;

output [15:0]	count_cknd0, count_cknd4;
output [15:0]	count_invd0, count_invd4;
output [15:0]	count_nand0, count_nand4;
output [15:0]	count_nord0, count_nord4;

inout wire VDD;
inout wire GND;
inout wire VSUB;

//*************************************	Declaration de fils
wire [3:0]	Count_4b_cknd0;
wire [11:0]	Count_12b_cknd0;
wire [3:0]	Count_4b_cknd4;
wire [11:0]	Count_12b_cknd4;
wire [3:0]	Count_4b_invd0;
wire [11:0]	Count_12b_invd0;
wire [3:0]	Count_4b_invd4;
wire [11:0]	Count_12b_invd4;
wire [3:0]	Count_4b_nand0;
wire [11:0]	Count_12b_nand0;
wire [3:0]	Count_4b_nand4;
wire [11:0]	Count_12b_nand4;
wire [3:0]	Count_4b_nord0;
wire [11:0]	Count_12b_nord0;
wire [3:0]	Count_4b_nord4;
wire [11:0]	Count_12b_nord4;

wire rc0, rc4, ri0, ri4, rnd0, rnd4, rno0, rno4;

// **********  oscillations
// **** un seul regitre suffit car quasi meme priode oscillation
reg lk0;

wire Clkp0, Clkp4, Clkip0, Clkip4, Clkdp0, Clkdp4, Clkop0, Clkop4;

// ******oscillations (lk0) dclanches b(start) et valides (en)

assign Clk0= start_stopN  & lk0 & en_cknd0;
assign Clk4= start_stopN  & lk0 & en_cknd4;
assign Clki0= start_stopN  & lk0 & en_invd0;
assign Clki4= start_stopN  & lk0 & en_invd4;
assign Clkd0= start_stopN & lk0 & en_nand0;
assign Clkd4= start_stopN & lk0 & en_nand4;
assign Clko0= start_stopN & lk0 & en_nord0;
assign Clko4= start_stopN & lk0 & en_nord4;


// ********** count pulses

assign Clkp0= start_stopN  & en_cknd0;
assign Clkp4= start_stopN  & en_cknd4;
assign Clkip0= start_stopN  & en_invd0;
assign Clkip4= start_stopN  & en_invd4;
assign Clkdp0= start_stopN & en_nand0;
assign Clkdp4= start_stopN & en_nand4;
assign Clkop0= start_stopN & en_nord0;
assign Clkop4= start_stopN & en_nord4;

// ********** les resets

assign rc0 = reset & en_cknd0;
assign rc4 = reset  & en_cknd4;
assign ri0 = reset  & en_invd0;
assign ri4 = reset  & en_invd4;
assign rnd0 = reset  & en_nand0;
assign rnd4 = reset  & en_nand4;
assign rno0 = reset  & en_nord0;
assign rno4 = reset  & en_nord4;

//*************************************	Code start here


assign  count_cknd0[15:12] = Count_4b_cknd0;
assign count_cknd4[15:12]= Count_4b_cknd4;
assign count_invd0[15:12] = Count_4b_invd0;
assign count_invd4[15:12] = Count_4b_invd4;
assign count_nand0[15:12] = Count_4b_nand0;
assign count_nand4[15:12]=Count_4b_nand4;
assign count_nord0[15:12]= Count_4b_nord0;
assign count_nord4[15:12]= Count_4b_nord4;

assign  count_cknd0[11:0] = Count_12b_cknd0;
assign count_cknd4[11:0]= Count_12b_cknd4;
assign count_invd0[11:0] = Count_12b_invd0;
assign count_invd4[11:0] = Count_12b_invd4;
assign count_nand0[11:0] = Count_12b_nand0;
assign count_nand4[11:0]=Count_12b_nand4;
assign count_nord0[11:0]= Count_12b_nord0;
assign count_nord4[11:0]= Count_12b_nord4;



// Instantiation of counters 12b_4b
ringosc_counters12b_4b ringosc_counters_ckn0 (.Reset(rc0),.Clk(Clkp0),.Clk_osc(Clk0),.Count(count_cknd0));
ringosc_counters12b_4b ringosc_counters_ckn4 (.Reset(rc4),.Clk(Clkp4),.Clk_osc(Clk4),.Count(count_cknd4));
ringosc_counters12b_4b ringosc_counters_inv0 (.Reset(ri0),.Clk(Clkip0),.Clk_osc(Clki0),.Count(count_invd0));
ringosc_counters12b_4b ringosc_counters_inv4 (.Reset(ri4),.Clk(Clkip4),.Clk_osc(Clki4),.Count(count_invd4));
ringosc_counters12b_4b ringosc_counters_nand0 (.Reset(rnd0),.Clk(Clkdp0),.Clk_osc(Clkd0),.Count(count_nand0));
ringosc_counters12b_4b ringosc_counters_nand4 (.Reset(rnd4),.Clk(Clkdp4),.Clk_osc(Clkd4),.Count(count_nand4));
ringosc_counters12b_4b ringosc_counters_nor0 (.Reset(rno0),.Clk(Clkop0),.Clk_osc(Clko0),.Count(count_nord0));
ringosc_counters12b_4b ringosc_counters_nor4 (.Reset(rno4),.Clk(Clkop4),.Clk_osc(Clko4),.Count(count_nord4));



// Instantiation of counters 12 bits with Clk_osc
// ********clock fromn oscillators


 

// **********on y va  : 
initial 
  begin 
    
    lk0=0; 
 // non c'est une entree   reset = 0; 
  end 

  always 
    	#5 lk0 = !lk0; 
	
//** c'est dans le test bunch :initial begin reset=1;#50 reset=0;#900000 $stop;end    


endmodule
