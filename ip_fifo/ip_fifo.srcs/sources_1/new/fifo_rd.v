module fifo_rd(
	input 				rd_clk,			//读时钟
	input				rst_n,
	//FIFO相关端口
	input 	[7:0]  		fifo_rd_data,	//FIFO读数据
	input				full,			//FIFO满信号，写时钟域下的信号
	input				almost_empty,	//FIFO将空信号
	input				rd_rst_busy,	//FIFO读复位忙信号
	output	reg			fifo_rd_en		//FIFO读使能信号
    );
    
reg		full_d0;    
reg		full_d1;   
    
//full打两拍同步到时钟域下
always	@(posedge rd_clk or negedge rst_n)begin
	if(!rst_n) begin
		full_d0 <= 1'b0;
		full_d1 <= 1'b0;
	end
	else begin
		full_d0 <= full;
		full_d1 <= full_d0;
	end
end    

//对fifo_rd_en赋值，当FIFO为空时开始写入，写满后停止
always	@(posedge rd_clk or negedge rst_n)begin
	if(!rst_n) begin
		fifo_rd_en <= 1'b0;
	end
	else if(!rd_rst_busy) begin
		if(full_d1)
			fifo_rd_en <= 1'b1;
		else if(almost_empty)
			fifo_rd_en <= 1'b1;
	end
end

endmodule
