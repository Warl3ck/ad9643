`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module lvds_interface
#(parameter N = 13)
     (
        input         clk_p,
        input         clk_n,
        input   [N:0] data_in_p,
        input   [N:0] data_in_n,
        output        clk,
        output  [N:0] data_out
     );
     
     
   IBUFDS #(
      .DIFF_TERM    ("FALSE"),      // Differential Termination
      .IBUF_LOW_PWR ("TRUE"),       // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD   ("DEFAULT")     // Specify the input I/O standard
   ) 
   IBUFDS_inst (
      .O(clk),          // Buffer output
      .I(clk_p),         // Diff_p buffer input (connect directly to top-level port)
      .IB(clk_n)         // Diff_n buffer input (connect directly to top-level port)
   );  
     
     
  genvar i;
  generate
    for (i = 0; i < N+1; i = i + 1)   
    begin
       IBUFDS #(
      .DIFF_TERM    ("FALSE"),      // Differential Termination
      .IBUF_LOW_PWR ("TRUE"),       // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD   ("DEFAULT")     // Specify the input I/O standard
   ) 
   IBUFDS_inst (
      .O(data_out[i]),          // Buffer output
      .I(data_in_p[i]),         // Diff_p buffer input (connect directly to top-level port)
      .IB(data_in_n[i])         // Diff_n buffer input (connect directly to top-level port)
   );
  end     
  endgenerate  
endmodule
