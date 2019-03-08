//timescale 1ns/10ps

`define BUF_DEPTH 16
`define BUF_DEPTH_BITS 4

module OutputAdapter (
    input Clk,
    input Reset, // active high

    input [`CBA_ROW_BITS-1:0] RowIdIn,
    input DataReadyIn,
    input [`CBA_DATA_BITS-1:0] DataIn,

    output logic [9:0] RowIdOut,
    output logic DataReadyOut,
    output logic [15:0] DataOut,
    output logic Busy

);

/*
 * Buffer Management
 */
logic [`CBA_DATA_BITS-1:0] data_buf [0:`BUF_DEPTH-1];
logic [`CBA_ROW_BITS-1:0] row_buf [0:`BUF_DEPTH-1];

logic [`BUF_DEPTH_BITS:0] buf_read_ext;
logic [`BUF_DEPTH_BITS:0] buf_write_ext;

wire [`BUF_DEPTH_BITS-1:0] buf_write = buf_write_ext[`BUF_DEPTH_BITS-1:0];
wire [`BUF_DEPTH_BITS-1:0] buf_read = buf_read_ext[`BUF_DEPTH_BITS-1:0];

wire buf_full, buf_empty;
logic buf_read_incr;
wire buf_write_incr = ~buf_full && DataReadyIn;

