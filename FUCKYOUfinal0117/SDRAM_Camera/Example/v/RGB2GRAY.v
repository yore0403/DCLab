module RGB2GRAY(
	iRed,
	iGreen,
	iBlue,
	oGray
);
input	[15:0]	iRed;
input	[15:0]	iGreen;
input	[15:0]	iBlue;
output [7:0] oGray;
wire [15:0] Gray;
assign oGRAY = (iRed*4 + iGreen*10 + iBlue*2) >> 4;
endmodule