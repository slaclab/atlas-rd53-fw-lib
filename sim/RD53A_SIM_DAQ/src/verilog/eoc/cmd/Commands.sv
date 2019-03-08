
//////
// All possible BitFlips
///////
wire   BitFlip_H;
assign BitFlip_H = ( Input[15:8] == 8'b00001011 ) || ( Input[15:8] == 8'b00001101 ) || ( Input[15:8] == 8'b00001110 ) || ( Input[15:8] == 8'b00010011 ) ||
                   ( Input[15:8] == 8'b00010101 ) || ( Input[15:8] == 8'b00010110 ) || ( Input[15:8] == 8'b00011001 ) || ( Input[15:8] == 8'b00011010 ) ||
                   ( Input[15:8] == 8'b00011100 ) || ( Input[15:8] == 8'b00100011 ) || ( Input[15:8] == 8'b00100101 ) || ( Input[15:8] == 8'b00100110 ) ||
                   ( Input[15:8] == 8'b00101001 ) || ( Input[15:8] == 8'b00101010 ) || ( Input[15:8] == 8'b00101100 ) || ( Input[15:8] == 8'b00101111 ) ||
                   ( Input[15:8] == 8'b00110001 ) || ( Input[15:8] == 8'b00110010 ) || ( Input[15:8] == 8'b00110100 ) || ( Input[15:8] == 8'b00110111 ) ||
                   ( Input[15:8] == 8'b00111000 ) || ( Input[15:8] == 8'b00111011 ) || ( Input[15:8] == 8'b00111101 ) || ( Input[15:8] == 8'b00111110 ) ||
                   ( Input[15:8] == 8'b01000011 ) || ( Input[15:8] == 8'b01000101 ) || ( Input[15:8] == 8'b01000110 ) || ( Input[15:8] == 8'b01001001 ) ||
                   ( Input[15:8] == 8'b01001010 ) || ( Input[15:8] == 8'b01001100 ) || ( Input[15:8] == 8'b01001111 ) || ( Input[15:8] == 8'b01010001 ) ||
                   ( Input[15:8] == 8'b01010010 ) || ( Input[15:8] == 8'b01010100 ) || ( Input[15:8] == 8'b01010111 ) || ( Input[15:8] == 8'b01011000 ) ||
                   ( Input[15:8] == 8'b01011011 ) || ( Input[15:8] == 8'b01011101 ) || ( Input[15:8] == 8'b01011110 ) || ( Input[15:8] == 8'b01100001 ) ||
                   ( Input[15:8] == 8'b01100010 ) || ( Input[15:8] == 8'b01100100 ) || ( Input[15:8] == 8'b01100111 ) || ( Input[15:8] == 8'b01101000 ) ||
                   ( Input[15:8] == 8'b01101011 ) || ( Input[15:8] == 8'b01101101 ) || ( Input[15:8] == 8'b01101110 ) || ( Input[15:8] == 8'b01110000 ) ||
                   ( Input[15:8] == 8'b01110011 ) || ( Input[15:8] == 8'b01110101 ) || ( Input[15:8] == 8'b01110110 ) || ( Input[15:8] == 8'b01111001 ) ||
                   ( Input[15:8] == 8'b01111010 ) || ( Input[15:8] == 8'b01111100 ) || ( Input[15:8] == 8'b10000011 ) || ( Input[15:8] == 8'b10000101 ) ||
                   ( Input[15:8] == 8'b10000110 ) || ( Input[15:8] == 8'b10001001 ) || ( Input[15:8] == 8'b10001010 ) || ( Input[15:8] == 8'b10001100 ) ||
                   ( Input[15:8] == 8'b10001111 ) || ( Input[15:8] == 8'b10010001 ) || ( Input[15:8] == 8'b10010010 ) || ( Input[15:8] == 8'b10010100 ) ||
                   ( Input[15:8] == 8'b10010111 ) || ( Input[15:8] == 8'b10011000 ) || ( Input[15:8] == 8'b10011011 ) || ( Input[15:8] == 8'b10011101 ) ||
                   ( Input[15:8] == 8'b10011110 ) || ( Input[15:8] == 8'b10100001 ) || ( Input[15:8] == 8'b10100010 ) || ( Input[15:8] == 8'b10100100 ) ||
                   ( Input[15:8] == 8'b10100111 ) || ( Input[15:8] == 8'b10101000 ) || ( Input[15:8] == 8'b10101011 ) || ( Input[15:8] == 8'b10101101 ) ||
                   ( Input[15:8] == 8'b10101110 ) || ( Input[15:8] == 8'b10110000 ) || ( Input[15:8] == 8'b10110011 ) || ( Input[15:8] == 8'b10110101 ) ||
                   ( Input[15:8] == 8'b10110110 ) || ( Input[15:8] == 8'b10111001 ) || ( Input[15:8] == 8'b10111010 ) || ( Input[15:8] == 8'b10111100 ) ||
                   ( Input[15:8] == 8'b11000001 ) || ( Input[15:8] == 8'b11000010 ) || ( Input[15:8] == 8'b11000100 ) || ( Input[15:8] == 8'b11000111 ) ||
                   ( Input[15:8] == 8'b11001000 ) || ( Input[15:8] == 8'b11001011 ) || ( Input[15:8] == 8'b11001101 ) || ( Input[15:8] == 8'b11001110 ) ||
                   ( Input[15:8] == 8'b11010000 ) || ( Input[15:8] == 8'b11010011 ) || ( Input[15:8] == 8'b11010101 ) || ( Input[15:8] == 8'b11010110 ) ||
                   ( Input[15:8] == 8'b11011001 ) || ( Input[15:8] == 8'b11011010 ) || ( Input[15:8] == 8'b11011100 ) || ( Input[15:8] == 8'b11100011 ) ||
                   ( Input[15:8] == 8'b11100101 ) || ( Input[15:8] == 8'b11100110 ) || ( Input[15:8] == 8'b11101001 ) || ( Input[15:8] == 8'b11101010 ) ||
                   ( Input[15:8] == 8'b11101100 ) || ( Input[15:8] == 8'b11110001 ) || ( Input[15:8] == 8'b11110010 ) || ( Input[15:8] == 8'b11110100 ) ;

