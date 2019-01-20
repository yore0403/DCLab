module Rsa256Core(
	input i_clk,
	input i_rst,
	input i_start,
	input [255:0] i_a,
	input [255:0] i_e,
	input [255:0] i_n,
	output [255:0] o_a_pow_e,
	output o_finished
);

logic working;

power_mont pmt1( 
	.i_start(i_start), 
	.i_clock(i_clk), 
	.i_rst(i_rst), 
	.i_a(i_a), 
	.i_b(i_e), 
	.i_n(i_n), 
	.o_ret(o_a_pow_e), 
	.o_finish(o_finished),
	.o_working(working)
);

endmodule

module power_mont(
	input i_start,
	input i_clock,
	input i_rst,
	input [255:0] i_a,
	input [255:0] i_b,
	input [255:0] i_n,
	output [255:0] o_ret,
	output o_finish,
	output o_working
);

	logic [255:0] a_r, a_w, b_r, b_w, n_r, n_w;
	logic [255:0] return_r, return_w, return_o_r, return_o_w, prep_return, mul1_return, mul2_return;
	logic [256:0] counter_r, counter_w;
	logic [255:0] a2_r, a2_w; 
	logic finish1_r, finish1_w, finish2_r, finish2_w, mul1_finish, mul2_finish, finish_r, finish_w;
	logic mul1_working, mul2_working, working_o_w, working_o_r;
	logic start_r, start_w;
	logic prep_working;
	logic prep_finish;
	
	assign o_finish = finish_r;
	assign o_ret = return_o_r;
	assign o_working = working_o_r;


preprocess_mont prep1( 
	 .i_start(i_start),
	 .i_clock(i_clock),
	 .i_rst(i_rst),
	 .i_a(i_a),
	 .i_n(i_n),
	 .o_ret(prep_return),
	 .o_finish(prep_finish),
	 .o_working(prep_working)
 );
 
mul_mont mul1( 
	 .i_start(start_r),
	 .i_clock(i_clock),
	 .i_rst(i_rst),
	 .i_a(return_r),
	 .i_b(a2_r),
	 .i_n(n_r),
	 .o_ret(mul1_return),
	 .o_finish(mul1_finish),
	 .o_working(mul1_working)
 );

mul_mont mul2( 
	 .i_start(start_r),
	 .i_clock(i_clock),
	 .i_rst(i_rst),
	 .i_a(a2_r),
	 .i_b(a2_r),
	 .i_n(n_r),
	 .o_ret(mul2_return),
	 .o_finish(mul2_finish),
	 .o_working(mul2_working)
 );
 
	always_comb begin
		if(i_rst) begin
			a_w = 0;
			b_w = 0;
			n_w = 0;
			counter_w = 0;
			return_w = 0; 
			finish_w = 0;
			return_o_w = 0;
			working_o_w = 0;
			a2_w = 0;
			finish1_w = 0;
			finish2_w = 0;
			start_w = 0;
		end else if(i_start) begin
			counter_w = 0;
			a2_w = 0;
			finish1_w = 0;
			finish2_w = 0;
			start_w = 0;
			return_o_w = return_o_r;
			finish_w = 0;
			a_w = i_a;
			b_w = i_b;
			n_w = i_n;
			return_w = 0;
			working_o_w = 1;
		end else if( prep_finish ) begin
			finish_w = 0;
			a_w = a_r;
			b_w = b_r;
			n_w = n_r;
			working_o_w = working_o_r;
			return_o_w = return_o_r;
			a2_w = prep_return;
			return_w = 1;
			counter_w = 1;
			finish1_w = 0;
			finish2_w = 0;
			start_w = 1;
//			hold_w = 1;
			
		end else begin
//			if(hold_r) begin start_w = 1; hold_w = 0; end
			if(finish_r) finish_w = 0;
			if(start_r) start_w = 0;
			if(~counter_r[256]) begin
				if( finish1_r & finish2_r ) begin
					return_w = return_r; 
					finish_w = 0;
					a2_w = a2_r;
					a_w = a_r;
					b_w = b_r;
					n_w = n_r;
					working_o_w = working_o_r;
					return_o_w = return_o_r;
					start_w = 1;
					finish1_w = 0;
					finish2_w = 0;
					counter_w = counter_r << 1;
				end else begin
					counter_w = counter_r;
					finish_w = 0;
					start_w = 0;
					a_w = a_r;
					b_w = b_r;
					n_w = n_r;
					working_o_w = working_o_r;
					return_o_w = return_o_r;
					if( mul1_finish ) begin
						if( b_r&counter_r[255:0]) return_w = mul1_return;
						else return_w = return_r;
						finish1_w = 1;
					end else begin return_w = return_r; finish1_w = 0; end
					if( mul2_finish ) begin
						a2_w = mul2_return;
						finish2_w = 1;
					end else begin a2_w = a2_r; finish2_w = 0; end
				end
			end else begin
				a2_w = a2_r;
				finish1_w = finish1_r;
				finish2_w = finish2_r;
				start_w = 0;
				a_w = a_r;
				b_w = b_r;
				n_w = n_r;
				counter_w = 0;
				return_o_w = return_r;
				return_w = return_r;
				finish_w = 1;
				working_o_w = 0;
			end
		end

		
	
	end
	
	always_ff @(posedge i_clock) begin
		counter_r <= counter_w;
		return_r <= return_w; 
		finish_r <= finish_w;
		a2_r <= a2_w;
		finish1_r <= finish1_w;
		finish2_r <= finish2_w;
		start_r <= start_w;
		a_r <= a_w;
		b_r <= b_w;
		n_r <= n_w;
		working_o_r <= working_o_w;
		return_o_r <= return_o_w;
	end
	
