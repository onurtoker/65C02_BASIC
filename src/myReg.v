module myReg
#(parameter N = 1, qinit=1)
(
	  input clk
	, input reset
	, input wire[N-1:0] din
	, output reg[N-1:0] dout
); 

always@(posedge clk)
	if (reset)
		dout <= qinit;
	else
		dout <= din;
		
endmodule
		
