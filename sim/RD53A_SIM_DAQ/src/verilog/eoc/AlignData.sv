

module AlignData
    (
        input logic Clk, Reset,
        input logic [1:0] ActiveLanes,
        
        input logic Write,
 
        output logic Full,
        input logic [31:0] DataWrite,
        input logic EofWrite,
        
        output logic Empty,
        output logic [7:0] ByteEnableRead,
        output logic EofRead,
        output logic [255:0] DataRead,
        input logic Read
    );
    
    logic [3:0] addr;
    logic [7:0][31:0] mem;
    logic mem_eof;
    logic write_next;
    logic read_next;
    
    logic store_read;
    
    always_ff@(posedge Clk) begin
        if(Reset)
            write_next <= 0;
        else
            write_next <= Write & !Full;
    end 
    
    
    always_ff@(posedge Clk) begin
        if(Reset)
            read_next <= 0;
        else 
            read_next <= Read;
    end
    
    always_ff@(posedge Clk) begin
        if(Reset)
            addr <= 0;
        else if(write_next)
            addr <= addr + 1;
        else if(store_read & !Empty)
            addr <= 0;
    end
            
    always_ff@(posedge Clk) begin
        if(Reset) 
            mem <= 0;
        else if(write_next) 
            mem[addr[2:0]] <= DataWrite;
    end
    
    
    always_ff@(posedge Clk) begin
        if(Reset)
            mem_eof <= 0;
        else if(write_next) 
            mem_eof <= EofWrite;
        else if(store_read & !Empty)
            mem_eof <= 0;
    end
    
    logic [7:0][31:0] store_data;
    logic store_eof;
    logic [7:0] store_be;
    logic [7:0] calc_be;
    logic store_full;
    logic store_write;
    
    always_ff@(posedge Clk) begin
        if(Reset) begin
            store_data <= 0;
            store_eof <= 0;
            store_be <= 0;
        end
        else if(store_write) begin
            store_data <= mem;
            store_eof <= mem_eof;
            store_be <= calc_be;
        end
    end
    
    logic [2:0] byte_calc;
    logic full_word;
    always_comb begin
        byte_calc = (addr-1);
        full_word = ((addr >= ((ActiveLanes+1)*2) ) | mem_eof);
        Full =  full_word | (write_next & (EofWrite | (addr+1 >= ((ActiveLanes+1)*2)))); //not write if this is end of word
        DataRead = store_data;
        EofRead = store_eof;
        Empty = !store_full;
        ByteEnableRead = store_be;
        store_read = Read & store_full;
        store_write = full_word & !store_full;
    end
   
   always_ff@(posedge Clk) begin
        if(Reset) 
            store_full <= 0;
        else if(store_write)
            store_full <= 1;
        else if(store_read)
            store_full <= 0;
   end
   
   always_comb begin
      case (byte_calc) 
        0 : calc_be = 8'b1; 
        1 : calc_be = 8'b11; 
        2 : calc_be = 8'b111; 
        3 : calc_be = 8'b1111;
        4 : calc_be = 8'b1_1111; 
        5 : calc_be = 8'b11_1111; 
        6 : calc_be = 8'b111_1111; 
        7 : calc_be = 8'b1111_1111; 
      endcase 
    end
     
endmodule

