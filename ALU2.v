//=============================================
// Register
//=============================================
module Register(clk,in,out);
  parameter n=16;//width
  input clk;
  input [n-1:0] in;
  output [n-1:0] out;
  reg [n-1:0] out;
  always @(posedge clk)
  out = in;
 endmodule


//=============================================
// Adder
//=============================================
module Adder2(a,b,cin,cout,s) ;
parameter n = 16 ;
input [n-1:0] a, b ;
input cin ;
output [n-1:0] s ;
output cout ;
wire [n-1:0] p = a ^ b ;
wire [n-1:0] g = a & b ;
wire [n:0] c = {g | (p & c[n-1:0]), cin} ;
assign s = p ^ c[n-1:0] ;
assign cout = c[n] ;
endmodule

//=============================================
// Subtractor
//=============================================
module Adder1(a,b,cin,cout,s) ;
parameter n = 16 ;
input [n-1:0] a, b ;
input cin ;
output [n-1:0] s ;
output cout ;
assign {cout, s} = a - b + cin ;
endmodule

module AddSub(a,b,sub,s,ovf) ;
parameter n = 16 ;
input [n-1:0] a, b ;
input sub ; // subtract if sub=1, otherwise add
output [n-1:0] s ;
output ovf ; // 1 if overflow
wire c1, c2 ; // carry out of last two bits
assign ovf = c1 ^ c2 ; // overflow if signs don't match
// add non sign bits
Adder1 #(n-1) ai(a[n-2:0],b[n-2:0]^{n-1{sub}},sub,c1,s[n-2:0]) ;
// add sign bits
Adder1 #(1) as(a[n-1],b[n-1]^sub,c1,c2,s[n-1]) ;
endmodule

//=============================================
// Multiplier
//=============================================
module MulAdd(a,b,cin,cout,s) ;
parameter n = 32 ;
input [n-1:0] a, b ;
input cin ;
output [n-1:0] s ;
output cout ;
assign {cout, s} = a + b + cin ;
endmodule

module Mul4(a,b,p) ;
input [15:0] a,b ;
output [15:0] p ;
// form partial products
wire [15:0] pp0 = a & {16{b[0]}} ; // x1
wire [15:0] pp1 = a & {16{b[1]}} ; // x2
wire [15:0] pp2 = a & {16{b[2]}} ; // x4
wire [15:0] pp3 = a & {16{b[3]}} ; // x8

wire [15:0] pp4 = a & {16{b[4]}} ;
wire [15:0] pp5 = a & {16{b[5]}} ;
wire [15:0] pp6 = a & {16{b[6]}} ;
wire [15:0] pp7 = a & {16{b[7]}} ;

wire [15:0] pp8 = a & {16{b[8]}} ;
wire [15:0] pp9 = a & {16{b[9]}} ;
wire [15:0] pp10 = a & {16{b[10]}} ;
wire [15:0] pp11 = a & {16{b[11]}} ;

wire [15:0] pp12 = a & {16{b[12]}} ;
wire [15:0] pp13 = a & {16{b[13]}} ;
wire [15:0] pp14 = a & {16{b[14]}} ;
wire [15:0] pp15 = a & {16{b[15]}} ;

// sum up partial products
wire cout1, cout2, cout3 ;
wire cout4, cout5, cout6 ;
wire cout7, cout8, cout9 ;
wire cout10, cout11, cout12 ;

wire [15:0] s1, s2, s3 ;
wire [15:0] s4, s5, s6 ;
wire [15:0] s7, s8, s9 ;
wire [15:0] s10, s11, s12 ;
MulAdd #(16) a1(pp1, {1'b0,pp0[15:1]}, 1'b0, cout1, s1) ;
MulAdd #(16) a2(pp2, {cout1,s1[15:1]}, 1'b0, cout2, s2) ;
MulAdd #(16) a3(pp3, {cout2,s2[15:1]}, 1'b0, cout3, s3) ;

MulAdd #(16) a4(pp4, {cout3,s3[15:1]}, 1'b0, cout4, s4) ;
MulAdd #(16) a5(pp5, {cout4,s4[15:1]}, 1'b0, cout5, s5) ;
MulAdd #(16) a6(pp6, {cout5,s5[15:1]}, 1'b0, cout6, s6) ;

