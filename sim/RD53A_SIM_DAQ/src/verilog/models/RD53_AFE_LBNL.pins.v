// Verilog file for cell "RD53_AFE_LBNL" view "abstract" 
// Language Version: 2001 

module RD53_AFE_LBNL (
    // Power pins.
    //VDDA,
    //VDDD,
    //VSUB,
    //GNDA,
    //GNDD,
    
    // Analog injection signals
    S0,
    S1,
  // Threshold adjust configuration
    DTH1,
    DTH2,
    
    in, // analog input 
    outdis, // discriminator output (negative polarity)
    
    // Biases
    CAL_HI,
    CAL_MI,
    PrmpVbnFol,
    PrmpVbp,
    VctrCF0,
    VctrLCC,
    compVbn,
    preCompVbn,
    vbnLcc,
    vff,
    vthin1,
    vthin2,
    
    ncas,
    out1,
    out2,
    out2b,
    InjPix,
    intCF0,
    outlcc,
    vbcas
    //out1i
    
    );
     
     // Power pins.
    //inout VDDA;
    //inout VDDD;
    //input VSUB;
    //inout GNDA;
    //inout GNDD;
    
    input S0;
    input S1;
    input [3:0] DTH1;
    input [3:0] DTH2;
    
    input in;
    output outdis;

    // Biases
    input CAL_HI;
    input CAL_MI;
    input PrmpVbnFol;
    input PrmpVbp;
    input VctrCF0;
    input VctrLCC;
    input compVbn;
    input preCompVbn;
    input vbnLcc;
    input vff;
    input vthin1;
    input vthin2;
    // Pins for Top-padframe
    output out1;
    output out2;
    output out2b;
    
    // Floating pins (testing).
    input ncas;
    input InjPix;
    input intCF0;
    input outlcc;
    input vbcas;
    //inout out1i;
    
endmodule // RD53_AFE_LBNL


