module binaryToBCD(data, t, o);

	input data;
	output t, o;
	
	wire[6:0] data;
	reg[3:0] t, o;
	
	integer i;
	  
	always @(data) begin
		t = 4'd0;
		o = 4'd0;
		
		for (i=6; i>=0; i=i-1) begin
			if(t >= 5)
			t = t + 3;
			if(o >= 5)
			o = o +3;
			
			t = t << 1;
			t[0] = o[3];
			o = o << 1;
			o[0] = data[i];
		end
	end
	
endmodule