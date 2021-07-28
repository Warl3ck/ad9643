//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
//Date        : Sun Jul 25 16:47:32 2021
//Host        : DESKTOP-IAAFL3G running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=4,numReposBlks=4,numNonXlnxBlks=1,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (clk_n_0,
    clk_p_0,
    data_in_n_0,
    data_in_p_0,
    s_aresetn,
    s_axi_aclk);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_N_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_N_0, CLK_DOMAIN design_1_clk_n_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input clk_n_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_P_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_P_0, ASSOCIATED_RESET m_axis_aresetn, CLK_DOMAIN design_1_clk_p_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input clk_p_0;
  input [13:0]data_in_n_0;
  input [13:0]data_in_p_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.S_ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.S_ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input s_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.S_AXI_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.S_AXI_ACLK, ASSOCIATED_RESET s_aresetn, CLK_DOMAIN design_1_aclk_1, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input s_axi_aclk;

  wire aclk_1_1;
  wire [31:0]adc_ad9643_0_m_axis_TDATA;
  wire [0:0]adc_ad9643_0_m_axis_TREADY;
  wire adc_ad9643_0_m_axis_TVALID;
  wire adc_ad9643_0_m_axis_aclk;
  wire aresetn_0_1;
  wire [31:0]axi_vip_0_M_AXI_ARADDR;
  wire [2:0]axi_vip_0_M_AXI_ARPROT;
  wire axi_vip_0_M_AXI_ARREADY;
  wire axi_vip_0_M_AXI_ARVALID;
  wire [31:0]axi_vip_0_M_AXI_AWADDR;
  wire [2:0]axi_vip_0_M_AXI_AWPROT;
  wire axi_vip_0_M_AXI_AWREADY;
  wire axi_vip_0_M_AXI_AWVALID;
  wire axi_vip_0_M_AXI_BREADY;
  wire [1:0]axi_vip_0_M_AXI_BRESP;
  wire axi_vip_0_M_AXI_BVALID;
  wire [31:0]axi_vip_0_M_AXI_RDATA;
  wire axi_vip_0_M_AXI_RREADY;
  wire [1:0]axi_vip_0_M_AXI_RRESP;
  wire axi_vip_0_M_AXI_RVALID;
  wire [31:0]axi_vip_0_M_AXI_WDATA;
  wire axi_vip_0_M_AXI_WREADY;
  wire [3:0]axi_vip_0_M_AXI_WSTRB;
  wire axi_vip_0_M_AXI_WVALID;
  wire clk_n_0_1;
  wire clk_p_0_1;
  wire [13:0]data_in_n_0_1;
  wire [13:0]data_in_p_0_1;
  wire sim_rst_gen_0_rst;

  assign aclk_1_1 = s_axi_aclk;
  assign aresetn_0_1 = s_aresetn;
  assign clk_n_0_1 = clk_n_0;
  assign clk_p_0_1 = clk_p_0;
  assign data_in_n_0_1 = data_in_n_0[13:0];
  assign data_in_p_0_1 = data_in_p_0[13:0];
  design_1_adc_ad9643_0_6 adc_ad9643_0
       (.clk_n(clk_n_0_1),
        .clk_p(clk_p_0_1),
        .data_in_n(data_in_n_0_1),
        .data_in_p(data_in_p_0_1),
        .m_axis_aclk(adc_ad9643_0_m_axis_aclk),
        .m_axis_aresetn(sim_rst_gen_0_rst),
        .m_axis_tdata(adc_ad9643_0_m_axis_TDATA),
        .m_axis_tready(adc_ad9643_0_m_axis_TREADY),
        .m_axis_tvalid(adc_ad9643_0_m_axis_TVALID),
        .s_axi_aclk(aclk_1_1),
        .s_axi_araddr(axi_vip_0_M_AXI_ARADDR),
        .s_axi_aresetn(aresetn_0_1),
        .s_axi_arprot(axi_vip_0_M_AXI_ARPROT),
        .s_axi_arready(axi_vip_0_M_AXI_ARREADY),
        .s_axi_arvalid(axi_vip_0_M_AXI_ARVALID),
        .s_axi_awaddr(axi_vip_0_M_AXI_AWADDR),
        .s_axi_awprot(axi_vip_0_M_AXI_AWPROT),
        .s_axi_awready(axi_vip_0_M_AXI_AWREADY),
        .s_axi_awvalid(axi_vip_0_M_AXI_AWVALID),
        .s_axi_bready(axi_vip_0_M_AXI_BREADY),
        .s_axi_bresp(axi_vip_0_M_AXI_BRESP),
        .s_axi_bvalid(axi_vip_0_M_AXI_BVALID),
        .s_axi_rdata(axi_vip_0_M_AXI_RDATA),
        .s_axi_rready(axi_vip_0_M_AXI_RREADY),
        .s_axi_rresp(axi_vip_0_M_AXI_RRESP),
        .s_axi_rvalid(axi_vip_0_M_AXI_RVALID),
        .s_axi_wdata(axi_vip_0_M_AXI_WDATA),
        .s_axi_wready(axi_vip_0_M_AXI_WREADY),
        .s_axi_wstrb(axi_vip_0_M_AXI_WSTRB),
        .s_axi_wvalid(axi_vip_0_M_AXI_WVALID));
  design_1_axi4stream_vip_0_0 axi4stream_vip_0
       (.aclk(adc_ad9643_0_m_axis_aclk),
        .aresetn(sim_rst_gen_0_rst),
        .s_axis_tdata(adc_ad9643_0_m_axis_TDATA),
        .s_axis_tready(adc_ad9643_0_m_axis_TREADY),
        .s_axis_tvalid(adc_ad9643_0_m_axis_TVALID));
  design_1_axi_vip_0_0 axi_vip_0
       (.aclk(aclk_1_1),
        .aresetn(aresetn_0_1),
        .m_axi_araddr(axi_vip_0_M_AXI_ARADDR),
        .m_axi_arprot(axi_vip_0_M_AXI_ARPROT),
        .m_axi_arready(axi_vip_0_M_AXI_ARREADY),
        .m_axi_arvalid(axi_vip_0_M_AXI_ARVALID),
        .m_axi_awaddr(axi_vip_0_M_AXI_AWADDR),
        .m_axi_awprot(axi_vip_0_M_AXI_AWPROT),
        .m_axi_awready(axi_vip_0_M_AXI_AWREADY),
        .m_axi_awvalid(axi_vip_0_M_AXI_AWVALID),
        .m_axi_bready(axi_vip_0_M_AXI_BREADY),
        .m_axi_bresp(axi_vip_0_M_AXI_BRESP),
        .m_axi_bvalid(axi_vip_0_M_AXI_BVALID),
        .m_axi_rdata(axi_vip_0_M_AXI_RDATA),
        .m_axi_rready(axi_vip_0_M_AXI_RREADY),
        .m_axi_rresp(axi_vip_0_M_AXI_RRESP),
        .m_axi_rvalid(axi_vip_0_M_AXI_RVALID),
        .m_axi_wdata(axi_vip_0_M_AXI_WDATA),
        .m_axi_wready(axi_vip_0_M_AXI_WREADY),
        .m_axi_wstrb(axi_vip_0_M_AXI_WSTRB),
        .m_axi_wvalid(axi_vip_0_M_AXI_WVALID));
  design_1_sim_rst_gen_0_0 sim_rst_gen_0
       (.rst(sim_rst_gen_0_rst));
endmodule
