module N_bit_subtractor(input1,input2,answer);
parameter N=16;
input [15:0] input1,input2;
   output [N-1:0] answer;
   wire  carry_out;
  wire [N-1:0] carry;
   genvar i;
   generate 
   for(i=0;i<N;i=i+1)
     begin: generate_N_bit_subtractor
   if(i==0) 
  half_subtractor f(input1[0],input2[0],answer[0],carry[0]);
   else
  full_subtractor f(input1[i],input2[i],carry[i-1],answer[i],carry[i]);
     end
  assign carry_out = carry[N-1];
   endgenerate
endmodule 

module half_subtractor(x,y,s,c);
   input x,y;
   output s,c;
   assign s=x^y;
   assign c=x&y;
endmodule // half subtractor

module full_subtractor(x,y,c_in,s,c_out);
   input x,y,c_in;
   output s,c_out;
 assign s = (x^y) ^ c_in;
 assign c_out = (y&c_in)| (~x&y) | (~x&c_in);
endmodule // full_subtractor


module tb_N_bit_subtractor;
 // Inputs
 reg [15:0] input1;
 reg [15:0] input2;
 // Outputs
 wire [15:0] answer;

 // Instantiate the Unit Under Test (UUT)
 N_bit_subtractor uut (
  .input1(input1), 
  .input2(input2), 
  .answer(answer)
 );

 initial begin
  // Initialize Inputs
  input1 = 5432;
  input2 = 1234;
  #100;
  $display("A:     %b", input1);
  $display("B:     %b", input2);
  $display("Sum =  %b", answer);
 end
      
endmodule