// TMR may be needed here!
wire [`BUF_DEPTH_BITS:0] rp1 = buf_read_ext+1;
wire wrm1 = (buf_write_ext == rp1);
reg buf_empty_sync;
always @(posedge Clk)
	if(buf_read_incr || buf_write_incr || Reset)
		buf_empty_sync <= Reset || (wrm1 && buf_read_incr && ~buf_write_incr);

//assign buf_empty = buf_write_ext == buf_read_ext;
assign buf_empty = buf_empty_sync;

assign buf_full = buf_write_ext[`BUF_DEPTH_BITS] != buf_read_ext[`BUF_DEPTH_BITS] &&
    buf_write == buf_read;


// Memory and Write Addr FFs
always @(posedge Clk) begin
    if (Reset) begin
//      data_buf <= {`BUF_DEPTH {`CBA_DATA_BITS'b0}};
//      row_buf <= {`BUF_DEPTH {`CBA_ROW_BITS'b0}};

        buf_write_ext <= 0;

    end else if(buf_write_incr) begin
        data_buf[buf_write] <= DataIn;
        row_buf[buf_write] <= RowIdIn;
        
        buf_write_ext <= buf_write_ext + 1;
    end
end

// Read FFs
always @(posedge Clk)
    if (Reset)
        buf_read_ext <= 'b0;
    else if (buf_read_incr)
        buf_read_ext <= buf_read_ext + 1;

/*
 * Output Translation into matrix
 */

wire [`CBA_DATA_BITS-1:0] current_line = data_buf[buf_read];
wire [`CBA_ROW_BITS-1:0] current_row = row_buf[buf_read];

logic [`CBA_REG_PIXELS-1:0] [`CBA_TOT_BITS-1:0] current_data;

localparam int order [`CBA_REG_PIXELS] = `CBA_PIX_ORDER;

// behavioral?
integer tr_pixel, tr_slot;
always @(current_line) begin
    tr_slot = 0;
    
    // ToT encoding: 4'b1111 equals 0
    current_data = {`CBA_REG_PIXELS*`CBA_TOT_BITS {1'b1}};

//  $display("Updated. current: %x", current_line);

    for(tr_pixel=0;tr_pixel<`CBA_REG_PIXELS;tr_pixel++) begin

        if(current_line[tr_pixel+`CBA_TOT_SLOTS*`CBA_TOT_BITS]) begin
//          $display("Pixel %d in slot %d hit w/ value %d", tr_pixel, tr_slot, current_line[(tr_slot+1)*`CBA_TOT_BITS-1-:`CBA_TOT_BITS]);

            // Missing TOT has to be mapped as 0xE.
            current_data[order[tr_pixel]] = (tr_slot < `CBA_TOT_SLOTS) ? current_line[(tr_slot+1)*`CBA_TOT_BITS-1-:`CBA_TOT_BITS] : 4'b1110;
            tr_slot = tr_slot + 1;

        end
//      else begin
//          $display("Pixel %d not hit", tr_pixel);
//
//      end
    end
end



// FSM State Update
//enum {ROW0, ROW1, ROW2, ROW3, IDLE, CONT} fsm_state, fsm_next;
enum {ROW0, INC0, ROW1, INC1, ROW2, INC2, ROW3, INC3, IDLE, CONT} fsm_state, fsm_next;

always @(posedge Clk) begin
    if (Reset)
        fsm_state <= IDLE;
    else
        fsm_state <= fsm_next;
end

// not empty means there's at least a 0
wire row0empty = (& (& current_data[3 -: 4]));
wire row1empty = (& (& current_data[7 -: 4]));
wire row2empty = (& (& current_data[11 -: 4]));
wire row3empty = (& (& current_data[15 -: 4]));

//            Refactoring
//
//       4X4               2X8
//
// +------+------+   +------+------+
// |   0  |   1  |   |   0      1  |
// |   2  |   3  |   |   2      3  |
// |   4  |   5  |   +------+------+
// |   6  |   7  |   |   4      5  |
// +------+------+   |   6      7  |
// |   8  |   9  |   +------+------+
// |  10  |  11  |   |   8      9  |
// |  12  |  13  |   |  10     11  |
// |  14  |  15  |   +------+------+
// +------+------+   |  12     13  |
//                   |  14     15  |  
//                   +------+------+

`ifdef CBA_2X8
    localparam [3:0] region_mapper [0:15] = {
        4'd2,  4'd3,  4'd0, 4'd1,
        4'd6,  4'd7,  4'd4, 4'd5,
        4'd10, 4'd11, 4'd8, 4'd9,
        4'd14,  4'd15, 4'd12, 4'd14
    };
`else
    localparam [3:0] region_mapper [0:15] = {
         4'd6,  4'd4,  4'd2,  4'd0,
         4'd7,  4'd5,  4'd3,  4'd1,
         4'd14, 4'd12, 4'd10, 4'd8,
         4'd15, 4'd13, 4'd11, 4'd9
    };
`endif

// FSM Next State Computation
always @(*) begin
    // Default State
    fsm_next = IDLE;
    buf_read_incr = 'b0;

    DataReadyOut = 'b0;
    DataOut = 'b0;
    RowIdOut = 'b0;

    case (fsm_state)
        IDLE: begin
            if(~buf_empty) begin
                if(~row0empty)
                    fsm_next = ROW0;
                else if(~row1empty)
                    fsm_next = ROW1;
                else if(~row2empty)
                    fsm_next = ROW2;
                else if(~row3empty)
                    fsm_next = ROW3;
            end
        end

        ROW0: begin
            DataReadyOut = 1'b1;

            DataOut = current_data[3 -: 4];
            RowIdOut = {current_row[7:2], region_mapper[{current_row[1:0], 2'b00}]};

            fsm_next = INC0;
        end

        INC0: begin
            if(~row1empty)
                fsm_next = ROW1;
            else if(~row2empty)
                fsm_next = ROW2;
            else if(~row3empty)
                fsm_next = ROW3;
            else begin
                fsm_next = CONT;

                buf_read_incr = 1'b1;
            end
        end
        
        ROW1: begin
            DataReadyOut = 1'b1;

            DataOut = current_data[7 -: 4];
            RowIdOut = {current_row[7:2], region_mapper[{current_row[1:0], 2'b01}]};

            fsm_next = INC1;
        end

        INC1: begin
            if(~row2empty)
                fsm_next = ROW2;
            else if(~row3empty)
                fsm_next = ROW3;
            else begin
                fsm_next = CONT;

                buf_read_incr = 1'b1;
            end
        end

        ROW2: begin
            DataReadyOut = 1'b1;

            DataOut = current_data[11 -: 4];
            RowIdOut = {current_row[7:2], region_mapper[{current_row[1:0], 2'b10}]};

            fsm_next = INC2;
        end

        INC2: begin
            if(~row3empty)
                fsm_next = ROW3;
            else begin
                fsm_next = CONT;

                buf_read_incr = 1'b1;
            end
        end

        ROW3: begin
            DataReadyOut = 1'b1;

            DataOut = current_data[15 -: 4];
            RowIdOut = {current_row[7:2], region_mapper[{current_row[1:0], 2'b11}]};

            fsm_next = INC3;

            buf_read_incr = 1'b1;
        end

        INC3: begin
            fsm_next = CONT;
        end

        CONT: begin
            if(~buf_empty) begin
                if(~row0empty)
                    fsm_next = ROW0;
                else if(~row1empty)
                    fsm_next = ROW1;
                else if(~row2empty)
                    fsm_next = ROW2;
                else if(~row3empty)
                    fsm_next = ROW3;
            end else
                fsm_next = IDLE;
        end

    endcase
end

assign Busy = fsm_next != IDLE;

endmodule


