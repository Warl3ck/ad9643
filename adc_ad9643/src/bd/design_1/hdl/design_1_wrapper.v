//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
//Date        : Sun Jul 25 16:47:32 2021
//Host        : DESKTOP-IAAFL3G running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (clk_n_0,
    clk_p_0,
    data_in_n_0,
    data_in_p_0,
    s_aresetn,
    s_axi_aclk);
  input clk_n_0;
  input clk_p_0;
  input [13:0]data_in_n_0;
  input [13:0]data_in_p_0;
  input s_aresetn;
  input s_axi_aclk;

  wire clk_n_0;
  wire clk_p_0;
  wire [13:0]data_in_n_0;
  wire [13:0]data_in_p_0;
  wire s_aresetn;
  wire s_axi_aclk;

  design_1 design_1_i
       (.clk_n_0(clk_n_0),
        .clk_p_0(clk_p_0),
        .data_in_n_0(data_in_n_0),
        .data_in_p_0(data_in_p_0),
        .s_aresetn(s_aresetn),
        .s_axi_aclk(s_axi_aclk));
endmodule
