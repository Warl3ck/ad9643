
`timescale 1 ns / 1 ps

	module axi_stream #
	(
		parameter integer DATA_WIDTH  = 14,
		// Parameters of Axi Master Bus Interface M_AXI
		parameter integer C_M_AXI_TDATA_WIDTH	= 32
//		parameter integer C_M_AXI_START_COUNT	= 32
	)
	(
		input 	wire 	clk_ctrl,	
		input 	wire 	[DATA_WIDTH - 1 : 0] adc_din,
		input 	wire 	data_en,
		input 	wire 	ddr_reset,
		// Ports of Axi Master Bus Interface M_AXI
		input 	wire  	m_axi_aclk,
//		input 	wire  	m_axi_aresetn,
		output 	wire  	m_axi_tvalid,
		output 	wire 	[C_M_AXI_TDATA_WIDTH-1 : 0] m_axi_tdata,
//		output 	wire 	[(C_M_AXI_TDATA_WIDTH/8)-1 : 0] m_axi_tstrb,
//		output 	wire  	m_axi_tlast,
		input 	wire  	m_axi_tready
	);
	
	wire 	[13:0] 	ddc_data_q1;
	wire 	[13:0]	ddc_data_q2;
	reg		[31:0] 	m_axis_tdata_i;
	wire	[1:0]	ctrl;
	wire	[1:0]	ctrl_z;
	wire	[1:0]	valid;
	
	
	
	
	assign ctrl = {data_en, ddr_reset};
	//cdc reset
	// xpm_cdc_array_single: Single-bit Array Synchronizer
	// Xilinx Parameterized Macro, version 2018.2
	xpm_cdc_array_single #(
	   .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
	   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
	   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	   .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
	   .WIDTH(2)           // DECIMAL; range: 1-1024
	)
	xpm_cdc_array_single_inst (
	   .dest_out(ctrl_z), // WIDTH-bit output: src_in synchronized to the destination clock domain. This output is registered.
	   .dest_clk(m_axi_aclk), // 1-bit input: Clock signal for the destination clock domain.
	   .src_clk(clk_ctrl),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
	   .src_in(ctrl)      	// WIDTH-bit input: Input single-bit array to be synchronized to destination clock
	                        // domain. It is assumed that each bit of the array is unrelated to the others. This
	                        // is reflected in the constraints applied to this macro. To transfer a binary value
	                        // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.

	);
	
// Instantiation of Axi Bus Interface M_AXI
//	axi_stream_v1_0_M_AXI # ( 
//		.C_M_AXIS_TDATA_WIDTH(C_M_AXI_TDATA_WIDTH),
//		.C_M_START_COUNT(C_M_AXI_START_COUNT)
//	) axi_stream_v1_0_M_AXI_inst (
//		.M_AXIS_ACLK(m_axi_aclk),
//		.M_AXIS_ARESETN(m_axi_aresetn),
//		.M_AXIS_TVALID(m_axi_tvalid),
//		.M_AXIS_TDATA(m_axi_tdata),
//		.M_AXIS_TSTRB(m_axi_tstrb),
//		.M_AXIS_TLAST(m_axi_tlast),
//		.M_AXIS_TREADY(m_axi_tready)
//	);

	 // IDDR Register
    genvar j;
    generate
    	for (j = 0; j < DATA_WIDTH; j = j + 1)   
    		begin
    IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                            //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0),       // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0),       // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC")       // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_inst (
      .Q1(ddc_data_q1[j]),  // 1-bit output for positive edge of clock
      .Q2(ddc_data_q2[j]),  // 1-bit output for negative edge of clock
      .C(m_axi_aclk),       // 1-bit clock input
      .CE(ctrl_z[1]),    	// 1-bit clock enable input
      .D(adc_din[j]),   	// 1-bit DDR data input
      .R(ctrl_z[0]),       	// 1-bit reset
      .S(1'b0)              // 1-bit set
   );
    	end 
   endgenerate


	// Выравнивание valid и данных
	assign	valid[0] = ctrl_z[1];	
	
	genvar i;
    generate
    	for (i = 0; i < 2; i = i + 1)   
    		begin
	FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst (
      .Q(valid[i+1]),   // 1-bit Data output
      .C(m_axi_aclk),   // 1-bit Clock input
      .CE(1'b1),    	// 1-bit Clock enable input
      .R(ddr_reset),    // 1-bit Synchronous reset input
      .D(valid[i])      // 1-bit Data input
   );
		end
	endgenerate

	always @(posedge m_axi_aclk)
    begin
    	if (m_axi_tready == 1) begin
        	m_axis_tdata_i 	<= {2'b0, ddc_data_q1, 2'b0, ddc_data_q2};
        end else
        	m_axis_tdata_i 	<= 0;
    end	

     
	assign m_axi_tvalid = valid[1];
	assign m_axi_tdata 	= m_axis_tdata_i;

	endmodule
