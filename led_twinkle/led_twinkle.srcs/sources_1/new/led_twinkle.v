//LED交替闪烁模块
module led_twinkle(
    input        clk,     	//系统时钟，例：50MHz
    input        rst_n,   	//系统复位信号，低电平有效
    
    output [1:0] led          	//输出，控制2路LED
);

reg [25:0] cnt;   //26位计数寄存器，最大可计67108863

//组合逻辑赋值：计数器小于0.5s计数值输出01，否则输出10
assign led = (cnt < 26'd2500_0000) ? 2'b01 : 2'b10;

//计数器时序逻辑，50MHz时钟，计数到5000_0000为1秒
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 26'd0;         //复位，计数器清零
    end
    else if(cnt < 26'd5000_0000) begin
        cnt <= cnt + 1'b1;    //未计满，计数器自增
    end
    else begin
        cnt <= 26'd0;         //计满1秒，计数器清零
    end
end

endmodule