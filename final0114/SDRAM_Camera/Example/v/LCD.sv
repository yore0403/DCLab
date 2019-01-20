module LCD(
	input i_clk, 
	input i_rst,
	input [6:0] i_state,
	input imode,
	//input [3:0] i_speed,
    inout [7:0] o_LCD_DATA,
	output o_LCD_EN,
	output o_LCD_ON,
	output o_LCD_RS,
	output o_LCD_RW
);

localparam LCD_INIT = 0, LCD_LINE1 = 4, LCD_LINE2 = 21; 
localparam clear_time = 19300, function_time = 600, write_time = 700;
localparam init_1 = 200, init_2 = init_1 + 52, init_3 = init_2 + 1210, init_4 = init_3 + function_time, init_5 = init_4 + function_time; 

logic en_w, en_r;
logic [6:0] i_state_r;
//logic [3:0] i_speed_r;
logic [14:0] LCD_counter_w, LCD_counter_r;
logic [8:0]  LCD_data_w, LCD_data_r;
logic [5:0]  index_w, index_r;
logic [8:0]  show [0:15];

assign o_LCD_ON = 1; // LCD power always on
assign o_LCD_RW = 0;
assign o_LCD_EN = en_r;
assign o_LCD_RS = LCD_data_r[8];
assign o_LCD_DATA = LCD_data_r[7:0];

//LCD_show show1(.state(i_state_r), .i_speed(i_speed), .show(show));
LCD_show show1(.music_state(i_state_r), .show(show), .mode(imode));

always_comb begin
	case(index_r)
		// initial
		LCD_INIT     : begin // function set
			if (LCD_counter_r < init_1) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
				en_w          = (LCD_counter_r == 1) ? 1 : 0;
			end else if ((LCD_counter_r >= init_1) && (LCD_counter_r < init_2)) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
				en_w          = (LCD_counter_r == init_1) ? 1 : 0;
			end else if ((LCD_counter_r >= init_2) && (LCD_counter_r < init_3)) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
				en_w          = (LCD_counter_r == init_2) ? 1 : 0;
			end else if ((LCD_counter_r >= init_3) && (LCD_counter_r < init_4)) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
				en_w          = (LCD_counter_r == init_3) ? 1 : 0;
			end else if ((LCD_counter_r >= init_4) && (LCD_counter_r < init_5)) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
				en_w          = (LCD_counter_r == init_4) ? 1 : 0;
			end else begin
				LCD_counter_w = 0;
				index_w       = index_r + 1;
				en_w = 0;
			end
		end
		
		LCD_INIT + 1 : begin  // display on
			en_w = (LCD_counter_r == 1) ? 1 : 0;
			if (LCD_counter_r < 3) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
			end else begin
				LCD_counter_w = 0;
				index_w       = index_r + 1;
			end
		end
		LCD_INIT + 2 : begin // display clear
			en_w = (LCD_counter_r == 1) ? 1 : 0;
			if (LCD_counter_r < clear_time) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
			end else begin
				LCD_counter_w = 0;
				index_w       = index_r + 1;
			end
		end
		LCD_INIT + 3 : begin // entry mode set
			en_w = (LCD_counter_r == 1) ? 1 : 0;
			if (LCD_counter_r < function_time) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
			end else begin
				LCD_counter_w = 0;
				index_w       = index_r + 1;
			end
		end
		
		// display
		LCD_LINE1, LCD_LINE2 : begin // set DDRAM address
			en_w = (LCD_counter_r == 1) ? 1 : 0;
			if (LCD_counter_r < function_time) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
			end else begin
				LCD_counter_w = 0;
				index_w       = index_r + 1;
			end
		end
		
		(LCD_LINE1 +  1), (LCD_LINE1 +  2), (LCD_LINE1 +  3), (LCD_LINE1 +  4), 
		(LCD_LINE1 +  5), (LCD_LINE1 +  6), (LCD_LINE1 +  7), (LCD_LINE1 +  8), 
		(LCD_LINE1 +  9), (LCD_LINE1 + 10), (LCD_LINE1 + 11), (LCD_LINE1 + 12),
		(LCD_LINE1 + 13), (LCD_LINE1 + 14), (LCD_LINE1 + 15), (LCD_LINE1 + 16), 
		(LCD_LINE2 +  1), (LCD_LINE2 +  2), (LCD_LINE2 +  3), (LCD_LINE2 +  4), 
		(LCD_LINE2 +  5), (LCD_LINE2 +  6), (LCD_LINE2 +  7), (LCD_LINE2 +  8), 
		(LCD_LINE2 +  9), (LCD_LINE2 + 10), (LCD_LINE2 + 11), (LCD_LINE2 + 12),
		(LCD_LINE2 + 13), (LCD_LINE2 + 14), (LCD_LINE2 + 15): begin
			en_w = ((LCD_counter_r < 8) && (LCD_counter_r > 0)) ? 1 : 0;
			if (LCD_counter_r < write_time) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
			end else begin
				LCD_counter_w = 0;
				index_w       = index_r + 1;
			end
		end
		(LCD_LINE2 + 16) : begin
			en_w = ((LCD_counter_r < 8) && (LCD_counter_r > 0)) ? 1 : 0;
			if (i_state == i_state_r) begin
				if (LCD_counter_r < write_time) begin
					LCD_counter_w =  LCD_counter_r + 1;
					index_w       = index_r;
				/*
				end else begin
					LCD_counter_w = (i_speed == i_speed_r) ? LCD_counter_r : 0;
					index_w       = (i_speed == i_speed_r) ? index_r : LCD_LINE1;
				
				*/
			    end else begin
			    	LCD_counter_w = LCD_counter_r;
			    	index_w = index_r;
			    	
				end
			end else begin
				if (LCD_counter_r < write_time) begin
					LCD_counter_w = LCD_counter_r + 1;
					index_w       = index_r;
				end else begin
					LCD_counter_w = 0;
					index_w       = LCD_LINE1;
				end
			end
		end
		
		default : begin // display clear
			en_w = (LCD_counter_r == 1) ? 1 : 0;
			if (LCD_counter_r < clear_time) begin
				LCD_counter_w = LCD_counter_r + 1;
				index_w       = index_r;
			end else begin
				LCD_counter_w = 0;
				index_w       = LCD_LINE1;
			end
		end
	endcase
