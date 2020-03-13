module decoder_using_case (
binary_in   , //  4 bit binary input
decoder_out , //  16-bit  out
enable        //  Enable for the decoder
);
input [3:0] binary_in  ;
input  enable ;
output [15:0] decoder_out ;

reg [15:0] decoder_out ;

always @ (enable or binary_in)
begin
  decoder_out = 0;
  if (enable) begin
    case (binary_in)
      4'h0 : decoder_out = 16'h0001;
      4'h1 : decoder_out = 16'h0002;
      4'h2 : decoder_out = 16'h0004;
      4'h3 : decoder_out = 16'h0008;
      4'h4 : decoder_out = 16'h0010;
      4'h5 : decoder_out = 16'h0020;
      4'h6 : decoder_out = 16'h0040;
      4'h7 : decoder_out = 16'h0080;
      4'h8 : decoder_out = 16'h0100;
      4'h9 : decoder_out = 16'h0200;
      4'hA : decoder_out = 16'h0400;
      4'hB : decoder_out = 16'h0800;
      4'hC : decoder_out = 16'h1000;
      4'hD : decoder_out = 16'h2000;
      4'hE : decoder_out = 16'h4000;
      4'hF : decoder_out = 16'h8000;
    endcase
  end
end

endmodule

module testBench;

//input
  reg [3:0] binary_in;
  reg enable;
  //output
  wire [15:0] decoder_out

  decoder_using_case UUT(.binary_in(binary_in),.enable(enable),.decoder_out(decoder_out));
  initail begin
    binary_in = 0;

    #100;
    encoderIn = 16'h0002;
      
    #20;

    encoderIn = 16'h0008;
      
    #20;
      
    encoderIn = 16'h0010;
      
    #20;
      
    encoderIn = 16'h0020;
      
    #20;
      
    encoderIn = 16'h0040;
      
    #20;
      
    encoderIn = 16'h0080;
      
    #20;
    encoderIn = 16'h0100;
      
    #20;
    encoderIn = 16'h0200;
      
    #20;
    encoderIn = 16'h0400;
      
    #20;
    encoderIn = 16'h0800;
      
    #20;
    encoderIn = 16'h1000;
      
    #20;
    encoderIn = 16'h2000;
      
    #20;
    encoderIn = 16'h4000;
      
    #20;
    encoderIn = 16'h8000;
      
    #20;
  end
endmodule




