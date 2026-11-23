`timescale 1ns / 1ps
module ip_fifo(
	input 				sys_clk,			
	input				rst_n      // 外部低电平复位
);

wire		clk_50m;
wire		clk_100m;
wire		locked;

// FIFO相关信号
wire		empty;	     
wire		almost_full;
wire		wr_rst_busy;
wire		fifo_wr_en;
wire [7:0]	fifo_wr_data;
wire		full;		     
wire		almost_empty;
wire		rd_rst_busy;	
wire 		fifo_rd_en;		
wire [7:0]	fifo_rd_data;
wire [7:0]	wr_data_count;
wire [7:0]	rd_data_count;

//====================复位处理====================
// fifo_rst: FIFO IP高电平复位；外部复位无效 OR 锁相环未锁定，FIFO复位
reg fifo_rst;
always @(*) begin
    if((!rst_n) || (!locked)) begin
        fifo_rst = 1'b1;  // FIFO高电平复位
    end
    else begin
        fifo_rst = 1'b0;
    end
end

// wr_rd_rst_n：给fifo_wr、fifo_rd子模块，低电平复位
wire wr_rd_rst_n;
assign wr_rd_rst_n = rst_n && locked;

clk_wiz_0 u_clk_wiz_0
(
	.clk_out1		(clk_50m		),
	.clk_out2		(clk_100m		),    
	.locked			(locked			),      
	.clk_in1		(sys_clk		)
);     
    
fifo_wr u_fifo_wr(
	.wr_clk			(clk_50m		),			    
	.rst_n			(wr_rd_rst_n	),                 
  
	.empty			(empty			),			
	.almost_full	(almost_full	),	
	.wr_rst_busy	(wr_rst_busy	),	
	.fifo_wr_en		(fifo_wr_en		),		
 	.fifo_wr_data	(fifo_wr_data	)
);
	
fifo_rd u_fifo_rd(
	.rd_clk			(clk_100m		),	
	.rst_n			(wr_rd_rst_n	),          
	                					
	.fifo_rd_data	(fifo_rd_data	),
	.full			(full			),			
	.almost_empty	(almost_empty	),
	.rd_rst_busy	(rd_rst_busy	),
	.fifo_rd_en		(fifo_rd_en		)
);  // 补充分号
	
fifo_generator_0 u_fifo_generator_0 (
  .rst				(fifo_rst),                      
  .wr_clk			(clk_50m),                
  .rd_clk			(clk_100m),                
  .din				(fifo_wr_data),                      
  .wr_en			(fifo_wr_en),                  
  .rd_en			(fifo_rd_en),                  
  .dout				(fifo_rd_data),                   
  .full				(full),                   
  .almost_full		(almost_full),     
  .empty			(empty),                 
  .almost_empty		(almost_empty),   
  .rd_data_count	(rd_data_count), 
  .wr_data_count	(wr_data_count), 
  .wr_rst_busy		(wr_rst_busy),     
  .rd_rst_busy		(rd_rst_busy)      
);

endmodule
