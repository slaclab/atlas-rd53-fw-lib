
module LTMR_EDFCND_voter1bit(a, b, c, y);
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

module LTMR_EDFCND_voter1bit_QN(a, b, c, y);
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


module LTMR_EDFCND (D, E, CP, CDN, Q, QN);
  input D, E, CP, CDN;  
  output Q, QN;
  wire D, E, CP, CDN;  
  wire Q, QN;
  wire Q1, Q2, Q3, _resetGlitch, mux, resetDelay, QN1, QN2, QN3;
  LTMR_EDFCND_voter1bit V1B5(.a (Q1), .b (Q2), .c (Q3), .y (Q));
  LTMR_EDFCND_voter1bit_QN V1B5QN(.a (QN1), .b (QN2), .c (QN3), .y (QN));
  DEL3 DeglitcherDelay(.I (CDN), .Z (resetDelay));
  OR2D0 DeglitcherOR(.A1 (CDN), .A2 (resetDelay), .Z (_resetGlitch));
  MUX2D0 mux1(.I0 (Q), .I1 (D), .S (E), .Z (mux));
  DFCND1 dreg1(.CDN (_resetGlitch), .CP (CP), .D (mux), .Q (Q1), .QN (QN1));
  DFCND1 dreg2(.CDN (_resetGlitch), .CP (CP), .D (mux), .Q (Q2), .QN (QN2));
  DFCND1 dreg3(.CDN (_resetGlitch), .CP (CP), .D (mux), .Q (Q3), .QN (QN3));
  
  // synopsys dc_script_begin
  // set_dont_touch DeglitcherDelay
  // synopsys dc_script_end
  
endmodule