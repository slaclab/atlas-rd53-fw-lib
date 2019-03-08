
`default_nettype wire

module eoc_mem_fifo  #(parameter DSIZE = 20, parameter ASIZE = 8) 
                    (
                    input logic reset, clk, en_wr, en_rd, 
                    input [DSIZE-1:0] in_data, 
                    output logic [DSIZE-1:0] out_data,
                    output logic full, 
                    output logic empty,
                    output logic [ASIZE-1:0] size
                    );

logic [ASIZE-1:0] wr_pnt, rd_pnt, rd_pnt_next, wr_pnt_next, wr_pnt_next_next;

localparam DEPTH = 1<<ASIZE;
logic [DSIZE-1:0] fifo_buffer [0:DEPTH-1];

logic next_wr, next_rd;
assign next_wr = (en_wr && !full);
assign next_rd = (en_rd && !empty);

assign rd_pnt_next = next_rd ? rd_pnt + 1 : rd_pnt;
assign wr_pnt_next = next_wr ? wr_pnt + 1 : wr_pnt;

logic reset_ff;
always@(posedge clk)
    reset_ff <= reset;
                    
// synopsys sync_set_reset "reset_ff"
    
always_ff@(posedge clk) begin
    if(reset_ff)
        wr_pnt <= '0;
    else if(next_wr)
        wr_pnt <= wr_pnt + 1;
end

always_ff@(posedge clk) begin
  if(next_wr) 
      fifo_buffer[wr_pnt] <= in_data;
end

always_ff@(posedge clk) begin
    if(reset_ff)
        rd_pnt <= '0;
    else if(next_rd)
        rd_pnt <= rd_pnt + 1;
end

assign wr_pnt_next_next = wr_pnt_next+1;
always_ff@(posedge clk)
    if(reset_ff)
        full <= 0;
    else
        full <= (wr_pnt_next_next == rd_pnt_next);

always_ff@(posedge clk)
    if(reset_ff)
        empty <= 1;
    else
        empty <= (wr_pnt == rd_pnt_next);

always_ff@(posedge clk)
    out_data <= fifo_buffer[rd_pnt_next];
    
    
always_ff@(posedge clk)
    size <= wr_pnt_next - rd_pnt_next;

endmodule

module  eoc_tree_fifo #(parameter COL_DSIZE = 3) (
        input logic reset, clk,
        input logic [4:0] trigger_id_req,
        input logic [3:0][9:0] row,
        input logic [3:0][4:0] trigger_id,
        input logic [3:0][COL_DSIZE-1:0] col,
        input logic [3:0][15:0] value,

        input logic [3:0] token_in,
        output logic [3:0] read_ready_in,

        output logic token_out,
        input logic read_out,
        output logic [9:0] row_out,
        output logic [COL_DSIZE-1:0] col_out,
        output logic [15:0] data_out,
        output logic [1:0] size

    );

    logic read_in;
    logic [1:0] fifo_to_read;
    logic fifo_full;
    
    logic [4:0] trigger_id_req_ff;
    always_ff@(posedge clk) 
        trigger_id_req_ff <= trigger_id_req;
    //assign trigger_id_req_ff = trigger_id_req;

    logic [3:0] trigger_id_match, trigger_id_match_token;
    always_comb begin
        for(int m=0; m<4; m=m+1)
            trigger_id_match[m] = (trigger_id[m] == trigger_id_req_ff);
    end
    
    assign trigger_id_match_token  = trigger_id_match & token_in;
    
    always_comb begin
    //always_ff@(posedge clk) begin
        read_in = |trigger_id_match_token && !fifo_full;
        for(int k=0; k<4; k=k+1)
            read_ready_in[k] = (k == fifo_to_read) ? read_in : 1'b0;
    end

    integer i;
    always_comb begin
    //always_ff@(posedge clk) begin
        fifo_to_read = 3;
        i = 3;
        while(i>=0 & trigger_id_match_token[i]==0) begin
                fifo_to_read = i-1;
                i = i -1;
        end
    end

    localparam DSIZE = COL_DSIZE+10+16;
    logic[DSIZE-1:0] data_fifo_out;
        
    eoc_mem_fifo #(.DSIZE(DSIZE), .ASIZE(2)) fifo
    (
        .reset(reset), .clk(clk), .en_wr(read_in), .en_rd(read_out), 
        .in_data({col[fifo_to_read],row[fifo_to_read],value[fifo_to_read]}), 
        .out_data(data_fifo_out),
        .full(fifo_full), 
        .empty(fifo_empty),
        .size(size)
    );
    
    always_comb begin
    //always_ff@(posedge clk) begin
        token_out = !fifo_empty;
        col_out = data_fifo_out[DSIZE-1:26];
        row_out = data_fifo_out[25:16];
        data_out = data_fifo_out[15:0];
    end 
    
endmodule

module DataConcentrator(
        input logic ClkIn, ClkOut, Reset,
        input logic [49:0] Write,
        input logic [49:0][15:0] DataIn,
        input logic [49:0][4:0] TriggerId,
        input logic [49:0][9:0] RowId,
        output logic [49:0] Full,

        input logic TriggerCmd40,
        input logic [15:0] BCIDCnt,
        input logic [5:0] TriggerIdGlobal,
        input logic [5:0] TriggerIdCurrentReq,
        input logic [4:0] TriggerTag,
        input logic TriggerAccept,

        input logic DstReady,
        output logic SrcReady,
        output logic [31:0] Data,
        output logic Sof, Eof

    );

    localparam CH_NUM = 64;

    logic reset_local;
    always@(posedge ClkOut)
        reset_local <= Reset;
    
    // synopsys sync_set_reset "reset_local"
    
    logic [CH_NUM-1:0][9:0] fifo_row;
    logic [CH_NUM-1:0][15:0] fifo_data;
    logic [CH_NUM-1:0][4:0] fifo_trigger_id;
    logic [CH_NUM-1:0][1:0] fifo_col;
    logic [CH_NUM-1:0] fifo_empty;
    logic [CH_NUM-1:0] read_ready_eoc;

    logic [15:0] token_level1, read_level1;
    logic [15:0][15:0] data_leve1;
    logic [15:0][9:0] row_leve1;
    logic [15:0][1:0] col_leve1;
    
    logic [15:0][3:0] col_leve2_in;
    
    logic [3:0] token_level2, read_level2;
    logic [3:0][15:0] data_level2;
    logic [3:0][9:0] row_leve12;
    logic [3:0][3:0] col_leve12;
    
    
    logic [5:0] trigger_id_req;
    
    logic [15:0][4:0] trigger_id_req_dist;

    always_ff@(posedge ClkOut)
        trigger_id_req_dist <= {16{trigger_id_req[4:0]}};
        
    logic [15:0] reset_dist;
    always_ff@(posedge ClkOut)
        reset_dist <= {16{reset_local}};
    
    logic [3:0] reset_dist_l2;
    always_ff@(posedge ClkOut)
        reset_dist_l2 <= {4{reset_local}};
        
    genvar k;
    generate
        for (k=0; k<CH_NUM; k=k+1) begin : tree_gen

            wire [30:0] data_fifo_out; // check if fine for additional bit on Trigger Id

            
            if(k < 50) begin: fifo_gen_l1
                
                logic [1:0] write_sync;
                logic write_fifo;
               
                logic write_in;
                logic [30:0] data_in_buf, data_in; // check if fine for additional bit on Trigger Id
                always_ff@(posedge ClkIn) begin
                    if(Write[k])
                        data_in_buf <= {TriggerId[k], RowId[k], DataIn[k]};
                end
                
                
                always_ff@(posedge ClkIn) begin
                    write_in <= Write[k];
                end
                                
                
                always_ff@(posedge ClkOut) begin
                    write_sync[1:0] <= {write_sync[0],write_in};
                    data_in <= data_in_buf;
                end
                
                assign write_fifo = (write_sync == 2'b01);
                    
                eoc_mem_fifo #(.DSIZE(31), .ASIZE(4)) mem_fifo 
                (
                    .reset(reset_dist[k/4]), .clk(ClkOut), .en_wr(write_fifo), .en_rd(read_ready_eoc[k]), 
                    .in_data(data_in), 
                    .out_data(data_fifo_out),
                    .full(Full[k]), 
                    .empty(fifo_empty[k])
                );
                
                assign fifo_trigger_id[k] = data_fifo_out[30:26]; 
                assign fifo_row[k] = data_fifo_out[25:16];
                assign fifo_data[k] = data_fifo_out[15:0];
                assign fifo_col[k] = 2'(k);
            end
            else begin
                assign fifo_empty[k] = 1;
                assign fifo_trigger_id[k] = 0; 
                assign fifo_row[k] = 0;
                assign fifo_data[k] = 0;
                assign fifo_col[k] = 0;
                
            end

            if(k%4==0) begin : eoc_gen_l1
            
                eoc_tree_fifo #(.COL_DSIZE(2)) tree_fifo_l1_inst(
                    .reset(reset_dist[k/4]), .clk(ClkOut),
                    .trigger_id_req(trigger_id_req_dist[k/4]),
                    .row(fifo_row[3+k:k]),
                    .trigger_id(fifo_trigger_id[3+k:k]),
                    .col(fifo_col[3+k:k]),
                    .value(fifo_data[3+k:k]),
                    .read_ready_in(read_ready_eoc[3+k:k]),
                    .token_in(~fifo_empty[3+k:k]),

                    .token_out(token_level1[k/4]),
                    .read_out(read_level1[k/4]),
                    .row_out(row_leve1[k/4]),
                    .col_out(col_leve1[k/4]),
                    .data_out(data_leve1[k/4])
                );

            end

            if(k%16==0) begin : eoc_gen_l2
            
 
                eoc_tree_fifo #(.COL_DSIZE(4)) tree_fifo_l1_inst(
                    .reset(reset_dist_l2[k/16]), .clk(ClkOut),
                    .trigger_id_req(5'b0),
                    .row(row_leve1[3+k/4:k/4]),
                    .trigger_id({4{5'b0}}),
                    .col({col_leve2_in[3+k/4:k/4]}),
                    .value(data_leve1[3+k/4:k/4]),
                    .read_ready_in(read_level1[3+k/4:k/4]),
                    .token_in(token_level1[3+k/4:k/4]),

                    .token_out(token_level2[k/16]),
                    .read_out(read_level2[k/16]),
                    .row_out(row_leve12[k/16]),
                    .col_out(col_leve12[k/16]),
                    .data_out(data_level2[k/16])
                );

            end

        end
    endgenerate
    
    always_comb begin
        for(int i = 0; i < 16; i=i+1) begin
            col_leve2_in[i] = {2'(i), col_leve1[i]};
        end
    end

    
    logic [3:0][5:0] fifo_l2_col;
    always_comb begin
        for(int i = 0; i < 4; i=i+1) begin
            fifo_l2_col[i] = {2'(i), col_leve12[i]};
        end
    end

    logic token_out;
    logic read_out;
    logic [15:0] data_out;
    logic [9:0] row_out;
    logic [5:0] column_out;
         
    logic [1:0] top_fifo_size;
    eoc_tree_fifo #(.COL_DSIZE(6)) tree_fifo_top_inst(
        .reset(reset_local), .clk(ClkOut),
        .trigger_id_req(5'b0),
        .row(row_leve12),
        .trigger_id({4{5'b0}}),
        .col(fifo_l2_col),
        .value(data_level2),
        .read_ready_in(read_level2),
        .token_in(token_level2),

        .token_out(token_out),
        .read_out(read_out),
        .data_out(data_out),
        .row_out(row_out),
        .col_out(column_out),
        .size(top_fifo_size)
    );

    enum {IDLE, DATA, HEADER, HERADR_EOF} state, next_state;
    
    logic trigger;
    always@(posedge ClkIn)
        trigger <= TriggerCmd40;
    
    logic trigger_accept;
    always@(posedge ClkIn)
        trigger_accept <= TriggerAccept;
    
    logic [3:0] reg_trigger_inc_dealy;
    
    logic next_trigger_empty;
    assign next_trigger_empty = !token_out && top_fifo_size == 0 && (TriggerIdCurrentReq != trigger_id_req) && reg_trigger_inc_dealy > 7;
    assign last_data = token_out && top_fifo_size == 1 && (TriggerIdCurrentReq != trigger_id_req) && reg_trigger_inc_dealy > 7;
        
    logic wait_for_eof;
    assign wait_for_eof = (top_fifo_size == 1  && TriggerIdCurrentReq == trigger_id_req);
    
    logic inc_trigger_id_req;
    assign inc_trigger_id_req = (TriggerIdCurrentReq != trigger_id_req) && ((state == DATA && last_data && DstReady ) || (state==HERADR_EOF && DstReady)) && reg_trigger_inc_dealy > 7;
    always_ff@(posedge ClkOut)
        if(reset_local)
            trigger_id_req <= 0;
        else if(inc_trigger_id_req)
            trigger_id_req <= trigger_id_req + 1;

    always_ff@(posedge ClkOut)
        if(reset_local || inc_trigger_id_req)
            reg_trigger_inc_dealy <= 0;
        else if(reg_trigger_inc_dealy != 4'hf)
            reg_trigger_inc_dealy <= reg_trigger_inc_dealy + 1;  
    
    logic [14:0] bcid_cnt;
    always_ff@(posedge ClkIn)
         bcid_cnt <= BCIDCnt[14:0];

    reg [24:0] bcid_trig_mem [63:0];

    always_ff@(posedge ClkIn)
        if(trigger & trigger_accept)
            bcid_trig_mem[TriggerIdGlobal] <= {TriggerIdGlobal[4:0], TriggerTag, bcid_cnt};

    always_ff@(posedge ClkOut)
        if(reset_local)
            state <= IDLE;
        else
            state <= next_state;

    always_comb begin : set_next_state
        next_state = state; //default
        case (state)
            IDLE:
                if(next_trigger_empty)
                    next_state = HERADR_EOF;
                else if(token_out)
                    next_state = HEADER;
            HERADR_EOF:
                if(DstReady)
                    next_state = IDLE;
            HEADER:
                if(DstReady)
                    next_state = DATA;
            DATA:
                if(last_data & DstReady)
                    next_state = IDLE;
        endcase
    end

    assign SrcReady = ((state == HERADR_EOF  || state == HEADER) && DstReady) || read_out ;
    assign Sof = (state == HERADR_EOF || state == HEADER);
    assign Eof = (state == HERADR_EOF || (state == DATA & last_data));
    assign read_out = DstReady & state == DATA & token_out & !wait_for_eof;
    
    logic [31:0] pixel_data;
    //always_ff@(posedge ClkOut)
        //if(read_out)
    assign pixel_data = {column_out, row_out, data_out};

    always_comb begin
        if(state == HERADR_EOF)
            Data = {7'b1, bcid_trig_mem[trigger_id_req]};
        else if(state == HEADER)
            Data = {7'b1, bcid_trig_mem[trigger_id_req]};
        else
            Data = pixel_data;
     end


endmodule