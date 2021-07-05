`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module axi_stream(
	input 			clk,
	input	[13:0]	data_in,
	input			data_en,
	input			reset,
	//
	output			m_axis_clk,
	output [31:0]   m_axis_tdata,
//	output          m_axis_tlast,
	input          	m_axis_tready,
	output			m_axis_tvalid
    );
    
    // cdc regs
    wire	[2:0]	data_en_i;
    wire	[2:0]	reset_i;
	wire 	[13:0] 	ddc_data_q1;
	wire 	[13:0]	ddc_data_q2;
	reg		[31:0] 	m_axis_tdata_i = 32'h0;
	reg		[31:0] 	m_axis_tdata_i1 = 32'h0;
	reg  			valid_i;
	reg         	valid_z = 1'b0;
	reg         	valid_z1 = 1'b0;
	reg         	strb_i	= 1'b0;
	reg         	strb_z	= 1'b0;
	
    
    
    // IDDR Register
    genvar j;
    generate
    	for (j = 0; j < 14; j = j + 1)   
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
      .C(clk),            	// 1-bit clock input
      .CE(data_en_i[2]),    // 1-bit clock enable input
      .D(data_in[j]),   	// 1-bit DDR data input
      .R(reset),       		// 1-bit reset
      .S(1'b0)              // 1-bit set
   );
    	end 
   endgenerate


	// cdc data enable
	assign	data_en_i[0] = data_en;	
	
	genvar i;
    generate
    	for (i = 0; i < 2; i = i + 1)   
    		begin
	FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst (
      .Q(data_en_i[i+1]),   // 1-bit Data output
      .C(clk),      		// 1-bit Clock input
      .CE(1'b1),    		// 1-bit Clock enable input
      .R(reset),      		// 1-bit Synchronous reset input
      .D(data_en_i[i])      // 1-bit Data input
   );
		end
	endgenerate
	
	// cdc reset
	assign	reset_i[0] = reset;	
	
	genvar k;
    generate
    	for (k = 0; k < 2; k = k + 1)   
    		begin
	FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst (
      .Q(reset_i[k+1]),   	// 1-bit Data output
      .C(clk),      		// 1-bit Clock input
      .CE(1'b1),    		// 1-bit Clock enable input
      .R(reset),      		// 1-bit Synchronous reset input
      .D(reset_i[k])      	// 1-bit Data input
   );
		end
	endgenerate

always @(posedge clk)
	begin
		if (reset_i[2] == 1) begin
			valid_i <= 0;
		end	
		else begin
			valid_i <= data_en_i[2];
		end
 	end
 	
    // создание AXI-stream
always @(posedge clk)
    begin
    	if (m_axis_tready == 1) begin
        	m_axis_tdata_i 	<= {2'b0, ddc_data_q1, 2'b0, ddc_data_q2};
        	valid_z			<= valid_i;
        end else 
        	m_axis_tdata_i 	<= 0;
        	valid_z			<= 0;
        end
   
  
    // Выходные сигналы модуля
    assign m_axis_clk		= clk;
    assign m_axis_tvalid 	= valid_z;
//    assign m_axis_tlast 	= strb_z;
    assign m_axis_tdata 	= m_axis_tdata_i;
    
    endmodule