module Flash_Controller (
	input i_clk,
	input i_clk2,
	input i_rst,

	input i_music_DO_enable,
	input i_music_RE_enable,
	input i_music_MI_enable,
	input i_music_FA_enable,
	input i_music_SOL_enable,
	input i_music_LA_enable,
	input i_music_SI_enable,

	output o_finished,
	
	output [22:0] FL_ADDR,
	output        FL_CE_N,
	inout  [7:0]  FL_DQ,
	output        FL_OE_N,
	output        FL_RST_N,
	input         FL_RY,
	output        FL_WE_N,
	output        FL_WP_N,

	output        o_I2C_SCLK,
	inout         I2C_SDAT,
	output        o_AUD_DACDAT,
	inout         DACLRCK
);

	enum {INIT, PLAY} state_w, state_r;
//	enum {PLAY_0, PLAY_1, PLAY_2, PLAY_3, PLAY_4, PLAY_5, PLAY_6, PLAY_7, PLAY_8} substate_w, substate_r;
	
	parameter PLAY_INIT = 4'b0000;
	parameter PLAY_DO = 4'b0001;
	parameter PLAY_RE = 4'b0010;
	parameter PLAY_MI = 4'b0011;
	parameter PLAY_FA = 4'b0100;
	parameter PLAY_SOL = 4'b0101;
	parameter PLAY_LA = 4'b0110;
	parameter PLAY_SI = 4'b0111;
	parameter PLAY_END = 4'b1000;

	logic [3:0] substate_w, substate_r;

	logic [15:0] play_data_r, play_data_w;
	logic [18:0] play_data_temp_r, play_data_temp_w;
	logic pre_DACLRCK_w, pre_DACLRCK_r;
	logic start_play_w, start_play_r;

	logic [31:0] data_out;
	logic [20:0] addr_read_r, addr_read_w;
	logic [15:0] play_data;
	logic start_init, done_init;
	logic start_play, done_play;
	logic ack;

	logic [20:0] counter_r , counter_w;

	logic play_finished_w, play_finished_r;

	assign start_init = (state_r == INIT);
	assign start_play = (pre_DACLRCK_r != DACLRCK);
	
	assign o_finished = play_finished_r;

	I2Cinitialize init(
	   .i_clk(i_clk2),
	   .i_start(start_init),
	   .i_rst(i_rst),
	   .o_scl(o_I2C_SCLK),
	   .o_finished(done_init),
	   .o_sda(I2C_SDAT)
	);

	Para2Seri p2s(
	   .i_clk(i_clk),
	   .i_rst(i_rst),
	   .i_start(start_play),
	   .flash_dq(play_data_r), // data 
	   .aud_dacdat(o_AUD_DACDAT),
	   .o_finished(done_play)
	);

	flash flash(
	   .i_clk(i_clk), 
	   .i_rst(i_rst),
       .i_start(start_play_r),  
	   .i_top_addr(addr_read_r),
	   .i_data_in(FL_DQ), 
       .o_data_out(data_out), 
	   .o_ack(ack),
	   .o_addr(FL_ADDR), 
	   .o_we_n(FL_WE_N),
       .o_rst_n(FL_RST_N),
       .o_wp_n(FL_WP_N), 
       .o_ce_n(FL_CE_N), 
	   .o_oe_n(FL_OE_N)    
	);
	
	task Play_Data_Control;
		input i_music_x_enable, PLAY_X;

		logic i_music_x_enable;
		logic [3:0] PLAY_X;

		begin
			if (ack) begin
				if (i_music_x_enable) begin
					if (data_out[23] == 1'b0) begin
						play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
					end else begin
						play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
					end
				end
				substate_w = PLAY_X;
				//play_data_w = data_out[23:8];
				start_play_w = 1;
			end else begin
				start_play_w = 0;
			end
		end
	endtask : Play_Data_Control


	always_comb begin
		// _w = _r
		state_w = state_r;
		substate_w = substate_r;
		counter_w = counter_r;
		pre_DACLRCK_w = DACLRCK;
		play_data_temp_w = play_data_temp_r;
		addr_read_w = addr_read_r;
		start_play_w = start_play_r;
		play_finished_w = play_finished_r;

		if (start_play && (DACLRCK == 0)) begin
			if (play_data_temp_r[18:15] == 4'b0000) begin // positive no overflow
				play_data_w = play_data_temp_r[15:0];
			end else if (play_data_temp_r[18:15] == 4'b1111) begin // negetive no overflow
				play_data_w = play_data_temp_r[15:0];
			end else if ((play_data_temp_r[18] == 1'b0) && (play_data_temp_r[17:15] != 4'b0)) begin // positive overflow
				play_data_w = {1'b0, 15'b111_1111_1111_1111};
			end else begin // negative overflow
				play_data_w = {1'b1, 15'b0};
			end
		end else begin
			play_data_w = play_data_r;
		end
		
		case (state_r) 
			INIT: begin
				if (done_init) begin
					state_w = PLAY;
					substate_w = PLAY_INIT;
				end
			end

			PLAY: begin
				case (substate_r)
					PLAY_INIT: begin
						if (start_play && (DACLRCK == 0)) begin
							substate_w = PLAY_DO;
							start_play_w = 1;
							play_data_temp_w = 0;
							play_finished_w = 0;
/*							if (i_music_1_enb) begin
								substate_w = PLAY_1
							end else if (i_music_2_enb) begin
								substate_w = PLAY_2
							end else if (i_music_3_enb) begin
								substate_w = PLAY_3
							end else if (i_music_4_enb) begin
								substate_w = PLAY_4
							end else if (i_music_5_enb) begin
								substate_w = PLAY_5
							end*/
						end
					end
/*					PLAY_1: begin
						addr_read_w = 21'b0_0000_0000_0000_0000_0000 + counter_r;
						if (ack) begin
							if (i_music_1_enb) begin
								if (data_out[23] == 1'b0) begin
									play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
								end else begin
									play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
								end
							end
							substate_w = PLAY_2;
							//play_data_w = data_out[23:8];
							start_play_w = 1;
						end else begin
							start_play_w = 0;
						end
					end

					PLAY_2: begin
						addr_read_w = 21'b0_0000_1000_0000_0000_0000 + counter_r; 
						if (ack) begin
							if (i_music_2_enb) begin
								if (data_out[23] == 1'b0) begin
									play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
								end else begin
									play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
								end
							end
							substate_w = PLAY_3;
							//play_data_w = data_out[23:8];
							start_play_w = 1;
						end else begin
							start_play_w = 0;
						end
					end

					PLAY_3: begin
						addr_read_w = 21'b0_0001_0000_0000_0000_0000 + counter_r;
						if (ack) begin
							if (i_music_3_enb) begin
								if (data_out[23] == 1'b0) begin
									play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
								end else begin
									play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
								end
							end
							substate_w = PLAY_4;
							//play_data_w = data_out[23:8];
							start_play_w = 1;
						end else begin
							start_play_w = 0;
						end
					end

					PLAY_4: begin
						addr_read_w = 21'b0_0001_1000_0000_0000_0000 + counter_r;
						if (ack) begin
							if (i_music_4_enb) begin
								if (data_out[23] == 1'b0) begin
									play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
								end else begin
									play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
								end
							end
							substate_w = PLAY_5;
							//play_data_w = data_out[23:8];
							start_play_w = 1;
						end else begin
							start_play_w = 0;
						end
					end

					PLAY_5: begin
						addr_read_w = 21'b0_0010_0000_0000_0000_0000 + counter_r;
						if (ack) begin
							if (i_music_5_enb) begin
								if (data_out[23] == 1'b0) begin
									play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
								end else begin
									play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
								end
							end
							substate_w = PLAY_6;
							//play_data_w = data_out[23:8];
							start_play_w = 1;
						end else begin
							start_play_w = 0;
						end
					end

					PLAY_6: begin
						addr_read_w = 21'b0_0010_1000_0000_0000_0000 + counter_r;
						if (ack) begin
							if (i_music_6_enb) begin
								if (data_out[23] == 1'b0) begin
									play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
								end else begin
									play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
								end
							end
							substate_w = PLAY_7;
							//start_play_w = 1;
						end else begin
							start_play_w = 0;
						end
					end

					PLAY_7: begin
						addr_read_w = 21'b0_0011_0000_0000_0000_0000 + counter_r;
						if (ack) begin
							if (i_music_7_enb) begin
								if (data_out[23] == 1'b0) begin
									play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
								end else begin
									play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
								end
							end
							substate_w = PLAY_8;
						end else begin
							start_play_w = 0;
						end
					end

					PLAY_7: begin
				    	//play_data_w = play_data_temp_r;
				    	
						if (counter_r == 21'b0_0000_0001_1111_0101_0011) begin
							counter_w = 21'b0_0000_0000_0000_0000_1011;
				    	end else begin
							counter_w = counter_r + 1;
						end
						
				    	substate_w = PLAY_0;
				    end
*/

					PLAY_DO: begin
						addr_read_w = 21'b0_0000_0000_0000_0000_0000 + counter_r;
						Play_Data_Control(i_music_DO_enable, PLAY_RE);
					end

					PLAY_RE: begin
						addr_read_w = 21'b0_0000_1000_0000_0000_0000 + counter_r; 
						Play_Data_Control(i_music_RE_enable, PLAY_MI);
					end

					PLAY_MI: begin
						addr_read_w = 21'b0_0001_0000_0000_0000_0000 + counter_r;
						Play_Data_Control(i_music_MI_enable, PLAY_FA);
					end

					PLAY_FA: begin
						addr_read_w = 21'b0_0001_1000_0000_0000_0000 + counter_r;
						Play_Data_Control(i_music_FA_enable, PLAY_SOL);
					end

					PLAY_SOL: begin
						addr_read_w = 21'b0_0010_0000_0000_0000_0000 + counter_r;
						Play_Data_Control(i_music_SOL_enable, PLAY_LA);
					end

					PLAY_LA: begin
						addr_read_w = 21'b0_0010_1000_0000_0000_0000 + counter_r;
						Play_Data_Control(i_music_LA_enable, PLAY_SI);
					end

					PLAY_SI: begin
						addr_read_w = 21'b0_0011_0000_0000_0000_0000 + counter_r;
						if (ack) begin
							if (i_music_SI_enable) begin
								if (data_out[23] == 1'b0) begin
									play_data_temp_w = play_data_temp_r + {3'b0, data_out[23:8]};
								end else begin
									play_data_temp_w = play_data_temp_r + {3'b111, data_out[23:8]};
								end
							end
							substate_w = PLAY_END;
						end else begin
							start_play_w = 0;
						end
					end

					PLAY_END: begin
				    	//play_data_w = play_data_temp_r;
				    	
						if (counter_r == 21'b0_0000_0001_1111_0101_0011) begin
							play_finished_w = 1;
							//counter_w = 21'b0_0000_0000_0000_0000_1011;
				    	end else begin
							counter_w = counter_r + 1;
						end
						
				    	substate_w = PLAY_INIT;
				    end

				endcase // substate_r
			end
		endcase // state_r
	end

	always_ff @(posedge i_clk or posedge i_rst) begin
		if(i_rst) begin
			state_r       <= INIT;
			substate_r    <= PLAY_INIT;
			pre_DACLRCK_r <= 0;
			play_data_r   <= 0;
			counter_r     <= 0;
			play_data_temp_r <= 0;
			addr_read_r   <= 0;
			start_play_r  <= 0;
			play_finished_r <= 0;
		end else begin
			state_r       <= state_w;
			substate_r    <= substate_w;
			pre_DACLRCK_r <= pre_DACLRCK_w;
			play_data_r   <= play_data_w;
			counter_r     <= counter_w;
			play_data_temp_r <= play_data_temp_w;
			addr_read_r   <= addr_read_w;
			start_play_r  <= start_play_w;
			play_finished_r <= play_finished_w;
		end
	end
endmodule