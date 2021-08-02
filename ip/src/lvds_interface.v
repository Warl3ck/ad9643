`timescale 1ns / 1ps

module lvds_interface
	#(
		parameter DATA_WIDTH = 14
	 )
     (
        input         				clk_p,
        input         				clk_n,
        input   [DATA_WIDTH-1:0] 	data_in_p,
        input   [DATA_WIDTH-1:0] 	data_in_n,
        output        				clk,
        output  [DATA_WIDTH-1:0] 	data_out
     );
    
   IBUFDS #(
      .DIFF_TERM    ("FALSE"),      // Differential Termination
      .IBUF_LOW_PWR ("TRUE"),       // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD   ("DEFAULT")     // Specify the input I/O standard
   ) 
   IBUFDS_inst (
      .O(clk),         	 			// Buffer output
      .I(clk_p),         			// Diff_p buffer input (connect directly to top-level port)
      .IB(clk_n)         			// Diff_n buffer input (connect directly to top-level port)
   );  
      
  genvar i;
  generate
    for (i = 0; i < DATA_WIDTH; i = i + 1)   
    begin
       IBUFDS #(
      .DIFF_TERM    ("FALSE"),      // Differential Termination
      .IBUF_LOW_PWR ("TRUE"),       // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD   ("DEFAULT")     // Specify the input I/O standard
   ) 
   IBUFDS_inst (
      .O(data_out[i]),          	// Buffer output
      .I(data_in_p[i]),         	// Diff_p buffer input (connect directly to top-level port)
      .IB(data_in_n[i])         	// Diff_n buffer input (connect directly to top-level port)
   );
  end     
  endgenerate  
endmodule