MulAdd #(16) a7(pp7, {cout6,s6[15:1]}, 1'b0, cout7, s7) ;
MulAdd #(16) a8(pp8, {cout7,s7[15:1]}, 1'b0, cout8, s8) ;
MulAdd #(16) a9(pp9, {cout8,s8[15:1]}, 1'b0, cout9, s9) ;

MulAdd #(16) a10(pp10, {cout9,s9[15:1]}, 1'b0, cout10, s10) ;
MulAdd #(16) a11(pp11, {cout10,s10[15:1]}, 1'b0, cout11, s11) ;
MulAdd #(16) a12(pp12, {cout11,s11[15:1]}, 1'b0, cout12, s12) ;
// collect the result
assign p = {cout12, s12, s11[0], s10[0], s9[0],s8[0],s7[0],s6[0],s5[0],s4[0],s3[0], s2[0], s1[0], pp0[0]} ;
endmodule


//=============================================
// Divider.
// Note: Simple components are used from Dr. Becker's slides
//=============================================

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

module ShiftRight(num, shift, shifted);
   input [15:0] num;
   input [3:0]  shift;
   output [15:0] shifted;

   wire [15:0]   layer0;
   wire [15:0]   layer1;
   wire [15:0]   layer2;

   parameter n = 1;

   // layer 0
   Mux2 #(n) L0_0  (layer0[0],  shift[0], num[1],  num[0]);
   Mux2 #(n) L0_1  (layer0[1],  shift[0], num[2],  num[1]);
   Mux2 #(n) L0_2  (layer0[2],  shift[0], num[3],  num[2]);
   Mux2 #(n) L0_3  (layer0[3],  shift[0], num[4],  num[3]);
   Mux2 #(n) L0_4  (layer0[4],  shift[0], num[5],  num[4]);
   Mux2 #(n) L0_5  (layer0[5],  shift[0], num[6],  num[5]);
   Mux2 #(n) L0_6  (layer0[6],  shift[0], num[7],  num[6]);
   Mux2 #(n) L0_7  (layer0[7],  shift[0], num[8],  num[7]);
   Mux2 #(n) L0_8  (layer0[8],  shift[0], num[9],  num[8]);
   Mux2 #(n) L0_9  (layer0[9],  shift[0], num[10], num[9]);
   Mux2 #(n) L0_10 (layer0[10], shift[0], num[11], num[10]);
   Mux2 #(n) L0_11 (layer0[11], shift[0], num[12], num[11]);
   Mux2 #(n) L0_12 (layer0[12], shift[0], num[13], num[12]);
   Mux2 #(n) L0_13 (layer0[13], shift[0], num[14], num[13]);
   Mux2 #(n) L0_14 (layer0[14], shift[0], num[15], num[14]);
   Mux2 #(n) L0_15 (layer0[15], shift[0], 1'b0,    num[15]);
   // layer 2
   Mux2 #(n) L1_0  (layer1[0],  shift[1], layer0[2],  layer0[0]);
   Mux2 #(n) L1_1  (layer1[1],  shift[1], layer0[3],  layer0[1]);
   Mux2 #(n) L1_2  (layer1[2],  shift[1], layer0[4],  layer0[2]);
   Mux2 #(n) L1_3  (layer1[3],  shift[1], layer0[5],  layer0[3]);
   Mux2 #(n) L1_4  (layer1[4],  shift[1], layer0[6],  layer0[4]);
   Mux2 #(n) L1_5  (layer1[5],  shift[1], layer0[7],  layer0[5]);
   Mux2 #(n) L1_6  (layer1[6],  shift[1], layer0[8],  layer0[6]);
   Mux2 #(n) L1_7  (layer1[7],  shift[1], layer0[9],  layer0[7]);
   Mux2 #(n) L1_8  (layer1[8],  shift[1], layer0[10], layer0[8]);
   Mux2 #(n) L1_9  (layer1[9],  shift[1], layer0[11], layer0[9]);
   Mux2 #(n) L1_10 (layer1[10], shift[1], layer0[12], layer0[10]);
   Mux2 #(n) L1_11 (layer1[11], shift[1], layer0[13], layer0[11]);
   Mux2 #(n) L1_12 (layer1[12], shift[1], layer0[14], layer0[12]);
   Mux2 #(n) L1_13 (layer1[13], shift[1], layer0[15], layer0[13]);
   Mux2 #(n) L1_14 (layer1[14], shift[1], 1'b0,       layer0[14]);
   Mux2 #(n) L1_15 (layer1[15], shift[1], 1'b0,       layer0[15]);
   // layer 2
   Mux2 #(n) L2_0  (layer2[0],  shift[2], layer1[4],  layer1[0]);
   Mux2 #(n) L2_1  (layer2[1],  shift[2], layer1[5],  layer1[1]);
   Mux2 #(n) L2_2  (layer2[2],  shift[2], layer1[6],  layer1[2]);
   Mux2 #(n) L2_3  (layer2[3],  shift[2], layer1[7],  layer1[3]);
   Mux2 #(n) L2_4  (layer2[4],  shift[2], layer1[8],  layer1[4]);
   Mux2 #(n) L2_5  (layer2[5],  shift[2], layer1[9],  layer1[5]);
   Mux2 #(n) L2_6  (layer2[6],  shift[2], layer1[10], layer1[6]);
   Mux2 #(n) L2_7  (layer2[7],  shift[2], layer1[11], layer1[7]);
   Mux2 #(n) L2_8  (layer2[8],  shift[2], layer1[12], layer1[8]);
   Mux2 #(n) L2_9  (layer2[9],  shift[2], layer1[13], layer1[9]);
   Mux2 #(n) L2_10 (layer2[10], shift[2], layer1[14], layer1[10]);
   Mux2 #(n) L2_11 (layer2[11], shift[2], layer1[15], layer1[11]);
   Mux2 #(n) L2_12 (layer2[12], shift[2], 1'b0,       layer1[12]);
   Mux2 #(n) L2_13 (layer2[13], shift[2], 1'b0,       layer1[13]);
   Mux2 #(n) L2_14 (layer2[14], shift[2], 1'b0,       layer1[14]);
   Mux2 #(n) L2_15 (layer2[15], shift[2], 1'b0,       layer1[15]);
   // layer 3
   Mux2 #(n) L3_0  (shifted[0],  shift[3], layer2[8],  layer2[0]);
   Mux2 #(n) L3_1  (shifted[1],  shift[3], layer2[9],  layer2[1]);
   Mux2 #(n) L3_2  (shifted[2],  shift[3], layer2[10], layer2[2]);
   Mux2 #(n) L3_3  (shifted[3],  shift[3], layer2[11], layer2[3]);
   Mux2 #(n) L3_4  (shifted[4],  shift[3], layer2[12], layer2[4]);
   Mux2 #(n) L3_5  (shifted[5],  shift[3], layer2[13], layer2[5]);
   Mux2 #(n) L3_6  (shifted[6],  shift[3], layer2[14], layer2[6]);
   Mux2 #(n) L3_7  (shifted[7],  shift[3], layer2[15], layer2[7]);
   Mux2 #(n) L3_8  (shifted[8],  shift[3], 1'b0,       layer2[8]);
   Mux2 #(n) L3_9  (shifted[9],  shift[3], 1'b0,       layer2[9]);
   Mux2 #(n) L3_10 (shifted[10], shift[3], 1'b0,       layer2[10]);
   Mux2 #(n) L3_11 (shifted[11], shift[3], 1'b0,       layer2[11]);
   Mux2 #(n) L3_12 (shifted[12], shift[3], 1'b0,       layer2[12]);
   Mux2 #(n) L3_13 (shifted[13], shift[3], 1'b0,       layer2[13]);
   Mux2 #(n) L3_14 (shifted[14], shift[3], 1'b0,       layer2[14]);
   Mux2 #(n) L3_15 (shifted[15], shift[3], 1'b0,       layer2[15]);
