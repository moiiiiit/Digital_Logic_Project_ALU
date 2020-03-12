

module Adder2(a,b,cin,cout,s) ;
parameter n = 8 ;
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

module tb_N_bit_adder;
 // Inputs
 reg [7:0] input1;
 reg [7:0] input2;
 // Outputs
 wire [7:0] answer;

 // Instantiate the Unit Under Test (UUT)
 Adder2 uut (
  .a(input1), 
  .b(input2), 
  .cin(1'b0),
  .cout(),
  .s(answer)
 );

 initial begin
  // Initialize Inputs
  input1 = 1;
  input2 = 200;
  #100;
  $display("A:     %b", input1);
  $display("B:     %b", input2);
  $display("Sum =  %b", answer);
 end
      
endmodule