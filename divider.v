//----------------------------------------------------------------------
//Mohit Bhole
//iverilog
//Source: http://bleyer.org/icarus/

//----------------------------------------------------------------------


//Simple components are used from Dr. Becker's slides
module AddHalf (input a, b, 
                output c_out, sum);

   xor G1(sum, a, b);	// Gate instance names are optional
   and G2(c_out, a, b);

endmodule 

module AddFull (input a, b, c_in, 
                output c_out, sum);	

   wire                w1, w2, w3;				// w1 is c_out; w2 is sum of first half adder
   AddHalf M1 (a, b, w1, w2);
   AddHalf M0 (w2, c_in, w3, sum);
   or (c_out, w1, w3);

endmodule 

module Mux2 (out, signal, in1, in2);

   parameter n = 4;
   input signal;
   input [n-1:0] in1;
   input [n-1:0] in2;
   output [n-1:0] out;
   assign out = (signal? in1 : in2);

endmodule 

module Mux4(a3, a2, a1, a0, s, b);

   parameter k = 5;
   input [k-1:0] a3, a2, a1, a0; // inputs
   input [3:0]   s;              // one-hot select
   output [k-1:0] b;
   assign b = (s[0]? a0 :
               (s[1]? a1 :
                (s[2]? a2 : a3)));

endmodule 

module binaryMux4(a,b,c,d,sel,out);

   parameter n = 16;
   input [n-1:0] a;        // 4-bit input called a
   input [n-1:0] b;        // 4-bit input called b
   input [n-1:0] c;        // 4-bit input called c
   input [n-1:0] d;        // 4-bit input called d
   input [1:0] sel;        // input sel used to select between a,b,c,d
   output [n-1:0] out;     // 4-bit output based on input sel
 
   // When sel[1] is 0, (sel[0]? b:a) is selected and when sel[1] is 1, (sel[0] ? d:c) is taken
   // When sel[0] is 0, a is sent to output, else b and when sel[0] is 0, c is sent to output, else d
   assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);

endmodule

module fourBitPriorityEncoder(in, out, valid);

   input [3:0] in;
   output valid;
   output [1:0] out;
   wire and1;
   and A1(and1, in[1],~in[2]);
   or O1(out[1], in[2],in[3]);
   or O2(out[0],in[3],and1);
   assign valid = in[3] | in[2] | in[1] | in[0];

endmodule

module sixteenBitPriorityEncoder(in, out, valid);

   input [15:0] in;
   output [3:0] out;
   output valid;
   wire [1:0] e1o,e2o,e3o,e4o;
   wire [1:0] o1,o2,o3,o4;
   wire [3:0] con1,con2;
   
   wire v0,v1,v2,v3,v4,v5;
   assign o1[0] = e1o[0] ^ v0;
   assign o2[0] = e2o[0] ^ v1;
   assign o3[0] = e3o[0] ^ v2;
   assign o4[0] = e4o[0] ^ v3;
   assign o1[1] = e1o[1];
   assign o2[1] = e2o[1];
   assign o3[1] = e3o[1];
   assign o4[1] = e4o[1];
   assign con1 = {{o4[0]|o4[1]},{o3[0]|o3[1]},{o2[0]|o2[1]},{o1[0]|o1[1]}};   //used to determine the first 

   fourBitPriorityEncoder e1(in[3:0],e1o,v0);
   fourBitPriorityEncoder e2(in[7:4],e2o,v1);
   fourBitPriorityEncoder e3(in[11:8],e3o,v2);
   fourBitPriorityEncoder e4(in[15:12],e4o,v3);
   fourBitPriorityEncoder e5(con1,out[3:2],v4);                         //We encode con1 to use the out as a selector for the mux
   fourBitPriorityEncoder e6(con2,out[1:0],v5); 
   binaryMux4 #(4) m(in[3:0],in[7:4],in[11:8],in[15:12],out[3:2],con2); //depending on which section we choose the second part of the accordingly
   assign valid = v4 | v5;