endmodule // ShiftRight


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

//
// MUX 16 and MUX 32.
// Note: Might not need 32.
//

module Mux16(a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0, s, b);
   parameter k = 16;
   input [k-1:0] a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0;
   input [15:0]   s;
   output [k-1:0] b;
   assign b = (s[0]? a0 :
        (s[1]? a1 :
         (s[2]? a2 :
          (s[3]? a3 :
           (s[4]? a4 :
            (s[5]? a5 :
             (s[6]? a6 :
			  (s[7]? a7 :
			   (s[8]? a8 :
			    (s[9]? a9 :
			     (s[10]? a10 :
			      (s[11]? a11 :
			       (s[12]? a12 :
			        (s[13]? a13 :
			         (s[14]? a14 : a15)))))))))))))));
endmodule // Mux16

module Mux32(a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0, s, b);
   parameter k = 32;
   input [k-1:0] a31, a30, a29, a28, a27, a26, a25, a24, a23, a22, a21, a20,
					a19, a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8,
					a7, a6, a5, a4, a3, a2, a1, a0;
   input [15:0]   s;
   output [k-1:0] b;
   assign b = (s[0]? a0 :
        (s[1]? a1 :
         (s[2]? a2 :
          (s[3]? a3 :
           (s[4]? a4 :
            (s[5]? a5 :
             (s[6]? a6 :
			  (s[7]? a7 :
			   (s[8]? a8 :
			    (s[9]? a9 :
			     (s[10]? a10 :
			      (s[11]? a11 :
			       (s[12]? a12 :
			        (s[13]? a13 :
			         (s[14]? a14 : a15)))))))))))))));
