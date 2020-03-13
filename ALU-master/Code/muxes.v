module Mux16(a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0, s, b);
   parameter k = 5;
   input [k-1:0] a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0;
   input [15:0]   s;
   output [k-1:0] b;
   assign b = (s[0]? a0 : 
        (s[1]? a1 :
         (s[2]? a2 :
          (s[3]? a3 :
           (s[4]? a4 :
            (s[5]? a5 :
             (s[6]? a6 :
			  (s[7]? a7 :
			   (s[8]? a8 :
			    (s[9]? a9 :
			     (s[10]? a10 :
			      (s[11]? a11 :
			       (s[12]? a12 :
			        (s[13]? a13 :
			         (s[14]? a14 : a15)))))))))))))));
endmodule // Mux16

module Mux32(a31, a30, a29, a28, a27, a26, a25, a24, a23, a22, a21, a20, a19, 
				a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5,
				a4, a3, a2, a1, a0, s, b);
   parameter k = 5;
   input [k-1:0] a31, a30, a29, a28, a27, a26, a25, a24, a23, a22, a21, a20, 
					a19, a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8, 
					a7, a6, a5, a4, a3, a2, a1, a0;
   input [31:0]   s;
   output [k-1:0] b;
   assign b = (s[0]? a0 : 
        (s[1]? a1 :
         (s[2]? a2 :
          (s[3]? a3 :
           (s[4]? a4 :
            (s[5]? a5 :
             (s[6]? a6 :
			  (s[7]? a7 :
			   (s[8]? a8 :
			    (s[9]? a9 :
			     (s[10]? a10 :
			      (s[11]? a11 :
			       (s[12]? a12 :
			        (s[13]? a13 :
					 (s[14]? a14 :
					  (s[15]? a15 :
					   (s[16]? a16 :
						(s[17]? a17 :
						 (s[18]? a18 :
						  (s[19]? a19 :
						   (s[20]? a20 :
							(s[21]? a21 :
							 (s[22]? a22 :
							  (s[23]? a23 :
							   (s[24]? a24 :
								(s[25]? a25 :
								 (s[26]? a26 :
								  (s[27]? a27 :
								   (s[28]? a28 :
								    (s[29]? a29 :
								     (s[30]? a30 : a31)
	))))))))))))))))))))))))))))));
endmodule // Mux32

module testbench();
	wire [15:0] sel_16;
	wire [31:0] sel_32;

	Mux16 mux0 (a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, 
					a1, a0, sel_16, b);

	Mux32 mux1 (a31, a30, a29, a28, a27, a26, a25, a24, a23, a22, a21, a20, a19, 
					a18, a17, a16, a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, 
					a5, a4, a3, a2, a1, a0, sel_32, b);
endmodule // testbench