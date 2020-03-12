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

module tb_N_bit_subtractor;
 // Inputs
 reg [15:0] input1;
 reg [15:0] input2;
 // Outputs
 wire [15:0] answer;

 // Instantiate the Unit Under Test (UUT)
 AddSub uut (
  .a(input1), 
  .b(input2), 
  .sub(1'b0), 
  .s(answer),
  .ovf()
 );

 initial begin
  // Initialize Inputs
  input1 = 1000;
  input2 = 999;
  #100;
  $display("A:          %b", input1);
  $display("B:          %b", input2);
  $display("Difference: %b", answer);
 end
      
endmodule