endmodule


module mul_mont(
	input i_start,
	input i_clock,
	input i_rst,
	input [255:0] i_a,
	input [255:0] i_b,
	input [255:0] i_n,
	output [255:0] o_ret,
	output o_finish,
	output o_working
);

	
	logic [257:0] a_r, a_w, b_r, b_w, n_r, n_w;
	logic [257:0] return_r, return_m0, return_m1, return_w, return_o_w, return_o_r;
	logic [256:0] counter_r, counter_w;
	logic finish_r, finish_w, working_w, working_r;
	
	assign o_finish = finish_r;
	assign o_ret = return_o_r[255:0];
	assign o_working = working_r;
	
	always_comb begin

		if(i_rst) begin
			counter_w = 0;
			return_w = 0; 
			finish_w = 0;
			return_o_w = 0;
			working_w = 0;
			n_w = 0;
			a_w = 0;
			b_w = 0;
		end else if( i_start ) begin
			counter_w = 1;
			finish_w = 0;
			a_w = i_a;
			b_w = i_b;
			n_w = i_n;
			return_w = 0;
			return_o_w = return_o_r;
			return_m1 = 0;
			working_w = 1;
		end else begin
			if(finish_r) finish_w = 0;
			if(~counter_r[256]) begin
				if( (b_r&counter_r[255:0]) && (return_r[0] ^ a_r[0]))
						return_w = (return_r + a_r + n_r) >> 1;
				else if(  b_r&counter_r[255:0] )
						return_w = (return_r + a_r ) >> 1;
				else if( return_r[0] )
						return_w = (return_r + n_r) >> 1;
				else 
						return_w = return_r >> 1;

				counter_w = counter_r << 1;
				finish_w = 0;
				a_w = a_r;
				b_w = b_r;
				n_w = n_r;
				working_w = working_r;
				return_o_w = return_o_r;
			end else begin
				counter_w = 0;
				if( return_r > n_r ) begin
					return_w = return_r - n_r;
					return_o_w = return_r - n_r;
				end else begin 
					return_w = return_r;
					return_o_w = return_r;
				end
				if(counter_r[256]) finish_w = 1;
				else finish_w = 0;
				a_w = a_r;
				b_w = b_r;
				n_w = n_r;
				working_w = 0;
				
			end
		end
		
		
	
	end
	
	always_ff @(posedge i_clock) begin
		counter_r <= counter_w;
		return_r <= return_w; 
		finish_r <= finish_w;
		n_r <= n_w;
		a_r <= a_w;
		b_r <= b_w;
		working_r <= working_w;
		return_o_r <= return_o_w;
	end

endmodule


module preprocess_mont(
	input i_start,
	input i_clock,
	input i_rst,
	input [255:0] i_a,
	input [255:0] i_n,
	output [255:0] o_ret,
	output o_finish,
	output o_working
);

	
	logic [255:0] n_w, n_r, n2;
	logic [256:0] a_r, a_m, a_w, return_w, return_r;
	logic [256:0] counter_r, counter_w;
	logic finish_r, finish_w, working_w, working_r;
	
	assign o_finish = finish_r;
	assign o_ret = return_r[255:0];
	assign o_working = working_r;
	
	always_comb begin
	counter_w = counter_r;
	a_w = a_r; 
	if(finish_r) finish_w = 0;
	else finish_w = finish_r;


		if( i_start ) begin
			counter_w = 1;
			finish_w = 0;
			a_w = i_a;
			n_w = i_n;
			working_w = 1;
			return_w = return_r;
		end else begin

//			if(finish_r) finish_w = 0;
			if(~counter_r[256]) begin
//				a_m = a_r << 1;
				if ({a_r[255:0],1'b0} >= n_r[255:0]) a_w = (a_r<<1) - n_r;
				else a_w = a_r<<1;
				counter_w = counter_r << 1;
				finish_w = 0;
				return_w = return_r;
				n_w = n_r;
			end else begin
				counter_w = 0;
				return_w = a_r;
				if(counter_r[256]) finish_w = 1;
				else finish_w = 0;
				working_w = 0;
				a_w = a_r;
				n_w = n_r;
			end
		end
		
		
		
	
	end
	
	always_ff @(posedge i_clock) begin
		
		if(i_rst)
		begin
			counter_r <= 0;
			a_r <= 0; 
			finish_r <= 0;	
			return_r <= 0;
			n_r <= 0;
		end
		else
		begin
			counter_r <= counter_w;
			a_r <= a_w; 
			finish_r <= finish_w;	
			return_r <= return_w;
			n_r <= n_w;
		end
	end
	
endmodule
