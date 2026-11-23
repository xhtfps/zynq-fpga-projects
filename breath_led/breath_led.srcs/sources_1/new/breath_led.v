module breath_led(
    input  wire clk,
    input  wire rst_n,

    output reg  led
);

//==========================================================
// 参数说明
// 系统时钟：50MHz
// PWM周期：5000个时钟 = 100us
// PWM频率：10kHz
//==========================================================

reg [15:0] period_cnt;      // PWM周期计数器 0~4999
reg [5:0]  breath_cnt;      // 呼吸速度计数器 0~39
reg [7:0]  brightness;      // 亮度等级 0~255
reg        inc_dec_flag;    // 0:渐亮  1:渐暗

// Gamma计算中间变量
wire [15:0] gamma_value;
wire [31:0] scaled_value;
wire [15:0] duty_cycle;


//==========================================================
// Gamma校正
//
// brightness范围：0~255
//
// 使用近似：
//      Gamma = brightness?
//
// brightness?最大：
//      255? = 65025
//
// 再映射到PWM范围0~5000：
//
// duty_cycle = brightness? × 5000 / 65025
//
//==========================================================

assign gamma_value  = brightness * brightness;

assign scaled_value = gamma_value * 16'd5000;

assign duty_cycle   = scaled_value / 16'd65025;


//==========================================================
// 1. PWM周期计数器
//
// 50MHz时钟：
// 一个时钟周期 = 20ns
//
// 5000 × 20ns = 100us
//
// 所以PWM频率：
// 1 / 100us = 10kHz
//
//==========================================================

always @(posedge clk or negedge rst_n) begin

    if (!rst_n)
        period_cnt <= 16'd0;

    else if (period_cnt == 16'd4999)
        period_cnt <= 16'd0;

    else
        period_cnt <= period_cnt + 1'b1;

end


//==========================================================
// 2. 呼吸速度计数器
//
// 一个PWM周期 = 100us
//
// 40个PWM周期：
// 40 × 100us = 4ms
//
// 所以每4ms改变一次brightness
//
//==========================================================

always @(posedge clk or negedge rst_n) begin

    if (!rst_n)
        breath_cnt <= 6'd0;

    else if (period_cnt == 16'd4999) begin

        if (breath_cnt == 6'd39)
            breath_cnt <= 6'd0;

        else
            breath_cnt <= breath_cnt + 1'b1;

    end

end


//==========================================================
// 3. 控制亮度等级
//
// brightness：
// 0 → 255 → 0
//
// 每4ms变化1级
//
// 渐亮时间：
// 255 × 4ms ≈ 1.02s
//
// 渐暗时间：
// 255 × 4ms ≈ 1.02s
//
// 完整呼吸周期 ≈ 2.04s
//
//==========================================================

always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin

        brightness   <= 8'd0;
        inc_dec_flag <= 1'b0;

    end

    else if ((period_cnt == 16'd4999) &&
             (breath_cnt == 6'd39)) begin

        //==============================
        // 渐亮
        //==============================
        if (inc_dec_flag == 1'b0) begin

            if (brightness == 8'd255) begin

                brightness   <= 8'd254;
                inc_dec_flag <= 1'b1;

            end

            else begin

                brightness <= brightness + 1'b1;

            end

        end


        //==============================
        // 渐暗
        //==============================
        else begin

            if (brightness == 8'd0) begin

                brightness   <= 8'd1;
                inc_dec_flag <= 1'b0;

            end

            else begin

                brightness <= brightness - 1'b1;

            end

        end

    end

end


//==========================================================
// 4. PWM输出
//
// period_cnt < duty_cycle
// LED点亮
//
// duty_cycle由Gamma曲线产生
//
//==========================================================

always @(posedge clk or negedge rst_n) begin

    if (!rst_n)
        led <= 1'b0;

    else begin

        if (period_cnt < duty_cycle)
            led <= 1'b1;

        else
            led <= 1'b0;

    end

end


endmodule