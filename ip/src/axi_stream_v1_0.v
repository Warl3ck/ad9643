
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
		output	wire	adc_or_state,
		// Ports of Axi Master Bus Interface M_AXI
		output 	wire  	m_axis_aclk,
		input 	wire  	m_axi_aresetn,
		input 	wire  	m_axi_tready,
		output	wire	adc_data_rdy,
		// channel A
		output 	wire  	m_axi_tvalid_chA,
		output 	wire 	[15:0] m_axi_tdata_chA,
		// channel B
		output 	wire  	m_axi_tvalid_chB,
		output 	wire 	[15:0] m_axi_tdata_chB
	);
	
	wire	data_en_i;
	wire	adc_data_ready_i;
	reg		[1:0]	valid_i;
	reg		[((M_AXI_DATA_WIDTH == 16) ? 16-M_AXI_DATA_WIDTH:0)-1:0]	msb_bits;
//	reg		[((DATA_WIDTH == 16) ? 16-DATA_WIDTH:0)-1:0]	lsb_bits;
	wire 	[M_AXI_DATA_WIDTH-1:0]	ddc_data_q1;
	wire 	[M_AXI_DATA_WIDTH-1:0]	ddc_data_q2;
	reg		[15:0]	m_axi_tdata_chA_i;
	reg		[15:0]	m_axi_tdata_chB_i;
	reg		m_axi_tvalid_chA_i;
	reg		m_axi_tvalid_chB_i;
	// or
	wire 	or_1, or_2, or_i;
					
	initial
	begin
		msb_bits = 0;
	end
	
	// cdc ddr data_enable
	xpm_cdc_single #(
      .DEST_SYNC_FF(2),   		// DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   		// DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), 		// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   		// DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_single_inst (
      .dest_out(data_en_i), 	// 1-bit output: src_in synchronized to the destination clock domain.
      .dest_clk(m_axi_aclk), 	// 1-bit input: Clock signal for the destination clock domain.
      .src_clk(s_axi_aclk), 	// 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(ddr_data_en)		// 1-bit input: Input signal to be synchronized to dest_clk domain.
   );
	
	// cdc adc_or
	xpm_cdc_single #(
      .DEST_SYNC_FF(2),   		// DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   		// DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), 		// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   		// DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_single_nst (
      .dest_out(adc_or_state), 	// 1-bit output: src_in synchronized to the destination clock domain.
      .dest_clk(s_axi_aclk), 	// 1-bit input: Clock signal for the destination clock domain.
      .src_clk(m_axi_aclk), 	// 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(adc_or_in)		// 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

	// or
    IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
      .INIT_Q1(1'b0),       // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0),       // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC")       // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_or (
      .Q1(or_1), 				// 1-bit output for positive edge of clock
      .Q2(or_2),  				// 1-bit output for negative edge of clock
      .C(m_axi_aclk),       // 1-bit clock input
      .CE(1'b1),    		// 1-bit clock enable input
      .D(adc_or_in),   		// 1-bit DDR data input
      .R(~m_axi_aresetn),   // 1-bit reset
      .S(1'b0)  // 1-bit set
 	);

	assign or_i = {or_1, or_2};

	// trig adc_or
   FDRE #(
      .INIT(1'b0) 			// Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst (
      .Q(adc_data_ready_i), // 1-bit Data output
      .C(m_axi_aclk),      	// 1-bit Clock input
      .CE(m_axi_aresetn),   // 1-bit Clock enable input
      .R(~m_axi_aresetn),   // 1-bit Synchronous reset input
      .D(~or_i)       		// 1-bit Data input
   );

	 // IDDR Register
    genvar j;
    generate
    	for (j = 0; j < M_AXI_DATA_WIDTH; j = j + 1)   
    		begin
    IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
      .INIT_Q1(1'b0),       // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0),       // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC")       // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_inst (
      .Q1(ddc_data_q1[j]), 	// 1-bit output for positive edge of clock
      .Q2(ddc_data_q2[j]),  // 1-bit output for negative edge of clock
      .C(m_axi_aclk),       // 1-bit clock input
      .CE(data_en_i),    	// 1-bit clock enable input
      .D(adc_din[j]),   	// 1-bit DDR data input
      .R(~m_axi_aresetn),   // 1-bit reset
      .S(1'b0)  			// 1-bit set
   );
    	end 
   endgenerate


	always @(posedge m_axi_aclk)
    begin
    	if (~m_axi_aresetn) begin
        	valid_i	<= 1'b0;
        	m_axi_tdata_chA_i <= 32'b0;
        	m_axi_tdata_chB_i <= 32'b0;
        end else 
        	begin	
    			if (m_axi_tready && data_en_i && ~adc_or_in) begin
    				m_axi_tdata_chA_i <= (M_AXI_DATA_WIDTH == 16) ? {ddc_data_q1} : {msb_bits, ddc_data_q1};
					m_axi_tdata_chB_i <= (M_AXI_DATA_WIDTH == 16) ? {ddc_data_q2} : {msb_bits, ddc_data_q2};
					m_axi_tvalid_chA_i <= valid_i[0];
					m_axi_tvalid_chB_i <= valid_i[1];
				end else begin 
					m_axi_tvalid_chA_i <= 1'b0;
        			m_axi_tvalid_chB_i <= 1'b0;
        		end	
			end
			valid_i	<= {data_en_i, valid_i[1]};
		end		
	
	
	assign m_axis_aclk = m_axi_aclk;
	assign adc_data_rdy = adc_data_ready_i;
	// channel A out
	assign m_axi_tdata_chA = m_axi_tdata_chA_i;
	assign m_axi_tvalid_chA = m_axi_tvalid_chA_i;
	// channel B out
	assign m_axi_tdata_chB = m_axi_tdata_chB_i;
	assign m_axi_tvalid_chB = m_axi_tvalid_chB_i;
	endmodule
