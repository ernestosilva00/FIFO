/*************************************************************************** 
 ***                                                                     *** 
 *** Ernesto Silva, Spring, 2022 										 *** 
 ***                                                                     *** 
 *** FIFO						            						     *** 
 ***                                                                     *** 
 *************************************************************************** 
 ***  Filename: fifo.v                  	by Ernesto Silva, 5/14/22    *** 
 ***    --- revision history, if any, goes here ---                      *** 
 ***************************************************************************/ 
`timescale 1 ns / 1 ns

module fifo(DATA_OUT,EF,AEF,FF,AFF,VF,OF,UF,COUNT,CLK,WR_EN,RD_EN,RST_N,DATA_IN);
parameter WIDTH = 8,
	  DEPTH = 32;

output reg [WIDTH-1:0] DATA_OUT;
output reg EF,AEF,FF,AFF,VF,OF,UF;
output reg signed [6:0] COUNT;

input CLK, WR_EN, RD_EN, RST_N;
input [WIDTH-1:0] DATA_IN;

reg [WIDTH-1:0] MEM [DEPTH:0];
//reg [WIDTH-1:0] NEXT_OUT;
reg [4:0] WR_P;
reg [4:0] RD_P;
 

//counter
   always @(posedge CLK or negedge RST_N)
   begin
	if(RST_N)
		COUNT <= 0;
	else if(WR_EN && RD_EN)
		COUNT <= COUNT;
	else if(WR_EN)
		if (COUNT<0)
			COUNT =0;
		else
			COUNT <= COUNT + 1;
	else if(RD_EN)
		if (COUNT > 32)
			COUNT <= 32;	
		else
			COUNT <= COUNT - 1;
	else 
		COUNT <= COUNT;
   end
	
//flags
  always@(COUNT)
	begin
 	if (COUNT==0) begin
		EF = 1'b1; AEF=1'b0; AFF=1'b0; FF=1'b0; UF=1'b0; OF=1'b0;
		end 
	else if (COUNT<4 && COUNT>0)begin
		EF =1'b0; AEF=1'b1; AFF=1'b0; FF=1'b0; UF=1'b0; OF=1'b0;
		end
	else if (COUNT>=4 && COUNT<=26) begin
		EF =1'b0; AEF=1'b0; AFF=1'b0; FF=1'b0; UF=1'b0; OF=1'b0;
		end
	else if (COUNT>28 && COUNT<32)	begin
		EF =1'b0; AEF=1'b0; AFF=1'b1; FF=1'b0; UF=1'b0; OF=1'b0;
		end
	else if (COUNT==32)begin
		EF =1'b0; AEF=1'b0; AFF=1'b0; FF=1'b1; UF=1'b0; OF=1'b0; 
		end
	else if (COUNT<0)begin
		EF =1'b0; AEF=1'b0; AFF=1'b0; FF=1'b0; UF=1'b1; OF=1'b0; 
		end
	else if (COUNT >32)begin
		EF =1'b0; AEF=1'b0; AFF=1'b0; FF=1'b0; UF=1'b0; OF=1'b1; 
		end
	else begin
		EF =1'b0; AEF=1'b0; AFF=1'b0; FF=1'b0; UF=1'b0; OF=1'b0; 
		end
  end

//read
  always@(posedge CLK or negedge RST_N)
    begin
	if(RST_N) 
		begin
		DATA_OUT <= 'bZ;
		EF =1'b1; AEF=1'b0; AFF=1'b0; FF=1'b0; UF=1'b0; OF=1'b0; VF=1'b0;
		end
	else 
	begin
		`ifdef FWFT
	 	if(WR_EN && (COUNT==1))
			begin
			DATA_OUT <= MEM[0];
			end
		else if(RD_EN && (COUNT==1))
			begin 
			DATA_OUT <= 'bz;
			end
		`else
		if (RD_EN && (COUNT==1)) //empty next 
		   DATA_OUT <= 'bZ;
		`endif
 		else if(((RD_EN && !EF) && (RD_EN && !UF)))
		 begin
		   DATA_OUT <= MEM[RD_P];
		   VF = 1'b1;
		 end		
		else
		 begin 
		   DATA_OUT <= DATA_OUT;	
		   VF = 1'b0;
		 end
	end
    end

//write
  always @(posedge CLK)
     begin 	
	if (((WR_EN && !FF) && (WR_EN && !OF)))
		MEM[WR_P] <= DATA_IN;
	else 
		MEM[WR_P] <= MEM[WR_P];
  end

//pointers
  always @(posedge CLK or negedge RST_N)
     begin
	if (RST_N)
		begin
		WR_P <= 0;
		RD_P <= 0;
		end
	else 
		begin
		if(((RD_EN && !EF) && (RD_EN && !UF)))
			RD_P <= RD_P+1;	
		
		else if(COUNT==0)begin
			RD_P <=0;
			WR_P <=0;
			end
		else
			RD_P  <= RD_P;

		if(((WR_EN && !FF) && (WR_EN && !OF)))
			WR_P <= WR_P+1;

		else if(COUNT==0)begin
			RD_P <=0;
			WR_P <=0;
			end
		else 
			WR_P  <= WR_P;
		end
     end
endmodule
