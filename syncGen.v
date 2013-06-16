module syncGen(clock, hsync, vsync, hcount, vcount, inDispArea);
	
	input clock;
	output hsync, vsync, hcount, vcount, inDispArea;
	
	reg hsync, vsync, hblank, vblank, inDispArea, inDispAreaX, inDispAreaY;
	reg[9:0] hcount, vcount;
	
	wire hson, hsoff, hreset, hblankon;
	wire vson, vsoff, vreset, vblankon;
	
	assign hblankon = hcount == 639;
	assign hson = hcount == 652;
	assign hsoff = hcount == 746;
	assign hreset = hcount == 793;
	
	assign vblankon = hreset & (vcount == 479);
	assign vson = hreset & (vcount == 492);
	assign vsoff = hreset & (vcount == 494);
	assign vreset = hreset & (vcount == 527);

	always @(posedge clock)	begin
		inDispAreaX <= hreset ? 1 : hblankon ? 0 : inDispAreaX;
		inDispAreaY <= vreset ? 1 : vblankon ? 0 : inDispAreaY;
		inDispArea <= inDispAreaX & inDispAreaY;
	
		hcount <= hreset ? 0 : hcount + 1;
		hblank <= hreset ? 0 : hblankon ? 1 : hblank;
		hsync <= hson ? 0 : hsoff ? 1 : hsync;
		
		vcount <= hreset ? (vreset ? 0: vcount + 1): vcount;
		vblank <= vreset ? 0 : vblankon ? 1 : vblank;
		vsync <= vson ? 0 : vsoff ? 1 : vsync;
	end
	
endmodule