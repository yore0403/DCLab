module SevenHexDecoder(
  input iCLK,
  input iRST,
  input [7:0] iNote, // SRAM address
  input [3:0] ibar,
  input [3:0] iNote1,
  input [7:0] iaddr,
  input iSave,
  input imode,
  output logic [6:0] o_seven_7,
  output logic [6:0] o_seven_6,
  output logic [6:0] o_seven_5,
  output logic [6:0] o_seven_4,
  output logic [6:0] o_seven_3,
  output logic [6:0] o_seven_2,
  output logic [6:0] o_seven_1,
  output logic [6:0] o_seven_0
);

//=======================================================
//----------------Seven Segment Display------------------
//=======================================================

  /* The layout of seven segment display, 1: dark
   *    00
   *   5  1
   *    66
   *   4  2
   *    33
   */
parameter TIMECONST = 8000000;
reg [48:0]count_w,count_r;

enum{IDLE,SAVE,PLAY}state_r,state_w;

  parameter D0 = 7'b1000000;
  parameter D1 = 7'b1111001;
  parameter D2 = 7'b0100100;
  parameter D3 = 7'b0110000;
  parameter D4 = 7'b0011001;
  parameter D5 = 7'b0010010;
  parameter D6 = 7'b0000010;
  parameter D7 = 7'b1011000;
  parameter D8 = 7'b0000000;
  parameter D9 = 7'b0010000;
  parameter D_ = 7'b0111111;
  parameter D0X = 7'b1111110;
  parameter D1X = 7'b1111101;
  parameter D2X = 7'b1111011;
  parameter D3X = 7'b1110111;
  parameter D4X = 7'b1101111;
  parameter D5X = 7'b1011111;
//=======================================================
//----------------SRAM Address Invertal------------------
//=======================================================

  parameter S0  = 4'b0000;
  parameter S1  = 4'b0001;
  parameter S2  = 4'b0010;
  parameter S3  = 4'b0011;
  parameter S4  = 4'b0100;
  parameter S5  = 4'b0101;
  parameter S6  = 4'b0110;
  parameter S7  = 4'b0111;
  parameter S8  = 4'b1000;
  parameter S9  = 4'b1001;
  parameter SA  = 4'b1010;
  parameter SB  = 4'b1011;
  parameter SC  = 4'b1100;
  parameter SD  = 4'b1101;
  parameter SE  = 4'b1110;
  parameter SF  = 4'b1111;
  parameter DA = 7'b0001000;
  parameter DC = 7'b1000110;
  parameter DD = 7'b1000000;
  parameter DE = 7'b0000110;
  parameter DI = 7'b1111001;
  parameter DL = 7'b1000111;
  parameter DN = 7'b1001000;
  parameter DO = 7'b1000000;
  parameter DP = 7'b0001100;
  parameter DR = 7'b0001000;
  parameter DS = 7'b0010010;
  parameter DT = 7'b1001110;
  parameter DU = 7'b1000001;
  parameter DY = 7'b0010001;
  //parameter D_ = 7'b0111111;
  parameter DDOT = 7'b0111111;


always@(*) begin

state_w = state_r;
count_w = count_r;








/*
    case(ibar[3:0])
      S0:o_seven_2 = D0;
      S1:o_seven_2 = D1;
      S2:o_seven_2 = D2;
      S3:o_seven_2 = D3;
      S4:o_seven_2 = D4;
      S5:o_seven_2 = D5;
      S6:o_seven_2 = D6;
      S7:o_seven_2 = D7;
      S8:o_seven_2 = D8;
      SA:o_seven_2 = D0X;
      SB:o_seven_2 = D1X;
      SC:o_seven_2 = D2X;
      SD:o_seven_2 = D3X;
      SE:o_seven_2 = D4X;
      SF:o_seven_2 = D5X;
      default:o_seven_2 = D_;
    endcase

    case(iaddr[3:0])
      S0:o_seven_3 = D0;
      S1:o_seven_3 = D1;
      S2:o_seven_3 = D2;
      S3:o_seven_3 = D3;
      S4:o_seven_3 = D4;
      S5:o_seven_3 = D5;
      S6:o_seven_3 = D6;
      S7:o_seven_3 = D7;
      S8:o_seven_3 = D8;
      S9:o_seven_3 = D9;
      SA:o_seven_3 = D0X;
      SB:o_seven_3 = D1X;
      SC:o_seven_3 = D2X;
      SD:o_seven_3 = D3X;
      SE:o_seven_3 = D4X;
      SF:o_seven_3 = D5X;
      default:o_seven_3 = D_;
    endcase
*/
    case(iNote1)
      S0:o_seven_4 = D0;
      S1:o_seven_4 = D1;
      S2:o_seven_4 = D2;
      S3:o_seven_4 = D3;
      S4:o_seven_4 = D4;
      S5:o_seven_4 = D5;
      S6:o_seven_4 = D6;
      S7:o_seven_4 = D7;
      S8:o_seven_4 = D8;
      SA:o_seven_4 = D0X;
      SB:o_seven_4 = D1X;
      SC:o_seven_4 = D2X;
      SD:o_seven_4 = D3X;
      SE:o_seven_4 = D4X;
      SF:o_seven_4 = D5X;      
      default:o_seven_4 = D_;
    endcase

