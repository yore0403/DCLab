module Music_Controller(
	iCLK,
	iRST,
	//iSpeedUp,
	iSpeed,
	//iSpeedDown,
	i_mode,
	i_save,
	iNote,
	iNote1,
	iBar,
	iBar2,
	i_read_n,
	oBar,
	oBar2,
	iFlashValid,
	o_S_Note,
	o_music_enb,
	o_rst,
	o_signal,
	flag
	);


	logic flag_w,flag_r;
input iCLK,iRST,i_mode,i_save,i_read_n,iSpeed;
input [63:0] iNote;
output [3:0] iNote1;
reg [63:0] note_r,note_w;
output [6:0]o_music_enb;
input [7:0]iBar;
input [7:0]iBar2;
reg [8:0]music_enb_r,music_enb_w;
reg [31:0]time_count_r,time_count_w;
reg [3:0]bar_count_r,bar_count_w;
reg [3:0]bar2_count_r,bar2_count_w;
output [3:0] oBar;
output [3:0] oBar2;
output [63:0] o_S_Note;
output o_signal;//to SRAM read
input iFlashValid;
output o_rst;
reg rst_r,rst_w;
reg signal_r,signal_w;
	assign flag = flag_r;
	output flag;

reg [28:0]TIMEDELAY_w,TIMEDELAY;

//parameter TIMESCALE = 13'b1_1111_0101_0011;
//parameter TIMEDELAY0 = 2000000;
parameter TIMEDELAY0 = 2000000;
parameter TIMEDELAY1 = 8000000;
parameter TIMEDELAY2 = 32000000;
//parameter TIMEDELAY3 = 16000000;
//parameter TIMEDELAY4 = 32000000;

enum{RECORD,PLAY}state_r,state_w;
enum{WAIT,PLAY1,PLAY2,PLAY3,PLAY4,PLAY5,PLAY6,PLAY7,PLAY8,IDLE}r_state_r,r_state_w;


assign iNote1 = r_state_r;
assign o_music_enb = music_enb_r;
assign o_S_Note = note_r;
assign o_rst = rst_r;
assign oBar = bar_count_r;
assign o_signal = signal_r;
//	speed controled by key up and key down

	task SpeedControl;

		begin
			case(TIMEDELAY)
				TIMEDELAY0: begin
					if(iSpeed) begin
					TIMEDELAY_w = TIMEDELAY2;
					end
				end
				TIMEDELAY1: begin
					if(iSpeed) begin					
					TIMEDELAY_w = TIMEDELAY0;
					time_count_w = time_count_r >> 4;
					end
				end
				TIMEDELAY2: begin
					if(iSpeed) begin					
					TIMEDELAY_w = TIMEDELAY1;
					time_count_w = time_count_r >> 4;
					end
				end
			
			endcase
		end
	endtask

