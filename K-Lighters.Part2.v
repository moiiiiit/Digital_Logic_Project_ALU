//----------------------------------------------------------------------
//K-Lighters
//iverilog
//Source: http://bleyer.org/icarus/
//ALU Project
//----------------------------------------------------------------------

module Divide(y, x, q, r) ;
   input [5:0] y ; // dividend
   input [2:0] x ; // divisor
   output [5:0] q ; // quotient
   output [2:0] r ; // remainder
   wire co5, co4, co3, co2, co1, co0 ; // carry out of adders
   wire sum5 ; // sum out of adder - stage 1
   Adder1 #(1) sub5(y[5],~x[0],1'b1, co5, sum5) ;
   assign q[5] = co5 & ~(|x[2:1]) ; // if x<<5 bigger than y, q[5] is 0
   wire [5:0] r4 = q[5]? {sum5,y[4:0]} : y ;
   wire [1:0] sum4 ; // sum out of the adder - stage 2
   Adder1 #(2) sub4(r4[5:4],~x[1:0],1'b1, co4, sum4) ;
   assign q[4] = co4 & ~x[2] ; // compare
   wire [5:0] r3 = q[4]? {sum4,r4[3:0]} : r4 ;
   wire [2:0] sum3 ; // sum out of the adder - stage 3
   Adder1 #(3) sub3(r3[5:3],~x,1'b1, co3, sum3) ;
   assign q[3] = co3 ; // compare
   wire [5:0] r2 = q[3]? {sum3,r3[2:0]} : r3 ;
   wire [3:0] sum2 ; // sum out of the adder - stage 4
   Adder1 #(4) sub2(r2[5:2],{1'b1,~x},1'b1, co2, sum2) ;
   assign q[2] = co2 ; // compare
   wire [4:0] r1 = q[2]? {sum2[2:0],r2[1:0]} : r2[4:0] ; // msb is zero, drop it
   wire [3:0] sum1 ; // sum out of the adder - stage 5
   Adder1 #(4) sub1(r1[4:1],{1'b1,~x},1'b1, co1, sum1) ;
   assign q[1] = co1 ; // compare
   wire [3:0] r0 = q[1]? {sum1[2:0],r1[0]} : r1[3:0] ; // msb is zero, drop it
   wire [2:0] sum0 ; // sum out of the adder - stage 6
   Adder1 #(4) sub0(r0[3:0],{1'b1,~x},1'b1, co0, sum0) ;
   assign q[0] = co0 ; // compare
   assign r = q[0]? sum0[2:0] : r0[2:0] ; // msb is zero, drop it
endmodule

module Mul4(a,b,p) ;
   input [3:0] a,b ;
   output [7:0] p ;
   // form partial products
   wire [3:0] pp0 = a & {4{b[0]}} ; // x1
   wire [3:0] pp1 = a & {4{b[1]}} ; // x2
   wire [3:0] pp2 = a & {4{b[2]}} ; // x4
   wire [3:0] pp3 = a & {4{b[3]}} ; // x8
   // sum up partial products
   wire cout1, cout2, cout3 ;
   wire [3:0] s1, s2, s3 ;
   Adder1 #(4) a1(pp1, {1'b0,pp0[3:1]}, 1'b0, cout1, s1) ;
   Adder1 #(4) a2(pp2, {cout1,s1[3:1]}, 1'b0, cout2, s2) ;
   Adder1 #(4) a3(pp3, {cout2,s2[3:1]}, 1'b0, cout3, s3) ;
   // collect the result
   assign p = {cout3, s3, s2[0], s1[0], pp0[0]} ;
endmodule

module Add_half (input a, b,  output c_out, sum);
   xor G1(sum, a, b);	
   and G2(c_out, a, b);
endmodule               

module Add_full (input a, b, c_in, output c_out, sum);	 
   wire w1, w2, w3;				
   Add_half M1 (a, b, w1, w2);
   Add_half M0 (w2, c_in, w3, sum);
   or (c_out, w1, w3);
endmodule               

module ripple_carry_adder (input [3:0] a, b, input c_in, output c_out, output [3:0] sum);
   wire c_in1, c_in2, c_in3, c_in4;
   Add_full M0 (a[0], b[0], c_in,  c_in1, sum[0]);
   Add_full M1 (a[1], b[1], c_in1, c_in2, sum[1]);
   Add_full M2 (a[2], b[2], c_in2, c_in3, sum[2]);
   Add_full M3 (a[3], b[3], c_in3, c_out, sum[3]);
endmodule               

module Add_subtract_circuit(input [3:0] a, b, input m, output [3:0] sum, output c_out);     //Addition and Subtraction Circuit
    wire [3:0] x;
    wire c1,c2,c3;

    xor gate0 (x[0],b[0], m);
    xor gate1 (x[1],b[1], m);
    xor gate2 (x[2],b[2], m);
    xor gate3 (x[3],b[3], m);

    ripple_carry_adder adder (a,x,m,c_out,sum);

endmodule               //Mode Ends

module Testbench();     //Main Tester

  //Registers act like local variables
  reg [3:0] A,B;
  reg  M;
  //A wire can hold the return of a function
  wire [3:0] sum;
  wire c_out;
  
  //Modules can be either functions, or model chips. 
  //They are instantiated like an object of a class, 
  //with a constructor with parameters.  They are not invoked,
  //but operate like a thread.
  Add_subtract_circuit AdderFunction0 (A,B,M,sum,c_out);   

  //Initial means "start," like a Main() function.
  //Begin denotes the start of a block of code.	
  initial begin
   $display("000A 000B M 000S 000C");        //Print out formatting as given in question
   $display("======================");
   $display("Begin");
   $display("xxxx xxxx x xxxx x");
   $display("======================");
   $display("Set Addition",A);
   M=0;                       //Set to Addition mode
   $display("Set A=%d",A);
   assign A=10;               //A=10
   $display("%4b %4b %1b %4b %1b",A,B,M,sum,c_out);
   $display("Set B=%d",B);
   assign B=5;                //B=5
   $display("%4b %4b %1b %4b %1b",A,B,M,sum,c_out);
   #1
   $display("A+B=%d",sum);
   $display("%4b %4b %1b %4b %1b",A,B,M,sum,c_out);      //Display Result
   $display("======================");
   $display("Set A=0");
   assign A=0;                //Set A and B to 0
   $display("Set B=0");
   assign B=0;
   $display("======================");
   $display("Set Subtraction",A);   
   M=1;                       //Set to Subtraction Mode
   $display("Set A=%d",A);
   assign A=10;               //A=10
   $display("%4b %4b %1b %4b %1b",A,B,M,sum,c_out);
   $display("Set B=%d",B);
   assign B=3;                //B=3
   $display("%4b %4b %1b %4b %1b",A,B,M,sum,c_out);
   #1
   $display("A+B=%d",sum);                               //Display Result
   $display("%4b %4b %1b %4b %1b",A,B,M,sum,c_out);
   $display("======================");

  end
  
endmodule
