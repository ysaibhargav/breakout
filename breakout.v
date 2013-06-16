module breakout(disp, left, right, clock, hsync, vsync, r, g, b);

	//`include "final.txt"
	`include "init.txt"

	input clock, left, right, disp;
	output hsync, vsync, r, g, b;
	
	integer i, j, k, brickIndex, brW = 40, brH = 10, pW = 32, pH = 4, pointValue = 1;
	
	wire inDispArea, border, ball, ballX, ballY, paddle, 
	paddleX, paddleY, bouncingObject, resetFrame, brickCollision;
	wire[23:0] num;
	wire[9:0] cX, cY, gX, gY;
	wire[3:0] sTens, sOnes;
	wire[1:0] scoreDispX;
	wire scoreDispY;
	
	reg[9:0] ballPX = 320, ballPY = 460, paddlePX = 320, paddlePY = 468, scoreDispPX[3:0], scoreDispPY;
	reg[2:0] bricks = 3'b0, scoreWriterX = 3'b0, scoreWriterY = 3'b0, strikePos = 3'b0;
	//bX(n) = 34 + 38 * n, bY(n) = 64 + 20 * n
	reg[9:0] brickPX[0:15], brickPY[0:4];
	reg[63:0] brickState, brickX, brickY;
	reg[7:0] font0[7:0], font1[7:0], font2[7:0], font3[7:0], font4[7:0], font5[7:0], font6[7:0], font7[7:0], font8[7:0], font9[7:0];
	reg[6:0] playerScore = 7'b0000000;
	reg[3:0] tens, ones;
	reg[1:0] ballSpeedX = 2'b10, ballSpeedY = 2'b10;
	reg endGame = 1'b0, score, bricksRow = 1'b1;
	wire[639:0] red[479:0], green[479:0], blue[479:0];
	
	always @(posedge num[0]) begin
		bricks = 3'b0;
		for(i = 48; i < 64; i = i + 1)
			bricksRow = bricksRow & ~brickState[i];
			
		for(i = 0; i < 64; i = i + 1) begin
			j = i % 16;
			k = i / 16;
			
			if(brickState[i])	begin
				brickX[i] = cX == (brickPX[j] - brW / 2) ? 1 : cX == (brickPX[j] + brW / 2 - 1) ? 0 : brickX[i];
				brickY[i] = cY == (brickPY[k] - brH / 2) ? 1 : cY == (brickPY[k] + brH / 2 - 1) ? 0 : brickY[i];
				
				if(k == 0) begin
					bricks[0] = bricks[0] | (brickX[i] & brickY[i]);
					bricks[1] = bricks[1] | (brickX[i] & brickY[i]);
				end
				
				else if(k == 1) begin
					bricks[2] = bricks[2] | (brickX[i] & brickY[i]);
					bricks[1] = bricks[1] | (brickX[i] & brickY[i]);
				end
				
				else if(k == 2) begin
					bricks[2] = bricks[2] | (brickX[i] & brickY[i]);
					bricks[0] = bricks[0] | (brickX[i] & brickY[i]);
				end
				
				else if(k == 3) begin
					bricks[0] = bricks[0] | (brickX[i] & brickY[i]);
				end
				
				else if(k == 4) begin
					bricks[1] = bricks[1] | (brickX[i] & brickY[i]);
				end
			end
		end
	end
	
	counter c(.clock(clock), .out(num));

	binaryToBCD convert(.data(playerScore), .t(sTens), .o(sOnes));
	
	syncGen generator(.clock(num[0]), .hsync(hsync), .vsync(vsync), .hcount(cX), .vcount(cY), .inDispArea(inDispArea));
	
	/*Right collision - x = (34 + brW/2) + 38 * m;  */
	reg collisionX1, collisionX2, collisionY1, collisionY2;
		
	always @(posedge num[0])
		if(resetFrame) begin
			collisionX1 <= 0; 
		end
		else if(bouncingObject & (cX == (ballPX - 4)) & (cY == ballPY)) begin 
			//strikePos <= 3'b111;
			collisionX1 <= 1; 
		end
		
	always @(posedge num[0]) 
		if(resetFrame) begin
			collisionX2 <= 0;
		end
		else if(bouncingObject & (cX == (ballPX + 4)) & (cY == ballPY)) begin 
			//strikePos <= 3'b111;
			collisionX2 <= 1; 
		end
		
	always @(posedge num[0]) 
		if(resetFrame) begin 
			collisionY1 <= 0; 
		end
		else if(bouncingObject & (cX == ballPX) & (cY == (ballPY - 4))) begin 
			//strikePos <= 3'b111;
			collisionY1 <= 1; 
		end
		
	always @(posedge num[0]) 
		if(resetFrame) begin
			collisionY2 <= 0; 
		end
		else if(bouncingObject & (cX == ballPX) & ((cY == ballPY + 4))) begin 
			if(cY[9:3] == 59)	endGame <= 1;
			if(paddle) begin
				if(cX - paddlePX > pW / 3)	strikePos <= 3'b000;
				else if(paddlePX - cX > pW / 3)	strikePos <= 3'b001;
				else strikePos <= 3'b010;
			end
			collisionY2 <= 1; 
		end
	
	always @(posedge num[0]) begin
		if(|scoreDispX & scoreDispY) begin
			scoreWriterX <= scoreWriterX + 1;
			if(scoreDispX[0]) begin
				case(tens)
					4'b0000: score <= font0[scoreWriterY][scoreWriterX];
					4'b0001: score <= font1[scoreWriterY][scoreWriterX];
					4'b0010: score <= font2[scoreWriterY][scoreWriterX];
					4'b0011: score <= font3[scoreWriterY][scoreWriterX];
					4'b0100: score <= font4[scoreWriterY][scoreWriterX];
					4'b0101: score <= font5[scoreWriterY][scoreWriterX];
					4'b0110: score <= font6[scoreWriterY][scoreWriterX];
					4'b0111: score <= font7[scoreWriterY][scoreWriterX];
					4'b1000: score <= font8[scoreWriterY][scoreWriterX];
					4'b1001: score <= font9[scoreWriterY][scoreWriterX];
					default: score <= font0[scoreWriterY][scoreWriterX];
				endcase
			end
			else if(scoreDispX[1])	begin 
				if(scoreWriterX == 3'b111) scoreWriterY <= scoreWriterY + 1;
				case(ones)
					4'b0000: score <= font0[scoreWriterY][scoreWriterX];
					4'b0001: score <= font1[scoreWriterY][scoreWriterX];
					4'b0010: score <= font2[scoreWriterY][scoreWriterX];
					4'b0011: score <= font3[scoreWriterY][scoreWriterX];
					4'b0100: score <= font4[scoreWriterY][scoreWriterX];
					4'b0101: score <= font5[scoreWriterY][scoreWriterX];
					4'b0110: score <= font6[scoreWriterY][scoreWriterX];
					4'b0111: score <= font7[scoreWriterY][scoreWriterX];
					4'b1000: score <= font8[scoreWriterY][scoreWriterX];
					4'b1001: score <= font9[scoreWriterY][scoreWriterX];
					default: score <= font0[scoreWriterY][scoreWriterX];
				endcase
			end
		end
		else score <= 0;
	end
	
	reg ball_dirX, ball_dirY = 1;
	always @(posedge num[0]) begin
		if(brickCollision) begin
		  for(i = 0; i < 64; i = i + 1)
			 if(brickX[i] & brickY[i])	begin 
				brickIndex <= i;
			 end	
		end
			 
		if(resetFrame) begin	
		  if(bricksRow)	pW <= 24;
		  if(brickIndex != -1)	begin
			brickState[brickIndex] <= 0;
			playerScore <= playerScore + (brickIndex / 16 == 0 ? 2 : 1) * pointValue;
			ones <= sOnes;
			tens <= sTens;
			brickIndex <= -1;
		  end
		  
			/*case(strikePos)
				//right third
				3'b000: begin ballSpeedY <= 3; ballSpeedX <= 2; end
				//left third
				3'b001: begin ballSpeedY <= 2; ballSpeedX <= 3; end
				//middle third
				3'b010: ballSpeedY <= ballSpeedX;
				default: begin ballSpeedX <= 2; ballSpeedY <= 2; end
			endcase*/
		  
		  if(~(collisionX1 & collisionX2))
		  begin
			 ballPX <= ballPX + (ball_dirX ? -ballSpeedX : ballSpeedX);
			 if(collisionX2) ball_dirX <= 1; else if(collisionX1) ball_dirX <= 0;
		  end

		  if(~(collisionY1 & collisionY2))
		  begin
			 ballPY <= ballPY + (ball_dirY ? -ballSpeedY : ballSpeedY);
			 if(collisionY2) ball_dirY <= 1; else if(collisionY1) ball_dirY <= 0;
		  end
		  
		  if(~left & ~(paddlePX - pW / 2 == 8 | paddlePX - pW / 2 == 7 | paddlePX - pW / 2 == 9))	paddlePX <= paddlePX - 3; else if(~right & ~(paddlePX + pW / 2 == 630))	paddlePX <= paddlePX + 3;
		end
	end
	
	assign scoreDispX[0] = cX == scoreDispPX[0] ? 1 : cX == (scoreDispPX[0] + 8) ? 0 : scoreDispX[0];
	assign scoreDispX[1] = cX == scoreDispPX[1] ? 1 : cX == (scoreDispPX[1] + 8) ? 0 : scoreDispX[1];
	//assign scoreDispX[2] = cX == scoreDispPX[2] ? 1 : cX == (scoreDispPX[2] + 8) ? 0 : scoreDispX[2];
	//assign scoreDispX[3] = cX == scoreDispPX[3] ? 1 : cX == (scoreDispPX[3] + 8) ? 0 : scoreDispX[3];
	assign scoreDispY = cY == scoreDispPY ? 1 : cY == (scoreDispPY + 8) ? 0 : scoreDispY;
	
	assign brickCollision = (|bricks) & ball;
	assign bouncingObject = border | paddle | bricks | cY[9:3] == 59;
	assign resetFrame = cX == 639 & cY == 479;
	assign border = cX[9:3] == 0 | cX[9:3] == 79  | cY[9:3] == 0;// | cY[9:3] == 59;
	
	assign gX = cX, gY = cY;
	
	assign ballX = cX == (ballPX - 4) ? 1 : cX == (ballPX + 4) ? 0 : ballX;
	assign ballY = cY == (ballPY - 2) ? 1 : cY == (ballPY + 2) ? 0 : ballY;
	assign paddleX = cX == (paddlePX - pW / 2) ? 1 : cX == (paddlePX + pW / 2 - 1) ? 0 : paddleX;
	assign paddleY = cY == (paddlePY - pH / 2) ? 1 : cY == (paddlePY + pH / 2 - 1) ? 0 : paddleY;
	assign ball = ballX & ballY;
	assign paddle = (paddleX & paddleY);
	
	assign r = (endGame) ? (cX[5] ^ cY[5]) : (border | bricks[0] | score | paddle);
	assign g = (endGame) ? 0 : (border | bricks[1] | score | paddle | ball);
	assign b = (endGame) ? 0 : (border | bricks[2] | score | paddle | ball);
	
endmodule