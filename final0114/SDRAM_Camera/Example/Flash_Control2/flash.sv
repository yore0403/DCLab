/*
flash.sv

The flash ROM interface is 8M address x 8-bit words in byte mode.

The code is meant to receive 32 bits (one sample) from flash memory by page mode read
and then output the data.
*/

`timescale 1ns/10ps
`default_nettype none

module flash(i_clk, i_rst, i_start, i_top_addr, i_data_in, 
             o_data_out, o_ack, o_addr, 
             o_we_n, o_rst_n, o_wp_n, o_ce_n, o_oe_n);
    

    input i_clk;
    input i_rst;
    input i_start;
    input [20:0] i_top_addr; // higher address bit (first 21 bits) to select appropriate page
    input [7:0] i_data_in; // received 8-bit data from flash memory in byte mode

    output [31:0] o_data_out; // output 32-bit data (2 channels with 16 bits/sample)
    output o_ack; // determine if the data is acknowledged
    output [22:0] o_addr; // address for the flah memory to read data
    output o_we_n;
    output o_rst_n;
    output o_wp_n;
    output o_ce_n;
    output o_oe_n;
        
  // flash memory read mode
  // the following control signals are all either constantly asserted or deasserted
  assign o_we_n = 1'b1;
  assign o_rst_n = 1'b1;
  assign o_wp_n = 1'b1;
  assign o_ce_n = 1'b0;
  assign o_oe_n = 1'b0;

  logic [1:0] counter;
  logic [4:0] time_count;
  
  // the flash ROM is organized as 8-bit word in byte mode, so we need to read four addresses to get 32 bits
  // lower address bits (last 2 bits) are determined by the counter in the state machine
  assign o_addr[22:2] = i_top_addr[20:0];
  assign o_addr[1:0] = counter[1:0];

  // the state machine
  // execute 4 Flash cycles to get a full sample (32 bits)
  always @(posedge i_clk) begin
    if (i_rst) begin
      o_ack <= 1'b0;
      time_count[4:0] <= 5'd0;
    end else begin
      if (time_count[4:0] == 5'd0) begin
        if (i_start) begin // start of access
          counter[1:0] <= 2'b00;
          time_count[4:0] <= 5'd1;
          o_ack <= 1'b0;
        end
      end else if (time_count[4:0] == 5'd6) begin
        o_data_out[31:24] <= i_data_in[7:0];
        counter[1:0] <= 2'b01;
        time_count[4:0] <= 5'd7;
      end else if (time_count[4:0] == 5'd12) begin
        o_data_out[23:16] <= i_data_in[7:0];
        counter[1:0] <= 2'b10;
        time_count[4:0] <= 5'd13;
      end else if (time_count[4:0] == 5'd18) begin
        o_data_out[15:8] <= i_data_in[7:0];
        counter[1:0] <= 2'b11;
        time_count[4:0] <= 5'd19;
      end else if (time_count[4:0] == 5'd24) begin
        o_data_out[7:0] <= i_data_in[7:0];
        o_ack <= 1'b1;
        time_count[4:0] <= 5'd25;
      end else if (time_count[4:0] == 5'd25) begin // end of access
        o_ack <= 1'b0;
        time_count[4:0] <= 5'd0;
      end else begin
        time_count[4:0] <= time_count[4:0] + 5'd1; // wait for flash ROM access time to pass
      end
    end
  end

endmodule