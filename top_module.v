`timescale 1ns / 1ps

module top_module
	#(
		parameter DATA_WIDTH = 14,
		parameter AXI_LITE_DATA_WIDTH = 32,
		parameter AXI_LITE_ADDR_WIDTH = 4,
		parameter AXI_STREAM_TDATA_WIDTH = 32
	)
     (
        // ADC interface
        input         						clk_p,
        input         						clk_n,
        input   [DATA_WIDTH-1:0] 			data_in_p,
        input   [DATA_WIDTH-1:0] 			data_in_n,
        // AXI-Lite
   		input          						s_axi_aclk,
        input          						s_axi_aresetn,
        input	[(AXI_LITE_DATA_WIDTH/8)-1 : 0]	s_axi_wstrb,
        input								s_axi_wvalid, 		
        input	[AXI_LITE_DATA_WIDTH-1 : 0]	s_axi_araddr,
        input	[2:0]						s_axi_arprot,
        input								s_axi_arvalid,
        input	[AXI_LITE_DATA_WIDTH-1:0]	s_axi_awaddr,
        input	[2:0]						s_axi_awprot, 
        input								s_axi_awvalid,
        input								s_axi_bready,
        input								s_axi_rready,
        input	[AXI_LITE_DATA_WIDTH-1:0]	s_axi_wdata,
        // output axi-lite signals
        output	[1:0]						s_axi_bresp,
        output								s_axi_bvalid,
        output	[AXI_LITE_DATA_WIDTH-1 : 0]	s_axi_rdata,
        output								s_axi_awready,
        output								s_axi_arready,
        output								s_axi_wready,
        output	[1:0]						s_axi_rresp,
        output								s_axi_rvalid,
        // AXI-stream
        output [31:0]   					m_axis_tdata,
//        output          					m_axis_tlast,
        input          						m_axis_tready,
        output								m_axis_tvalid
     );

	wire        				clk_i;
	wire 	[DATA_WIDTH-1:0] 	single_data;
	wire						reset_i, data_en_i;
	

	lvds_interface #(.DATA_WIDTH(DATA_WIDTH)) 
	lvds_interface_inst(
        .clk_p     		(clk_p),
        .clk_n     		(clk_n),
        .clk       		(clk_i),
        .data_in_p		(data_in_p),
        .data_in_n		(data_in_n),
        .data_out		(single_data)
    );       

	axi_lite #(.C_S_AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH), .C_S_AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH))
	axi_lite_inst(
    	.ddr_reset		(reset_i),
    	.data_en		(data_en_i),
		// Ports of Axi Slave Bus Interface S_AXI
		.s_axi_aclk		(s_axi_aclk),
		.s_axi_aresetn	(s_axi_aresetn),
		.s_axi_awaddr	(s_axi_awaddr),
		.s_axi_awprot	(s_axi_awprot),
		.s_axi_awvalid	(s_axi_awvalid),
		.s_axi_awready	(s_axi_awready),
		.s_axi_wdata	(s_axi_wdata),
		.s_axi_wstrb	(s_axi_wstrb),
		.s_axi_wvalid	(s_axi_wvalid),
		.s_axi_wready	(s_axi_wready),
		.s_axi_bresp	(s_axi_bresp),
		.s_axi_bvalid	(s_axi_bvalid),
		.s_axi_bready	(s_axi_bready),
		.s_axi_araddr	(s_axi_araddr),
		.s_axi_arprot	(s_axi_arprot),
		.s_axi_arvalid	(s_axi_arvalid),
		.s_axi_arready  (s_axi_arready),
		.s_axi_rdata	(s_axi_rdata),
		.s_axi_rresp	(s_axi_rresp),
		.s_axi_rvalid	(s_axi_rvalid),
		.s_axi_rready	(s_axi_rready)
		);

 
    axi_stream	#(.DATA_WIDTH(DATA_WIDTH), .
C_M_AXI_TDATA_WIDTH(AXI_STREAM_TDATA_WIDTH))
    axi_stream_inst
    (
		.clk_ctrl		(s_axi_aclk),	
		.adc_din		(single_data),
		.data_en		(data_en_i),
		.ddr_reset		(reset_i),
		.m_axi_aclk		(clk_i),
//		input 	wire  	m_axi_aresetn,
		.m_axi_tvalid	(m_axis_tvalid),
		.m_axi_tdata	(m_axis_tdata),
//		output 	wire 	[(C_M_AXI_TDATA_WIDTH/8)-1 : 0] m_axi_tstrb,
//		output 	wire  	m_axi_tlast,
		.m_axi_tready	(m_axis_tready)
    );
endmodule
