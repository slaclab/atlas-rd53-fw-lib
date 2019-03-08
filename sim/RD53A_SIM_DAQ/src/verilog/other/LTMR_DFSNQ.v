
module LTMR_DFSNQ_voter1bit(a, b, c, y);
  input a, b, c;
  output y;
  wire a, b, c;
  wire y;
  wire or1, z1, z2, z3;
  CKAN2D0 AND1(.A1 (a), .A2 (b), .Z (z1));
  CKAN2D0 AND2(.A1 (b), .A2 (c), .Z (z2));
  CKAN2D0 AND3(.A1 (c), .A2 (a), .Z (z3));
  OR2D0 OR1(.A1 (z1), .A2 (z2), .Z (or1));
  OR2D0 OR2(.A1 (or1), .A2 (z3), .Z (y));
endmodule

module LTMR_DFSNQ(CP, SDN, D, Q);
  input CP, SDN, D;
  output Q;
  wire CP, SDN, D;
  wire Q;
  wire Q1, Q2, Q3, _resetGlitch, resetDelay;
  LTMR_DFSNQ_voter1bit V1B5(.a (Q1), .b (Q2), .c (Q3), .y (Q));
  DEL3 DeglitcherDelay(.I (SDN), .Z (resetDelay));
  OR2D0 DeglitcherOR(.A1 (SDN), .A2 (resetDelay), .Z (_resetGlitch));
  DFSNQD1 dreg1(.SDN (_resetGlitch), .CP (CP), .D (D), .Q (Q1));
  DFSNQD1 dreg2(.SDN (_resetGlitch), .CP (CP), .D (D), .Q (Q2));
  DFSNQD1 dreg3(.SDN (_resetGlitch), .CP (CP), .D (D), .Q (Q3));
  
  // synopsys dc_script_begin
  // set_dont_touch DeglitcherDelay
  // synopsys dc_script_end
  
endmodule  