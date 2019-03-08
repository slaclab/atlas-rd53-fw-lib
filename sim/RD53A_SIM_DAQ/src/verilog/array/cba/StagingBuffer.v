`include "array/interfaces/CoreCBAIf.sv"

module StagingBuffer (
    input wire clk,
    input wire reset,
    input wire [`CBA_SG_LATENCY_BITS-1:0] WriteSyncTime,
    input wire [15:0] imap,
    output wire [15:0] omap,
    output logic write
);

// Clock gating
reg [0:`CBA_SG_DEPTH-1] sblclk  ; // Latch Clocks
reg [0:`CBA_SG_DEPTH-1] sbcclk  ; // FF Clocks
reg [0:`CBA_SG_DEPTH-1] sblclk_en   ; // Latch Clock Enables
reg [0:`CBA_SG_DEPTH-1] sbcclk_en   ; // FF Clock Enables

// Data
reg [`CBA_REG_PIXELS-1:0] sbhm [0:`CBA_SG_DEPTH-1]; // Hit Map Latches
reg [`CBA_SG_LATENCY_BITS-1:0] sbc  [0:`CBA_SG_DEPTH-1]; // Counters
wire [`CBA_SG_LATENCY_BITS-1:0] sbcn [0:`CBA_SG_DEPTH-1]; // Counters next value

// Flags
wire [0:`CBA_SG_DEPTH-1] sbcf; // Line is full
wire [0:`CBA_SG_DEPTH-1] sbcod; // Line is selected for output

// Output mux
wire [0:`CBA_SG_DEPTH] [`CBA_REG_PIXELS-1:0] omap_or;
assign omap_or[0] = 'b0;

reg any;
assign any = (| imap);

// Row selection
`ifdef CBA_SG_COUNTER
reg [`CBA_SG_DEPTH_LOG2-1:0] cnt;
wire [`CBA_SG_DEPTH_LOG2-1:0] cnt_n = cnt + {`CBA_SG_DEPTH_LOG2-1 {1'b0}, 1'b1};

always @(posedge clk or posedge reset)
    if(reset == 1'b1)
        cnt <= 0;
    else if (any == 1'b1)
        cnt <= cnt_n;

`else
wire [`CBA_SG_DEPTH-1:0] cnt_oh;

generate
    genvar m;
    for (m=0; m<`CBA_SG_DEPTH; m=m+1)
    begin : addr_dec
        if( m==0 )
            assign cnt_oh[m] = ~sbcf[m];
        else
            assign cnt_oh[m] = ~sbcf[m] & (& sbcf[0:m-1] );
    end
endgenerate

`endif

generate
    genvar w, b;
    for(w=0;w<`CBA_SG_DEPTH;w++) begin

		// Combinational
        assign sbcod[w] = (sbc[w] == ({{`CBA_SG_LATENCY_BITS-1 {1'b0}}, 1'b1})) ? 1'b1 : 1'b0;   // 2nd last: data out
        assign sbcf[w] = (sbc[w] == {`CBA_SG_LATENCY_BITS {1'b0}}) ? 1'b0 : 1'b1;				// Last: reset
        assign omap_or[w+1] = ((sbcod[w] == 1'b1) ? sbhm[w] : 'b0) | omap_or[w];

        // Clock gating enable signals
`ifdef CBA_SG_COUNTER
        assign sblclk_en[w] = (any == 1'b1 && cnt == w);
`else
        assign sblclk_en[w] = (any == 1'b1 && cnt_oh[w] == 1'b1);
`endif
        assign sbcclk_en[w] = sblclk_en[w] | sbcf[w];

        // Clock gating
        assign sbcclk[w] = ~clk & sbcclk_en[w];
        assign sblclk[w] = sbcclk[w] & sblclk_en[w];
        
        // Hit Map Latches
        always @(*) if(sblclk[w] == 1'b1)
            sbhm[w] <= imap;
		
        //always @(posedge sblclk[w])
        //    sbhm[w] <= imap;

        // Counters
        assign sbcn[w] = (sbcf[w]) ? sbc[w] - {{`CBA_SG_LATENCY_BITS-1 {1'b0}}, 1'b1} : WriteSyncTime;

        always @(negedge sbcclk[w] or posedge reset) 
            if(reset == 1'b1)
                sbc[w] <= 'b0;
            else
                sbc[w] <= sbcn[w];

    end
endgenerate

// Mux
assign omap = omap_or[`CBA_SG_DEPTH];

// Output data valid
assign write = (| sbcod);

// Synthesizer will remove this
wire buffer_full = (& sbcclk_en);

endmodule
