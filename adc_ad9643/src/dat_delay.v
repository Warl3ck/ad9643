`timescale 1ns / 1ps

module dat_delay
		#(
			parameter DATA_WIDTH = 14
		)
		(
			input   [DATA_WIDTH-1:0] 	adc_dat_in,
			input						adc_or_in,
			input						clk_del,
			input						rst_idelay,
			output						rdy,
			output						adc_or_out,
			output	[DATA_WIDTH-1:0] 	adc_dat_out
		);

//   (* IODELAY_GROUP = <iodelay_group_name> *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL

   IDELAYCTRL IDELAYCTRL_inst 
   (
      .RDY(rdy),       			// 1-bit output: Ready output
      .REFCLK(clk_del), 		// 1-bit input: Reference clock input
      .RST(rst_idelay)         // 1-bit input: Active high reset input
   );

  genvar i;
    generate
    	for (i = 0; i < DATA_WIDTH; i = i + 1)   
    		begin
   IDELAYE2 #(
      .CINVCTRL_SEL("FALSE"),          	// Enable dynamic clock inversion (FALSE, TRUE)
      .DELAY_SRC("DATAIN"),            	// Delay input (IDATAIN, DATAIN)
      .HIGH_PERFORMANCE_MODE("FALSE"), 	// Reduced jitter ("TRUE"), Reduced power ("FALSE")
      .IDELAY_TYPE("FIXED"),           	// FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_VALUE(0),                	// Input delay tap setting (0-31)
      .PIPE_SEL("FALSE"),              	// Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY(200.0),        	// IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN("DATA")          	// DATA, CLOCK input signal
   )
   IDELAYE2_inst (
      .CNTVALUEOUT(), 					// 5-bit output: Counter value output
      .DATAOUT(adc_dat_out[i]),  		// 1-bit output: Delayed data output
      .C(clk_del),                 		// 1-bit input: Clock input
      .CE(1'b1),                 		// 1-bit input: Active high enable increment/decrement input
      .CINVCTRL(1'b0),       	 		// 1-bit input: Dynamic clock inversion input
      .CNTVALUEIN(CNTVALUEIN),   		// 5-bit input: Counter value input
      .DATAIN(adc_dat_in[i]),   		// 1-bit input: Internal delay data input
      .IDATAIN(IDATAIN),         		// 1-bit input: Data input from the I/O
      .INC(1'b1),                		// 1-bit input: Increment / Decrement tap delay input
      .LD(1'b1),                 		// 1-bit input: Load IDELAY_VALUE input
      .LDPIPEEN(1'b1),         	 		// 1-bit input: Enable PIPELINE register to load data input
      .REGRST(1'b0)              		// 1-bit input: Active-high reset tap-delay input
   );
    end 
   endgenerate
   
   // adc_or
   IDELAYE2 #(
      .CINVCTRL_SEL("FALSE"),          	// Enable dynamic clock inversion (FALSE, TRUE)
      .DELAY_SRC("DATAIN"),            	// Delay input (IDATAIN, DATAIN)
      .HIGH_PERFORMANCE_MODE("FALSE"), 	// Reduced jitter ("TRUE"), Reduced power ("FALSE")
      .IDELAY_TYPE("FIXED"),           	// FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_VALUE(0),                	// Input delay tap setting (0-31)
      .PIPE_SEL("FALSE"),              	// Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY(200.0),        	// IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN("DATA")          	// DATA, CLOCK input signal
   )
   IDELAYE2_inst (
      .CNTVALUEOUT(), 					// 5-bit output: Counter value output
      .DATAOUT(adc_or_out),  	 		// 1-bit output: Delayed data output
      .C(clk_del),                 		// 1-bit input: Clock input
      .CE(1'b1),                 		// 1-bit input: Active high enable increment/decrement input
      .CINVCTRL(1'b0),       	 		// 1-bit input: Dynamic clock inversion input
      .CNTVALUEIN(CNTVALUEIN),   		// 5-bit input: Counter value input
      .DATAIN(adc_or_in),   	 		// 1-bit input: Internal delay data input
      .IDATAIN(IDATAIN),         		// 1-bit input: Data input from the I/O
      .INC(1'b1),                		// 1-bit input: Increment / Decrement tap delay input
      .LD(1'b1),                 		// 1-bit input: Load IDELAY_VALUE input
      .LDPIPEEN(1'b1),         	 		// 1-bit input: Enable PIPELINE register to load data input
      .REGRST(1'b0)              		// 1-bit input: Active-high reset tap-delay input
   );

endmodule
