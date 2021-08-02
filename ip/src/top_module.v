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
        input          						m_axis_tready,
        output								m_axis_aclk,
        output								adc_ready,
        // channel A
        output 								m_axis_tvalid_chA,
		output 	[15:0] 						m_axis_tdata_chA,
		// channel B
		output 								m_axis_tvalid_chB,
		output 	[15:0] 						m_axis_tdata_chB
     );

	wire        				clk_i;
	wire 	[DATA_WIDTH-1:0] 	single_data;
	wire						data_en_i;
	wire 						adc_or_in_i;
	wire						adc_or_state_i;
	wire 						delay_rst_i;
	//
//	wire 	[DATA_WIDTH-1:0] 	idelay_data;
	

	lvds_interface #(.DATA_WIDTH(DATA_WIDTH)) 
	lvds_interface_inst(
        .clk_p     		(clk_p),
        .clk_n     		(clk_n),
        .clk       		(clk_i),
        .adc_or_in_p	(adc_or_in_p),
        .adc_or_in_n	(adc_or_in_n),
        .adc_or_in		(adc_or_in_i),
        .data_in_p		(data_in_p),
        .data_in_n		(data_in_n),
        .data_out		(single_data)
    );       

//   (* IODELAY_GROUP = <iodelay_group_name> *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL

   IDELAYCTRL IDELAYCTRL_inst (
      .RDY(RDY),       			// 1-bit output: Ready output
      .REFCLK(delay_clk_200M), 	// 1-bit input: Reference clock input
      .RST(delay_rst_i)         // 1-bit input: Active high reset input
   );

//// (IODELAY_GROUP = iodelay_group_name) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
//  genvar j;
//    generate
//    	for (j = 0; j < 14; j = j + 1)   
//    		begin
//   IDELAYE2 #(
//      .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
//      .DELAY_SRC("DATAIN"),            // Delay input (IDATAIN, DATAIN)
//      .HIGH_PERFORMANCE_MODE("FALSE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
//      .IDELAY_TYPE("FIXED"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
//      .IDELAY_VALUE(4),                // Input delay tap setting (0-31)
//      .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
//      .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
//      .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
//   )
//   IDELAYE2_inst (
//      .CNTVALUEOUT(CNTVALUEOUT), // 5-bit output: Counter value output
//      .DATAOUT(idelay_data[j]),  // 1-bit output: Delayed data output
//      .C(clk_i),                 // 1-bit input: Clock input
//      .CE(1'b1),                 // 1-bit input: Active high enable increment/decrement input
//      .CINVCTRL(1'b0),       	// 1-bit input: Dynamic clock inversion input
//      .CNTVALUEIN(CNTVALUEIN),  // 5-bit input: Counter value input
//      .DATAIN(single_data[j]),   // 1-bit input: Internal delay data input
//      .IDATAIN(IDATAIN),         // 1-bit input: Data input from the I/O
//      .INC(1'b1),                // 1-bit input: Increment / Decrement tap delay input
//      .LD(1'b1),                 // 1-bit input: Load IDELAY_VALUE input
//      .LDPIPEEN(1'b1),         	 // 1-bit input: Enable PIPELINE register to load data input
//      .REGRST(1'b0)              // 1-bit input: Active-high reset tap-delay input
//   );
//    end 
//   endgenerate
   
	axi_lite #(.C_S_AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH), .C_S_AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH))
	axi_lite_inst(
		// user ports
		.adc_or_state	(adc_or_state_i),
		.delay_rst		(delay_rst_i),
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
 
    axi_stream	#(.M_AXI_DATA_WIDTH(DATA_WIDTH))
    axi_stream_inst
    (
		.s_axi_aclk			(s_axi_aclk),	
		.m_axi_aclk			(clk_i),
		.adc_din			(single_data),
		.ddr_data_en		(data_en_i),
		.adc_or_in			(adc_or_in_i),
		.adc_or_state		(adc_or_state_i),
		.adc_data_rdy		(adc_ready),
		.m_axis_aclk		(m_axis_aclk),
		.m_axi_aresetn		(m_axis_aresetn),
		.m_axi_tready		(m_axis_tready),
				// channel A
		.m_axi_tvalid_chA	(m_axis_tvalid_chA), 
		.m_axi_tdata_chA	(m_axis_tdata_chA),
		// channel B
		.m_axi_tvalid_chB	(m_axis_tvalid_chB),
		.m_axi_tdata_chB	(m_axis_tdata_chB)
    );
endmodule
