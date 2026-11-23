//按键控制LED模块，加入按键消抖
module key_led(
	input 			clk,		//系统时钟，50MHz
	input 			rst_n,		//复位信号，低电平有效
	
	input 		[1:0] 	key_in,		//原始按键输入，低电平按下
	output reg	[1:0] 	led		//2位LED输出
);

reg [24:0] 	cnt;			//0.5s定时计数器
reg			led_ctrl;		//LED闪烁控制标志位
wire [1:0]	key;			//经过消抖后的有效按键信号

//例化两个按键消抖模块，分别对key_in[0] key_in[1]消抖
key_filter u_key_filter0(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key_in[0]),
    .key_out(key[0])
);

key_filter u_key_filter1(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(key_in[1]),
    .key_out(key[1])
);

//0.5s定时计数器，50MHz，计数2500_0000对应0.5秒
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt <= 25'd0;					//复位，计数器清零
	else if(cnt < 25'd2500_0000)
		cnt <= cnt + 1'b1;				//计数累加
	else
		cnt <= 25'd0;					//计满0.5s清零
end

//0.5s定时到，翻转闪烁标志
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
		led_ctrl <= 1'd0;				//复位标志初始0
	else if(cnt == 25'd2500_0000)		//到达0.5s计数值
		led_ctrl <= ~led_ctrl;			//标志位翻转
end

//按键状态判断，控制LED输出
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
		led <= 2'b11;					//复位LED熄灭(高电平熄灭)
	else case(key)
		2'b10 : begin					//key[0]按键按下
			if(led_ctrl == 1'b0)
				led <= 2'b01;
			else
				led <= 2'b10;
		end
		2'b01 : begin					//key[1]按键按下
			if(led_ctrl == 1'b0)
				led <= 2'b11;
			else
				led <= 2'b00;
		end
		2'b11 : begin					//无按键按下
			led <= 2'b11;				//LED全部熄灭
		end
		default : ;						//其他组合保持
	endcase
end

endmodule

//按键消抖子模块，20ms消抖，50MHz时钟
module key_filter(
    input        clk,
    input        rst_n,
    input        key_in,    //原始按键输入
    output reg   key_out    //消抖后输出
);

reg [19:0] cnt_filter;      //消抖计数器 50MHz:20ms = 1_000_000
reg key_sync0, key_sync1;   //两级寄存器同步，避免亚稳态

//两级打拍同步外部按键信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_sync0 <= 1'b1;
        key_sync1 <= 1'b1;
    end
    else begin
        key_sync0 <= key_in;
        key_sync1 <= key_sync0;
    end
end

//20ms消抖计数逻辑
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_filter <= 20'd0;
        key_out    <= 1'b1;
    end
    else begin
        if(key_sync1 != key_out) begin      //检测到电平变化，开始计时
            if(cnt_filter < 20'd1_000_000) begin
                cnt_filter <= cnt_filter + 1'b1;
            end
            else begin                      //稳定20ms，更新输出
                cnt_filter <= 20'd0;
                key_out    <= key_sync1;
            end
        end
        else begin                          //电平未变化，计数器清零
            cnt_filter <= 20'd0;
        end
    end
end

endmodule