end

// data
always_comb begin
	case(index_r)
		// initial
		LCD_INIT     : LCD_data_w = 9'h038; // 0_0011_1000, function set
		LCD_INIT + 1 : LCD_data_w = 9'h00c; // 0_0000_1100, display on
		LCD_INIT + 2 : LCD_data_w = 9'h001; // 0_0000_0101, display clear
		LCD_INIT + 3 : LCD_data_w = 9'h006; // 0_0000_0110, entry mode set
		
		// display line 1
		LCD_LINE1 : LCD_data_w = 9'h080; // set DDRAM address
		
		LCD_LINE1 +  1 : LCD_data_w = 9'h120; // " "
		LCD_LINE1 +  2 : LCD_data_w = 9'h120; // " "
		LCD_LINE1 +  3 : LCD_data_w = 9'h120; // " "
		LCD_LINE1 +  4 : LCD_data_w = show[0];
		LCD_LINE1 +  5 : LCD_data_w = show[1];
		LCD_LINE1 +  6 : LCD_data_w = show[2];
		LCD_LINE1 +  7 : LCD_data_w = show[3];
		LCD_LINE1 +  8 : LCD_data_w = show[4];
		LCD_LINE1 +  9 : LCD_data_w = show[5];
		LCD_LINE1 + 10 : LCD_data_w = show[6];
		LCD_LINE1 + 11 : LCD_data_w = show[7];
		LCD_LINE1 + 12 : LCD_data_w = show[8];
		LCD_LINE1 + 13 : LCD_data_w = show[9];
		LCD_LINE1 + 14 : LCD_data_w = 9'h120; // " "
		LCD_LINE1 + 15 : LCD_data_w = 9'h120; // " "
		LCD_LINE1 + 16 : LCD_data_w = 9'h120; // " "
		
		// display line 2
		LCD_LINE2 : LCD_data_w = 9'h0C0; // set DDRAM address
		
		LCD_LINE2 +  1 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 +  2 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 +  3 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 +  4 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 +  5 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 +  6 : LCD_data_w = show[10];
		LCD_LINE2 +  7 : LCD_data_w = show[11];
		LCD_LINE2 +  8 : LCD_data_w = show[12];
		LCD_LINE2 +  9 : LCD_data_w = show[13];
		LCD_LINE2 + 10 : LCD_data_w = show[14];
		LCD_LINE2 + 11 : LCD_data_w = show[15];
		LCD_LINE2 + 12 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 + 13 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 + 14 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 + 15 : LCD_data_w = 9'h120; // " "
		LCD_LINE2 + 16 : LCD_data_w = 9'h120; // " "
		
		default : LCD_data_w = 9'h001; // display clear
	endcase
