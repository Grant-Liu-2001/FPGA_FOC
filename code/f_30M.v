module f_30M(
	input clk_120m,
	input rst_n,
	output reg clk,
	output reg done
    );

localparam DIVCNT_MAX =4'd2 - 1'b1;
reg[15:0] divcnt;

///////////////////////////////////////////
//对输入时钟clk 120MHZ做4分频的计数

always @(posedge clk_120m or negedge rst_n)	begin
	if (!rst_n) divcnt <= 'b0;
	else if(divcnt < DIVCNT_MAX) divcnt <= divcnt+1'b1;
	else divcnt <= 'b0;
end

//////////////////////////////////////////
//产生时钟使能信号，这个时钟使能信号每隔4个时钟周期有一个高脉冲

always @(posedge clk_120m or negedge rst_n)	begin
	if (!rst_n) clk <= 1'b0;
	else if(divcnt == DIVCNT_MAX) clk <= 1'b1;
	else clk <= 1'b0;
end

always @(posedge clk_120m or negedge rst_n)	begin
	if (!rst_n) done <= 1'b0;
	else if(clk == 1'b1) done <= 1'b1;
end

endmodule