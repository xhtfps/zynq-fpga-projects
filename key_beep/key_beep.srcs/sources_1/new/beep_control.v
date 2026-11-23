// 蜂鸣器控制
module beep_control(
	input        clk,
	input        rst_n,
	
	input 		key_value,
	input 		key_flag,
	output reg 	beep
);
   
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		beep <= 1'b0;    // 低电平蜂鸣器关闭
	end
	else if(key_flag && (key_value == 1'b0)) begin
		beep <= ~beep;   // 按键按下瞬间翻转状态
	end
end

endmodule