end

always_ff @(posedge i_clk) begin
	if (!i_rst) begin
		index_r    <= LCD_INIT;
		LCD_data_r <= 9'h038;
		i_state_r  <= 0;
		en_r       <= 0;
		//i_speed_r  <= 7;
		LCD_counter_r <= 0;
	end else begin
		index_r    <= index_w;
		LCD_data_r <= LCD_data_w;
		i_state_r  <= i_state;
		en_r       <= en_w;
		//i_speed_r  <= i_speed;
		LCD_counter_r <= LCD_counter_w;
	end
end

endmodule






module LCD_show(
	input [6:0] music_state,
	input mode,
	output reg [8:0] show [0:15]

);
always_comb begin






	if(mode) begin	
		case (music_state)
			7'b1000000 : begin
					show[0] = 9'h14D; // "M"
					show[1] = 9'h16F; // "o"
					show[2] = 9'h16E; // "n"
					show[3] = 9'h16F; // "o"
					show[4] = 9'h170; // "p"
					show[5] = 9'h168; // "h"
					show[6] = 9'h16F; // "o"
					show[7] = 9'h16E; // "n"
					show[8] = 9'h169; // "i"
					show[9] = 9'h163; // "c"

					show[10] = 9'h120; // " "
					show[11] = 9'h150; // "P"
					show[12] = 9'h14C; // "L"
					show[13] = 9'h141; // "A"
					show[14] = 9'h159; // "Y"
					show[15] = 9'h120; // " "
			end
			7'b0100000 : begin
				show[0] = 9'h14D; // "M"
				show[1] = 9'h16F; // "o"
				show[2] = 9'h16E; // "n"
				show[3] = 9'h16F; // "o"
				show[4] = 9'h170; // "p"
				show[5] = 9'h168; // "h"
				show[6] = 9'h16F; // "o"
				show[7] = 9'h16E; // "n"
				show[8] = 9'h169; // "i"
				show[9] = 9'h163; // "c"

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0010000 : begin
				show[0] = 9'h14D; // "M"
				show[1] = 9'h16F; // "o"
				show[2] = 9'h16E; // "n"
				show[3] = 9'h16F; // "o"
				show[4] = 9'h170; // "p"
				show[5] = 9'h168; // "h"
				show[6] = 9'h16F; // "o"
				show[7] = 9'h16E; // "n"
				show[8] = 9'h169; // "i"
				show[9] = 9'h163; // "c"

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0001000 : begin
				show[0] = 9'h14D; // "M"
				show[1] = 9'h16F; // "o"
				show[2] = 9'h16E; // "n"
				show[3] = 9'h16F; // "o"
				show[4] = 9'h170; // "p"
				show[5] = 9'h168; // "h"
				show[6] = 9'h16F; // "o"
				show[7] = 9'h16E; // "n"
				show[8] = 9'h169; // "i"
				show[9] = 9'h163; // "c"

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0000100 : begin
				show[0] = 9'h14D; // "M"
				show[1] = 9'h16F; // "o"
				show[2] = 9'h16E; // "n"
				show[3] = 9'h16F; // "o"
				show[4] = 9'h170; // "p"
				show[5] = 9'h168; // "h"
				show[6] = 9'h16F; // "o"
				show[7] = 9'h16E; // "n"
				show[8] = 9'h169; // "i"
				show[9] = 9'h163; // "c"

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0000010 : begin
				show[0] = 9'h14D; // "M"
				show[1] = 9'h16F; // "o"
				show[2] = 9'h16E; // "n"
				show[3] = 9'h16F; // "o"
				show[4] = 9'h170; // "p"
				show[5] = 9'h168; // "h"
				show[6] = 9'h16F; // "o"
				show[7] = 9'h16E; // "n"
				show[8] = 9'h169; // "i"
				show[9] = 9'h163; // "c"

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0000001 : begin
				show[0] = 9'h14D; // "M"
				show[1] = 9'h16F; // "o"
				show[2] = 9'h16E; // "n"
				show[3] = 9'h16F; // "o"
				show[4] = 9'h170; // "p"
				show[5] = 9'h168; // "h"
				show[6] = 9'h16F; // "o"
				show[7] = 9'h16E; // "n"
				show[8] = 9'h169; // "i"
				show[9] = 9'h163; // "c"

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b1100000 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b1010000 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b1001000 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b1000100 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b1000010 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b1000001 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0110000 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0101000 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0100100 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0100010 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0100001 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0011000 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0010100 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0010010 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0010001 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0001100 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0001010 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0001001 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0000110 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "
	 
				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0000101 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0000011 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b1010100 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b1001010 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0001101 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
			7'b0100100 : begin
				show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h143; // "C"
				show[3] = 9'h168; // "h"
				show[4] = 9'h16F; // "o"
				show[5] = 9'h172; // "r"
				show[6] = 9'h164; // "d"
				show[7] = 9'h120; // " "
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end

		endcase
		end else if(!mode) begin
			show[0] = 9'h120; // " "
				show[1] = 9'h120; // " "
				show[2] = 9'h152; // "R"
				show[3] = 9'h165; // "e"
				show[4] = 9'h163; // "c"
				show[5] = 9'h16F; // "o"
				show[6] = 9'h172; // "r"
				show[7] = 9'h164; // "d"
				show[8] = 9'h120; // " "
				show[9] = 9'h120; // " "

				show[10] = 9'h120; // " "
				show[11] = 9'h150; // "P"
				show[12] = 9'h14C; // "L"
				show[13] = 9'h141; // "A"
				show[14] = 9'h159; // "Y"
				show[15] = 9'h120; // " "
			end
	


