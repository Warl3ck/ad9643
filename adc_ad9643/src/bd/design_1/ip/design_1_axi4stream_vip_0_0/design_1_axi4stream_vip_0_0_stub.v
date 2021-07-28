// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Thu Jul 15 13:45:48 2021
// Host        : DESKTOP-IAAFL3G running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               x:/Netlist/project_1/project_1.srcs/sources_1/bd/design_1/ip/design_1_axi4stream_vip_0_0/design_1_axi4stream_vip_0_0_stub.v
// Design      : design_1_axi4stream_vip_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tsbv484-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axi4stream_vip_v1_1_7_top,Vivado 2020.1" *)
module design_1_axi4stream_vip_0_0(aclk, aresetn, s_axis_tvalid, s_axis_tready, 
  s_axis_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,s_axis_tvalid[0:0],s_axis_tready[0:0],s_axis_tdata[31:0]" */;
  input aclk;
  input aresetn;
  input [0:0]s_axis_tvalid;
  output [0:0]s_axis_tready;
  input [31:0]s_axis_tdata;
endmodule
