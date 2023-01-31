/*************************************************************************** 
 ***                                                                     *** 
 *** Ernesto Silva, Spring, 2022 										 *** 
 ***                                                                     *** 
 *** FIFO Testbench						             			         *** 
 ***                                                                     *** 
 *************************************************************************** 
 ***  Filename: fifo_tb.v                  	by Ernesto Silva, 5/14/22    *** 
 ***    --- revision history, if any, goes here ---                      *** 
 ***************************************************************************/
`timescale 1 ns / 1 ns
`define MONITOR_STR_1 "%d DATA_OUT = %d, DATA_IN = %d, COUNT= %d, CLK= %b, WR_EN=%b, RD_EN = %d "

module fifo_tb();
	wire [7:0] DATA_OUT;
	wire EF, AEF, FF, AFF, VF, OF, UF;
	wire signed [6:0] COUNT;
	reg CLK, WR_EN, RD_EN, RST_N;
	reg [7:0] DATA_IN;
	integer i;
	reg [7:0] MEM[0:31]; 	
	
fifo	UUT(DATA_OUT,EF,AEF,FF,AFF,VF,OF,UF,COUNT,CLK,WR_EN,RD_EN,RST_N,DATA_IN);

	initial begin		
		$monitor(`MONITOR_STR_1, $time, DATA_OUT,DATA_IN,COUNT,CLK, WR_EN,RD_EN);
	end
	//clock generation
	always #5 CLK = ~CLK;

initial begin
	$vcdpluson;
 	//write to every location
	$display("Write to FIFO");
	CLK =1'b1; RST_N=1'b1; WR_EN =1'b0; RD_EN=1'b0; DATA_IN = 8'b1;		
	#5 RST_N=1'b0; 
	//write
	#5 WR_EN =1'b1;
	for(i=2; i<34; i=i+1) begin
		#10 DATA_IN = i;
		end
	#5 WR_EN =1'b0; RD_EN = 1'b1;
	$display("Start to read from FIFO");
	#370 
	#5 DATA_IN = 8'b1;
	$display("Write to FIFO");
	//write 
	#10 WR_EN =1'b1; RD_EN =0;
	for(i=1; i<10; i=i+1) begin
		#10 DATA_IN = i;
		end
	$display("Write and Read to FIFO");
	//write and read
	#5 WR_EN =1'b1; RD_EN = 1'b1;
	for(i=10; i<15; i=i+1) begin
		#10 DATA_IN = i;
		end
	WR_EN= 1'b0;
	
	#90$finish;
	end
endmodule