/*
	case (music_state)
		7'b1000000 : begin
			show[0] = 9'h14D; // "M"
			show[1] = 9'h16F; // "o"
			show[2] = 9'h16E; // "n"
			show[3] = 9'h16F; // "o"
			show[4] = 9'h170; // "p"
			show[5] = 9'h168; // "h"
			show[6] = 9'h16F; // "o"
			show[7] = 9'h16E; // "n"
			show[8] = 9'h169; // "i"
			show[9] = 9'h163; // "c"

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h120; // " "
			show[13] = 9'h120; // " "
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0100000 : begin
			show[0] = 9'h14D; // "M"
			show[1] = 9'h16F; // "o"
			show[2] = 9'h16E; // "n"
			show[3] = 9'h16F; // "o"
			show[4] = 9'h170; // "p"
			show[5] = 9'h168; // "h"
			show[6] = 9'h16F; // "o"
			show[7] = 9'h16E; // "n"
			show[8] = 9'h169; // "i"
			show[9] = 9'h163; // "c"

			show[10] = 9'h152; // "R"
			show[11] = 9'h165; // "e"
			show[12] = 9'h120; // " "
			show[13] = 9'h120; // " "
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0010000 : begin
			show[0] = 9'h14D; // "M"
			show[1] = 9'h16F; // "o"
			show[2] = 9'h16E; // "n"
			show[3] = 9'h16F; // "o"
			show[4] = 9'h170; // "p"
			show[5] = 9'h168; // "h"
			show[6] = 9'h16F; // "o"
			show[7] = 9'h16E; // "n"
			show[8] = 9'h169; // "i"
			show[9] = 9'h163; // "c"

			show[10] = 9'h14D; // "M"
			show[11] = 9'h165; // "e"
			show[12] = 9'h120; // " "
			show[13] = 9'h120; // " "
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0001000 : begin
			show[0] = 9'h14D; // "M"
			show[1] = 9'h16F; // "o"
			show[2] = 9'h16E; // "n"
			show[3] = 9'h16F; // "o"
			show[4] = 9'h170; // "p"
			show[5] = 9'h168; // "h"
			show[6] = 9'h16F; // "o"
			show[7] = 9'h16E; // "n"
			show[8] = 9'h169; // "i"
			show[9] = 9'h163; // "c"

			show[10] = 9'h146; // "F"
			show[11] = 9'h161; // "a"
			show[12] = 9'h120; // " "
			show[13] = 9'h120; // " "
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0000100 : begin
			show[0] = 9'h14D; // "M"
			show[1] = 9'h16F; // "o"
			show[2] = 9'h16E; // "n"
			show[3] = 9'h16F; // "o"
			show[4] = 9'h170; // "p"
			show[5] = 9'h168; // "h"
			show[6] = 9'h16F; // "o"
			show[7] = 9'h16E; // "n"
			show[8] = 9'h169; // "i"
			show[9] = 9'h163; // "c"

			show[10] = 9'h153; // "S"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h120; // " "
			show[13] = 9'h120; // " "
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0000010 : begin
			show[0] = 9'h14D; // "M"
			show[1] = 9'h16F; // "o"
			show[2] = 9'h16E; // "n"
			show[3] = 9'h16F; // "o"
			show[4] = 9'h170; // "p"
			show[5] = 9'h168; // "h"
			show[6] = 9'h16F; // "o"
			show[7] = 9'h16E; // "n"
			show[8] = 9'h169; // "i"
			show[9] = 9'h163; // "c"

			show[10] = 9'h14C; // "L"
			show[11] = 9'h165; // "a"
			show[12] = 9'h120; // " "
			show[13] = 9'h120; // " "
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0000001 : begin
			show[0] = 9'h14D; // "M"
			show[1] = 9'h16F; // "o"
			show[2] = 9'h16E; // "n"
			show[3] = 9'h16F; // "o"
			show[4] = 9'h170; // "p"
			show[5] = 9'h168; // "h"
			show[6] = 9'h16F; // "o"
			show[7] = 9'h16E; // "n"
			show[8] = 9'h169; // "i"
			show[9] = 9'h163; // "c"

			show[10] = 9'h153; // "S"
			show[11] = 9'h169; // "i"
			show[12] = 9'h120; // " "
			show[13] = 9'h120; // " "
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b1100000 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h152; // "R"
			show[13] = 9'h165; // "e"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b1010000 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h14D; // "M"
			show[13] = 9'h165; // "e"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b1001000 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h146; // "F"
			show[13] = 9'h161; // "a"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b1000100 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h153; // "S"
			show[13] = 9'h16F; // "o"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b1000010 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h14C; // "L"
			show[13] = 9'h161; // "a"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b1000001 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h153; // "S"
			show[13] = 9'h169; // "i"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0110000 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h152; // "R"
			show[11] = 9'h165; // "e"
			show[12] = 9'h14D; // "M"
			show[13] = 9'h165; // "e"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0101000 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h152; // "R"
			show[11] = 9'h165; // "e"
			show[12] = 9'h146; // "F"
			show[13] = 9'h161; // "a"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0100100 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h152; // "R"
			show[11] = 9'h165; // "e"
			show[12] = 9'h153; // "S"
			show[13] = 9'h16F; // "o"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0100010 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h152; // "R"
			show[11] = 9'h165; // "e"
			show[12] = 9'h14C; // "L"
			show[13] = 9'h161; // "a"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0100001 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h152; // "R"
			show[11] = 9'h165; // "e"
			show[12] = 9'h153; // "S"
			show[13] = 9'h169; // "i"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0011000 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h14D; // "M"
			show[11] = 9'h165; // "e"
			show[12] = 9'h146; // "F"
			show[13] = 9'h161; // "a"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0010100 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h14D; // "M"
			show[11] = 9'h165; // "e"
			show[12] = 9'h153; // "S"
			show[13] = 9'h16F; // "o"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0010010 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h14D; // "M"
			show[11] = 9'h165; // "e"
			show[12] = 9'h14C; // "L"
			show[13] = 9'h161; // "a"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0010001 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h14D; // "M"
			show[11] = 9'h165; // "e"
			show[12] = 9'h153; // "S"
			show[13] = 9'h169; // "i"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0001100 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h146; // "F"
			show[11] = 9'h161; // "a"
			show[12] = 9'h153; // "S"
			show[13] = 9'h16F; // "o"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0001010 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h146; // "F"
			show[11] = 9'h161; // "a"
			show[12] = 9'h14C; // "L"
			show[13] = 9'h161; // "a"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0001001 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h146; // "F"
			show[11] = 9'h161; // "a"
			show[12] = 9'h153; // "S"
			show[13] = 9'h169; // "i"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0000110 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "
 
			show[10] = 9'h153; // "S"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h14C; // "L"
			show[13] = 9'h161; // "a"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0000101 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h153; // "S"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h153; // "S"
			show[13] = 9'h169; // "i"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b0000011 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h14C; // "L"
			show[11] = 9'h161; // "a"
			show[12] = 9'h153; // "S"
			show[13] = 9'h169; // "i"
			show[14] = 9'h120; // " "
			show[15] = 9'h120; // " "
		end
		7'b1010100 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h14D; // "M"
			show[13] = 9'h165; // "e"
			show[14] = 9'h153; // "S"
			show[15] = 9'h16F; // "o"
		end
		7'b1001010 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h144; // "D"
			show[11] = 9'h16F; // "o"
			show[12] = 9'h146; // "F"
			show[13] = 9'h161; // "a"
			show[14] = 9'h14C; // "L"
			show[15] = 9'h161; // "a"
		end
		7'b0001101 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h146; // "F"
			show[11] = 9'h161; // "a"
			show[12] = 9'h153; // "S"
			show[13] = 9'h16F; // "o"
			show[14] = 9'h153; // "S"
			show[15] = 9'h169; // "i"
		end
		7'b0100100 : begin
			show[0] = 9'h120; // " "
			show[1] = 9'h120; // " "
			show[2] = 9'h143; // "C"
			show[3] = 9'h168; // "h"
			show[4] = 9'h16F; // "o"
			show[5] = 9'h172; // "r"
			show[6] = 9'h164; // "d"
			show[7] = 9'h120; // " "
			show[8] = 9'h120; // " "
			show[9] = 9'h120; // " "

			show[10] = 9'h152; // "R"
			show[11] = 9'h165; // "e"
			show[12] = 9'h153; // "S"
			show[13] = 9'h16F; // "o"
			show[14] = 9'h153; // "S"
			show[15] = 9'h169; // "i"
		end
	endcase
*/
end
endmodule
/*
module LCD_show(
	input [2:0] state, 
	input [3:0] i_speed,
	output reg [8:0] show [0:15]
);

localparam IDLE = 0, PLAY = 1, PLAY_s = 2, RECORD = 3, RECORD_s = 4;

logic [8:0] speed [0:2];

always_comb begin
	
	case (i_speed)
		0 : begin
			speed[0] = 9'h13C; // "<"
			speed[1] = 9'h13C; // "<"
			speed[2] = 9'h138; // "8"
		end
		1 : begin
			speed[0] = 9'h13C; // "<"
			speed[1] = 9'h13C; // "<"
			speed[2] = 9'h137; // "7"
		end
		2 : begin
			speed[0] = 9'h13C; // "<"
			speed[1] = 9'h13C; // "<"
			speed[2] = 9'h136; // "6"
		end
		3 : begin
			speed[0] = 9'h13C; // "<"
			speed[1] = 9'h13C; // "<"
			speed[2] = 9'h135; // "5"
		end
		4 : begin
			speed[0] = 9'h13C; // "<"
			speed[1] = 9'h13C; // "<"
			speed[2] = 9'h134; // "4"
		end
		5 : begin
			speed[0] = 9'h13C; // "<"
			speed[1] = 9'h13C; // "<"
			speed[2] = 9'h133; // "3"
		end
		6 : begin
			speed[0] = 9'h13C; // "<"
			speed[1] = 9'h13C; // "<"
			speed[2] = 9'h132; // "2"
		end
		7 : begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h131; // "1" 
		end
		8 : begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h132; // "2" 
		end
		9 : begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h133; // "3"
		end
		10: begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h134; // "4"
		end
		11: begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h135; // "5"
		end
		12: begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h136; // "6"
		end
		13: begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h137; // "7" 
		end
		14: begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h138; // "8"
		end
		default : begin
			speed[0] = 9'h13E; // ">"
			speed[1] = 9'h13E; // ">"
			speed[2] = 9'h131; // "1" 
		end
	endcase

	
	case (state) 
		RECORD_s, PLAY_s : begin
			show[11] = 9'h150;  // "P"
			show[12] = 9'h141;  // "A"
			show[13] = 9'h155;  // "U"
			show[14] = 9'h153;  // "S"
			show[15] = 9'h145;  // "E"
		end
		PLAY : begin
			show[11] = speed[0];
			show[12] = speed[1];
			show[13] = 9'h120;  // " "
			show[14] = 9'h120;  // " "
			show[15] = speed[2];
		end
		default : begin
			show[11] = 9'h120;  // " "
			show[12] = 9'h120;  // " "
			show[13] = 9'h120;  // " "
			show[14] = 9'h120;  // " "
			show[15] = 9'h120;  // " "
		end
	endcase
	
	case (state) 
		RECORD, RECORD_s : begin
			show[0]  = 9'h152;  // "R"
			show[1]  = 9'h145;  // "E"
			show[2]  = 9'h143;  // "C"
			show[3]  = 9'h14F;  // "O"
			show[4]  = 9'h152;  // "R"
			show[5]  = 9'h144;  // "D"
			show[6]  = 9'h1DA;
			show[7]  = 9'h1BA;
			show[8]  = 9'h1B0;
			show[9]  = 9'h1C4;
			show[10] = 9'h1DE;
		end
		PLAY, PLAY_s : begin
			show[0]  = 9'h120;  // " "
			show[1]  = 9'h150;  // "P"
			show[2]  = 9'h14C;  // "L"
			show[3]  = 9'h141;  // "A"
			show[4]  = 9'h159;  // "Y"
			show[5]  = 9'h120;  // " "
			show[6]  = 9'h120;
			show[7]  = 9'h1CC;
			show[8]  = 9'h1DF;
			show[9] = 9'h1DA;
			show[10] = 9'h1B0;
		end
		default : begin // IDLE
			show[0]  = 9'h120;  // " "
			show[1]  = 9'h149;  // "I"
			show[2]  = 9'h144;  // "D"
			show[3]  = 9'h14C;  // "L"
			show[4]  = 9'h145;  // "E"
			show[5]  = 9'h120;  // " "
			show[6]  = 9'h1B1;
			show[7]  = 9'h1B2;
			show[8]  = 9'h1C4;
			show[9] = 9'h1DE;
			show[10] = 9'h1D9;
		end
	endcase
end
endmodule
*/