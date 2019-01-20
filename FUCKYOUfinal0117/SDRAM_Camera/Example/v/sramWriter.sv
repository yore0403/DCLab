//code by b05901084
//o_state for idle(1100) stop(0100) record(0101) pause(0110)
//o_state[3] for idle or not,
//o_state[2] for readmode or writemode,
//o_state[0] for recording or not,
//o_state[1] for puase or not
//different from chiachen :i_pause =>i_play
//						   i_clk => i_bclk
//						   no o_LED

module SramWriter(
	input i_bclk,
	input i_rst,
	input i_save,
	input i_mode,

	//input [15:0] i_record_data,
	input [63:0] i_music_data,
	input [7:0] i_bar_data,//switch
	input [7:0] i_bar2_data,//switch
	output [15:0] o_SRAM_DQ,
	//output [3:0]o_state,
	output o_write_n,
	output [19:0] o_addr,
	output flag
	//output o_finish
	//output [19:0] o_end_addr
);

	enum {CLEAR, IDLE, WAIT, WRITE,WAIT2, WRITE2, PAUSE, STOP} state_w, state_r;

	logic [19:0] addr_w, addr_r;
	logic [19:0] end_addr_w, end_addr_r;
	//logic new_w, new_r;
	logic write_w, write_r;
	logic flag_w,flag_r;
	logic [31:0] counter_w, counter_r;
	//logic [3:0] o_state_w, o_state_r;
	logic [15:0] record_data_w,record_data_r;
	logic [3:0] bar_count_w,bar_count_r;
	logic [3:0] r_count_w,r_count_r;
	logic [7:0] bar_valid_w,bar_valid_r;
	assign o_addr = addr_r;
	assign o_write_n = write_r? 0 : 1'bz;
	assign o_SRAM_DQ = i_mode? (record_data_r) : 16'bz;
	assign o_end_addr = end_addr_r;
	assign flag = flag_r;
	always_comb begin
		state_w = state_r;
		addr_w = addr_r;
		write_w = write_r;
		end_addr_w = end_addr_r;
		//new_w = new_r;
		counter_w = counter_r;
		record_data_w = record_data_r;
		bar_count_w = bar_count_r;
		r_count_w = r_count_r;
		flag_w = flag_r;
		bar_valid_w = bar_valid_r;

		case (state_r)
			CLEAR:begin
				write_w = 1;
				addr_w = addr_r + 1;
				record_data_w = 16'b0;
				if(addr_r==20'b00000000000011111111)state_w = IDLE;
			end
			IDLE: begin
					//new_w = 0;
					write_w = 0;
					flag_w = 0;
					addr_w = 0;
				if(i_mode) begin
					state_w = STOP;
					
					bar_count_w = 0;
					
				end

			end
			STOP: begin
				addr_w = 0;
				if(!i_save)begin
					state_w = WAIT;
					
					bar_count_w = 0;
					//bar_valid_w = bar_valid_r | i_bar_data;
				end
				if(!i_mode) begin
							state_w = IDLE;
							write_w = 0;
						end
			end

			WAIT: begin
				//end_addr_w = addr_r;
				//if(!i_mode) begin
					//state_w = IDLE;
					//end_addr_w = addr_r;
				//end
				 
				if(i_bar_data[bar_count_r])begin
					write_w = 1;
					state_w = WRITE;
					record_data_w = i_music_data[15:0];
					addr_w = {14'b0,(bar_count_r+1),2'b0};
					bar_count_w = bar_count_r + 1;
					r_count_w = 0;
				end else begin//no this bar
					if(bar_count_r == 7) begin//no bar1
						bar_count_w = 0;				
							state_w = STOP;
							write_w = 0;
					end else begin//not bar 7
					bar_count_w = bar_count_r + 1;
					state_w = WAIT;
					end
				end	
					if(!i_mode) begin
						state_w = IDLE;
						write_w = 0;
					end
				//else
				//if(i_ready) begin
				//	state_w = WRITE;
				//	write_w = 1;
				//end else
			end
			
			WRITE: begin
				//end_addr_w = addr_r;
				//if(!i_mode) begin
					//state_w = IDLE;
					//end_addr_w = addr_r;
					//write_w = 0;
				//end else 
				if(r_count_r != 3)begin
					write_w = 1;
					state_w = WRITE;
					case(r_count_r)
					2'b00:record_data_w = i_music_data[31:16];
					2'b01:record_data_w = i_music_data[47:32];
					2'b10:record_data_w = i_music_data[63:48];
					endcase
					r_count_w =r_count_r+1;
					addr_w = addr_r + 1;
				end else begin//r count == 3
					if (bar_count_r == 8) begin//end of bar
						bar_count_w = 0;
						if(!i_mode) begin
							state_w = IDLE;
							write_w = 0;
						end else begin
					
							state_w = STOP;
							write_w = 0;
						end
					end else begin
						state_w = WAIT;
						write_w = 0;
					end
flag_w = 1;
					if(!i_mode) begin
							state_w = IDLE;
							write_w = 0;
					end
				end
			end


		endcase
	end

	always_ff @(posedge i_bclk or negedge i_rst) begin
		if(!i_rst) begin
			state_r <= CLEAR;
			write_r <= 0;
			addr_r <= 0;
			end_addr_r <= 0;
			//new_r <= 1;
			counter_r <= 0;
			record_data_r <= 0;
			bar_count_r <= 0;
			r_count_r <= 0;
			flag_r <= 0;
			bar_valid_r <= 0;
		end else begin
			state_r <= state_w;
			write_r <= write_w;
			addr_r <= addr_w;
			end_addr_r <= end_addr_w;
			//new_r <= new_w;
			counter_r <= counter_w;
			record_data_r <= record_data_w;
			bar_count_r <= bar_count_w;
			r_count_r <= r_count_w;
			flag_r <= flag_w;
			bar_valid_r <= bar_valid_w;
		end
	end



endmodule // sramWriter