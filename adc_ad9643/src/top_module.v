`timescale 1ns / 1ps

module top_module
	#(
		parameter DATA_WIDTH = 14,
		parameter AXI_LITE_DATA_WIDTH = 32,
		parameter AXI_LITE_ADDR_WIDTH = 32
	)
     (
     	input 								delay_clk_200M,
        // ADC LVDS interface
        input         						clk_p,
        input         						clk_n,
        input								adc_or_in_p,
        input								adc_or_in_n,
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
        input								m_axis_aresetn,
        output								m_axis_aclk,
        output								adc_ready,
        // channel A
        input          						m_axis_tready_chA,
        output 								m_axis_tvalid_chA,
		output 	[15:0] 						m_axis_tdata_chA,
		// channel B
		input          						m_axis_tready_chB,
		output 								m_axis_tvalid_chB,
		output 	[15:0] 						m_axis_tdata_chB
     );

	wire        				clk_i;
	wire 	[DATA_WIDTH-1:0] 	single_data, idelay_data;
	// OR
	wire 						adc_or_in_i, idelay_or;
	//
	wire	[1:0]				adc_or_state_i;
	wire 						delay_rst_i;
	wire						data_valid_i;
	
	
	// LVDS MODULE
	lvds_interface #(.DATA_WIDTH(DATA_WIDTH)) 
	lvds_interface_inst
		(
        	.clk_p     			(clk_p),
        	.clk_n     			(clk_n),
        	.clk       			(clk_i),
        	.adc_or_in_p		(adc_or_in_p),
        	.adc_or_in_n		(adc_or_in_n),
        	.adc_or_in			(adc_or_in_i),
        	.data_in_p			(data_in_p),
        	.data_in_n			(data_in_n),
        	.data_out			(single_data)
    	);       

	// IDELAYE MODULE
	dat_delay #(.DATA_WIDTH(DATA_WIDTH))
	dat_delay_inst 
		(
			.adc_dat_in			(single_data),
			.adc_or_in			(adc_or_in_i),
			.clk_del			(delay_clk_200M),
			.rst_idelay 		(delay_rst_i),
			.rdy				(),
			.adc_or_out			(idelay_or),
			.adc_dat_out 		(idelay_data)
		);

	// AXI_LITE MODULE
	axi_lite #(.C_S_AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH), .C_S_AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH))
	axi_lite_inst
		(
			// user ports
			.adc_or_state		(adc_or_state_i),
			.delay_rst			(delay_rst_i),
    		.data_valid_en		(data_valid_i),
			// Ports of Axi Slave Bus Interface S_AXI
			.s_axi_aclk			(s_axi_aclk),
			.s_axi_aresetn		(s_axi_aresetn),
			.s_axi_awaddr		(s_axi_awaddr),
			.s_axi_awprot		(s_axi_awprot),
			.s_axi_awvalid		(s_axi_awvalid),
			.s_axi_awready		(s_axi_awready),
			.s_axi_wdata		(s_axi_wdata),
			.s_axi_wstrb		(s_axi_wstrb),
			.s_axi_wvalid		(s_axi_wvalid),
			.s_axi_wready		(s_axi_wready),
			.s_axi_bresp		(s_axi_bresp),
			.s_axi_bvalid		(s_axi_bvalid),
			.s_axi_bready		(s_axi_bready),
			.s_axi_araddr		(s_axi_araddr),
			.s_axi_arprot		(s_axi_arprot),
			.s_axi_arvalid		(s_axi_arvalid),
			.s_axi_arready  	(s_axi_arready),
			.s_axi_rdata		(s_axi_rdata),
			.s_axi_rresp		(s_axi_rresp),
			.s_axi_rvalid		(s_axi_rvalid),
			.s_axi_rready		(s_axi_rready)
		);
 
 		// AXI_STREAM MODULE
    axi_stream	#(.M_AXI_DATA_WIDTH(DATA_WIDTH))
    axi_stream_inst
    	(
			.s_axi_aclk			(s_axi_aclk),	
			.m_axi_aclk			(clk_i),
			.adc_din			(idelay_data),//(single_data),
			.data_valid			(data_valid_i),
			.adc_or_in			(idelay_or), //(adc_or_in_i),
			.adc_or_state		(adc_or_state_i),
			.adc_data_rdy		(adc_ready),
			.m_axis_aclk		(m_axis_aclk),
			.m_axi_aresetn		(m_axis_aresetn),
			// channel A
			.m_axi_tready_chA	(m_axis_tready_chA),
			.m_axi_tvalid_chA	(m_axis_tvalid_chA), 
			.m_axi_tdata_chA	(m_axis_tdata_chA),
			// channel B
			.m_axi_tready_chB	(m_axis_tready_chB),
			.m_axi_tvalid_chB	(m_axis_tvalid_chB),
			.m_axi_tdata_chB	(m_axis_tdata_chB)
    	);
    
endmodule
