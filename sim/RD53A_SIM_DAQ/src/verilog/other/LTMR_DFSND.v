
module LTMR_DFSND_voter1bit(a, b, c, y);
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

module LTMR_DFSND_voter1bit_QN(a, b, c, y);
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

module LTMR_DFSND(CP, SDN, D, Q, QN);
  input CP, SDN, D;
  output Q, QN;
  wire CP, SDN, D;
  wire Q;
  wire Q1, Q2, Q3, _resetGlitch, resetDelay, QN1, QN2, QN3;
  LTMR_DFSND_voter1bit V1B5(.a (Q1), .b (Q2), .c (Q3), .y (Q));
  LTMR_DFSND_voter1bit_QN V1B5QN(.a (QN1), .b (QN2), .c (QN3), .y (QN));
  
  DEL3 DeglitcherDelay(.I (SDN), .Z (resetDelay));
  OR2D0 DeglitcherOR(.A1 (SDN), .A2 (resetDelay), .Z (_resetGlitch));
  DFSND1 dreg1(.SDN (_resetGlitch), .CP (CP), .D (D), .Q (Q1), .QN(QN1));
  DFSND1 dreg2(.SDN (_resetGlitch), .CP (CP), .D (D), .Q (Q2), .QN(QN2));
  DFSND1 dreg3(.SDN (_resetGlitch), .CP (CP), .D (D), .Q (Q3), .QN(QN3));
  
  // synopsys dc_script_begin
  // set_dont_touch DeglitcherDelay
  // synopsys dc_script_end
  
endmodule  