//citation: https://personal.utdallas.edu/~jxw143630/index_files/Page5212.htm
//citation: https://www.nandland.com/verilog/examples/example-bitwise-operators.html
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
module testbench();
  reg [15:0] x;
  reg [15:0] y;
  wire [15:0] z;
  wire [15:0] q;
  wire [15:0] r;
  wire [15:0] s;
  wire [15:0] t;
  wire [15:0] u;
  wire [15:0] v;
  logicFunctions test1(x, y, z, q, r, s, t, u, v);
  initial begin
      begin
      x = 16'b1010101110101011;
      y = 16'b0101011101010111;
      end
      #10;
 
      $display ("input A %16b", x);
      $display ("input B %16b", y);
      $display ("A and B %16b", z);
      $display ("A or B %16b", q);
      $display ("A xor B %16b", r);
      $display ("not A %16b", s);
      $display ("A nor B %16b", t);
      $display ("A xnor B %16b", u);
      $display ("A nand B %16b", v);
  end  //End the code block of the main (initial)
  
endmodule //Close the testbench module
