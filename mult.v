// multi-bit adder - behavioral
//From slides 

module Adder1(a,b,cin,cout,s) ;
parameter n = 32 ;
input [n-1:0] a, b ;
input cin ;
output [n-1:0] s ;
output cout ;
assign {cout, s} = a + b + cin ;
endmodule

module Mul4(a,b,p) ;
input [15:0] a,b ;
output [31:0] p ;
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
Adder1 #(16) a1(pp1, {1'b0,pp0[15:1]}, 1'b0, cout1, s1) ;
Adder1 #(16) a2(pp2, {cout1,s1[15:1]}, 1'b0, cout2, s2) ;
Adder1 #(16) a3(pp3, {cout2,s2[15:1]}, 1'b0, cout3, s3) ;

Adder1 #(16) a4(pp4, {cout3,s3[15:1]}, 1'b0, cout4, s4) ;
Adder1 #(16) a5(pp5, {cout4,s4[15:1]}, 1'b0, cout5, s5) ;
Adder1 #(16) a6(pp6, {cout5,s5[15:1]}, 1'b0, cout6, s6) ;

Adder1 #(16) a7(pp7, {cout6,s6[15:1]}, 1'b0, cout7, s7) ;
Adder1 #(16) a8(pp8, {cout7,s7[15:1]}, 1'b0, cout8, s8) ;
Adder1 #(16) a9(pp9, {cout8,s8[15:1]}, 1'b0, cout9, s9) ;

Adder1 #(16) a10(pp10, {cout9,s9[15:1]}, 1'b0, cout10, s10) ;
Adder1 #(16) a11(pp11, {cout10,s10[15:1]}, 1'b0, cout11, s11) ;
Adder1 #(16) a12(pp12, {cout11,s11[15:1]}, 1'b0, cout12, s12) ;
// collect the result
assign p = {cout12, s12, s11[0], s10[0], s9[0],s8[0],s7[0],s6[0],s5[0],s4[0],s3[0], s2[0], s1[0], pp0[0]} ;
endmodule



module tb_multiplier;
 // Inputs
 reg [15:0] input1;
 reg [15:0] input2;
 // Outputs
 wire [31:0] answer;

 // Instantiate the Unit Under Test (UUT)
 Mul4 uut (
  .a(input1), 
  .b(input2), 
  .p(answer)
 );

 initial begin
  // Initialize Inputs
  input1 = 50;
  input2 = 50;
  #100;
  $display("A:                         %b", input1);
  $display("B:                         %b", input2);
  $display("Product =  %b", answer);
 end
      
endmodule