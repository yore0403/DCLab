module	Object_Detector(	//	Host Side
		iRed,
		iGreen,
		iBlue,
		oNote[63:0],
		//oSave,
						iCLK,
						iRST_N,
						oSave
						//iZOOM_MODE_SW		
		);
`include "VGA_Param.h"

`ifdef VGA_640x480p60
//	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	96;
parameter	H_SYNC_BACK	=	48;
parameter	H_SYNC_ACT	=	640;	
parameter	H_SYNC_FRONT=	16;
parameter	H_SYNC_TOTAL=	800;

//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	2;
parameter	V_SYNC_BACK	=	33;
parameter	V_SYNC_ACT	=	480;	
parameter	V_SYNC_FRONT=	10;
parameter	V_SYNC_TOTAL=	525; 

parameter   H_MARGIN = 0;
parameter   V_MARGIN = 0;
parameter   WIDTH = 80;
parameter   HEIGHT = 60;

parameter THRESHOLD = 1000;
parameter THRESHOLD2 = 500;

`else
 // SVGA_800x600p60
////	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	128;         //Peli
parameter	H_SYNC_BACK	=	88;
parameter	H_SYNC_ACT	=	800;	
parameter	H_SYNC_FRONT=	40;
parameter	H_SYNC_TOTAL=	1056;
//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	4;
parameter	V_SYNC_BACK	=	23;
parameter	V_SYNC_ACT	=	600;	
parameter	V_SYNC_FRONT=	1;
parameter	V_SYNC_TOTAL=	628;

parameter   H_MARGIN = 0;
parameter   V_MARGIN = 0;
parameter   WIDTH = 100;
parameter   HEIGHT = 75;

parameter THRESHOLD = 1600;
parameter THRESHOLD2 = 1000;
`endif
//	Start Offset
parameter	X_START		=	H_SYNC_CYC+H_SYNC_BACK+H_MARGIN;
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK+V_MARGIN;


//	Host Side
input		[9:0]	iRed;
input		[9:0]	iGreen;
input		[9:0]	iBlue;
output		[63:0]	oNote;
output				oSave;
//output	reg			oRequest;
//	VGA Side
reg 	[63:0]		mNote_r,mNote_w;
reg 				oSave_r,oSave_w;

//	Control Signal
input				iCLK;
input				iRST_N;
//input 				iZOOM_MODE_SW;

//	Internal Registers and Wires
reg		[12:0]		H_Cont;
reg		[12:0]		V_Cont;
reg     [3:0]		H_count_r,H_count_w;
reg     [3:0]		W_count_r,W_count_w;

wire	[12:0]		v_mask;

reg 	[6:0]		n_count;
reg 	[6:0]		a_count;
reg 	[6:0]		i_count;

reg     [14:0]		detect_count[63:0];//8*8
reg     [19:0]		output_valid;//8*8

assign v_mask = 13'd0 ;//iZOOM_MODE_SW ? 13'd0 : 13'd26;
assign oNote = mNote_r;
////////////////////////////////////////////////////////
//Width_count Height_count//
always @(*) begin
		case(H_Cont)
			X_START + WIDTH,
			X_START + 2*WIDTH,
			X_START + 3*WIDTH,
			X_START + 4*WIDTH,
			X_START + 5*WIDTH,
			X_START + 6*WIDTH,
			X_START + 7*WIDTH: W_count_w = W_count_r + 1;
			X_START + 8*WIDTH: W_count_w = 0;
			default: W_count_w = W_count_r;
		endcase
		if(H_Cont == 0) begin
			case(V_Cont)
				Y_START + HEIGHT,
				Y_START + 2*HEIGHT,
				Y_START + 3*HEIGHT,
				Y_START + 4*HEIGHT,
				Y_START + 5*HEIGHT,
				Y_START + 6*HEIGHT,
				Y_START + 7*HEIGHT:H_count_w = H_count_r + 1;
				Y_START + 8*HEIGHT:H_count_w = H_count_r + 1;
				Y_START :H_count_w = 0;				
				default:H_count_w = H_count_r;
			endcase
		end
		else  H_count_w = H_count_r;
