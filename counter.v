module counter(clock, out);

	input clock;
	output out;
	
	reg[23:0] out;
	
	always @(posedge clock)	out <= out + 1;
	
endmodule