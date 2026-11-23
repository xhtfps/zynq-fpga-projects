// 顶层模块
module top_key_beep(
	input        clk,
	input        rst_n,
	input  [1:0] key,    // 总线 key[0],key[1]
	output       beep
);

wire key_value;
wire key_flag;

key_debounce u_key_debounce(
	.clk		(clk),
	.rst_n		(rst_n),
	.key		(key[0]),  // 使用KEY0
	.key_value	(key_value),    
	.key_flag   (key_flag)  
);

beep_control u_beep_control(
    .clk		(clk),
    .rst_n		(rst_n),
    .key_value	(key_value),
    .key_flag	(key_flag),
    .beep		(beep)
);

endmodule