
// 模块： pi_controller
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// 功能： PI 控制器

module pi_controller #(
    parameter logic [23:0] Kp = 24'd25169,
    parameter logic [23:0] Ki = 24'd2
) (
    input  wire               rstn,
    input  wire               clk,
    input  wire               i_en,
    input  wire signed [15:0] i_aim,
    input  wire signed [15:0] i_real,
    output reg                o_en,
    output wire signed [15:0] o_value
);

parameter [23:0] Kp1 = 24'd243250;
parameter [23:0] Ki1 = 24'd1;
	
reg               en1, en2, en3, en4;
reg signed [31:0] pdelta, idelta, kpdelta1, kpdelta, kidelta, kpidelta, value;

assign o_value = value[31:16];

always @(posedge clk or negedge rstn)	begin
	if (!rstn) begin
		pdelta <= 'd0;
		idelta <= 'd0;
		value <= 'd0;
	end
	
	else begin
		pdelta <= i_aim - i_real;
		idelta <= idelta +  pdelta; 
		value <= $signed((Kp1 * pdelta) + (Ki1 * idelta));
	end
	
end


endmodule