end
always @(posedge iCLK or negedge iRST_N) begin
	if(!iRST_N) begin
		W_count_r <= 0;
		H_count_r <= 0;
	end else begin
		W_count_r <= W_count_w;
		H_count_r <= H_count_w;
	end
end
////////////////////////////////////////////////////////
//


//calculate each block detect//
always@(posedge iCLK or negedge iRST_N) begin
	if (!iRST_N) begin
		for(a_count = 0;a_count<=63;a_count = a_count +1) begin
			detect_count[a_count] <= 14'b0; 
		end
	end
	else begin
		if(!(((V_Cont-Y_START)%HEIGHT)||H_Cont != X_START))//clear hori detect count to refresh pitch
		begin
			oSave_w = 1;
			for(a_count = 0;a_count <= 63;a_count = a_count + 1)begin
				if(a_count/8 == H_count_r)begin
					detect_count[a_count] <= 14'b0;
				end
				else detect_count[a_count] <= detect_count[a_count];
			end
		end else if(iRed[9:8] == 3)begin//just detect red 
		oSave_w = 0;
			for(a_count = 0;a_count <= 63;a_count = a_count + 1)begin
				if(a_count/8 == H_count_r&&a_count%8 == W_count_r)begin
					detect_count[a_count] <= detect_count[a_count] + 1;
				end
				else detect_count[a_count] <= detect_count[a_count];
			end
		end else
			for(a_count = 0;a_count <= 63;a_count = a_count + 1)begin
				detect_count[a_count] <= detect_count[a_count];
			end		
	end 
end
// mNote
always @(*) begin
	mNote_w = mNote_r;
	if(H_Cont==X_START+H_SYNC_ACT&&(V_Cont-Y_START+1)%HEIGHT == 0 &&H_count_r!=8)//end 
	begin: break1
		for(i_count = 0;i_count<=7;i_count = i_count +1) begin//hori
			if(mNote_r[(H_count_r)*8+i_count] && detect_count[(H_count_r)*8+i_count]>= THRESHOLD2) begin
				mNote_w[(H_count_r)*8+i_count] = 1;
				//disable break1;
			end else if(detect_count[(H_count_r)*8+i_count]>= THRESHOLD)begin
				mNote_w[(H_count_r)*8+i_count] = 1;
				//disable break1;
			end else mNote_w[(H_count_r)*8+i_count] = 0;
		end
		//mNote_w[(H_count_r)*8+i_count] = 0;
	end 
			
end
always@(posedge iCLK or negedge iRST_N)begin
		if (!iRST_N)begin
			output_valid <= 0; 
		end
		else if(H_Cont == H_SYNC_TOTAL-2 && V_Cont/8 == 0) begin 
			output_valid <= 1;
		end  else
			output_valid <= 0;
end
always@(posedge iCLK or negedge iRST_N)begin
		if (!iRST_N)begin
			oSave_r <= 0;
			mNote_r <= 0; 
		end
		else begin
			oSave_r <= oSave_w;
			mNote_r <= mNote_w;
		end  
end

//	H_Sync Generator, Ref. 40 MHz Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
	end else begin
		//	H_Sync Counter
		if( H_Cont < H_SYNC_TOTAL ) begin
		H_Cont	<=	H_Cont+1;

		end else begin
		H_Cont	<=	0;
		//	H_Sync Generator
		end
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
	end
	else
	begin
		//	When H_Sync Re-start
		if(H_Cont==0)
		begin
			//	V_Sync Counter
			if( V_Cont < V_SYNC_TOTAL ) begin
			V_Cont	<=	V_Cont+1;
			end else begin
			V_Cont	<=	0;
			//	V_Sync Generator
		end
		end
	end
end

endmodule