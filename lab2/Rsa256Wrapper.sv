module Rsa256Wrapper(
    input avm_rst,
    input avm_clk,
    output [4:0] avm_address,
    output avm_read,
    input [31:0] avm_readdata,
    output avm_write,
    output [31:0] avm_writedata,
    input avm_waitrequest
);
    localparam RX_BASE     = 0*4;
    localparam TX_BASE     = 1*4;
    localparam STATUS_BASE = 2*4;
    localparam TX_OK_BIT = 6;
    localparam RX_OK_BIT = 7;

    // Feel free to design your own FSM!
    localparam S_GET_KEY = 0;
    localparam S_GET_DATA = 1;
    localparam S_WAIT_CALCULATE = 2;
    localparam S_SEND_DATA = 3;

    logic [255:0] n_r, n_w, e_r, e_w, enc_r, enc_w, dec_r, dec_w;
    logic [1:0] state_r, state_w;
    logic [6:0] bytes_counter_r, bytes_counter_w;
    logic [4:0] avm_address_r, avm_address_w;
    logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;

    logic rsa_start_r, rsa_start_w;
    logic rsa_finished;
    logic [255:0] rsa_dec;
    logic check_r, check_w;
    logic [3:0] counter_r,counter_w;

    assign avm_address = avm_address_r;
    assign avm_read = avm_read_r;
    assign avm_write = avm_write_r;
    assign avm_writedata = dec_r[247-:8];

    Rsa256Core rsa256_core(
        .i_clk(avm_clk),
        .i_rst(avm_rst),
        .i_start(rsa_start_r),
        .i_a(enc_r),
        .i_e(e_r),
        .i_n(n_r),
        .o_a_pow_e(rsa_dec),
        .o_finished(rsa_finished)
    );

    task StartRead;
        input [4:0] addr;
        begin
            avm_read_w = 1;
            avm_write_w = 0;
            avm_address_w = addr;
        end
    endtask
    task StartWrite;
        input [4:0] addr;
        begin
            avm_read_w = 0;
            avm_write_w = 1;
            avm_address_w = addr;
        end
    endtask

    always_comb begin
        // TODO
        n_w = n_r;
        e_w = e_r;
        enc_w = enc_r;
        dec_w = dec_r;
        avm_read_w = avm_read_r;
        avm_write_w = avm_write_r;
        avm_address_w = avm_address_r;
        state_w = state_r;
        bytes_counter_w = bytes_counter_r;
        rsa_start_w = rsa_start_r;
        check_w = check_r;
        counter_w = counter_r;






        case(state_r)
            S_GET_KEY:begin
                if(!check_r)begin //check if waitrequest = 0 and RX_OK_BIT = 1
                    if(!avm_waitrequest)begin
                        if(avm_readdata[RX_OK_BIT])begin
                            StartRead(RX_BASE);
                            check_w = 1;
                        end
                        else check_w = check_r;
                    end
                    else check_w = check_r;
                    state_w = S_GET_KEY;
                end
                else begin // start to get key
                    if(bytes_counter_r[6:5] == 2)begin //count from 64 to 95 for getting N
                        if(!avm_waitrequest) begin
                            StartRead(STATUS_BASE);
                            n_w = (n_r << 8) + avm_readdata[7:0];
                            bytes_counter_w = bytes_counter_r + 1;
                            check_w = 0;
                        end
                        else begin
                            n_w = n_r;
                            bytes_counter_w = bytes_counter_r;
                            check_w = check_r;
                        end
                        state_w = S_GET_KEY;
						e_w = e_r;
						enc_w = enc_r;
						dec_w = dec_r;
                        rsa_start_w = rsa_start_r;
                    end
                    else if (bytes_counter_r[6:5] == 3)begin //count from 96 to 127 for getting e
                        if(!avm_waitrequest) begin
                            StartRead(STATUS_BASE);
                            e_w = (e_r << 8) + avm_readdata[7:0];
                            bytes_counter_w = bytes_counter_r + 1;
                            check_w = 0;
                            if(bytes_counter_r[4:0] == 31) state_w = S_GET_DATA; // finish getting key
							else state_w = S_GET_KEY;
                        end
                        else begin
                            e_w = e_r;
                            bytes_counter_w = bytes_counter_r;
                            check_w = check_r;
                        end
                    end
                    else begin
                        n_w = n_r;
						e_w = e_r;
						enc_w = enc_r;
						dec_w = dec_r;
						state_w = state_r;
						bytes_counter_w = bytes_counter_r;
						rsa_start_w = rsa_start_r;
                        check_w = check_r;
                    end
                end
            end
            
            S_GET_DATA:begin
                if(!check_r)begin //check if waitrequest = 0 and RX_OK_BIT = 1
                    if(!avm_waitrequest)begin
                        if(avm_readdata[RX_OK_BIT])begin
                            StartRead(RX_BASE);
                            check_w = 1;
                        end
                        else check_w = check_r;
                    end
                    else check_w = check_r;
                    state_w = S_GET_DATA;
                end
                else begin // start to get data
                    if(bytes_counter_r[6:5] == 0)begin
                        if(!avm_waitrequest) begin
                            StartRead(STATUS_BASE);
                            enc_w = (enc_r << 8) + avm_readdata[7:0];
                            bytes_counter_w = bytes_counter_r + 1;
                            check_w = 0;
                        
                            if(bytes_counter_r == 31) begin
                                state_w = S_WAIT_CALCULATE;
                                rsa_start_w = 1;
                            end 
                            else begin
                                state_w = S_GET_DATA;
                                rsa_start_w = rsa_start_r;
                            end
                        end
                        else begin 
                            enc_w = enc_r;
                            bytes_counter_w = bytes_counter_r;
                            check_w = check_r;
                            state_w = state_r;
                            rsa_start_w = rsa_start_r;
                        end
                    end
                    else begin
                        enc_w = enc_r;
						bytes_counter_w = bytes_counter_r;
						check_w = check_r;
						state_w = state_r;
                        rsa_start_w = rsa_start_r;
                    end
                end
            end
            
            S_WAIT_CALCULATE:begin // waiting for calculate from core
                rsa_start_w = 0;
				n_w = n_r;
				e_w = e_r;
				enc_w = enc_r;
				bytes_counter_w = bytes_counter_r;
				check_w = check_r;
                if(rsa_finished) begin 
					state_w = S_SEND_DATA;
					dec_w = rsa_dec;
					StartRead(STATUS_BASE);
                end 
                else begin 
					state_w = state_r;
					dec_w = dec_r;
					//avm_read_w = 0;
					//avm_write_w = 0;
					avm_address_w = avm_address_r;
				end
            end

            S_SEND_DATA:begin // ready for calculating and sending data 
                if(!check_r)begin //check if waitrequest = 0 and TX_OK_BIT = 1
                    if(!avm_waitrequest)begin
                        if(avm_readdata[TX_OK_BIT])begin
                            StartWrite(TX_BASE);
                            check_w = 1;
                        end
                        else check_w = check_r;
                    end
                    else check_w = check_r;
                    state_w = S_SEND_DATA;
                end
                else begin
                    if(bytes_counter_r[6:5] == 1)begin
                        if(!avm_waitrequest) begin
                            StartRead(STATUS_BASE);
                            dec_w = dec_r << 8;
                            check_w = 0;
                            if(bytes_counter_r[4:0] == 30) begin // finish sending data
                                state_w = S_GET_DATA;
                                bytes_counter_w = 0;
                                avm_write_w = 0;
                                counter_w = counter_w + 1;
                            end
                            else begin
                                bytes_counter_w = bytes_counter_r + 1;
                                state_w = S_SEND_DATA;
                            end
                        end
                        else begin
							dec_w = dec_r;
							check_w = check_r;
							bytes_counter_w = bytes_counter_r;
							state_w = S_SEND_DATA;
                        end
                    end
                    else begin
                        bytes_counter_w[6:5] = 1;
						n_w = n_r;
						e_w = e_r;
						enc_w = enc_r;
						dec_w = dec_r;
						state_w = state_r;
						rsa_start_w = rsa_start_r;
                        check_w = check_r;
                    end
                end
            end
        endcase
    end


    always_ff @(posedge avm_clk or posedge avm_rst) begin
        if (avm_rst) begin
            n_r <= 0;
            e_r <= 0;
            enc_r <= 0;
            dec_r <= 0;
            avm_address_r <= STATUS_BASE;
            avm_read_r <= 1;
            avm_write_r <= 0;
            state_r <= S_GET_KEY;
            bytes_counter_r <= 64;
            rsa_start_r <= 0;
            check_r <= 0;
            counter_r<=0;
        end else begin
            n_r <= n_w;
            e_r <= e_w;
            enc_r <= enc_w;
            dec_r <= dec_w;
            avm_address_r <= avm_address_w;
            avm_read_r <= avm_read_w;
            avm_write_r <= avm_write_w;
            state_r <= state_w;
            bytes_counter_r <= bytes_counter_w;
            rsa_start_r <= rsa_start_w;
            check_r <= check_w;
            counter_r <= counter_w;
        end
    end
endmodule
