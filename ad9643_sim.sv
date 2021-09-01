`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2021 20:32:10
// Design Name: 
// Module Name: ad9643_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`include "../config_dsp_tb.vh" 

module ad9643_sim #(
parameter PERIOD_250 = 4
 )
(
// SPI interface
     input wire sclk
    ,input wire csb
    ,inout wire sdio //temporarily as an input
    ,input wire dir
    ,input wire pdwn
    ,input wire sync
    
// ADC DDR interface
    ,input wire         clk_p
    ,input wire         clk_n
    ,output wire        or_p
    ,output wire        or_n
    ,output wire [13:0] data_p
    ,output wire [13:0] data_n
    ,output wire        dco_p
    ,output wire        dco_n
    
);

logic data_spi_tx;
logic data_spi_rx;

logic OR_P;


logic [13:0] data_count1 ;
//logic [13:0] data_count2 ;
reg   [13:0] data_p_reg;
reg   [13:0] data_n_reg;
 
assign  dco_p = ~clk_p;
assign  dco_n = ~clk_n;

assign data_p = data_p_reg  ;
assign data_n = data_n_reg ;

assign or_p =  OR_P;
assign or_n = ~OR_P;

initial begin 
data_count1 = 0;
//data_count2 = 0;
OR_P = 0;

data_p_reg  = 0;
data_n_reg  = 0;
end


 always begin
 fork
 begin
 #(PERIOD_250/2) data_count1 <= data_count1 +1;
 end
 /*begin
 #(PERIOD_250) data_count2 <= data_count2 - 1;
 end*/
 join
end

 always  @( posedge clk_p or posedge clk_n ) begin
    data_p_reg <= data_count1;
    data_n_reg <= ~data_count1;
end 

// channel B or
always  @(negedge clk_p) begin
	if (data_count1 == 14'h017c) begin
		OR_P <= 1'b1;	
	#(PERIOD_250/2)
		OR_P <= 1'b0;
	#(PERIOD_250/2)
		OR_P <= 1'b1;
	#(PERIOD_250/2)
		OR_P <= 1'b0;
	end 	
end

 spi_if SPI_IF0 (.sdio(sdio),.ss_n(csb),.sclk(sclk));



endmodule

