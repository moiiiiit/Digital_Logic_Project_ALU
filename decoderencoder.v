//citation DIgital Design for both the decoder and encoder
//Figure 8.3
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

  Muxb8 #(1) m(1, 0, 1, 0, 1, 1, 1, 0, in, isprime) ;
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

module testbench();
	reg [15:0] toEncode;
	wire [3:0] encodeOut;
	reg [3:0] toDecode;
	wire [15:0] decodeOut;
	Enc164 blah1(toEncode, encodeOut);
	Dec4to16 blah2(toDecode, decodeOut);
	initial
		begin
		toEncode = 16'b0000000000000010;
		toDecode = 4'b1111;
		#10;
		$display("Input to decoder: %b Output from decoder: %b", toDecode, decodeOut); 
		$display("Input to encoder: %b Output from encoder: %b", toEncode, encodeOut); 
	end
endmodule
