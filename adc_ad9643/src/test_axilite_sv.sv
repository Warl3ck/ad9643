
`timescale 1ps/1ps

import axi_vip_pkg::*;
import axi_vip_0_pkg::*;
// axi-stream
import axi4stream_vip_pkg::*;
import axi4stream_vip_0_pkg::*;
import axi4stream_vip_1_pkg::*;


module testbench();

	parameter DATA_WIDTH = 14;
 	parameter period_axi_clk = 8.138ns; // 122.8 MHz
 	parameter period_adc_clk = 6.510ns; // 153.6 MHz
 	parameter period_clk_del = 5ns; // 200 MHz
 	parameter aresetn = period_axi_clk * 16; // minimum for axi interface
 	parameter str_aresetn = period_adc_clk * 10;
 
	// Clock signal
  	bit clock_p;
  	bit	clock_n;
  	bit	clock_axi;
  	bit clock_delay;
  	// Reset signal
  	bit   reset;
  	// lvds data signal
  	reg	[DATA_WIDTH-1:0] data_p;
	reg	[DATA_WIDTH-1:0] data_n;
	// lvds overflow adc
	bit adc_or_in_p;
	bit adc_or_in_n;
	// axi lite
	bit	[31:0] 	m_axi_awaddr; 
	bit [2:0]	m_axi_awprot, m_axi_arprot; 
	bit 		m_axi_awvalid, m_axi_awready, m_axi_arvalid, m_axi_arready, m_axi_bvalid, m_axi_bready;;
	bit	[31:0]	m_axi_wdata;
	bit [3:0] 	m_axi_wstrb;
	bit 		m_axi_wvalid, m_axi_wready;
	bit	[1:0]	m_axi_bresp, m_axi_rresp;
	bit	[31:0]	m_axi_araddr;
	bit [31:0]  m_axi_rdata;  
	bit		 	m_axi_rvalid, m_axi_rready;
	// axi stream
	bit			m_axis_aresetn, m_axis_aclk;
	bit 		m_axis_tvalid_chA_i, m_axis_tvalid_chB;
	bit			m_axis_tready_chA_i, m_axis_tready_chB_i;
	bit	[15:0]	m_axis_tdata_chA_i, m_axis_tdata_chB_i;


    // Declarations and initialisations
    xil_axi_ulong   	addr1 = 32'h00000000;
    xil_axi_ulong   	addr2 = 32'h00000004;
    xil_axi_prot_t  	prot  = 0;
    xil_axi_resp_t  	resp;
    bit [31:0]      	data_wr1 = 32'h01234561;
    bit [31:0]      	data_wr2 = 32'h89ABCDE2;
    bit [31:0]      	data_rd1;
    bit [31:0]      	data_rd2;
    axi4stream_ready_gen ready_gen;

  // s_axi aresetn
  initial begin
    reset 			<= 1'b0;
    m_axis_aresetn 	<= 1'b0;
    #aresetn
  	@(posedge clock_axi);
  	m_axis_aresetn 	<= 1'b1;
  	reset 			<= 1'b1;
  end
  
  
  
  // axi_stream
  initial begin
  		m_axis_aresetn	<= 1'b0;
  		adc_or_in_p		<= 1'b0;
  		#str_aresetn
  	@(posedge clock_p);
		data_p 			<= 0;
		#195.3ns // channel B 
//		#198.55ns // channel A
		adc_or_in_p		<= 1'b1;
		#(period_adc_clk/2)
		adc_or_in_p		<= 1'b0;
		#(period_adc_clk)
		adc_or_in_p		<= 1'b1;
		#(period_adc_clk/2)
		adc_or_in_p		<= 1'b0;
		// 2 times
//		#201.785ns
//		adc_or_in_p		<= 1'b1;
//		#(period_adc_clk*6)
//		adc_or_in_p		<= 1'b0;
//		#351.767ns
//		m_axis_aresetn 	<= 1'b0;
//		#str_aresetn
//		m_axis_aresetn 	<= 1'b1;
  end
  
  assign adc_or_in_n = ~adc_or_in_p;
  
  // clocks
  always #(period_adc_clk/2) clock_p <= ~clock_p;	
  assign clock_n = ~clock_p;
  always #(period_axi_clk/2) clock_axi <= ~clock_axi;
  always #(period_clk_del/2) clock_delay <= ~clock_delay;
  
  // counter data_in ddr lvds
  always @(posedge clock_p or negedge clock_p)
  	begin
		data_p <= data_p + 1;
	end	
  assign data_n = ~data_p;
  

// axi_lite vip
axi_vip_0 axi_vip_0_inst(
  .aclk				(clock_axi),
  .aresetn			(reset),
  .m_axi_awaddr		(m_axi_awaddr),
  .m_axi_awprot		(m_axi_awprot),
  .m_axi_awvalid	(m_axi_awvalid),
  .m_axi_awready	(m_axi_awready),
  .m_axi_wdata		(m_axi_wdata),
  .m_axi_wstrb		(m_axi_wstrb),
  .m_axi_wvalid		(m_axi_wvalid),
  .m_axi_wready		(m_axi_wready),
  .m_axi_bresp		(m_axi_bresp),
  .m_axi_bvalid		(m_axi_bvalid),
  .m_axi_bready		(m_axi_bready),
  .m_axi_araddr		(m_axi_araddr),
  .m_axi_arprot		(m_axi_arprot),
  .m_axi_arvalid	(m_axi_arvalid),
  .m_axi_arready	(m_axi_arready),
  .m_axi_rdata		(m_axi_rdata),
  .m_axi_rresp		(m_axi_rresp),
  .m_axi_rvalid		(m_axi_rvalid),
  .m_axi_rready		(m_axi_rready)
);

// axi_stream vip channel A
 axi4stream_vip_0 axi4stream_vip_0_inst(
  .aclk				(m_axis_aclk),
  .aresetn			(m_axis_aresetn),
  .s_axis_tvalid	(m_axis_tvalid_chA_i),
  .s_axis_tready	(m_axis_tready_chA_i),
  .s_axis_tdata		(m_axis_tdata_chA_i)
);

// axi_stream vip channel B
 axi4stream_vip_1 axi4stream_vip_1_inst(
  .aclk				(m_axis_aclk),
  .aresetn			(m_axis_aresetn),
  .s_axis_tvalid	(m_axis_tvalid_chB_i),
  .s_axis_tready	(m_axis_tready_chB_i),
  .s_axis_tdata		(m_axis_tdata_chB_i)
);


top_module DUT (
	.delay_clk_200M		(clock_delay),
	// LVDS interface
	.clk_p				(clock_p), 
	.clk_n				(clock_n), 
	.data_in_p			(data_p), 
	.data_in_n			(data_n), 
	.adc_or_in_p		(adc_or_in_p),
	.adc_or_in_n		(adc_or_in_n),
	// AXI_LITE interface
    .s_axi_aclk			(clock_axi),
    .s_axi_aresetn		(reset),
    .s_axi_wstrb		(m_axi_wstrb),
    .s_axi_wvalid 		(m_axi_wvalid),
    .s_axi_araddr       (m_axi_araddr),
    .s_axi_arprot       (m_axi_arprot),
    .s_axi_arvalid      (m_axi_arvalid),
    .s_axi_awaddr       (m_axi_awaddr),
    .s_axi_awprot       (m_axi_awprot),
    .s_axi_awvalid      (m_axi_awvalid),
    .s_axi_bready       (m_axi_bready),
    .s_axi_rready       (m_axi_rready),
    .s_axi_wdata        (m_axi_wdata),
    .s_axi_bresp        (m_axi_bresp),
    .s_axi_bvalid       (m_axi_bvalid),
    .s_axi_rdata        (m_axi_rdata),
    .s_axi_awready      (m_axi_awready),
    .s_axi_arready      (m_axi_arready),
    .s_axi_wready       (m_axi_wready),
    .s_axi_rresp        (m_axi_rresp),
    .s_axi_rvalid       (m_axi_rvalid),
    // AXI_STREAM interface
    .adc_ready			(),
    .m_axis_aresetn		(m_axis_aresetn),
    .m_axis_aclk		(m_axis_aclk),
    // channel A	
    .m_axis_tvalid_chA	(m_axis_tvalid_chA_i),
	.m_axis_tdata_chA	(m_axis_tdata_chA_i),
	.m_axis_tready_chA	(m_axis_tready_chA_i),
	 // channel B
	.m_axis_tvalid_chB	(m_axis_tvalid_chB_i),
	.m_axis_tdata_chB	(m_axis_tdata_chB_i),
   	.m_axis_tready_chB	(m_axis_tready_chB_i)
);


axi_vip_0_mst_t 		master_agent;
axi4stream_vip_0_slv_t 	slv_agent;
axi4stream_vip_1_slv_t 	slave_agent;



// axi-stream vip
initial begin
	slv_agent = new("slave vip agent",testbench.axi4stream_vip_0_inst.inst.IF);
	slv_agent.start_slave();
	ready_gen = slv_agent.driver.create_ready("ready_gen");
 	ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_OSC);
 	ready_gen.set_low_time(1);
 	ready_gen.set_high_time(200);
 	slv_agent.driver.send_tready(ready_gen);
 	ready_gen = slv_agent.driver.create_ready("ready_gen 2");
 	ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_SINGLE);
 	ready_gen.set_high_time(100);
 	slv_agent.driver.send_tready(ready_gen);
end


initial begin
	slave_agent = new("slave vip agent",testbench.axi4stream_vip_1_inst.inst.IF);
	slave_agent.start_slave();
	ready_gen = slave_agent.driver.create_ready("ready_gen");
 	ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_OSC);
 	ready_gen.set_low_time(1);
 	ready_gen.set_high_time(200);
 	slave_agent.driver.send_tready(ready_gen);
 	ready_gen = slave_agent.driver.create_ready("ready_gen 2");
 	ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_SINGLE);
 	ready_gen.set_high_time(100);
 	slave_agent.driver.send_tready(ready_gen);
end


integer i;
 // axi-lite vip
initial begin
    master_agent = new("master vip agent",testbench.axi_vip_0_inst.inst.IF);
    master_agent.set_agent_tag("Master VIP");
    master_agent.set_verbosity(400);
    master_agent.start_master();
    #(period_axi_clk*10)
	for (i = 0; i < 3; i++)
	begin
    	master_agent.AXI4LITE_WRITE_BURST(addr1,prot,data_wr1,resp);
    	#(period_axi_clk*10)
    	master_agent.AXI4LITE_WRITE_BURST(addr1,prot,data_wr2,resp);
    	#154.62ns
    	master_agent.AXI4LITE_READ_BURST(addr2,prot,data_rd1,resp);
    end
     #1 $finish;
end
  endmodule
