// calculate a ^ e mod n
module Rsa256Core(
    input  i_clk,
    input  i_rst,
    input  i_start,
    input  [255:0] i_a,
    input  [255:0] i_e,
    input  [255:0] i_n,
    output [255:0] o_a_pow_e,
    output o_finished
);

    enum {IDLE, MOD_PROD, MONT, MONT_CAL, DONE} state_w, state_r;
 
	logic [255:0] ans_r, ans_w, t_w, t_r;
	logic [255:0] a_r, a_w, e_r, e_w, n_r, n_w;
	logic [  8:0] k_r, k_w; // counter
	logic [  1:0] mc_r, mc_w; 
    logic         finished_w, finished_r;
    
    logic [255:0] result_mod_prod, result_mod;
    logic         start_mod_prod_r, start_mod_prod_w;
    logic         finish_mod_prod;

    logic [255:0] result_mont_1, result_mont_2;
    logic         start_mont_1_r, start_mont_1_w, start_mont_2_r, start_mont_2_w;
    logic         finish_mont_1, finish_mont_2;
    logic [255:0] a_mont_1_w, a_mont_1_r, a_mont_2_w, a_mont_2_r;
    logic [255:0] b_mont_1_w, b_mont_1_r, b_mont_2_w, b_mont_2_r;

    ModuloProduct modulo_product(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(start_mod_prod_r),
        .i_n({1'b0,n_r}), // concat 1 bit to MSB since i_n [256:0]
        .i_a({1'b1,{256{1'b0}}}), // a = 2^256
        .i_b({1'b0,a_r}),
        .o_result(result_mod_prod),
        .o_finished(finish_mod_prod)
    );

    Mongomery mongomery_1(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(start_mont_1_r),
        .a(a_mont_1_r),
        .b(b_mont_1_r),
        .n(n_r),
        .m(result_mont_1),
        .done(finish_mont_1)
    );

    Mongomery mongomery_2(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(start_mont_2_r),
        .a(a_mont_2_r),
        .b(b_mont_2_r),
        .n(n_r),
        .m(result_mont_2),
        .done(finish_mont_2)
    );

    assign o_finished = finished_r;
    assign o_a_pow_e = ans_r;

    always_comb begin
        state_w = state_r;
		ans_w = ans_r;
		t_w = t_r;
		a_w = a_r;
		e_w = e_r;
		n_w = n_r;
    	k_w = k_r; // counter
        finished_w = finished_r;
        start_mod_prod_w = start_mod_prod_r;
    	start_mont_1_w = start_mont_1_r;
		start_mont_2_w = start_mont_2_r;
    	a_mont_1_w = a_mont_1_r;
	   	a_mont_2_w = a_mont_2_r;
    	b_mont_1_w = b_mont_1_r;
	   	b_mont_2_w = b_mont_2_r;
		mc_w = mc_r;

        case (state_r)
            IDLE: begin
                finished_w = 0;
                ans_w = 0;
            end

            MOD_PROD: begin
                start_mod_prod_w = 0;
                if (finish_mod_prod == 1) begin
                    state_w = MONT;
                    t_w = result_mod_prod;
                end
            end

            MONT: begin
                if (e_r[k_r] == 1) begin
					start_mont_1_w = 1;
					a_mont_1_w = ans_r;
					b_mont_1_w = t_r;
                end else begin
					mc_w = mc_r + 1;
				end

				start_mont_2_w = 1;
			    a_mont_2_w = t_r;
				b_mont_2_w = t_r;

				state_w = MONT_CAL;
            end

			MONT_CAL: begin
				start_mont_1_w = 0;
				start_mont_2_w = 0;
				if (finish_mont_1) begin
					mc_w[0] = 1;
					ans_w = result_mont_1;
				end
				if (finish_mont_2) begin
					mc_w[1] = 1;
					t_w = result_mont_2;
				end
				if (mc_r == 3) begin
					if (k_r == 255) begin
						state_w = DONE;
						finished_w = 1;
						mc_w = 0;
						k_w = 0;
					end else begin
						state_w = MONT;
						mc_w = 0;
						k_w = k_r + 1;
					end
				end
			end

            DONE: begin
                state_w = IDLE;
                finished_w = 0;
            end

		endcase
        
        if (i_start) begin
            state_w = MOD_PROD;
			start_mod_prod_w = 1;
            ans_w = 1;
            k_w = 0;
			a_w = i_a;
			e_w = i_e;
			n_w = i_n;
			mc_w = 0;
		end
    end

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            ans_r <= 1;
            state_r <= IDLE;
			t_r <= 0;
			k_r <= 0;
			finished_r <= 0;
	   	    start_mod_prod_r <= 0;
   		 	start_mont_1_r <= 0;
			start_mont_2_r <= 0;
    		a_mont_1_r <= 0;
		   	a_mont_2_r <= 0;
    		b_mont_1_r <= 0;
	   		b_mont_2_r <= 0;
			a_r <= 0;
			e_r <= 0;
			n_r <= 0;
			mc_r <= 0;
			end else begin
	        state_r <= state_w;
			ans_r <= ans_w;
			t_r <= t_w;
   	 		k_r <= k_w; // counter
   	    	finished_r <= finished_w;
   	    	start_mod_prod_r <= start_mod_prod_w;
   		 	start_mont_1_r <= start_mont_1_w;
			start_mont_2_r <= start_mont_2_w;
   		 	a_mont_1_r <= a_mont_1_w;
		   	a_mont_2_r <= a_mont_2_w;
    		b_mont_1_r <= b_mont_1_w;
	   		b_mont_2_r <= b_mont_2_w;
			a_r <= a_w;
			e_r <= e_w;
			n_r <= n_w;
			mc_r <= mc_w;
        end
    end
endmodule





module Mongomery(
    input i_clk,
    input i_rst,
    input i_start,
    input [255:0] a,
    input [255:0] b,
    input [255:0] n,
    output [255:0] m,
    output done
);
    //combinational 
    logic [256:0] ret_w;
    logic [7:0] i_w;
    logic [256:0] ret_temp; 
    //sequential 
    logic [7:0] i_r;
    logic [256:0] ret_r;
    assign i_w=i_r;
    assign m = ret_w[255:0];
    assign done = (i_w==255) ? 1 : 0;
    
    always_comb begin
        if(b[i_w]==1) begin
            if(ret_w[0]==1) begin  // ret_w is odd
                ret_temp = (ret_r + a + n) >> 1 ;
            end
            else begin
                ret_temp = (ret_r + a) >> 1 ;
            end
            
        end
        else begin
            ret_temp = ret_r;
        end
        
        if(ret_temp >= n) begin
            ret_w = ret_temp - n;
        end
        else begin
            ret_w = ret_temp;
        end
    end
    
    always_ff @ (posedge i_clk) begin
        if(i_rst==1 || i_start==1) begin
            ret_r <= 0;
            i_r <=0;
        end
        else begin
            ret_r <= ret_w;
            i_r <= i_w + 1;
        end
    end

endmodule


module ModuloProduct(
    input  i_clk,
    input  i_rst,
    input  i_start,
    input  [256:0] i_n,
    input  [256:0] i_a, //2^256 has 257 bits
    input  [256:0] i_b,
    output [255:0] o_result, // 256 bits only
    output         o_finished
);


    enum  {IDLE, RUN, DONE} state_w, state_r;

    logic [256:0] result_w, result_r;
    logic [256:0] temp_w, temp_r;
    logic [9:0]   counter_w, counter_r;
    logic         finished_w, finished_r;
    logic [256:0] temp_times_two;

    assign o_result = result_w[255:0]; // no overflow for result_w
    assign o_finished = finished_w;
	assign temp_times_two = temp_r << 1; // calculate 2*temp_r by bitwise shoft operator
                                         // modulo i_n (256bits) by truncation

    always_comb begin
        state_w = state_r;
        result_w = result_r;
        temp_w = temp_r;
        counter_w = counter_r;
        finished_w = finished_r;

        case (state_r)
            IDLE:   begin
                        if (i_start) begin
                            state_w = RUN;
                            result_w = 0;
							temp_w = i_b;
                        end
                    end

            RUN:    begin
                        if (counter_r == 256) begin // 2^256 only has bit 1 at the 257-th bit
                            if ((result_r + temp_r) >= i_n) begin
                                result_w = result_r + temp_r - i_n;
                            end else begin
                                result_w = result_r + temp_r;
                            end // end else
                            state_w = DONE;
                            finished_w = 1;
                            counter_w = 0;
                        end else begin
                            counter_w = counter_r + 1;
                        end // end else

                        if (temp_times_two >= i_n) begin
                            temp_w = temp_times_two - i_n;
                        end else begin
                            temp_w = temp_times_two;
                        end // end else

                    end

            DONE:   begin
                        finished_w = 0;
                        state_w = IDLE;
                    end
        endcase
    end // always_comb

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            state_r <= IDLE;
            result_r <= 0;
            temp_r <= 0;
            counter_r <= 0;
            finished_r <= 0;
        end else begin 
            state_r <= state_w;
            result_r <= result_w;
            temp_r <= temp_w;
            counter_r <= counter_w;
            finished_r <= finished_w;
        end 
    end

endmodule // ModuloProduct
