
`timescale 1 ns / 1 ps

	module axi_stream #
	(
		parameter integer M_AXI_DATA_WIDTH  = 14
	)
	(
		input 	wire 	s_axi_aclk,	
		input	wire	m_axi_aclk,
		input 	wire 	[M_AXI_DATA_WIDTH - 1 : 0] adc_din,
		input 	wire 	ddr_data_en,
		input	wire	adc_or_in,
		output	wire	[1:0] adc_or_state,
		// Ports of Axi Master Bus Interface M_AXI
		output 	wire  	m_axis_aclk,
		input 	wire  	m_axi_aresetn,
		output	wire	adc_data_rdy,
		// channel A
		input 	wire  	m_axi_tready_chA,
		output 	wire  	m_axi_tvalid_chA,
		output 	wire 	[15:0] m_axi_tdata_chA,
		// channel B
		input 	wire  	m_axi_tready_chB,
		output 	wire  	m_axi_tvalid_chB,
		output 	wire 	[15:0] m_axi_tdata_chB
	);
	
	wire	data_en_i;
	wire	adc_dat_rdy_i;
	reg		[((M_AXI_DATA_WIDTH == 16) ? 16-M_AXI_DATA_WIDTH:0)-1:0]	msb_bits;
	wire 	[M_AXI_DATA_WIDTH-1:0]	ddr_data_q1;
	wire 	[M_AXI_DATA_WIDTH-1:0]	ddr_data_q2;
	wire	[2*M_AXI_DATA_WIDTH-1:0] ddr_data;
	reg		[15:0]	m_axi_tdata_chA_i;
	reg		[15:0]	m_axi_tdata_chB_i;
	wire	[2*M_AXI_DATA_WIDTH-1:0] delayed_data [0:10];
	reg		m_axi_tvalid_chA_i;
	reg		m_axi_tvalid_chB_i;
	// or
	wire 	or_b, or_a; 
	wire	[1:0] adc_or_ab_i;
	reg 	adc_rdy_a, adc_rdy_b;
					
	initial
	begin
		msb_bits = 0;
		m_axi_tvalid_chA_i = 1'b0;
		m_axi_tvalid_chB_i = 1'b0;
	end
	
	//************************************************** ADC_OR SECTION 
	// or ddr regs
    IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
      .INIT_Q1(1'b0),       // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0),       // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC")       // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_or (
      .Q1(or_b), 			// 1-bit output for positive edge of clock
      .Q2(or_a),  			// 1-bit output for negative edge of clock
      .C(m_axi_aclk),       // 1-bit clock input
      .CE(1'b1),    		// 1-bit clock enable input
      .D(adc_or_in),   		// 1-bit DDR data input
      .R(~m_axi_aresetn),   // 1-bit reset
      .S(1'b0)  			// 1-bit set
 	);

	assign adc_or_ab_i = {or_a, or_b};
	
	// cdc adc_or
	xpm_cdc_array_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(2)           // DECIMAL; range: 1-1024
   )
   xpm_cdc_array_single_inst 
   (
      .dest_out(adc_or_state), 
      .dest_clk(s_axi_aclk), 
      .src_clk(m_axi_aclk),   
      .src_in(adc_or_ab_i)      
   );
   

   always @(posedge m_axi_aclk)
   begin
   	if (~m_axi_aresetn) begin
   		adc_rdy_a <= 1'b0;
		adc_rdy_b <= 1'b0;
	end else begin	
   		adc_rdy_a	<= or_a;
   		adc_rdy_b	<= or_b;
   	end
   end
   
	assign adc_dat_rdy_i = adc_rdy_a || adc_rdy_b;
	//**************************************************

	//************************************************** ADC_DATA and create valid signals
	// cdc ddr data_enable
	xpm_cdc_single #(
      .DEST_SYNC_FF(2),   		// DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   		// DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), 		// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   		// DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_single_inst 
   (
      .dest_out(data_en_i), 
      .dest_clk(m_axi_aclk), 	
      .src_clk(s_axi_aclk), 	
      .src_in(ddr_data_en)		
   );

   
	// IDDR Register
    genvar j;
    generate
    	for (j = 0; j < M_AXI_DATA_WIDTH; j = j + 1)   
    		begin
    IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
      .INIT_Q1(1'b0),       	// Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0),       	// Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC")       	// Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_inst (
      .Q1(ddr_data_q1[j]), 		// 1-bit output for positive edge of clock
      .Q2(ddr_data_q2[j]),  	// 1-bit output for negative edge of clock
      .C(m_axi_aclk),       	// 1-bit clock input
      .CE(1'b1),    			// 1-bit clock enable input
      .D(adc_din[j]),  			// 1-bit DDR data input
      .R(~m_axi_aresetn),   	// 1-bit reset
      .S(1'b0)  				// 1-bit set
   );
    	end 
   endgenerate
   
   
   	// delay data_signal (signal or) 
   	assign ddr_data = {ddr_data_q1, ddr_data_q2};
	assign delayed_data[0] = ddr_data; 
	
	genvar i,k;
    generate
    	for (i = 0; i < 2*M_AXI_DATA_WIDTH; i = i + 1) begin
    		for (k = 0; k < 10; k = k + 1) begin
	FDRE #(
      .INIT(1'b0) 					// Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst (
      .Q(delayed_data[k+1][i]),  	// 1-bit Data output
      .C(m_axi_aclk),      			// 1-bit Clock input
      .CE(1'b1),    				// 1-bit Clock enable input
      .R(~m_axi_aresetn),   		// 1-bit Synchronous reset input
      .D(delayed_data[k][i])        // 1-bit Data input
   );
   	end
   end
   endgenerate
   
   
	// channel A axi_stream logic
	always @(posedge m_axi_aclk)
    begin
    	if (~m_axi_aresetn) 
        	m_axi_tdata_chA_i <= 32'b0;	
        else begin	
			if (m_axi_tready_chA && data_en_i && ~or_a) begin //~adc_rdy_a[1]
				m_axi_tdata_chA_i <= (M_AXI_DATA_WIDTH == 16) ? {delayed_data[10][27:14]} : {msb_bits, delayed_data[10][27:14]};
				m_axi_tvalid_chA_i <= data_en_i;
			end else begin 
				m_axi_tvalid_chA_i <= 1'b0;
        	end	
		end
	end

	// channel B axi_stream logic
	always @(posedge m_axi_aclk)
    begin
    	if (~m_axi_aresetn)
        	m_axi_tdata_chB_i <= 32'b0;
        else begin	
    		if (m_axi_tready_chB && data_en_i && ~or_b) begin
					m_axi_tdata_chB_i <= (M_AXI_DATA_WIDTH == 16) ? {delayed_data[10][13:0]} : {msb_bits, delayed_data[10][13:0]};
					m_axi_tvalid_chB_i <= data_en_i;
			end else begin
					m_axi_tvalid_chB_i <= 1'b0;
			end	
		end
	end				
	//**************************************************
	
	assign m_axis_aclk = m_axi_aclk;
	assign adc_data_rdy = ~adc_dat_rdy_i;
	// channel A out
	assign m_axi_tdata_chA = m_axi_tdata_chA_i;
	assign m_axi_tvalid_chA = m_axi_tvalid_chA_i;
	// channel B out
	assign m_axi_tdata_chB = m_axi_tdata_chB_i;
	assign m_axi_tvalid_chB = m_axi_tvalid_chB_i;
	endmodule
