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

module testbench();
  reg [4-1:0]opCode;
  reg clk;
initial begin
end
endmodule // testbench
