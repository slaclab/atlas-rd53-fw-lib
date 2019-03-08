
module LTMR_EDFCNQD_voter1bit(a, b, c, y);
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

module LTMR_EDFCNQD(E, CP, CDN, D, Q);
  input E, CP, CDN, D;
  output Q;
  wire E, CP, CDN, D;
  wire Q;
  wire Q1, Q2, Q3, _resetGlitch, mux, resetDelay;
  LTMR_EDFCNQD_voter1bit V1B5(.a (Q1), .b (Q2), .c (Q3), .y (Q));
  DEL3 DeglitcherDelay(.I (CDN), .Z (resetDelay));
  OR2D0 DeglitcherOR(.A1 (CDN), .A2 (resetDelay), .Z (_resetGlitch));
  MUX2D0 mux1(.I0 (Q), .I1 (D), .S (E), .Z (mux));
  DFCNQD1 dreg1(.CDN (_resetGlitch), .CP (CP), .D (mux), .Q (Q1));
  DFCNQD1 dreg2(.CDN (_resetGlitch), .CP (CP), .D (mux), .Q (Q2));
  DFCNQD1 dreg3(.CDN (_resetGlitch), .CP (CP), .D (mux), .Q (Q3));
  
  
  // synopsys dc_script_begin
  // set_dont_touch DeglitcherDelay
  // synopsys dc_script_end
  
endmodule