always_comb begin
	music_enb_w = music_enb_r;
	state_w = state_r;
	r_state_w = r_state_r;
	rst_w = rst_r;
	time_count_w = time_count_r;
	note_w = note_r;
	signal_w = signal_r;
	bar_count_w = bar_count_r;
	bar2_count_w = bar2_count_r;
	TIMEDELAY_w = TIMEDELAY;
		flag_w = flag_r;




	case(state_r) 

		RECORD:begin
			if(!i_save)begin
				note_w = iNote;//save the bar note and output to sram 
			end
			if(i_mode == 1) begin//change to play
				state_w = PLAY;
				r_state_w = IDLE;
				//bar_count_w =0;
				bar_count_w = 0;
			end


			case(r_state_r)
			IDLE: begin
				rst_w = 1;
				time_count_w = 0;
				bar_count_w = 0;
				if(iNote == 63'b0)begin//when note is on screen, start play the music
					r_state_w = IDLE;
				end else begin	
					r_state_w = PLAY1;//play first note//rst_w = 0;
				end
			end

			PLAY1: begin
				rst_w = 0;
				//pitch(iNote[3:0]);
				music_enb_w = iNote[7:0];//output to flash input from VGA
				if(iNote == 0)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY2;
					end else time_count_w = time_count_r + 1;					
				end
			end
			PLAY2: begin
				rst_w = 0;
				//pitch(iNote[7:4]);
				music_enb_w = iNote[15:8];
				if(iNote == 0)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY3;
					end else time_count_w = time_count_r + 1;
				end

			end
			PLAY3: begin
				rst_w = 0;
				//pitch(iNote[11:8]);
				music_enb_w = iNote[23:16];
				if(iNote == 0)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY4;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY4: begin
				rst_w = 0;
				//pitch(iNote[15:12]);
				music_enb_w = iNote[31:24];
				if(iNote == 0)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY5;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY5: begin
				rst_w = 0;
				//pitch(iNote[19:16]);
				music_enb_w = iNote[39:32];
				if(iNote == 0)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY6;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY6: begin
				rst_w = 0;
				//pitch(iNote[23:20]);
				music_enb_w = iNote[47:40];
				if(iNote == 0)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY7;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY7: begin
				rst_w = 0;
				//pitch(iNote[27:24]);
				music_enb_w = iNote[55:48];
				if(iNote == 0)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY8;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY8: begin
				rst_w = 0;
				//pitch(iNote[31:28]);
				music_enb_w = iNote[63:56];
				if(iNote == 0)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY1;
					end else time_count_w = time_count_r + 1;
				end
			end
			endcase

		end


		PLAY:begin
			//if(iSave)begin
			//	note_w = iNote;//save the bar and output to sram 
			//end
			if(i_mode == 0) begin//change to play
				state_w = RECORD;
				r_state_w = IDLE;
				bar_count_w = 0;
			end
			case(r_state_r)
			IDLE: begin
				rst_w = 1;
				time_count_w = 0;
				bar_count_w = 0;
				if(!i_save)//play
					r_state_w = WAIT;
				bar_count_w = 0;
				//if(iNote != 0)begin
				//	state_w = RECORD;
				//	time_count_w = 0;
				//	rst_w = 0;
				//end
			end
			WAIT: begin //select which bar to play
				rst_w = 1;
				time_count_w = 0;
				if(iBar[bar_count_r]) begin
					//if(iBar2) begin
						//if(iBar2[bar2_count_r]) begin
							signal_w = 1;

					//bar_count_w = bar_count_w + 1;
							r_state_w = WAIT;		
						//end else begin		
				
						//end		
					//end else begin
						//signal_w = 1;

					//bar_count_w = bar_count_w + 1;
							//r_state_w = WAIT;								
					//end			
				end else begin
				if(bar_count_r == 8)bar_count_w = 0;
				else bar_count_w = bar_count_r + 1;
					r_state_w = WAIT;		
				end	

				if(i_read_n) begin//get note
					signal_w = 0;
				if(bar_count_r == 8)bar_count_w = 0;
				else bar_count_w = bar_count_r + 1;
					


					r_state_w = PLAY1;
					//rst_w = 0;
				end
			end
			PLAY1: begin
				
				rst_w = 0;flag_w = 1;
				//pitch(iNote[3:0]);
				music_enb_w = iNote[7:0];
				if(!i_mode)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin

					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY2;
					end else time_count_w = time_count_r + 1;
					
				end
			end
			PLAY2: begin
				rst_w = 0;flag_w = 0;
				//pitch(iNote[7:4]);
				music_enb_w = iNote[15:8];
				if(!i_mode)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY3;
					end else time_count_w = time_count_r + 1;
				end

			end
			PLAY3: begin
				rst_w = 0;flag_w = 1;
				//pitch(iNote[11:8]);
				music_enb_w = iNote[23:16];
				if(!i_mode)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY4;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY4: begin
				rst_w = 0;flag_w = 1;
				//pitch(iNote[15:12]);
				music_enb_w = iNote[31:24];
				if(!i_mode)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY5;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY5: begin
				rst_w = 0;flag_w = 0;
				//pitch(iNote[19:16]);
				music_enb_w = iNote[39:32];
				if(!i_mode)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY6;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY6: begin
				rst_w = 0;
				//pitch(iNote[23:20]);
				music_enb_w = iNote[47:40];
				if(!i_mode)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY7;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY7: begin
				rst_w = 0;
				//pitch(iNote[27:24]);
				music_enb_w = iNote[55:48];
				if(!i_mode)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						time_count_w = 0;
						rst_w = 1;
						r_state_w = PLAY8;
					end else time_count_w = time_count_r + 1;
				end
			end
			PLAY8: begin
				rst_w = 0;
				
				//pitch(iNote[31:28]);
				music_enb_w = iNote[63:56];
				if(!i_mode)
					r_state_w = IDLE;
				//if(time_count_r == TIMESCALE)
				if(iFlashValid) begin
					if(time_count_r == TIMEDELAY)begin
						if(bar_count_r == 8) bar_count_w = 0; 
						if(bar2_count_r == 8) bar2_count_w = 0; 
						time_count_w = 0;
						rst_w = 1;
						r_state_w = WAIT;
					end else time_count_w = time_count_r + 1;
				end
			end
			endcase
		end


		endcase
		SpeedControl();
end


always@(posedge iCLK or negedge iRST) begin
	if(!iRST) begin
		music_enb_r <= 0;
		r_state_r <= IDLE;
		state_r <= RECORD;
		time_count_r <= 0;
		rst_r <= 1;
		note_r <= 0;
		bar_count_r <= 0;
		bar2_count_r <= 0;
			flag_r <= 0;
		signal_r <= 0;
		TIMEDELAY <= TIMEDELAY1;
	end else begin
		music_enb_r <= music_enb_w;
		state_r <= state_w;
		r_state_r <= r_state_w;
		time_count_r <= time_count_w;
		rst_r <= rst_w;
		note_r <= note_w;
		bar_count_r <= bar_count_w;
		bar2_count_r <= bar2_count_w;
			flag_r <= flag_w;
		signal_r <= signal_w;
		TIMEDELAY <= TIMEDELAY_w;
	end
end
endmodule
/*
task pitch;
	input [31:0]note;
	begin
		music_enb_w = 0;
		case(note)
			4'b0001:music_enb_w[0] = 1;
			4'b0010:music_enb_w[1] = 1;
			4'b0011:music_enb_w[2] = 1;
			4'b0100:music_enb_w[3] = 1;
			4'b0101:music_enb_w[4] = 1;
			4'b0110:music_enb_w[5] = 1;
			4'b0111:music_enb_w[6] = 1;
			default:music_enb_w = 0;
		endcase
	end
endtask

assign o_music_enb = music_enb_r;
assign o_rst = rst_r;

always_comb begin
	music_enb_w = music_enb_r;
	state_w = state_r;
	rst_w = rst_r;
	time_count_w = time_count_r;

	case(state_r) 
		IDLE: begin
			if(iNote != 0)begin
				state_w = PLAY1;
				time_count_w = 0;
				rst_w = 0;
			end
		end
		PLAY1: begin
			rst_w = 0;
			pitch(iNote[3:0]);
			if(iNote == 0)
				state_w = IDLE;
			//if(time_count_r == TIMESCALE)
			if(iFlashValid) begin

				if(time_count_r == TIMEDELAY)begin
					time_count_w = 0;
					rst_w = 1;
					state_w = PLAY2;
				end else time_count_w = time_count_r + 1;
				
			end
		end
		PLAY2: begin
			rst_w = 0;
			pitch(iNote[7:4]);
			if(iNote == 0)
				state_w = IDLE;
			//if(time_count_r == TIMESCALE)
			if(iFlashValid) begin
				if(time_count_r == TIMEDELAY)begin
					time_count_w = 0;
					rst_w = 1;
					state_w = PLAY3;
				end else time_count_w = time_count_r + 1;
			end

		end
		PLAY3: begin
			rst_w = 0;
			pitch(iNote[11:8]);
			if(iNote == 0)
				state_w = IDLE;
			//if(time_count_r == TIMESCALE)
			if(iFlashValid) begin
				if(time_count_r == TIMEDELAY)begin
					time_count_w = 0;
					rst_w = 1;
					state_w = PLAY4;
				end else time_count_w = time_count_r + 1;
			end
		end
		PLAY4: begin
			rst_w = 0;
			pitch(iNote[15:12]);
			if(iNote == 0)
				state_w = IDLE;
			//if(time_count_r == TIMESCALE)
			if(iFlashValid) begin
				if(time_count_r == TIMEDELAY)begin
					time_count_w = 0;
					rst_w = 1;
					state_w = PLAY5;
				end else time_count_w = time_count_r + 1;
			end
		end
		PLAY5: begin
			rst_w = 0;
			pitch(iNote[19:16]);
			if(iNote == 0)
				state_w = IDLE;
			//if(time_count_r == TIMESCALE)
			if(iFlashValid) begin
				if(time_count_r == TIMEDELAY)begin
					time_count_w = 0;
					rst_w = 1;
					state_w = PLAY6;
				end else time_count_w = time_count_r + 1;
			end
		end
		PLAY6: begin
			rst_w = 0;
			pitch(iNote[23:20]);
			if(iNote == 0)
				state_w = IDLE;
			//if(time_count_r == TIMESCALE)
			if(iFlashValid) begin
				if(time_count_r == TIMEDELAY)begin
					time_count_w = 0;
					rst_w = 1;
					state_w = PLAY7;
				end else time_count_w = time_count_r + 1;
			end
		end
		PLAY7: begin
			rst_w = 0;
			pitch(iNote[27:24]);
			if(iNote == 0)
				state_w = IDLE;
			//if(time_count_r == TIMESCALE)
			if(iFlashValid) begin
				if(time_count_r == TIMEDELAY)begin
					time_count_w = 0;
					rst_w = 1;
					state_w = PLAY8;
				end else time_count_w = time_count_r + 1;
			end
		end
		PLAY8: begin
			rst_w = 0;
			pitch(iNote[31:28]);
			if(iNote == 0)
				state_w = IDLE;
			//if(time_count_r == TIMESCALE)
			if(iFlashValid) begin
				if(time_count_r == TIMEDELAY)begin
					time_count_w = 0;
					rst_w = 1;
					state_w = PLAY1;
				end else time_count_w = time_count_r + 1;
			end
		end

	endcase
end


always@(posedge iCLK or negedge iRST) begin
	if(!iRST) begin
		music_enb_r <= 0;
		state_r <= IDLE;
		time_count_r <= 0;
		rst_r <= 1;
	end else begin
		music_enb_r <= music_enb_w;
		state_r <= state_w;
		time_count_r <= time_count_w;
		rst_r <= rst_w;
	end
end
endmodule
*/