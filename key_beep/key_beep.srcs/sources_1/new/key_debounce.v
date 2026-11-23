// 按键消抖模块 50MHz 20ms消抖
module key_debounce(
	input        clk,
	input        rst_n,
	
	input        key,           // 原始按键输入，高电平松开、低电平按下
	output reg   key_value,     // 消抖后稳定按键电平
	output reg   key_flag       // 电平稳定瞬间产生1个时钟脉冲标志
);
    
reg [19:0] cnt;
reg        key_sync0; // 第一级同步寄存器
reg        key_reg;   // 同步后的按键寄存

// 两级同步，消除外部按键亚稳态
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		key_sync0 <= 1'b1;
		key_reg   <= 1'b1;
	end
	else begin
		key_sync0 <= key;
		key_reg   <= key_sync0;
	end
end

// 20ms消抖计数逻辑
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt <= 20'd0;
	end
	else begin
		if(key_reg != key_sync0) begin // 同步后的按键电平发生变化，重启计时
			cnt <= 20'd1_000_000;
		end
		else begin
			if(cnt > 20'd0) begin
				cnt <= cnt - 1'b1;
			end
		end
	end
end

// 计时结束，更新稳定电平 + 产生按键标志
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		key_value <= 1'b1;
		key_flag  <= 1'b0;
	end
	else begin
		key_flag <= 1'b0;
		if(cnt == 20'd1) begin // 20ms计时完成
			key_value <= key_reg;
			key_flag  <= 1'b1; // 只在稳定那一刻输出脉冲
		end
	end
end

endmodule