wire   BitFlip_L;
assign BitFlip_L = ( Input[7:0] ==  8'b00001011 ) || ( Input[7:0] ==  8'b00001101 ) || ( Input[7:0] ==  8'b00001110 ) || ( Input[7:0] ==  8'b00010011 ) ||
                   ( Input[7:0] ==  8'b00010101 ) || ( Input[7:0] ==  8'b00010110 ) || ( Input[7:0] ==  8'b00011001 ) || ( Input[7:0] ==  8'b00011010 ) ||
                   ( Input[7:0] ==  8'b00011100 ) || ( Input[7:0] ==  8'b00100011 ) || ( Input[7:0] ==  8'b00100101 ) || ( Input[7:0] ==  8'b00100110 ) ||
                   ( Input[7:0] ==  8'b00101001 ) || ( Input[7:0] ==  8'b00101010 ) || ( Input[7:0] ==  8'b00101100 ) || ( Input[7:0] ==  8'b00101111 ) ||
                   ( Input[7:0] ==  8'b00110001 ) || ( Input[7:0] ==  8'b00110010 ) || ( Input[7:0] ==  8'b00110100 ) || ( Input[7:0] ==  8'b00110111 ) ||
                   ( Input[7:0] ==  8'b00111000 ) || ( Input[7:0] ==  8'b00111011 ) || ( Input[7:0] ==  8'b00111101 ) || ( Input[7:0] ==  8'b00111110 ) ||
                   ( Input[7:0] ==  8'b01000011 ) || ( Input[7:0] ==  8'b01000101 ) || ( Input[7:0] ==  8'b01000110 ) || ( Input[7:0] ==  8'b01001001 ) ||
                   ( Input[7:0] ==  8'b01001010 ) || ( Input[7:0] ==  8'b01001100 ) || ( Input[7:0] ==  8'b01001111 ) || ( Input[7:0] ==  8'b01010001 ) ||
                   ( Input[7:0] ==  8'b01010010 ) || ( Input[7:0] ==  8'b01010100 ) || ( Input[7:0] ==  8'b01010111 ) || ( Input[7:0] ==  8'b01011000 ) ||
                   ( Input[7:0] ==  8'b01011011 ) || ( Input[7:0] ==  8'b01011101 ) || ( Input[7:0] ==  8'b01011110 ) || ( Input[7:0] ==  8'b01100001 ) ||
                   ( Input[7:0] ==  8'b01100010 ) || ( Input[7:0] ==  8'b01100100 ) || ( Input[7:0] ==  8'b01100111 ) || ( Input[7:0] ==  8'b01101000 ) ||
                   ( Input[7:0] ==  8'b01101011 ) || ( Input[7:0] ==  8'b01101101 ) || ( Input[7:0] ==  8'b01101110 ) || ( Input[7:0] ==  8'b01110000 ) ||
                   ( Input[7:0] ==  8'b01110011 ) || ( Input[7:0] ==  8'b01110101 ) || ( Input[7:0] ==  8'b01110110 ) || ( Input[7:0] ==  8'b01111001 ) ||
                   ( Input[7:0] ==  8'b01111010 ) || ( Input[7:0] ==  8'b01111100 ) || ( Input[7:0] ==  8'b10000011 ) || ( Input[7:0] ==  8'b10000101 ) ||
                   ( Input[7:0] ==  8'b10000110 ) || ( Input[7:0] ==  8'b10001001 ) || ( Input[7:0] ==  8'b10001010 ) || ( Input[7:0] ==  8'b10001100 ) ||
                   ( Input[7:0] ==  8'b10001111 ) || ( Input[7:0] ==  8'b10010001 ) || ( Input[7:0] ==  8'b10010010 ) || ( Input[7:0] ==  8'b10010100 ) ||
                   ( Input[7:0] ==  8'b10010111 ) || ( Input[7:0] ==  8'b10011000 ) || ( Input[7:0] ==  8'b10011011 ) || ( Input[7:0] ==  8'b10011101 ) ||
                   ( Input[7:0] ==  8'b10011110 ) || ( Input[7:0] ==  8'b10100001 ) || ( Input[7:0] ==  8'b10100010 ) || ( Input[7:0] ==  8'b10100100 ) ||
                   ( Input[7:0] ==  8'b10100111 ) || ( Input[7:0] ==  8'b10101000 ) || ( Input[7:0] ==  8'b10101011 ) || ( Input[7:0] ==  8'b10101101 ) ||
                   ( Input[7:0] ==  8'b10101110 ) || ( Input[7:0] ==  8'b10110000 ) || ( Input[7:0] ==  8'b10110011 ) || ( Input[7:0] ==  8'b10110101 ) ||
                   ( Input[7:0] ==  8'b10110110 ) || ( Input[7:0] ==  8'b10111001 ) || ( Input[7:0] ==  8'b10111010 ) || ( Input[7:0] ==  8'b10111100 ) ||
                   ( Input[7:0] ==  8'b11000001 ) || ( Input[7:0] ==  8'b11000010 ) || ( Input[7:0] ==  8'b11000100 ) || ( Input[7:0] ==  8'b11000111 ) ||
                   ( Input[7:0] ==  8'b11001000 ) || ( Input[7:0] ==  8'b11001011 ) || ( Input[7:0] ==  8'b11001101 ) || ( Input[7:0] ==  8'b11001110 ) ||
                   ( Input[7:0] ==  8'b11010000 ) || ( Input[7:0] ==  8'b11010011 ) || ( Input[7:0] ==  8'b11010101 ) || ( Input[7:0] ==  8'b11010110 ) ||
                   ( Input[7:0] ==  8'b11011001 ) || ( Input[7:0] ==  8'b11011010 ) || ( Input[7:0] ==  8'b11011100 ) || ( Input[7:0] ==  8'b11100011 ) ||
                   ( Input[7:0] ==  8'b11100101 ) || ( Input[7:0] ==  8'b11100110 ) || ( Input[7:0] ==  8'b11101001 ) || ( Input[7:0] ==  8'b11101010 ) ||
                   ( Input[7:0] ==  8'b11101100 ) || ( Input[7:0] ==  8'b11110001 ) || ( Input[7:0] ==  8'b11110010 ) || ( Input[7:0] ==  8'b11110100 ) ;

