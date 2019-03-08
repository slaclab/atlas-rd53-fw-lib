
// **NOTE: Ref. to OA cell view RD53_ADC12_CPPM => ADC_CLK_SOC_gen => verilogams

// Verilog-AMS HDL for "RD53_ADC12_CPPM", "ADC_ClkGen" "verilogams"

//`include "constants.vams"
//`include "disciplines.vams"

module ADC_CLK_SOC_gen( GNDD, VDDD, PHI1, PHI2, PHI3, PHI4, SOC_LF, CLOCK, RESETB, SOC );

   input RESETB ;
   input CLOCK ;
   input SOC ;
   output PHI1 ;
   output PHI2 ;
   output PHI3 ;
   output PHI4 ;
   output SOC_LF ;
   inout GNDD ;
   inout VDDD ;
  
   wire PHI1 ;
   wire PHI2 ;
   wire PHI1int ;
   wire PHI2int ;
   wire PHI3 ;
   wire PHI4 ;

   wire RESETB ;
   wire CLOCK ;
   wire SOC ;
   reg SOC_LF ;

   reg [9:0] div_count ;
   reg [1:0] soc_state ;
   reg [11:0] soc_count ;

   parameter SOC_RESET=0, SOC_IDLE=1, SOC_COUNT=2, SOC_ENDCOUNT=3 ;

   assign  PHI1int = !(!div_count[9] &&  PHI2) ;
   assign  PHI2int = !( div_count[9] &&  PHI1) ;
   assign  PHI3 = !PHI2 ;
   assign  PHI4 = !PHI1 ;

   buf #20 ( PHI1, PHI1int) ;
   buf #20 ( PHI2, PHI2int) ;


   // clock divider by 512
   always @(posedge CLOCK or negedge RESETB)
      if (!RESETB)
         div_count = 0 ;
      else
         div_count = div_count + 1 ;

   always @(posedge CLOCK or negedge RESETB) begin
      if (!RESETB)
         soc_state = SOC_RESET ;
      else
         case (soc_state)
            SOC_RESET : 
               if (SOC==1) soc_state = SOC_IDLE ;
               else soc_state = SOC_RESET ;
	
            SOC_IDLE  :
               soc_state = SOC_COUNT ;

            SOC_COUNT :
               if (soc_count[10]==1) soc_state = SOC_ENDCOUNT ;
               else begin
                  soc_state = SOC_COUNT ;
                  soc_count = soc_count+1 ;
               end

            SOC_ENDCOUNT : soc_state = SOC_RESET ;

         endcase
   end


   always @(soc_state or soc_count) begin

      case (soc_state)

         SOC_RESET :
            begin
               SOC_LF = 0 ;
               soc_count = 0 ;
            end

         SOC_IDLE :
            begin
               SOC_LF = 0 ;
               soc_count = 0 ;
            end

         SOC_COUNT :
            begin
               SOC_LF = 1 ;
            end

         SOC_ENDCOUNT :
            begin
               SOC_LF = 0 ;
               soc_count = soc_count ;
            end

 	endcase
   end

endmodule
