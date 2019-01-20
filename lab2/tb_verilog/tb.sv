`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;

	logic clk, start_cal, fin, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;
	logic [255:0] encrypted_data, decrypted_data;
	logic [247:0] golden;
	integer fp_e, fp_d;

	Rsa256Core core(
		.i_clk(clk),
		.i_rst(rst),
		.i_start(start_cal),
		.i_a(12),
		.i_b(5),
		.i_n(13),
		.o_result(decrypted_data),
		.o_finished(fin)
	);

	initial begin
		$fsdbDumpfile("core.fsdb");
		$fsdbDumpvars;
		//fp_e = $fopen("../pc_python/golden/enc1.bin", "rb");
		//fp_d = $fopen("../pc_python/golden/dec1.txt", "rb");
		rst = 1;
		#(2*CLK)
		rst = 0;

		$finish;
	end

	initial begin
		#(500000*CLK)
		$display("Too slow, abort.");
		$finish;
	end

endmodule