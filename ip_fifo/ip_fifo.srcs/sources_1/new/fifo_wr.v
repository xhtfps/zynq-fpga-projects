module fifo_wr(
	input 				wr_clk,			//写时钟
	input				rst_n,
	//FIFO相关端口
	input				empty,			//FIFO空信号，读时钟域下的信号
	input				almost_full,	//FIFO将满信号
	input				wr_rst_busy,	//FIFO写复位忙信号
	output reg			fifo_wr_en,		//FIFO写使能信号
	output reg 	[7:0]  	fifo_wr_data	//FIFO写数据
    );
    
reg		empty_d0;    
reg		empty_d1;   
    
//empty打两拍同步到时钟域下
always	@(posedge wr_clk or negedge rst_n)begin
	if(!rst_n) begin
		empty_d0 <= 1'b0;
		empty_d1 <= 1'b0;
	end
	else begin
		empty_d0 <= empty;
		empty_d1 <= empty_d0;
	end
end    

//对fifo_wr_en赋值，当FIFO为空时开始写入，写满后停止
always	@(posedge wr_clk or negedge rst_n)begin
	if(!rst_n) begin
		fifo_wr_en <= 1'b0;
	end
	else if(!wr_rst_busy) begin
		if(empty_d1)
			fifo_wr_en <= 1'b1;
		else if(almost_full)
			fifo_wr_en <= 1'b1;
	end
end

//对fifo_wr_data赋值，0-254
always	@(posedge wr_clk or negedge rst_n)begin
	if(!rst_n)
		fifo_wr_data <= 8'b0;
	else if(fifo_wr_en && fifo_wr_data < 8'd254)
		fifo_wr_data <= fifo_wr_data + 8'b1;
	else
		fifo_wr_data <= 8'b0;
end

endmodule
