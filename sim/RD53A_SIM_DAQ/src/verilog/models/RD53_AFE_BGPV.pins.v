module RD53_AFE_BGPV (
    
    IHU_KRUM_BG, 
    TH_DAC, 
    GAIN_SEL,  
    POWER_DOWN, 
    HIT,
    //VDD_KRUM_BG,
    CAL_HI, 
    IPA_IN_BIAS_BG, 
    ILDAC_MIR1_BG,
    ILDAC_MIR2_BG,
    VTH_BG, 
    S1, 
    COMP_BIAS_BG, 
    VRIF_KRUM_BG,
    PIXEL_IN_BG, 
    S0, 
    IHD_KRUM_BG, 
    CAL_MI, 
    IFC_BIAS_BG,
    PA_OUT_BG
);
    
input IHU_KRUM_BG;
input [3:0] TH_DAC;
input GAIN_SEL;
input POWER_DOWN;
output HIT;
//input VDD_KRUM_BG;
input CAL_HI;
input IPA_IN_BIAS_BG;
input ILDAC_MIR1_BG;
input ILDAC_MIR2_BG;
input VTH_BG;
input S1;
input COMP_BIAS_BG;
input VRIF_KRUM_BG;
input PIXEL_IN_BG;
input S0;
input IHD_KRUM_BG;
input CAL_MI;
input IFC_BIAS_BG;
output PA_OUT_BG;

//input wire VDDA,
//input wire GNDA,
//input wire VSUB,
//input wire VDDD,
//input wire GNDD,

endmodule
