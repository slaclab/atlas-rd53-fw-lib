module RowAddressDec_4X4 (input wire [0:3] Token, 
                       output wire [3:0] RowAddr);


wire [16:0] addr [3:0];

generate
    genvar k;
    for (k=0; k<16; k=k+1)
    begin: address_gen
        assign addr[0][k] = !(addr[0][k+1] & Token[k]);
        if(k%2==0)
            assign addr[1][k] = !(addr[1][k+2] & Token[k]);
        if(k%4==0)
            assign addr[2][k] = !(addr[2][k+4] & Token[k]);
        if(k%8==0)
            assign addr[3][k] = !(addr[3][k+8] & Token[k]);
    end 
endgenerate
    
assign addr[0][16] = 1;
assign addr[1][16] = 1;
assign addr[2][16] = 1;
assign addr[3][16] = 1;
    
assign RowAddr[0] = !addr[0][0];
assign RowAddr[1] = !addr[1][0];
assign RowAddr[2] = !addr[2][0];
assign RowAddr[3] = !addr[3][0];

endmodule 