endmodule // Mux32

//
// DECODER and ENCODER
//

//citation DIgital Design for both the decoder and encoder
//Figure 8.3

module Decoder3(n, out);
   input [2:0] n;
   output [7:0] out;
   assign out[0] =  {~n[2] & ~n[1] & ~n[0]};
   assign out[1] =  {~n[2] & ~n[1] &  n[0]};
   assign out[2] =  {~n[2] &  n[1] & ~n[0]};
   assign out[3] =  {~n[2] &  n[1] &  n[0]};
   assign out[4] =  { n[2] & ~n[1] & ~n[0]};
   assign out[5] =  { n[2] & ~n[1] &  n[0]};
   assign out[6] =  { n[2] &  n[1] & ~n[0]};
   assign out[7] =  { n[2] &  n[1] &  n[0]};
endmodule // Decoder3

module Dec(a,b) ;
   parameter n=2 ;
   parameter m=4 ;

   input  [n-1:0] a ;
   output [m-1:0] b ;

   assign b = 1<<a ;
endmodule

//Figure 8.7
module Primed(in, isprime) ;
   input [2:0] in ;
   output      isprime ;
   wire [7:0]  b ;

   // compute the output as the OR of the required minterms
   assign        isprime = b[1] | b[2] | b[3] | b[5] | b[7] ;

   // instantiate a 3->8 decoder
   Dec #(3,8) d(in,b) ;
endmodule

//Figure 8.8
module Dec4to16(a, b) ;
  input  [3:0] a ;
  output [15:0] b ;
  wire [3:0] x, y ;  // output of pre-decoders

  // instantiate pre-decoders
  Dec #(2, 4) d0(a[1:0],x) ;
  Dec #(2, 4) d1(a[3:2],y) ;

  // combine pre-decoder outputs with AND gates
  assign b[3:0] = x & {4{y[0]}} ;
  assign b[7:4] = x & {4{y[1]}} ;
  assign b[11:8] = x & {4{y[2]}} ;
  assign b[15:12] = x & {4{y[3]}} ;
endmodule //Dec4to16

// three input mux with one-hot select (arbitrary width)
// Figure 8.11
module Mux8(a7, a6, a5, a4, a3, a2, a1, a0, s, b);
   parameter k = 5;
   input [k-1:0] a7, a6, a5, a4, a3, a2, a1, a0;
   input [7:0]   s;
   output [k-1:0] b;
   assign b = (s[0]? a0 :
        (s[1]? a1 :
         (s[2]? a2 :
          (s[3]? a3 :
           (s[4]? a4 :
            (s[5]? a5 :
             (s[6]? a6 : a7)))))));
endmodule // Mux8

module Mux3(a2, a1, a0, s, b) ;
  parameter k = 1 ;
  input [k-1:0] a2, a1, a0 ;  // inputs
  input [2:0]   s ; // one-hot select
  output[k-1:0] b ;
  assign b = ({k{s[2]}} & a2) |
                   ({k{s[1]}} & a1) |
                   ({k{s[0]}} & a0) ;
endmodule // Mux3

