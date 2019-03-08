
`ifndef SIG_FORK
`define SIG_FORK

module SigFork (
    input wire I,
    output wire L,
    output wire O
);

CKBD16 outbuf (.I(I), .Z(O));
CKBD6 locbuf (.I(O), .Z(L));

endmodule

`endif