endmodule

module Sub(a, b, cin, ovf, diff);

   parameter n = 16;
   input [n-1:0] a, b;
   output [n-1:0] diff;
   input         cin;
   output        ovf;
   wire [n-1:0]   carry;
   wire [n-1:0]   w;
   wire [n-1:0]   xorWire;
   assign xorWire = {n{1'b1}};                                          //fill cinWire up with the cin value n times so it can be xor'd
   assign w = b ^ xorWire;                                              //xor the values
   genvar i;                                                            //variable for iteration in generate for loop
   generate                                                             //generate code over and over
      for (i = 0;i<n;i=i+1) begin                                       //generate multiple instances
         if(i==0)                                                       //For the first time take the cin
            AddFull A0(a[i], w[i], cin, carry[i], diff[i]);
         else                                                           //otherwise just do the usual
            AddFull A(a[i], w[i], carry[i-1], carry[i], diff[i]);
         end
      assign ovf = carry[n-1]^cin;                                      //assign the cout to the proper value
   endgenerate

endmodule 

module ShiftLeft(num, shift, shifted);

   input [15:0]  num;
   input [3:0]   shift;                                                 // max shift amount is 15
   output [15:0] shifted;
   
   wire [15:0]   layer0;
   wire [15:0]   layer1;
   wire [15:0]   layer2;

   parameter n = 1;
   // layer 0
   Mux2 #(n) SL0_0  (layer0[0],  shift[0], 1'b0,    num[0]);
   Mux2 #(n) SL0_1  (layer0[1],  shift[0], num[0],  num[1]);
   Mux2 #(n) SL0_2  (layer0[2],  shift[0], num[1],  num[2]);
   Mux2 #(n) SL0_3  (layer0[3],  shift[0], num[2],  num[3]);
   Mux2 #(n) SL0_4  (layer0[4],  shift[0], num[3],  num[4]);
   Mux2 #(n) SL0_5  (layer0[5],  shift[0], num[4],  num[5]);
   Mux2 #(n) SL0_6  (layer0[6],  shift[0], num[5],  num[6]);
   Mux2 #(n) SL0_7  (layer0[7],  shift[0], num[6],  num[7]);
   Mux2 #(n) SL0_8  (layer0[8],  shift[0], num[7],  num[8]);
   Mux2 #(n) SL0_9  (layer0[9],  shift[0], num[8],  num[9]);
   Mux2 #(n) SL0_10 (layer0[10], shift[0], num[9],  num[10]);
   Mux2 #(n) SL0_11 (layer0[11], shift[0], num[10], num[11]);
   Mux2 #(n) SL0_12 (layer0[12], shift[0], num[11], num[12]);
   Mux2 #(n) SL0_13 (layer0[13], shift[0], num[12], num[13]);
   Mux2 #(n) SL0_14 (layer0[14], shift[0], num[13], num[14]);
   Mux2 #(n) SL0_15 (layer0[15], shift[0], num[14], num[15]);
   // layer 2
   Mux2 #(n) SL1_0  (layer1[0],  shift[1], 1'b0,       layer0[0]);
   Mux2 #(n) SL1_1  (layer1[1],  shift[1], 1'b0,       layer0[1]);
   Mux2 #(n) SL1_2  (layer1[2],  shift[1], layer0[0],  layer0[2]);
   Mux2 #(n) SL1_3  (layer1[3],  shift[1], layer0[1],  layer0[3]);
   Mux2 #(n) SL1_4  (layer1[4],  shift[1], layer0[2],  layer0[4]);
   Mux2 #(n) SL1_5  (layer1[5],  shift[1], layer0[3],  layer0[5]);
   Mux2 #(n) SL1_6  (layer1[6],  shift[1], layer0[4],  layer0[6]);
   Mux2 #(n) SL1_7  (layer1[7],  shift[1], layer0[5],  layer0[7]);
   Mux2 #(n) SL1_8  (layer1[8],  shift[1], layer0[6],  layer0[8]);
   Mux2 #(n) SL1_9  (layer1[9],  shift[1], layer0[7],  layer0[9]);
   Mux2 #(n) SL1_10 (layer1[10], shift[1], layer0[8],  layer0[10]);
   Mux2 #(n) SL1_11 (layer1[11], shift[1], layer0[9],  layer0[11]);
   Mux2 #(n) SL1_12 (layer1[12], shift[1], layer0[10], layer0[12]);
   Mux2 #(n) SL1_13 (layer1[13], shift[1], layer0[11], layer0[13]);
   Mux2 #(n) SL1_14 (layer1[14], shift[1], layer0[12], layer0[14]);
   Mux2 #(n) SL1_15 (layer1[15], shift[1], layer0[13], layer0[15]);
   // layer 2
   Mux2 #(n) SL2_0  (layer2[0],  shift[2], 1'b0,       layer1[0]);
   Mux2 #(n) SL2_1  (layer2[1],  shift[2], 1'b0,       layer1[1]);
   Mux2 #(n) SL2_2  (layer2[2],  shift[2], 1'b0,       layer1[2]);
   Mux2 #(n) SL2_3  (layer2[3],  shift[2], 1'b0,       layer1[3]);
   Mux2 #(n) SL2_4  (layer2[4],  shift[2], layer1[0],  layer1[4]);
   Mux2 #(n) SL2_5  (layer2[5],  shift[2], layer1[1],  layer1[5]);
   Mux2 #(n) SL2_6  (layer2[6],  shift[2], layer1[2],  layer1[6]);
   Mux2 #(n) SL2_7  (layer2[7],  shift[2], layer1[3],  layer1[7]);
   Mux2 #(n) SL2_8  (layer2[8],  shift[2], layer1[4],  layer1[8]);
   Mux2 #(n) SL2_9  (layer2[9],  shift[2], layer1[5],  layer1[9]);
   Mux2 #(n) SL2_10 (layer2[10], shift[2], layer1[6],  layer1[10]);
   Mux2 #(n) SL2_11 (layer2[11], shift[2], layer1[7],  layer1[11]);
   Mux2 #(n) SL2_12 (layer2[12], shift[2], layer1[8],  layer1[12]);
   Mux2 #(n) SL2_13 (layer2[13], shift[2], layer1[9],  layer1[13]);
   Mux2 #(n) SL2_14 (layer2[14], shift[2], layer1[10], layer1[14]);
   Mux2 #(n) SL2_15 (layer2[15], shift[2], layer1[11], layer1[15]);
   // layer 3
   Mux2 #(n) SL3_0  (shifted[0],  shift[3], 1'b0,      layer2[0]);
   Mux2 #(n) SL3_1  (shifted[1],  shift[3], 1'b0,      layer2[1]);
   Mux2 #(n) SL3_2  (shifted[2],  shift[3], 1'b0,      layer2[2]);
   Mux2 #(n) SL3_3  (shifted[3],  shift[3], 1'b0,      layer2[3]);
   Mux2 #(n) SL3_4  (shifted[4],  shift[3], 1'b0,      layer2[4]);
   Mux2 #(n) SL3_5  (shifted[5],  shift[3], 1'b0,      layer2[5]);
   Mux2 #(n) SL3_6  (shifted[6],  shift[3], 1'b0,      layer2[6]);
   Mux2 #(n) SL3_7  (shifted[7],  shift[3], 1'b0,      layer2[7]);
   Mux2 #(n) SL3_8  (shifted[8],  shift[3], layer2[0], layer2[8]);
   Mux2 #(n) SL3_9  (shifted[9],  shift[3], layer2[1], layer2[9]);
   Mux2 #(n) SL3_10 (shifted[10], shift[3], layer2[2], layer2[10]);
   Mux2 #(n) SL3_11 (shifted[11], shift[3], layer2[3], layer2[11]);
   Mux2 #(n) SL3_12 (shifted[12], shift[3], layer2[4], layer2[12]);
   Mux2 #(n) SL3_13 (shifted[13], shift[3], layer2[5], layer2[13]);
   Mux2 #(n) SL3_14 (shifted[14], shift[3], layer2[6], layer2[14]);
   Mux2 #(n) SL3_15 (shifted[15], shift[3], layer2[7], layer2[15]);

endmodule 


module changeSign(sign,num,out);

   parameter n= 16;
   input sign;
   input [n-1:0] num;
   output [n-1:0] out;
   wire valid;
   wire [n-1:0] flippedNum;
   Sub #(n) S(16'b0,num,1'b1,valid,flippedNum);
   Mux2 #(n) m(out,sign,flippedNum,num);

endmodule

module flipNegativeNum(sign,num1,num2,out1,out2);

   parameter n = 16;
   input sign;
   input [n-1:0] num1,num2;
   output [n-1:0] out1,out2;
   wire [n-1:0] flippedNum1,flippedNum2, tempIn1, tempIn2;
   changeSign #(n) cS1(sign,num1,flippedNum1);
   changeSign #(n) cS2(sign,num2,flippedNum2);
   Mux2 #(n) M1(out1,num1[n-1],flippedNum1,num1);
   Mux2 #(n) M2(out2,num2[n-1],flippedNum2,num2);

endmodule

module equalBitsDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend,divisor;
   output [15:0] quotient, rem;
   assign quotient[15:1] = 14'b0;
   divideModule divideM(dividend,divisor,quotient[0],rem);

endmodule

module oneShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1;
   wire [15:0] rem13;
   
   assign quotient[15:2] = 12'b0;

   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM13(dividend,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module twoShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3;
   wire [15:0] rem11,rem12,rem13;
   
   assign quotient[15:3] = 12'b0;

   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM12(dividend,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module threeShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3;
   wire [15:0] rem11,rem12,rem13;
   
   assign quotient[15:4] = 11'b0;

   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM11(dividend,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module fourShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4;
   wire [15:0] rem10,rem11,rem12,
               rem13;

   assign quotient[15:5] = 11'b0;

   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);
   
   divideModule divideM10(dividend,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module fiveShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5;
   wire [15:0] rem9,rem10,rem11,
               rem12,rem13;

   assign quotient[15:6] = 10'b0;

   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM9(dividend,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module sixShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6;
   wire [15:0] rem8,rem9,rem10,
               rem11,rem12,rem13;

   assign quotient[15:7] = 9'b0;

   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM8(dividend,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module sevenShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6,
               shiftedDivisor7;
   wire [15:0] rem7,rem8,rem9,
               rem10,rem11,rem12,
               rem13;
   
   assign quotient[15:8] = 8'b0;

   ShiftLeft sll7(divisor,4'b0111,shiftedDivisor7);
   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM7(dividend,shiftedDivisor7,quotient[7],rem7);
   divideModule divideM8(rem7,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module eightShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6,
               shiftedDivisor7,shiftedDivisor8,shiftedDivisor9;
   wire [15:0] rem6,rem7,rem8,
               rem9,rem10,rem11,
               rem12,rem13;

   assign quotient[15:9] = 7'b0;

   ShiftLeft sll8(divisor,4'b1000,shiftedDivisor8);
   ShiftLeft sll7(divisor,4'b0111,shiftedDivisor7);
   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM6(dividend,shiftedDivisor8,quotient[8],rem6);
   divideModule divideM7(rem6,shiftedDivisor7,quotient[7],rem7);
   divideModule divideM8(rem7,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module nineShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6,
               shiftedDivisor7,shiftedDivisor8,shiftedDivisor9;
   wire [15:0] rem5,rem6,rem7,
               rem8,rem9,rem10,
               rem11,rem12,rem13;

   assign quotient[15:10] = 6'b0;

   ShiftLeft sll9(divisor,4'b1001,shiftedDivisor9);
   ShiftLeft sll8(divisor,4'b1000,shiftedDivisor8);
   ShiftLeft sll7(divisor,4'b0111,shiftedDivisor7);
   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM5(dividend,shiftedDivisor9,quotient[9],rem5);
   divideModule divideM6(rem5,shiftedDivisor8,quotient[8],rem6);
   divideModule divideM7(rem6,shiftedDivisor7,quotient[7],rem7);
   divideModule divideM8(rem7,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module tenShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6,
               shiftedDivisor7,shiftedDivisor8,shiftedDivisor9,
               shiftedDivisor10;
   wire [15:0] rem4,rem5,rem6,
               rem7,rem8,rem9,
               rem10,rem11,rem12,
               rem13;
               
   assign quotient[15:11] = 5'b0;

   ShiftLeft sll10(divisor,4'b1010,shiftedDivisor10);
   ShiftLeft sll9(divisor,4'b1001,shiftedDivisor9);
   ShiftLeft sll8(divisor,4'b1000,shiftedDivisor8);
   ShiftLeft sll7(divisor,4'b0111,shiftedDivisor7);
   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM4(dividend,shiftedDivisor10,quotient[10],rem4);
   divideModule divideM5(rem4,shiftedDivisor9,quotient[9],rem5);
   divideModule divideM6(rem5,shiftedDivisor8,quotient[8],rem6);
   divideModule divideM7(rem6,shiftedDivisor7,quotient[7],rem7);
   divideModule divideM8(rem7,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module elevenShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6,
               shiftedDivisor7,shiftedDivisor8,shiftedDivisor9,
               shiftedDivisor10,shiftedDivisor11;
   wire [15:0] rem3,rem4,rem5,
               rem6,rem7,rem8,
               rem9,rem10,rem11,
               rem12,rem13;
               
   assign quotient[15:12] = 4'b0;

   ShiftLeft sll11(divisor,4'b1011,shiftedDivisor11);
   ShiftLeft sll10(divisor,4'b1010,shiftedDivisor10);
   ShiftLeft sll9(divisor,4'b1001,shiftedDivisor9);
   ShiftLeft sll8(divisor,4'b1000,shiftedDivisor8);
   ShiftLeft sll7(divisor,4'b0111,shiftedDivisor7);
   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM3(dividend,shiftedDivisor11,quotient[11],rem3);
   divideModule divideM4(rem3,shiftedDivisor10,quotient[10],rem4);
   divideModule divideM5(rem4,shiftedDivisor9,quotient[9],rem5);
   divideModule divideM6(rem5,shiftedDivisor8,quotient[8],rem6);
   divideModule divideM7(rem6,shiftedDivisor7,quotient[7],rem7);
   divideModule divideM8(rem7,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module twelveShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6,
               shiftedDivisor7,shiftedDivisor8,shiftedDivisor9,
               shiftedDivisor10,shiftedDivisor11,shiftedDivisor12;
   wire [15:0] rem2,rem3,
               rem4,rem5,rem6,
               rem7,rem8,rem9,
               rem10,rem11,rem12,
               rem13;

   assign quotient[15:13] = 3'b0;
   
   ShiftLeft sll12(divisor,4'b1100,shiftedDivisor12);
   ShiftLeft sll11(divisor,4'b1011,shiftedDivisor11);
   ShiftLeft sll10(divisor,4'b1010,shiftedDivisor10);
   ShiftLeft sll9(divisor,4'b1001,shiftedDivisor9);
   ShiftLeft sll8(divisor,4'b1000,shiftedDivisor8);
   ShiftLeft sll7(divisor,4'b0111,shiftedDivisor7);
   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM2(dividend,shiftedDivisor12,quotient[12],rem2);
   divideModule divideM3(rem2,shiftedDivisor11,quotient[11],rem3);
   divideModule divideM4(rem3,shiftedDivisor10,quotient[10],rem4);
   divideModule divideM5(rem4,shiftedDivisor9,quotient[9],rem5);
   divideModule divideM6(rem5,shiftedDivisor8,quotient[8],rem6);
   divideModule divideM7(rem6,shiftedDivisor7,quotient[7],rem7);
   divideModule divideM8(rem7,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module thirteenShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6,
               shiftedDivisor7,shiftedDivisor8,shiftedDivisor9,
               shiftedDivisor10,shiftedDivisor11,shiftedDivisor12,
               shiftedDivisor13;
   wire [15:0] rem1,rem2,rem3,
               rem4,rem5,rem6,
               rem7,rem8,rem9,
               rem10,rem11,rem12,
               rem13;
               
   assign quotient[15:14] = 2'b0;

   ShiftLeft sll13(divisor,4'b1101,shiftedDivisor13);
   ShiftLeft sll12(divisor,4'b1100,shiftedDivisor12);
   ShiftLeft sll11(divisor,4'b1011,shiftedDivisor11);
   ShiftLeft sll10(divisor,4'b1010,shiftedDivisor10);
   ShiftLeft sll9(divisor,4'b1001,shiftedDivisor9);
   ShiftLeft sll8(divisor,4'b1000,shiftedDivisor8);
   ShiftLeft sll7(divisor,4'b0111,shiftedDivisor7);
   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM1(dividend,shiftedDivisor13,quotient[13],rem1);
   divideModule divideM2(rem1,shiftedDivisor12,quotient[12],rem2);
   divideModule divideM3(rem2,shiftedDivisor11,quotient[11],rem3);
   divideModule divideM4(rem3,shiftedDivisor10,quotient[10],rem4);
   divideModule divideM5(rem4,shiftedDivisor9,quotient[9],rem5);
   divideModule divideM6(rem5,shiftedDivisor8,quotient[8],rem6);
   divideModule divideM7(rem6,shiftedDivisor7,quotient[7],rem7);
   divideModule divideM8(rem7,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module fourteenShiftDivide(dividend,divisor, quotient, rem);

   input [15:0] dividend;
   input [15:0] divisor;
   output [15:0] quotient, rem;
   wire [15:0] shiftedDivisor1,shiftedDivisor2,shiftedDivisor3,
               shiftedDivisor4,shiftedDivisor5,shiftedDivisor6,
               shiftedDivisor7,shiftedDivisor8,shiftedDivisor9,
               shiftedDivisor10,shiftedDivisor11,shiftedDivisor12,
               shiftedDivisor13,shiftedDivisor14;
   wire [15:0] rem0,rem1,rem2,
               rem3,rem4,rem5,
               rem6, rem7,rem8,
               rem9,rem10,rem11,
               rem12,rem13,rem14;

   assign quotient[15] = 1'b0;

   ShiftLeft sll14(divisor,4'b1110,shiftedDivisor14);
   ShiftLeft sll13(divisor,4'b1101,shiftedDivisor13);
   ShiftLeft sll12(divisor,4'b1100,shiftedDivisor12);
   ShiftLeft sll11(divisor,4'b1011,shiftedDivisor11);
   ShiftLeft sll10(divisor,4'b1010,shiftedDivisor10);
   ShiftLeft sll9(divisor,4'b1001,shiftedDivisor9);
   ShiftLeft sll8(divisor,4'b1000,shiftedDivisor8);
   ShiftLeft sll7(divisor,4'b0111,shiftedDivisor7);
   ShiftLeft sll6(divisor,4'b0110,shiftedDivisor6);
   ShiftLeft sll5(divisor,4'b0101,shiftedDivisor5);
   ShiftLeft sll4(divisor,4'b0100,shiftedDivisor4);
   ShiftLeft sll3(divisor,4'b0011,shiftedDivisor3);
   ShiftLeft sll2(divisor,4'b0010,shiftedDivisor2);
   ShiftLeft sll1(divisor,4'b0001,shiftedDivisor1);

   divideModule divideM0(dividend,shiftedDivisor14,quotient[14],rem0);
   divideModule divideM1(rem0,shiftedDivisor13,quotient[13],rem1);
   divideModule divideM2(rem1,shiftedDivisor12,quotient[12],rem2);
   divideModule divideM3(rem2,shiftedDivisor11,quotient[11],rem3);
   divideModule divideM4(rem3,shiftedDivisor10,quotient[10],rem4);
   divideModule divideM5(rem4,shiftedDivisor9,quotient[9],rem5);
   divideModule divideM6(rem5,shiftedDivisor8,quotient[8],rem6);
   divideModule divideM7(rem6,shiftedDivisor7,quotient[7],rem7);
   divideModule divideM8(rem7,shiftedDivisor6,quotient[6],rem8);
   divideModule divideM9(rem8,shiftedDivisor5,quotient[5],rem9);
   divideModule divideM10(rem9,shiftedDivisor4,quotient[4],rem10);
   divideModule divideM11(rem10,shiftedDivisor3,quotient[3],rem11);
   divideModule divideM12(rem11,shiftedDivisor2,quotient[2],rem12);
   divideModule divideM13(rem12,shiftedDivisor1,quotient[1],rem13);
   divideModule divideM14(rem13,divisor,quotient[0],rem);

endmodule

module divideByOne(dividend,divisor, quotient, rem);

   //If you have to shift the dividend over fifteen then you are dividing by 1
   input [15:0] dividend,divisor;
   output [15:0] quotient, rem;
   assign quotient = dividend;
   assign rem = 0;

endmodule

module longDivisionMux(input [15:0] D0,D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,input [3:0] selector,output [15:0] out);

   wire [15:0] out1,out2,out3,out4;
   binaryMux4 m1(D0,D1,D2,D3,selector[1:0],out1);
   binaryMux4 m2(D4,D5,D6,D7,selector[1:0],out2);
   binaryMux4 m3(D8,D9,D10,D11,selector[1:0],out3);
   binaryMux4 m4(D12,D13,D14,D15,selector[1:0],out4);
   binaryMux4 final(out1,out2,out3,out4,selector[3:2],out);

endmodule

module sixteenBitCompare(a,b,eq,gt,lt);

   input [15:0] a,b;
   output eq,gt,lt;
   wire cout;
   wire [15:0] out;
   Sub #(16) s(a,b,1'b1,cout,out);
   assign eq = ~out[15]&~out[14]&~out[13]&~out[12]&~out[11]&~out[10]&~out[9]&~out[8]&~out[7]&~out[6]&~out[5]&~out[4]&~out[3]&~out[2]&~out[1]&~out[0];
   assign gt = ~out[15]^eq;
   assign lt = out[15]^eq;

endmodule

module divideModule(dividend, divisor, quotientBit, result);

   parameter n = 16;
   input [n-1:0] dividend;
   input [n-1:0] divisor;
   output quotientBit;
   output [n-1:0] result;
   wire [n-1:0] difference;
   wire ovf,gt,lt,eq;
   Sub s(dividend,divisor,1'b1,ovf,difference);
   sixteenBitCompare c(divisor,dividend,eq,gt,lt);
   Mux2 #(1) m0(quotientBit,gt,1'b0,1'b1);
   Mux2 #(n) m(result, quotientBit, difference, dividend);

endmodule

module Div(dividend, divisor, quotient, rem);

   input [15:0] dividend, divisor;
   output [15:0] quotient, rem;
   wire [15:0] quotient0, quotient1,quotient2,
               quotient3,quotient4,quotient5,
               quotient6,quotient7,quotient8,
               quotient9,quotient10,quotient11,
               quotient12,quotient13,quotient14,
               quotient15;
   wire [15:0] rem0,rem1,rem2,
            rem3,rem4,rem5,
            rem6, rem7,rem8,
            rem9,rem10,rem11,
            rem12,rem13,rem14,
            rem15;
   wire [15:0] ovf,valid0,valid1,valid2;
   wire [3:0] dendSize,sorSize,diffSize,tempDiff;
   wire subOverflow;
   wire sign = dividend[15] ^ divisor[15];
   wire doubleNegative = dividend[15] & divisor[15];
   wire [15:0] dividendFixed, divisorFixed;
   wire [15:0] divisorOneFlipped, dividendOneFlipped, divisorFlipped, dividendFlipped;
   wire [15:0] quotientOut, remOut;
   flipNegativeNum fNN(sign,dividend,divisor,dividendOneFlipped,divisorOneFlipped);
   changeSign cS0(doubleNegative,dividend,dividendFlipped);
   changeSign cS1(doubleNegative,divisor,divisorFlipped);
   Mux2 #(16) muxEnd(dividendFixed,doubleNegative,dividendFlipped,dividendOneFlipped);
   Mux2 #(16) muxSor(divisorFixed,doubleNegative,divisorFlipped,divisorOneFlipped);
   sixteenBitPriorityEncoder e(dividendFixed, dendSize, valid0[0]);
   sixteenBitPriorityEncoder e1(divisorFixed, sorSize, valid1[0]);
   wire eq,gt,lt,gteq;
   assign gteq = gt|eq;
   sixteenBitCompare sBC(dividendFixed,divisorFixed,eq,gt,lt);
   Sub #(4) S2(dendSize,sorSize,1'b1,valid2[0],tempDiff);
   assign diffSize = tempDiff & {4{gteq}};


   //THere's different modules for shifting left n number of times and then dividing
   //I cou'dnt figure out a way to use a generate for loop with a variable inside so I just made 16 modules
   equalBitsDivide d0(dividendFixed,divisorFixed,quotient0,rem0);
   oneShiftDivide d1(dividendFixed,divisorFixed,quotient1,rem1);
   twoShiftDivide d2(dividendFixed,divisorFixed,quotient2,rem2);
   threeShiftDivide d3(dividendFixed,divisorFixed,quotient3,rem3);
   fourShiftDivide d4(dividendFixed,divisorFixed,quotient4,rem4);
   fiveShiftDivide d5(dividendFixed,divisorFixed,quotient5,rem5);
   sixShiftDivide d6(dividendFixed,divisorFixed,quotient6,rem6);
   sevenShiftDivide d7(dividendFixed,divisorFixed,quotient7,rem7);
   eightShiftDivide d8(dividendFixed,divisorFixed,quotient8,rem8);
   nineShiftDivide d9(dividendFixed,divisorFixed,quotient9,rem9);
   tenShiftDivide d10(dividendFixed,divisorFixed,quotient10,rem10);
   elevenShiftDivide d11(dividendFixed,divisorFixed,quotient11,rem11);
   twelveShiftDivide d12(dividendFixed,divisorFixed,quotient12,rem12);
   thirteenShiftDivide d13(dividendFixed,divisorFixed,quotient13,rem13);
   fourteenShiftDivide d14(dividendFixed,divisorFixed,quotient14,rem14);
   divideByOne d15(dividendFixed,divisorFixed,quotient15,rem15);
   
   longDivisionMux muxQ(quotient0,quotient1,quotient2,quotient3,quotient4,quotient5,
                     quotient6,quotient7,quotient8,quotient9,quotient10,quotient11,
                     quotient12,quotient13,quotient14,quotient15,diffSize,quotientOut);
   longDivisionMux muxR(rem0,rem1,rem2,rem3,rem4,rem5,
                     rem6,rem7,rem8,rem9,rem10,rem11,
                     rem12,rem13,rem14,rem15,diffSize,remOut);
   changeSign #(16) fNNQ(sign,quotientOut,quotient);
   changeSign #(16) fNNR(dividend[15],remOut,rem);   

endmodule // Div

module testbench();
    
   wire signed [15:0] A,B;
   wire [15:0] resultDiv;
   wire [15:0] DivRem;
   assign A=25;
   assign B=5;
   Div d(A, B, resultDiv, DivRem);

   initial begin
      #1
      $display("Divider:\n Dividing \t%d \tby \t%d\n Quotient: \t%d, \tRemainder: %d\n\n", A, B, resultDiv, DivRem);
   end

endmodule // testbench