
`timescale 1 ns / 1 ps

	module axi_stream #
	(
		parameter integer DATA_WIDTH  = 14,
		parameter integer C_M_AXI_TDATA_WIDTH	= 32
	)
	(
		input 	wire 	clk_ctrl,	
		input 	wire 	[DATA_WIDTH - 1 : 0] adc_din,
		input 	wire 	data_en,
		input 	wire 	ddr_reset,
		// Ports of Axi Master Bus Interface M_AXI
		input 	wire  	m_axi_aclk,
		input 	wire  	m_axi_aresetn,
		output 	wire  	m_axi_tvalid,
		output 	wire 	[C_M_AXI_TDATA_WIDTH-1 : 0] m_axi_tdata,
//		output 	wire 	[(C_M_AXI_TDATA_WIDTH/8)-1 : 0] m_axi_tstrb,
//		output 	wire  	m_axi_tlast,
		input 	wire  	m_axi_tready
	);
	
	reg		[C_M_AXI_TDATA_WIDTH-1:0] 						m_axis_tdata_i;
	wire	[1:0]											ctrl;
	wire	[1:0]											ctrl_z;
	reg		[2:0]											valid_i;
	reg		[((DATA_WIDTH == 16) ? 16-DATA_WIDTH:0)-1:0]	msb_bits;
	reg		[((DATA_WIDTH == 16) ? 16-DATA_WIDTH:0)-1:0]	lsb_bits;
	wire 	[DATA_WIDTH-1:0]								ddc_data_q1;
	wire 	[DATA_WIDTH-1:0]								ddc_data_q2;
					
	initial
	begin
		msb_bits = 0;
		lsb_bits = 0;
	end
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
	   .dest_out(ctrl_z), 		// WIDTH-bit output: src_in synchronized to the destination clock domain. This output is registered.
	   .dest_clk(m_axi_aclk), 	// 1-bit input: Clock signal for the destination clock domain.
	   .src_clk(clk_ctrl),   	// 1-bit input: optional; required when SRC_INPUT_REG = 1
	   .src_in(ctrl)      		
	);
	
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
      .Q1(ddc_data_q1[j]), 	// 1-bit output for positive edge of clock
      .Q2(ddc_data_q2[j]),  // 1-bit output for negative edge of clock
      .C(m_axi_aclk),       // 1-bit clock input
      .CE(ctrl_z[1]),    	// 1-bit clock enable input
      .D(adc_din[j]),   	// 1-bit DDR data input
      .R(~m_axi_aresetn),   // 1-bit reset
      .S(1'b0)              // 1-bit set
   );
    	end 
   endgenerate


	always @(posedge m_axi_aclk)
    begin
    	if (~m_axi_aresetn) 
    		begin
    			m_axis_tdata_i 	<= 0;
        		valid_i			<= 0;
        	end 
        else 
        	begin	
    			if (m_axi_tready & ctrl_z[1] == 1) 
    				begin
        				m_axis_tdata_i  <= (DATA_WIDTH == 16) ? {ddc_data_q1,ddc_data_q2} : {msb_bits, ddc_data_q1, lsb_bits, ddc_data_q2};
        				valid_i			<= {ctrl_z[1],valid_i[2:1]};
					end 
				else 
					begin 
        				m_axis_tdata_i 	<= 0;
        				valid_i			<= 0;
        			end	
				end
		end		
	
	assign m_axi_tvalid = valid_i[0];
	assign m_axi_tdata 	= m_axis_tdata_i;

	endmodule