/*
    case(iNote[23:20])
      S0:o_seven_5 = D_;
      S1:o_seven_5 = D1;
      S2:o_seven_5 = D2;
      S3:o_seven_5 = D3;
      S4:o_seven_5 = D4;
      S5:o_seven_5 = D5;
      S6:o_seven_5 = D6;
      S7:o_seven_5 = D7;
      S8:o_seven_5 = D8;
      default:o_seven_5 = D_;
    endcase
    */
    case(ibar)
      S0:o_seven_6 = D0;
      S1:o_seven_6 = D1;
      S2:o_seven_6 = D2;
      S3:o_seven_6 = D3;
      S4:o_seven_6 = D4;
      S5:o_seven_6 = D5;
      S6:o_seven_6 = D6;
      S7:o_seven_6 = D7;
      S8:o_seven_6 = D8;
      default:o_seven_6 = D_;


    endcase/*
    case(ibar)
      S0:o_seven_7 = D0;
      S1:o_seven_7 = D1;
      S2:o_seven_7 = D2;
      S3:o_seven_7 = D3;
      S4:o_seven_7 = D4;
      S5:o_seven_7 = D5;
      S6:o_seven_7 = D6;
      S7:o_seven_7 = D7;
      S8:o_seven_7 = D8;
      default:o_seven_7 = D_;

    endcase
*/
if(!iSave&&imode == 0)begin
  state_w = SAVE;    
  count_w = 0;
end
if(!iSave&&imode == 1)begin
  state_w = PLAY;    
  count_w = 0;
end
case(state_r)
IDLE:begin
  count_w = 0;
  o_seven_3 = D_;
  o_seven_2 = D_;
    case(iNote[3:0])
      S0:o_seven_0 = D_;
      S1:o_seven_0 = D1;
      S2:o_seven_0 = D2;
      S3:o_seven_0 = D3;
      S4:o_seven_0 = D4;
      S5:o_seven_0 = D5;
      S6:o_seven_0 = D6;
      S7:o_seven_0 = D7;
      S8:o_seven_0 = D8;
      default:o_seven_0 = D_;
    endcase
    
    case(iNote[7:4])
      S0:o_seven_1 = D_;
      S1:o_seven_1 = D1;
      S2:o_seven_1 = D2;
      S3:o_seven_1 = D3;
      S4:o_seven_1 = D4;
      S5:o_seven_1 = D5;
      S6:o_seven_1 = D6;
      S7:o_seven_1 = D7;
      S8:o_seven_1 = D8;
      default:o_seven_1 = D_;
    endcase


end
SAVE:begin
o_seven_3 = DS;
o_seven_2 = DA;    
o_seven_1 = DU;    
o_seven_0 = DE;
count_w = count_r + 1;
if(count_r == TIMECONST)state_w = IDLE;
end
SAVE:begin
o_seven_3 = DP;
o_seven_2 = DL;    
o_seven_1 = DA;    
o_seven_0 = DY;
count_w = count_r + 1;
if(count_r == TIMECONST)state_w = IDLE;
end
endcase
o_seven_5 = D0;
o_seven_7 = D0;  
  end
always@(posedge iCLK or negedge iRST) begin
  if(!iRST) begin
    count_r <= 0;
    state_r <= IDLE;
  end else begin
count_r<= count_w;
    state_r <= state_w;
  end
end
endmodule
