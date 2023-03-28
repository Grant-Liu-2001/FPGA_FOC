module speed(
	input 					 clk,	//时钟周期
	input 					 rst_n, //复位信号
	input  wire       [11:0] phi,	//角度，用于计算速度
	input  wire	signed  [15:0]  n,		//目标转速
	output signed [15:0] n_target,
	output signed [15:0] n_now,
	output signed [15:0] P_speed_o,
	output signed [15:0] I_speed_o,
	output wire signed [15:0] iq_aim //iq目标值
    );
parameter [23:0] Kp = 24'd1000;	// 速度环 PID 控制算法的 P 参数
parameter [23:0] Ki = 24'd2;   // 速度环 PID 控制算法的 I 参数

parameter DIVCNT_MAX = 16'd150_000 - 1'b1;

reg 	   [15:0] divcnt;
reg 	   		  clk_100hz;

reg 	   [15:0] phi_last;
reg 	   [15:0] phi_now;
reg signed [15:0] delta_phi;
reg signed [15:0] delta_phi_abs;

reg signed [31:0] speed_target;
reg signed [15:0] speed_now; 

reg signed [31:0] iq;
reg signed [31:0] P_speed;
reg signed [31:0] I_speed;
  
	

always @(*) begin
    if (!rst_n) begin
        speed_target <= 'd0;
    end
    else begin
        speed_target <= 256 * n;
    end
end 

///////////////////////////////////////////
//对输入时钟clk计数

always @(posedge clk or negedge rst_n)	begin
	if (!rst_n) divcnt <= 'b0;
	else if(divcnt < DIVCNT_MAX) divcnt <= divcnt+1'b1;
	else divcnt <= 'b0;
end  

//////////////////////////////////////////
//产生100hz时钟使能信号，这个时钟使能信号每隔1k有一个高脉冲

always @(posedge clk or negedge rst_n)	begin
	if (!rst_n) clk_100hz <= 1'b0;
	else if(divcnt == DIVCNT_MAX) clk_100hz <= !clk_100hz;
	else clk_100hz <= clk_100hz;
end  
////////////////////////////////////////
//更新角度信息，计算当前转速
always @(posedge clk_100hz or negedge rst_n)	begin
	if (!rst_n) begin
		phi_now <= 'd0;
		phi_last <= 'd0;
		delta_phi <= 'd0;
	end
	
	else begin
		phi_now <= phi;
		phi_last <= phi_now;
		delta_phi <= phi_now - phi_last;
	end	
	
end 

// Calculate the speed in RPM
always @(*) begin
  if (!rst_n) begin
    speed_now <= 0;
  end else begin
    speed_now <= delta_phi * 15 * 25;
  end
end
//////////////////////////////////////////
//error与intager项计算

always @(posedge clk_100hz or negedge rst_n)	begin
	if (!rst_n) begin
		P_speed <= 'd0;
		I_speed <= 'd0;
		iq <= 'd0;
	end
	
	else begin
		P_speed <= speed_target - speed_now;
		I_speed <= I_speed +  P_speed; 
		iq <= $signed((Kp * P_speed) + (Ki * I_speed));
	end
	
end

assign iq_aim = iq[31:16];  

assign n_target = speed_target[15:0];
assign n_now = speed_now[15:0];
assign P_speed_o = {P_speed[31], P_speed[14:0]};
assign I_speed_o = {I_speed[31], I_speed[14:0]};


//////////////////////////////////////////////////////
/* always @(posedge clk_100hz or negedge rst_n)	begin
	if (!rst_n) begin
		iq_see <= 'd0;
	end
	else if(iq_see < 'd100) iq_see <= iq_see+1'b1;
	else iq_see <= 'b0;	 */
/* 	else begin
		iq_see <= iq_real;
	end	 */
	 
endmodule  



