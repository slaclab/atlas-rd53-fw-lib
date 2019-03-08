//-------------------------------------------------------------------------------
// Just can be used for RTL simulation (to not force to use models from foundry) 
//-------------------------------------------------------------------------------

`timescale 1ns/1ps

module DEL0 (I, Z);
    input wire I;
    output wire Z;
    
    //assign #1ns Z = I;
    assign Z = I;
    
endmodule

module DEL1 (I, Z);
    input wire I;
    output wire Z;
    
    assign Z = I;
    
endmodule

module DEL01 (I, Z);
    input wire I;
    output wire Z;
    
    assign Z = I;
    
endmodule

module CKMUX2D0 (I0, I1, S, Z);
    input wire I0, I1, S;
    output Z;
    
    reg Z;    
    always@(*) begin
        if (S==1'b0)
            Z = I0;
        else if (S==1'b1)
            Z = I1;
        else
            Z = 1'bx;
    end        

endmodule 