//Figure 8.12
module Mux3a(a2, a1, a0, s, b) ;
   parameter k = 1 ;
   input [k-1:0] a0, a1, a2 ;  // inputs
   input [2:0]   s ; // one-hot select
   output [k-1:0] b ;
  reg [k-1:0] b ;

  always @(*) begin
    case(s)
      3'b001: b = a0 ;
      3'b010: b = a1 ;
      3'b100: b = a2 ;
      default: b =  {k{1'bx}} ;
    endcase
  end
endmodule // Mux3a

// 3:1 multiplexer with binary select (arbitrary width)
// Figure 8.14
module Muxb3(a2, a1, a0, sb, b) ;
  parameter k = 1 ;
  input [k-1:0] a0, a1, a2 ;  // inputs
  input [1:0]   sb ;          // binary select
  output[k-1:0] b ;
  wire  [2:0]   s ;

  Dec #(2,3) d(sb,s) ;              // decoder converts binary to one-hot
  Mux3 #(k)  m(a2, a1, a0, s, b) ;  // multiplexer selects input
endmodule

// Figure 8.16
module Muxb3a(a2, a1, a0, sb, b) ;
   parameter k = 1 ;
   input [k-1:0] a0, a1, a2 ;  // inputs
   input [1:0]   sb ; // binary select
   output [k-1:0] b ;
   reg [k-1:0]    b ;

   always @(*) begin
      case(sb)
        0: b = a0 ;
        1: b = a1 ;
        2: b = a2 ;
        default: b =  {k{1'bx}};
      endcase
  end
endmodule

//Figure 8.17
module Mux6a(a5, a4, a3, a2, a1, a0, s, b) ;
   parameter k = 1 ;
   input [k-1:0] a5, a4, a3, a2, a1, a0 ;  // inputs
   input [5:0]  s ;                       // one-hot select
   output [k-1:0] b ;
   wire [k-1:0] ba, bb ;
   assign  b = ba | bb ;

   Mux3 #(k) ma(a2, a1, a0, s[2:0], ba) ;
   Mux3 #(k) mb(a5, a4, a3, s[5:3], bb) ;
endmodule

//Test bnuch for the Mux's
module tb_mux ;
   reg [3:0] a2, a1, a0, a3, a4, a5;
   reg [2:0] s;
   reg [1:0] b;
   reg [5:0] s6;

   wire [3:0] o0, o1, o2, o3;

   Mux3a #(4) dut0(a2, a1, a0, s, o0);
   Muxb3 #(4) dut1(a2, a1, a0, b, o1);
   Muxb3a #(4) dut2(a2, a1, a0, b, o2);
   Mux6a #(4) dut3(a5, a4, a3, a2, a1, a0, s6, o3);


   initial begin;
      s = 1;
      s6 = 1;
      b = 0;
      a5 = 4'h7;
      a4 = 4'h8;
      a3 = 4'h9;
      a2 = 4'ha;
      a1 = 4'hb;
      a0 = 4'hc;
      repeat (6) begin
         #10
         s = s<<1;
         s6 = s6 << 1;
         b = b+1;
      end
   end
endmodule // tb_mux

//------------------------------------------------------------------------
//Figure 8.20, including required 8:1 binary select mux and test bench
module Muxb8(a7, a6, a5, a4, a3, a2, a1, a0, sb, b) ;
   parameter k = 1 ;
   input [k-1:0] a0, a1, a2, a3, a4, a5, a6, a7 ;  // inputs
   input [2:0]   sb ; // binary select
   output [k-1:0] b ;
   reg [k-1:0]    b ;

   always @(*) begin
      case(sb)
        0: b = a0 ;
        1: b = a1 ;
        2: b = a2 ;
        3: b = a3 ;
        4: b = a4 ;
        5: b = a5 ;
        6: b = a6 ;
        7: b = a7 ;
        default: b =  {k{1'bx}};
      endcase
  end
endmodule

module Primem(in, isprime) ;
  input [2:0] in ;
  output      isprime ;

  Muxb8 #(1) m(1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, in, isprime) ;
endmodule


module tb_Primem ;
   reg [2:0] in;
   wire      out;
   Primem dut(in, out);
   initial begin
      in = 0;
      repeat (8) begin
         #10
         in = in + 1;
      end
   end
endmodule // test
//------------------------------------------------------------------------

//Figure 8.23
module Enc42(a, b) ;
  input  [3:0] a ;
  output [1:0] b ;
  assign b = {a[3] | a[2], a[3] | a[1]} ;
endmodule // Enc42

// 4:2 encoder
//Figure 8.24
module Enc42b(a, b) ;
  input  [3:0] a ;
  output [1:0] b ;
  reg   [1:0] b ;

  always @(*) begin
    case(a)
      4'b0001: b = 2'd0 ;
      4'b0010: b = 2'd1 ;
      4'b0100: b = 2'd2 ;
      4'b1000: b = 2'd3 ;
      4'b0000: b = 2'd0 ; // to facilitate large encoders
      default: b = 2'bxx ;
    endcase
  end
endmodule // Enc42b
//------------------------------------------------------------------------
//Figure 8.26
module Enc42a(a, b, c) ;
  input  [3:0] a ;
  output [1:0] b ;
  output c ;
  assign b = {a[3] | a[2], a[3] | a[1]} ;
  assign  c  = |a ;
endmodule
// factored encoder
module Enc164(a, b) ;
  input [15:0] a ;
  output[3:0]  b ;
  wire [7:0] c ; // intermediate result of first stage
  wire [3:0] d ; // if any set in group of four

  // four LSB encoders each include 4-bits of the input
  Enc42a e0(a[3:0],  c[1:0],d[0]) ;
  Enc42a e1(a[7:4],  c[3:2],d[1]) ;
  Enc42a e2(a[11:8], c[5:4],d[2]) ;
  Enc42a e3(a[15:12],c[7:6],d[3]) ;

  // MSB encoder takes summaries and gives msb of output
  Enc42 e4(d[3:0], b[3:2]) ;

  // two OR gates combine output of LSB encoders
  assign b[1] = c[1]|c[3]|c[5]|c[7] ;
  assign b[0] = c[0]|c[2]|c[4]|c[6] ;
endmodule // Enc164

//
// Logic Functions
//

module logicFunctions(A, B, C, D, E, F, G, H, I);
   parameter k = 16;
   input [k-1:0] A, B;
   output [k-1:0] C, D, E, F, G, H, I;
   reg [k-1:0] C, D, E, F, G, H, I;
   always @(A or B)
   begin
      //and
      C=A&B;
      //or
      D=A|B;
      //xor
      E=A^B;
      //complement
      F=!A;
      //nor
      G=A~|B;
      //xnor
      H=A~^B;
      //nand
      I=A~&B;
   end
endmodule

module Breadboard(opcode, operand1, operand2,
           result, high, statusOut);
  parameter n = 16;
   input [3:0]   opcode;
   input [15:0]  operand1, operand2;
   output [15:0] result, high;
   output [1:0]  statusOut;
   // opcodes:
   // | code | operation |
   // |------+-----------|
   // | 0000 | no-op     |
   // | 0001 | and       |
   // | 0010 | nand      |
   // | 0011 | or        |
   // | 0100 | nor       |
   // | 0101 | xor       |
   // | 0110 | xnor      |
   // | 0111 | not       |
   // | 1000 | add       |
   // | 1001 | subtract  |
   // | 1010 | multiply  |
   // | 1011 | divide    |
   // | 1100 | shift <-  |
   // | 1101 | shift ->  |
   wire [15:0]   resultAnd, resultNand, resultOr, resultNor, resultXor, resultXnor, resultNot, resultAdd, resultSub, resultDiv;
   wire [15:0] resultMult;
   wire          AddCout, SubCout;
   wire [15:0]   MultHigh, DivRem;

   and G0 [15:0] (resultAnd, operand1, operand2);
   nand G1 [15:0] (resultNand, operand1, operand2);
   or G2 [15:0] (resultOr, operand1, operand2);
   nor G3 [15:0] (resultNor, operand1, operand2);
   xor G4 [15:0] (resultXor, operand1, operand2);
   xnor G5 [15:0] (resultXnor, operand1, operand2);
   not G6 [15:0] (resultNot, operand1);
   Adder2 a(operand1, operand2, 1'b0, AddCout, resultAdd);
   AddSub s(operand1, operand2, 1'b0, resultSub, SubCout);
   Mul4 m(operand1, operand2, resultMult);
   Div d(operand1, operand2, resultDiv, DivRem);
//   ShiftLeft sl(operand1, {operand2[3],operand2[2],operand2[1],operand2[0]}, resultSL);
 //  ShiftRight sr(operand1, {operand2[3],operand2[2],operand2[1],operand2[0]}, resultSR);

   wire [15:0]   arithmetic, logical, arithmeticHigh;
   wire [7:0]    op1hot;

   Decoder3 op({opcode[2], opcode[1], opcode[0]}, op1hot);
   // output
   Mux8 #(n) logicalDecision(resultXor, //0111
                             resultOr, //0110
                             resultAnd,  //0101
                             DivRem,  //0100
                             resultDiv, //0011
                             resultMult, //0010
                             resultSub, //0001
                             resultAdd, //0000
                             op1hot, logical);
   Mux8 #(n) ArithmeticDecision(16'b0000000000000000,  //1111
                                16'b0000000000000000,  //1110
                                16'b0000000000000000,  //1101
                                16'b0000000000000000, //1100
                                16'b0000000000000000,  //1011
                                resultNor, //1010
                                resultNand,  //1001
                                resultNot,  //1000
                                op1hot, arithmetic);
   Mux2 #(n) fin1(result, opcode[3], arithmetic, logical);
   // high

   // if statusOut is non zero then there is an error
   // | code | error          |
   // |------+----------------|
   // |   00 | no error       |
   // |   01 | carry-over     |
   // |   10 | divide by zero |
   // |   11 | overflow       |

endmodule

module testbench();


// ADD 0000
// SUBTRACT 0001
// MULTIPLY 0010
// DIVIDE 0011
// MODULO 0100
// AND 0101
// OR 0110
// XOR 0111
// NOT 1000
// NAND 1001
// NOR 1010
// No operation 1011
// No operation 1100
// No operation 1101
// No operation 1110
// Error Mode (overflow or divide by zero) 1111




   reg clock = 1;
   reg signed [15:0] Val1;
   wire signed [15:0] val1 = Val1;
   reg signed [15:0]  Val2;
   wire signed [15:0] val2 = Val2;
   reg signed [15:0]         Result1, Result2;
   wire signed [15:0]        result1, result2;
   reg signed [31:0]         MultResult;
   reg [1:0]          Status;
   wire [1:0]         status;
   reg [3:0]          Opcode;
   wire [3:0]         opcode = Opcode;

   Breadboard G(opcode, val1, val2, result1, result2, status);

   initial begin
   // //$display("C|      |      |           |      |");
   // //$display("L|Input |ACC   |Instruction|Next  |");
   // //$display("K|#|BIN |#|BIN |CMD|OpCode |#|BIN |Error");
   // //$display("-|-|----|-|----|------|----|-|----|-----");
   // $display("C|                    |                    |           |                    |");
   // $display("L|Input               |ACC                 |Instruction|Next                |");

   // $display("K|#  |BIN             |#  |BIN             |CMD  OpCode|#  |BIN             |Error");
   // $display("-|---|----------------|---|----------------|------|----|---|----------------|-----");
   //    //$display("OPERATIONS:");
   //    // noop6
   //    Opcode = 4'b1011;
   //    Val1 = 0;
   //    Val2 = 0;
   //    #11 Result1 = result1;
   //    Result2 = result2;
   //    Status = status;
	//   $display("-|%3d|%16b|%3d|%16b|NO-OP |%4b|%3d|%16b|%2b", Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
   //    //$display("NOOP: \n\tresult: %b\n\tstatus: %b", Result1, Status);
   //    // and
   //    Opcode = 4'b0101;
   //    Val1 = 16'b0101001001010110;
   //    Val2 = 16'b0010100101010101;
   //    #10 Result1 = result1;
   //    Result2 = result2;
   //    Status = status;
   //    $display("AND: \n\t%b and \n\t%b == \n\t%b", Val1, Val2, Result1);
   //    // nand
   //    Opcode = 4'b1001;
   //    Val1 = 16'b0101001001010110;
   //    Val2 = 16'b0010100101010101;
   //    #10 Result1 = result1;
   //    Result2 = result2;
   //    Status = status;
   //    $display("NAND: \n\t%b nand \n\t%b == \n\t%b", Val1, Val2, Result1);
   //    // or
   //    Opcode = 4'b0110;
   //    Val1 = 16'b0101001001010110;
   //    Val2 = 16'b0010100101010101;
   //    #10 Result1 = result1;
   //    Result2 = result2;
   //    Status = status;
   //    $display("OR: \n\t%b or \n\t%b == \n\t%b", Val1, Val2, Result1);
   //    // nor
   //    Opcode = 4'b1010;
   //    Val1 = 16'b0101001001010110;
   //    Val2 = 16'b0010100101010101;
   //    #10 Result1 = result1;
   //    Result2 = result2;
   //    Status = status;
   //    $display("NOR: \n\t%b nor \n\t%b == \n\t%b", Val1, Val2, Result1);
   //    // xor
   //    Opcode = 4'b0111;
   //    Val1 = 16'b0101001001010110;
   //    Val2 = 16'b0010100101010101;
   //    #10 Result1 = result1;
   //    Result2 = result2;
   //    Status = status;
   //    $display("XOR: \n\t%b xor \n\t%b == \n\t%b", Val1, Val2, Result1);
      $display("C|                    |                    |             |                    |");
      $display("L|Input               |Output              |Instruction  |Next                |");
      $display("K|#  |BIN             |#  |BIN             |Cmd   |Opcode|#  |BIN             |Error");
      $display("-|--------------------|--------------------|------|------|--------------------|------");


      Opcode = 4'b0000;
      Val1 = 100;
      Val2 = 1;
      Result1 = 0;
      clock = 0;
      $display("%b|%3d|%16b|%3d|%16b|ADDITN|%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status);
      #10 Result1 = result1;
      Result2 = result2;
      Status = status;
      clock = ~clock;
      //$display("ADD: \n\t %b + \n\t %b == \n\t%b%b", Val1, Val2, Result2[0], Result1);

      $display("%b|%3d|%16b|%3d|%16b|ADDITN|%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status);
      // sub
      Opcode = 4'b0001;
      Val1 = 150;
      Val2 = Result1;
      clock = ~clock;
      $display("%b|%3d|%16b|%3d|%16b|SUBTRC|%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
      #10 Result1 = result1;
      Result2 = result2;
      Status = status;
      clock = ~clock;
      //$display("SUBTRACT: \n\t %b - \n\t %b == \n\t%b%b", Val1, Val2, Result2[0], Result1);
	   $display("%b|%3d|%16b|%3d|%16b|SUBTRC|%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
      Opcode = 4'b0010;
      Val1 = 7;
      Val2 = Result1;
      clock = ~clock;
      $display("%b|%3d|%16b|%3d|%16b|MULT  |%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
      #10 Result1 = result1;
      Result2 = result2;
      //MultResult = result1 + (MultResult << 16);
      Status = status;
      clock = ~clock;
      //$display("MULTIPLY: \n%16d x \n%16d == \n%16d", Val1, Val2, Result1);
	   $display("%b|%3d|%16b|%3d|%16b|MULT  |%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
      // div
      Opcode = 4'b0011;
      Val1 = 697;
      Val2 = Result1;
      clock = ~clock;
      $display("%b|%3d|%16b|%3d|%16b|DIV   |%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
      #10 Result1 = result1;
      Result2 = result2;
      Status = status;
      clock = ~clock;
      //$display("DIVIDE: \n\t%d / \n\t%d == \n\t%d with remainder %d", Val1, Val2, Result1,Result2);
	   $display("%b|%3d|%16b|%3d|%16b|DIV   |%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
      // modulus
      Opcode = 4'b0100;
      Val1 = 326;
      Val2 = Result1;
      clock = ~clock;
      $display("%b|%3d|%16b|%3d|%16b|MOD   |%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
      #10 Result1 = result1;
      Result2 = result2;
      Status = status;
      clock = ~clock;
      //$display("DIVIDE: \n\t%d / \n\t%d == \n\t%d with remainder %d", Val1, Val2, Result1,Result2);
	   $display("%b|%3d|%16b|%3d|%16b|MOD   |%4b  |%3d|%16b|%2b",clock, Val1,Val1,Val2,Val2,Opcode,Result1,Result1,Status); //new output.
   end
endmodule // testbench
