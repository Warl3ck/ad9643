`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module top_module
#(parameter N = 13)
     (
        // ADC interface
        input         	clk_p,
        input         	clk_n,
        input   [N:0] 	data_in_p,
        input   [N:0] 	data_in_n,
        // AXI-Lite
   		input          	s_axi_aclk,
        input          	s_axi_aresetn,
        input	[3:0]	s_axi_wstrb,
        input			s_axi_wvalid, 		
        input	[31:0]	s_axi_araddr,
        input	[2:0]	s_axi_arprot,
        input			s_axi_arvalid,
        input	[31:0]	s_axi_awaddr,
        input	[2:0]	s_axi_awprot, // protection data (1 - privileged acces)
        input			s_axi_awvalid,
        input			s_axi_bready,
        input			s_axi_rready,
        input	[31:0]	s_axi_wdata,
        // output axi-lite signals
        output	[1:0]	m_axi_bresp,
        output			m_axi_bvalid,
        output	[31:0]	m_axi_rdata,
        output			m_axi_awready,
        output			m_axi_arready,
        output			m_axi_wready,
        output	[1:0]	m_axi_rresp,
        output			m_axi_rvalid,
        // AXI-stream
        output			m_axis_clk,
        output [31:0]   m_axis_tdata,
//        output          m_axis_tlast,
        input          	m_axis_tready,
        output			m_axis_tvalid
     );

	wire        	clk_i;
	wire 	[13:0] 	single_data;
	wire			reset_i, data_en;
	

	lvds_interface lvds_interface_inst
    (   
        .clk_p     		(clk_p),
        .clk_n     		(clk_n),
        .clk       		(clk_i),
        .data_in_p		(data_in_p),
        .data_in_n		(data_in_n),
        .data_out		(single_data)
    );       
    
    // axi-lite
	axi_lite axi_lite_inst
    (
   		.s_axi_aclk			(s_axi_aclk),
    	.s_axi_aresetn		(s_axi_aresetn),
    	.s_axi_wstrb		(s_axi_wstrb),
    	.s_axi_wvalid 		(s_axi_wvalid),
    	.s_axi_araddr       (s_axi_araddr),
    	.s_axi_arvalid      (s_axi_arvalid),
    	.s_axi_awaddr       (s_axi_awaddr),
    	.s_axi_awvalid      (s_axi_awvalid),
    	.s_axi_bready       (s_axi_bready),
    	.s_axi_rready       (s_axi_rready),
    	.s_axi_wdata        (s_axi_wdata),
    	.m_axi_bresp        (m_axi_bresp),
    	.m_axi_bvalid       (m_axi_bvalid),
    	.m_axi_rdata        (m_axi_rdata),
    	.m_axi_awready      (m_axi_awready),
    	.m_axi_arready      (m_axi_arready),
    	.m_axi_wready       (m_axi_wready),
    	.m_axi_rresp        (m_axi_rresp),
    	.m_axi_rvalid       (m_axi_rvalid),
    	// to AXI-stream
        .reset				(reset_i),
        .data_en			(data_en)
    );
 

    axi_stream	axi_stream_inst
    (
    	.clk				(clk_i),	
    	.data_in			(single_data),
    	.data_en			(data_en),
    	.reset				(reset_i),
    	// AXI-stream interface
    	.m_axis_clk			(m_axis_clk),
   		.m_axis_tdata		(m_axis_tdata),
//   		.m_axis_tlast		(m_axis_tlast),
   		.m_axis_tready		(m_axis_tready),
   		.m_axis_tvalid		(m_axis_tvalid)
    );
endmodule
