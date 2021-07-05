
`timescale 1ps/1ps

import axi_vip_pkg::*;
import axi_vip_0_pkg::*;


module testbench();
 
	// Clock signal
  bit                                   clock_p;
  bit									clock_n;
  bit									clock_axi;
  // Reset signal
  bit                                   reset;
  // data signal
  reg	[13:0]							data_p;
  reg	[13:0]							data_n;

    // Declarations and initialisations
    xil_axi_ulong   addr1 = 32'h00000000, addr2 = 32'h00000001;
    xil_axi_prot_t  prot        = 0;
    xil_axi_resp_t  resp;
    bit [31:0]      data_wr1 = 32'h01234561;
    bit [31:0]      data_wr2 = 32'h89ABCDE2;
    bit [31:0]      data_rd1;
    bit [31:0]      data_rd2;

 // axi aresetn
  initial begin
    reset <= 1'b0;
  	repeat (10) @(posedge clock_axi);
  	reset <= 1'b1;
	data_p = 0;
  end
  
  // data_in lvds
  always @(posedge clock_p or negedge clock_p)
  	begin
	data_p = data_p + 1;
	data_n = ~data_p;
	end	
  
  // clocks
  always #3.255 clock_p <= ~clock_p;	
  assign clock_n = ~clock_p;
  always #4.069 clock_axi <= ~clock_axi;
  


axi_vip_0_mst_t master_agent;

initial begin
    master_agent = new("master vip agent",testbench.DUT.design_1_i.axi_vip_0.inst.IF);
    // set tag for agents for easy debug
    master_agent.set_agent_tag("Master VIP");
    // set print out verbosity level.
    master_agent.set_verbosity(400);
    master_agent.start_master();
    #116ps
    master_agent.AXI4LITE_WRITE_BURST(addr1,prot,data_wr1,resp);
    #8.138ps
    master_agent.AXI4LITE_WRITE_BURST(addr2,prot,data_wr2,resp);
    #8.138ps
    master_agent.AXI4LITE_READ_BURST(addr1,prot,data_rd1,resp);
    #8.138ps
    master_agent.AXI4LITE_READ_BURST(addr2,prot,data_rd2,resp);
end


  // instantiate bd
 design_1_wrapper DUT(
  	.clk_p_0				(clock_p), 
	.clk_n_0				(clock_n), 
	.data_in_p_0			(data_p), 
	.data_in_n_0			(data_n), 
    .s_axi_aclk_0			(clock_axi),
    .s_axi_aresetn_0		(reset)
	    // AXI-stream
//   	.m_axis_tdata_0			(),
//   	.m_axis_tlast_0			(),
//   	.m_axis_tready_0		(),
//   	.m_axis_tvalid_0		()
  );

  endmodule
