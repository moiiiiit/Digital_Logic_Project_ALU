//----------------------------------------------------------------------
//K-Lighters
//iverilog
//Source: http://bleyer.org/icarus/
//Project

//----------------------------------------------------------------------
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
