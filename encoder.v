module encoder(
binaryOut , //  4 bit binary Output
encoderIn , //  16-bit Input
enable       //  Enable for the encoder
);
output [3:0] binaryOut  ;
input  enable ; 
input [15:0] encoderIn ; 
     
reg [3:0] binaryOut ;
      
always @ (enable or encoderIn)
begin
  binaryOut = 0;
  if (enable) begin
    case (encoderIn) 
      16'h0002 : binaryOut = 1;
      16'h0004 : binaryOut = 2; 
      16'h0008 : binaryOut = 3; 
      16'h0010 : binaryOut = 4;
      16'h0020 : binaryOut = 5; 
      16'h0040 : binaryOut = 6; 
      16'h0080 : binaryOut = 7; 
      16'h0100 : binaryOut = 8;
      16'h0200 : binaryOut = 9;
      16'h0400 : binaryOut = 10; 
      16'h0800 : binaryOut = 11; 
      16'h1000 : binaryOut = 12; 
      16'h2000 : binaryOut = 13; 
      16'h4000 : binaryOut = 14; 
      16'h8000 : binaryOut = 15; 
   endcase
  end
end

endmodule

module testBench;

// Inputs
   reg [15:0] encoderIn;
   reg enable;
   // Outputs
   wire [3:0] binaryOut;

   // Instantiate the Unit Under Test (UUT)
   encoder uut(.encoderIn(encoderIn),.enable(enable),.binaryOut(binaryOut)
   );

   initial begin
       // Initialize Inputs
       encoderIn = 0;

       // Wait 100 ns for global reset to finish
       #100;
  
       encoderIn = 16'h0002;
       $display("Binary out : %d",binaryOut);
       #20;

       encoderIn = 16'h0008;
        
       #20;
       $display("Encoder in : %b\nBinary out : %b",encoderIn,binaryOut);
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
       $display("Encoder in : %b\nBinary out : %b",encoderIn,binaryOut);
   end
  
endmodule