//////
// BitFlip definition
///////
wire   BitFlip;
assign BitFlip = ( BitFlip_H || BitFlip_L );

///////
// BCR 01011001
///////
wire   BCR_OK_H, BCR_OK_L, BCR_BF_H, BCR_BF_L;
assign BCR_OK_H = ( Input[15:8] == 8'b01011001);
assign BCR_OK_L = (  Input[7:0] == 8'b01011001);
assign BCR_BF_H = ((Input[15:8] == 8'b11011001) || (Input[15:8] == 8'b00011001) ||
                      (Input[15:8] == 8'b01111001) || (Input[15:8] == 8'b01001001) ||
                      (Input[15:8] == 8'b01010001) || (Input[15:8] == 8'b01011101) ||
                      (Input[15:8] == 8'b01011011) || (Input[15:8] == 8'b01011000)
                     );
assign BCR_BF_L = ((Input[7:0] == 8'b11011001) || (Input[7:0] == 8'b00011001) ||
                      (Input[7:0] == 8'b01111001) || (Input[7:0] == 8'b01001001) ||
                      (Input[7:0] == 8'b01010001) || (Input[7:0] == 8'b01011101) ||
                      (Input[7:0] == 8'b01011011) || (Input[7:0] == 8'b01011000)
                     );

///////
// Cal 01100011
///////
wire   Cal_OK_H, Cal_OK_L, Cal_BF_H, Cal_BF_L;
assign Cal_OK_H = ( Input[15:8] == 8'b01100011);
assign Cal_OK_L = (  Input[7:0] == 8'b01100011);
assign Cal_BF_H = ((Input[15:8] == 8'b11100011) || (Input[15:8] == 8'b00100011) ||
                      (Input[15:8] == 8'b01000011) || (Input[15:8] == 8'b01110011) ||
                      (Input[15:8] == 8'b01101011) || (Input[15:8] == 8'b01100111) ||
                      (Input[15:8] == 8'b01100001) || (Input[15:8] == 8'b01100010)
                     );
assign Cal_BF_L = ((Input[7:0] == 8'b11100011) || (Input[7:0] == 8'b00100011) ||
                      (Input[7:0] == 8'b01000011) || (Input[7:0] == 8'b01110011) ||
                      (Input[7:0] == 8'b01101011) || (Input[7:0] == 8'b01100111) ||
                      (Input[7:0] == 8'b01100001) || (Input[7:0] == 8'b01100010)
                     );

///////
// Data00 01101010
///////
wire   Data00_OK_H, Data00_OK_L;
assign Data00_OK_H = ( Input[15:8] == 8'b01101010);
assign Data00_OK_L = (  Input[7:0] == 8'b01101010);
///////
// Data01 01101100
///////
wire   Data01_OK_H, Data01_OK_L;
assign Data01_OK_H = ( Input[15:8] == 8'b01101100);
assign Data01_OK_L = (  Input[7:0] == 8'b01101100);
///////
// Data02 01110001
///////
wire   Data02_OK_H, Data02_OK_L;
assign Data02_OK_H = ( Input[15:8] == 8'b01110001);
assign Data02_OK_L = (  Input[7:0] == 8'b01110001);
///////
// Data03 01110010
///////
wire   Data03_OK_H, Data03_OK_L;
assign Data03_OK_H = ( Input[15:8] == 8'b01110010);
assign Data03_OK_L = (  Input[7:0] == 8'b01110010);
///////
// Data04 01110100
///////
wire   Data04_OK_H, Data04_OK_L;
assign Data04_OK_H = ( Input[15:8] == 8'b01110100);
assign Data04_OK_L = (  Input[7:0] == 8'b01110100);
///////
// Data05 10001011
///////
wire   Data05_OK_H, Data05_OK_L;
assign Data05_OK_H = ( Input[15:8] == 8'b10001011);
assign Data05_OK_L = (  Input[7:0] == 8'b10001011);
///////
// Data06 10001101
///////
wire   Data06_OK_H, Data06_OK_L;
assign Data06_OK_H = ( Input[15:8] == 8'b10001101);
assign Data06_OK_L = (  Input[7:0] == 8'b10001101);
///////
// Data07 10001110
///////
wire   Data07_OK_H, Data07_OK_L;
assign Data07_OK_H = ( Input[15:8] == 8'b10001110);
assign Data07_OK_L = (  Input[7:0] == 8'b10001110);
///////
// Data08 10010011
///////
wire   Data08_OK_H, Data08_OK_L;
assign Data08_OK_H = ( Input[15:8] == 8'b10010011);
assign Data08_OK_L = (  Input[7:0] == 8'b10010011);
///////
// Data09 10010101
///////
wire   Data09_OK_H, Data09_OK_L;
assign Data09_OK_H = ( Input[15:8] == 8'b10010101);
assign Data09_OK_L = (  Input[7:0] == 8'b10010101);
///////
// Data10 10010110
///////
wire   Data10_OK_H, Data10_OK_L;
assign Data10_OK_H = ( Input[15:8] == 8'b10010110);
assign Data10_OK_L = (  Input[7:0] == 8'b10010110);
///////
// Data11 10011001
///////
wire   Data11_OK_H, Data11_OK_L;
assign Data11_OK_H = ( Input[15:8] == 8'b10011001);
assign Data11_OK_L = (  Input[7:0] == 8'b10011001);
///////
// Data12 10011010
///////
wire   Data12_OK_H, Data12_OK_L;
assign Data12_OK_H = ( Input[15:8] == 8'b10011010);
assign Data12_OK_L = (  Input[7:0] == 8'b10011010);
///////
// Data13 10011100
///////
wire   Data13_OK_H, Data13_OK_L;
assign Data13_OK_H = ( Input[15:8] == 8'b10011100);
assign Data13_OK_L = (  Input[7:0] == 8'b10011100);
///////
// Data14 10100011
///////
wire   Data14_OK_H, Data14_OK_L;
assign Data14_OK_H = ( Input[15:8] == 8'b10100011);
assign Data14_OK_L = (  Input[7:0] == 8'b10100011);
///////
// Data15 10100101
///////
wire   Data15_OK_H, Data15_OK_L;
assign Data15_OK_H = ( Input[15:8] == 8'b10100101);
assign Data15_OK_L = (  Input[7:0] == 8'b10100101);
///////
// Data16 10100110
///////
wire   Data16_OK_H, Data16_OK_L;
assign Data16_OK_H = ( Input[15:8] == 8'b10100110);
assign Data16_OK_L = (  Input[7:0] == 8'b10100110);
///////
// Data17 10101001
///////
wire   Data17_OK_H, Data17_OK_L;
assign Data17_OK_H = ( Input[15:8] == 8'b10101001);
assign Data17_OK_L = (  Input[7:0] == 8'b10101001);
///////
// Data18 10101010
///////
wire   Data18_OK_H, Data18_OK_L;
assign Data18_OK_H = ( Input[15:8] == 8'b10101010);
assign Data18_OK_L = (  Input[7:0] == 8'b10101010);
///////
// Data19 10101100
///////
wire   Data19_OK_H, Data19_OK_L;
assign Data19_OK_H = ( Input[15:8] == 8'b10101100);
assign Data19_OK_L = (  Input[7:0] == 8'b10101100);
///////
// Data20 10110001
///////
wire   Data20_OK_H, Data20_OK_L;
assign Data20_OK_H = ( Input[15:8] == 8'b10110001);
assign Data20_OK_L = (  Input[7:0] == 8'b10110001);
///////
// Data21 10110010
///////
wire   Data21_OK_H, Data21_OK_L;
assign Data21_OK_H = ( Input[15:8] == 8'b10110010);
assign Data21_OK_L = (  Input[7:0] == 8'b10110010);
///////
// Data22 10110100
///////
wire   Data22_OK_H, Data22_OK_L;
assign Data22_OK_H = ( Input[15:8] == 8'b10110100);
assign Data22_OK_L = (  Input[7:0] == 8'b10110100);
///////
// Data23 11000011
///////
wire   Data23_OK_H, Data23_OK_L;
assign Data23_OK_H = ( Input[15:8] == 8'b11000011);
assign Data23_OK_L = (  Input[7:0] == 8'b11000011);
///////
// Data24 11000101
///////
wire   Data24_OK_H, Data24_OK_L;
assign Data24_OK_H = ( Input[15:8] == 8'b11000101);
assign Data24_OK_L = (  Input[7:0] == 8'b11000101);
///////
// Data25 11000110
///////
wire   Data25_OK_H, Data25_OK_L;
assign Data25_OK_H = ( Input[15:8] == 8'b11000110);
assign Data25_OK_L = (  Input[7:0] == 8'b11000110);
///////
// Data26 11001001
///////
wire   Data26_OK_H, Data26_OK_L;
assign Data26_OK_H = ( Input[15:8] == 8'b11001001);
assign Data26_OK_L = (  Input[7:0] == 8'b11001001);
///////
// Data27 11001010
///////
wire   Data27_OK_H, Data27_OK_L;
assign Data27_OK_H = ( Input[15:8] == 8'b11001010);
assign Data27_OK_L = (  Input[7:0] == 8'b11001010);
///////
// Data28 11001100
///////
wire   Data28_OK_H, Data28_OK_L;
assign Data28_OK_H = ( Input[15:8] == 8'b11001100);
assign Data28_OK_L = (  Input[7:0] == 8'b11001100);
///////
// Data29 11010001
///////
wire   Data29_OK_H, Data29_OK_L;
assign Data29_OK_H = ( Input[15:8] == 8'b11010001);
assign Data29_OK_L = (  Input[7:0] == 8'b11010001);
///////
// Data30 11010010
///////
wire   Data30_OK_H, Data30_OK_L;
assign Data30_OK_H = ( Input[15:8] == 8'b11010010);
assign Data30_OK_L = (  Input[7:0] == 8'b11010010);
///////
// Data31 11010100
///////
wire   Data31_OK_H, Data31_OK_L;
assign Data31_OK_H = ( Input[15:8] == 8'b11010100);
assign Data31_OK_L = (  Input[7:0] == 8'b11010100);
//////
// Data_OK_H
///////
wire   Data_OK_H;
assign Data_OK_H = (Data00_OK_H || Data01_OK_H || Data02_OK_H || Data03_OK_H ||
                    Data04_OK_H || Data05_OK_H || Data06_OK_H || Data07_OK_H ||
                    Data08_OK_H || Data09_OK_H || Data10_OK_H || Data11_OK_H ||
                    Data12_OK_H || Data13_OK_H || Data14_OK_H || Data15_OK_H ||
                    Data16_OK_H || Data17_OK_H || Data18_OK_H || Data19_OK_H ||
                    Data20_OK_H || Data21_OK_H || Data22_OK_H || Data23_OK_H ||
                    Data24_OK_H || Data25_OK_H || Data26_OK_H || Data27_OK_H ||
                    Data28_OK_H || Data29_OK_H || Data30_OK_H || Data31_OK_H 
                   );

//////
// Data_OK_L
///////
wire   Data_OK_L;
assign Data_OK_L = (Data00_OK_L || Data01_OK_L || Data02_OK_L || Data03_OK_L ||
                    Data04_OK_L || Data05_OK_L || Data06_OK_L || Data07_OK_L ||
                    Data08_OK_L || Data09_OK_L || Data10_OK_L || Data11_OK_L ||
                    Data12_OK_L || Data13_OK_L || Data14_OK_L || Data15_OK_L ||
                    Data16_OK_L || Data17_OK_L || Data18_OK_L || Data19_OK_L ||
                    Data20_OK_L || Data21_OK_L || Data22_OK_L || Data23_OK_L ||
                    Data24_OK_L || Data25_OK_L || Data26_OK_L || Data27_OK_L ||
                    Data28_OK_L || Data29_OK_L || Data30_OK_L || Data31_OK_L 
                   );

///////
// ECR 01011010
///////
wire   ECR_OK_H, ECR_OK_L, ECR_BF_H, ECR_BF_L;
assign ECR_OK_H = ( Input[15:8] == 8'b01011010);
assign ECR_OK_L = (  Input[7:0] == 8'b01011010);
assign ECR_BF_H = ((Input[15:8] == 8'b11011010) || (Input[15:8] == 8'b00011010) ||
                      (Input[15:8] == 8'b01111010) || (Input[15:8] == 8'b01001010) ||
                      (Input[15:8] == 8'b01010010) || (Input[15:8] == 8'b01011110) ||
                      (Input[15:8] == 8'b01011000) || (Input[15:8] == 8'b01011011)
                     );
assign ECR_BF_L = ((Input[7:0] == 8'b11011010) || (Input[7:0] == 8'b00011010) ||
                      (Input[7:0] == 8'b01111010) || (Input[7:0] == 8'b01001010) ||
                      (Input[7:0] == 8'b01010010) || (Input[7:0] == 8'b01011110) ||
                      (Input[7:0] == 8'b01011000) || (Input[7:0] == 8'b01011011)
                     );

///////
// GlobalPulse 01011100
///////
wire   GlobalPulse_OK_H, GlobalPulse_OK_L, GlobalPulse_BF_H, GlobalPulse_BF_L;
assign GlobalPulse_OK_H = ( Input[15:8] == 8'b01011100);
assign GlobalPulse_OK_L = (  Input[7:0] == 8'b01011100);
assign GlobalPulse_BF_H = ((Input[15:8] == 8'b11011100) || (Input[15:8] == 8'b00011100) ||
                      (Input[15:8] == 8'b01111100) || (Input[15:8] == 8'b01001100) ||
                      (Input[15:8] == 8'b01010100) || (Input[15:8] == 8'b01011000) ||
                      (Input[15:8] == 8'b01011110) || (Input[15:8] == 8'b01011101)
                     );
assign GlobalPulse_BF_L = ((Input[7:0] == 8'b11011100) || (Input[7:0] == 8'b00011100) ||
                      (Input[7:0] == 8'b01111100) || (Input[7:0] == 8'b01001100) ||
                      (Input[7:0] == 8'b01010100) || (Input[7:0] == 8'b01011000) ||
                      (Input[7:0] == 8'b01011110) || (Input[7:0] == 8'b01011101)
                     );

///////
// Null 01101001
///////
wire   Null_OK_H, Null_OK_L, Null_BF_H, Null_BF_L;
assign Null_OK_H = ( Input[15:8] == 8'b01101001);
assign Null_OK_L = (  Input[7:0] == 8'b01101001);
assign Null_BF_H = ((Input[15:8] == 8'b11101001) || (Input[15:8] == 8'b00101001) ||
                    (Input[15:8] == 8'b01001001) || (Input[15:8] == 8'b01111001) ||
                    (Input[15:8] == 8'b01100001) || (Input[15:8] == 8'b01101101) ||
                    (Input[15:8] == 8'b01101011) || (Input[15:8] == 8'b01101000)
                     );
assign Null_BF_L = ((Input[7:0] == 8'b11101001) || (Input[7:0] == 8'b00101001) ||
                      (Input[7:0] == 8'b01001001) || (Input[7:0] == 8'b01111001) ||
                      (Input[7:0] == 8'b01100001) || (Input[7:0] == 8'b01101101) ||
                      (Input[7:0] == 8'b01101011) || (Input[7:0] == 8'b01101000)
                     );
///////
// RdReg 01100101
///////
wire   RdReg_OK_H, RdReg_OK_L, RdReg_BF_H, RdReg_BF_L;
assign RdReg_OK_H = ( Input[15:8] == 8'b01100101);
assign RdReg_OK_L = (  Input[7:0] == 8'b01100101);
assign RdReg_BF_H = ((Input[15:8] == 8'b11100101) || (Input[15:8] == 8'b00100101) ||
                      (Input[15:8] == 8'b01000101) || (Input[15:8] == 8'b01110101) ||
                      (Input[15:8] == 8'b01101101) || (Input[15:8] == 8'b01100001) ||
                      (Input[15:8] == 8'b01100111) || (Input[15:8] == 8'b01100100)
                     );
assign RdReg_BF_L = ((Input[7:0] == 8'b11100101) || (Input[7:0] == 8'b00100101) ||
                      (Input[7:0] == 8'b01000101) || (Input[7:0] == 8'b01110101) ||
                      (Input[7:0] == 8'b01101101) || (Input[7:0] == 8'b01100001) ||
                      (Input[7:0] == 8'b01100111) || (Input[7:0] == 8'b01100100)
                     );

///////
// Trigger01 00101011
///////
wire   Trigger01_OK_H, Trigger01_BF_L, Trigger01Cmd;
assign Trigger01_OK_H = ( Input[15:8] == 8'b00101011);
assign Trigger01_BF_L = ( (Trigger01_OK_H && BitFlip_L) );
assign Trigger01Cmd   = ( (Trigger01_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger02 00101101
///////
wire   Trigger02_OK_H, Trigger02_BF_L, Trigger02Cmd;
assign Trigger02_OK_H = ( Input[15:8] == 8'b00101101);
assign Trigger02_BF_L = ( (Trigger02_OK_H && BitFlip_L) );
assign Trigger02Cmd   = ( (Trigger02_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger03 00101110
///////
wire   Trigger03_OK_H, Trigger03_BF_L, Trigger03Cmd;
assign Trigger03_OK_H = ( Input[15:8] == 8'b00101110);
assign Trigger03_BF_L = ( (Trigger03_OK_H && BitFlip_L) );
assign Trigger03Cmd   = ( (Trigger03_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger04 00110011
///////
wire   Trigger04_OK_H, Trigger04_BF_L, Trigger04Cmd;
assign Trigger04_OK_H = ( Input[15:8] == 8'b00110011);
assign Trigger04_BF_L = ( (Trigger04_OK_H && BitFlip_L) );
assign Trigger04Cmd   = ( (Trigger04_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger05 00110101
///////
wire   Trigger05_OK_H, Trigger05_BF_L, Trigger05Cmd;
assign Trigger05_OK_H = ( Input[15:8] == 8'b00110101);
assign Trigger05_BF_L = ( (Trigger05_OK_H && BitFlip_L) );
assign Trigger05Cmd   = ( (Trigger05_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger06 00110110
///////
wire   Trigger06_OK_H, Trigger06_BF_L, Trigger06Cmd;
assign Trigger06_OK_H = ( Input[15:8] == 8'b00110110);
assign Trigger06_BF_L = ( (Trigger06_OK_H && BitFlip_L) );
assign Trigger06Cmd   = ( (Trigger06_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger07 00111001
///////
wire   Trigger07_OK_H, Trigger07_BF_L, Trigger07Cmd;
assign Trigger07_OK_H = ( Input[15:8] == 8'b00111001);
assign Trigger07_BF_L = ( (Trigger07_OK_H && BitFlip_L) );
assign Trigger07Cmd   = ( (Trigger07_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger08 00111010
///////
wire   Trigger08_OK_H, Trigger08_BF_L, Trigger08Cmd;
assign Trigger08_OK_H = ( Input[15:8] == 8'b00111010);
assign Trigger08_BF_L = ( (Trigger08_OK_H && BitFlip_L) );
assign Trigger08Cmd   = ( (Trigger08_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger09 00111100
///////
wire   Trigger09_OK_H, Trigger09_BF_L, Trigger09Cmd;
assign Trigger09_OK_H = ( Input[15:8] == 8'b00111100);
assign Trigger09_BF_L = ( (Trigger09_OK_H && BitFlip_L) );
assign Trigger09Cmd   = ( (Trigger09_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger10 01001011
///////
wire   Trigger10_OK_H, Trigger10_BF_L, Trigger10Cmd;
assign Trigger10_OK_H = ( Input[15:8] == 8'b01001011);
assign Trigger10_BF_L = ( (Trigger10_OK_H && BitFlip_L) );
assign Trigger10Cmd   = ( (Trigger10_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger11 01001101
///////
wire   Trigger11_OK_H, Trigger11_BF_L, Trigger11Cmd;
assign Trigger11_OK_H = ( Input[15:8] == 8'b01001101);
assign Trigger11_BF_L = ( (Trigger11_OK_H && BitFlip_L) );
assign Trigger11Cmd   = ( (Trigger11_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger12 01001110
///////
wire   Trigger12_OK_H, Trigger12_BF_L, Trigger12Cmd;
assign Trigger12_OK_H = ( Input[15:8] == 8'b01001110);
assign Trigger12_BF_L = ( (Trigger12_OK_H && BitFlip_L) );
assign Trigger12Cmd   = ( (Trigger12_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger13 01010011
///////
wire   Trigger13_OK_H, Trigger13_BF_L, Trigger13Cmd;
assign Trigger13_OK_H = ( Input[15:8] == 8'b01010011);
assign Trigger13_BF_L = ( (Trigger13_OK_H && BitFlip_L) );
assign Trigger13Cmd   = ( (Trigger13_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger14 01010101
///////
wire   Trigger14_OK_H, Trigger14_BF_L, Trigger14Cmd;
assign Trigger14_OK_H = ( Input[15:8] == 8'b01010101);
assign Trigger14_BF_L = ( (Trigger14_OK_H && BitFlip_L) );
assign Trigger14Cmd   = ( (Trigger14_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// Trigger15 01010110
///////
wire   Trigger15_OK_H, Trigger15_BF_L, Trigger15Cmd;
assign Trigger15_OK_H = ( Input[15:8] == 8'b01010110);
assign Trigger15_BF_L = ( (Trigger15_OK_H && BitFlip_L) );
assign Trigger15Cmd   = ( (Trigger15_OK_H && (Data_OK_L || BitFlip_L) ) );

///////
// WrReg 01100110
///////
wire   WrReg_OK_H, WrReg_OK_L, WrReg_BF_H, WrReg_BF_L;
assign WrReg_OK_H = ( Input[15:8] == 8'b01100110);
assign WrReg_OK_L = (  Input[7:0] == 8'b01100110);
assign WrReg_BF_H = ((Input[15:8] == 8'b11100110) || (Input[15:8] == 8'b00100110) ||
                      (Input[15:8] == 8'b01000110) || (Input[15:8] == 8'b01110110) ||
                      (Input[15:8] == 8'b01101110) || (Input[15:8] == 8'b01100010) ||
                      (Input[15:8] == 8'b01100100) || (Input[15:8] == 8'b01100111)
                     );
assign WrReg_BF_L = ((Input[7:0] == 8'b11100110) || (Input[7:0] == 8'b00100110) ||
                      (Input[7:0] == 8'b01000110) || (Input[7:0] == 8'b01110110) ||
                      (Input[7:0] == 8'b01101110) || (Input[7:0] == 8'b01100010) ||
                      (Input[7:0] == 8'b01100100) || (Input[7:0] == 8'b01100111)
                     );

///////
// Sync 1000000101111110
///////
wire   Sync_OK, Sync_BF, Sync;
assign Sync_OK = ( Input[15:0] == 16'b1000000101111110);
assign Sync_BF = ((Input[15:0] == 16'b0000000101111110) || (Input[15:0] == 16'b1100000101111110) ||
                  (Input[15:0] == 16'b1010000101111110) || (Input[15:0] == 16'b1001000101111110) ||
                  (Input[15:0] == 16'b1000100101111110) || (Input[15:0] == 16'b1000010101111110) ||
                  (Input[15:0] == 16'b1000001101111110) || (Input[15:0] == 16'b1000000001111110) ||
                  (Input[15:0] == 16'b1000000111111110) || (Input[15:0] == 16'b1000000100111110) ||
                  (Input[15:0] == 16'b1000000101011110) || (Input[15:0] == 16'b1000000101101110) ||
                  (Input[15:0] == 16'b1000000101110110) || (Input[15:0] == 16'b1000000101111010) ||
                  (Input[15:0] == 16'b1000000101111100) || (Input[15:0] == 16'b1000000101111111)
                 );
assign Sync = (Sync_OK) || (Sync_BF);

//////
// Allowed Command combinations
///////
wire   BB_BF, BB;
assign BB_BF = ((BCR_OK_H && BCR_BF_L) || (BCR_BF_H && BCR_OK_L));
assign BB    = ((BCR_OK_H && BCR_OK_L) || BB_BF);
wire   CC_BF, CC;
assign CC_BF = ((Cal_OK_H && Cal_BF_L) || (Cal_BF_H && Cal_OK_L));
assign CC    = ((Cal_OK_H && Cal_OK_L) || CC_BF);
wire   DD;
assign DD    = (Data_OK_H && Data_OK_L);
wire   EE_BF, EE;
assign EE_BF = ((ECR_OK_H && ECR_BF_L) || (ECR_BF_H && ECR_OK_L));
assign EE    = ((ECR_OK_H && ECR_OK_L) || EE_BF);
wire   GG_BF, GG;
assign GG_BF = ((GlobalPulse_OK_H && GlobalPulse_BF_L) || (GlobalPulse_BF_H && GlobalPulse_OK_L));
assign GG    = ((GlobalPulse_OK_H && GlobalPulse_OK_L) || GG_BF);
wire   NN_BF, NN;
assign NN_BF = ((Null_OK_H && Null_BF_L) || (Null_BF_H && Null_OK_L));
assign NN    = ((Null_OK_H && Null_OK_L) || NN_BF);
wire   RR_BF, RR;
assign RR_BF = ((RdReg_OK_H && RdReg_BF_L) || (RdReg_BF_H && RdReg_OK_L));
assign RR    = ((RdReg_OK_H && RdReg_OK_L) || RR_BF);
wire   WW_BF, WW;
assign WW_BF = ((WrReg_OK_H && WrReg_BF_L) || (WrReg_BF_H && WrReg_OK_L));
assign WW    = ((WrReg_OK_H && WrReg_OK_L) || WW_BF);
//
// There has been a BF but it was corrected
wire   CMD_BF;
assign CMD_BF = (Sync_BF || BB_BF || CC_BF || EE_BF || GG_BF || NN_BF || RR_BF || WW_BF);

