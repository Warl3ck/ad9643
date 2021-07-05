`timescale 1ns / 1ps

module axi_lite
	(
   		// AXI-Lite
   		input          	s_axi_aclk,
   		input          	s_axi_aresetn,
   		input	[3:0]	s_axi_wstrb,
   		input			s_axi_wvalid, 		
   		input	[31:0]	s_axi_araddr,
   		input	[2:0]	s_axi_arprot,
   		input			s_axi_arvalid,
   		input	[31:0]	s_axi_awaddr,
   		input	[2:0]	s_axi_awprot, // protection data (1 - privileged acces)
   		input			s_axi_awvalid,
   		input			s_axi_bready,
   		input			s_axi_rready,
   		input	[31:0]	s_axi_wdata,
   		// output signals
   		output	[1:0]	m_axi_bresp,
   		output			m_axi_bvalid,
   		output	[31:0]	m_axi_rdata,
   		output			m_axi_awready,
   		output			m_axi_arready,
   		output			m_axi_wready,
   		output	[1:0]	m_axi_rresp,
   		output			m_axi_rvalid,
   		// out
   		output			reset,
   		output			data_en
    );
    
	reg [31:0]	ctrl_reg;
	reg	[31:0]	mode_reg;
	reg [31:0] 	s_axi_rdata_i;
	reg			s_axi_awready_i;
	reg			s_axi_wready_i;
	reg			s_axi_arready_i;
	reg			s_axi_rvalid_i;
	reg	[31:0]	s_axi_awaddr_i;
	reg [31:0] 	s_axi_wdata_i;
	reg			wr_data_cmplt;
	reg [1:0]	s_axi_rresp_i;
	
	
	// fsm axi-lite
	reg [1:0] state;
	parameter [1:0] read_wait = 0, write_addr = 1, write_data = 2, read = 3;


	initial
	begin
		s_axi_rresp_i = 2'b00;
	end
	
	always @(*)
	begin
		if (~s_axi_aresetn) begin 
				s_axi_awready_i <= 0;
				s_axi_wready_i	<= 0;
				ctrl_reg		<= 0;
				mode_reg 		<= 0;
				s_axi_wdata_i 	<= 0;
				s_axi_rvalid_i 	<= 0;
				s_axi_rdata_i 	<= 0;
				s_axi_arready_i <= 0;
				state			<= read_wait;
		end else
			case(state)
				read_wait		: 	
									begin					
										s_axi_awready_i = 1;
										s_axi_wready_i	= 0;
										s_axi_arready_i	= 1;
										wr_data_cmplt	= 0;						
									if (s_axi_arvalid == 1)
										state = read;
									else if (s_axi_awvalid == 1) begin
							 			state = write_addr;
									end else
										state = read_wait;
									end	
					read		:	begin
										state = read_wait;
									end				
					write_addr	:	begin
										state = write_data;
									end	
					write_data	:	begin	
										if (wr_data_cmplt == 1)
											state = read_wait;
									end
				endcase
		end


always @(posedge s_axi_aclk)
	begin
		case(state)
			read_wait	:	
							begin	
								wr_data_cmplt	<= 0;	
								s_axi_rvalid_i	<= 0;
							end
			read		:	begin
								s_axi_rvalid_i <= 1;
								case(s_axi_araddr)
									32'h0: s_axi_rdata_i <= ctrl_reg;
									32'h1: s_axi_rdata_i <= mode_reg;
								endcase	
							end
			write_addr	: 	begin
								s_axi_awready_i <= 0;
								s_axi_wready_i	<= 1;
								s_axi_awaddr_i	<= s_axi_awaddr;	
							end	
			write_data	:	begin
								if (s_axi_wvalid == 1) begin	
									s_axi_awready_i <= 1;	
									s_axi_wready_i	<= 0;
									wr_data_cmplt	<= 1;
									s_axi_wdata_i	<= s_axi_wdata;
								end	
							end									
		endcase
		end


	always @(posedge s_axi_aclk)
	begin
		if (wr_data_cmplt == 1)
			case(s_axi_awaddr_i)
				32'h0: ctrl_reg <= s_axi_wdata_i;
				32'h1: mode_reg <= s_axi_wdata_i;
			endcase		
		else 
			s_axi_wdata_i <= 0;
	end
	
	assign m_axi_rdata = s_axi_rdata_i;
	assign reset 	= ctrl_reg[0];
	assign data_en 	= ctrl_reg[1];
	assign m_axi_rresp = s_axi_rresp_i;
	assign m_axi_bresp = s_axi_rresp_i;
	
	assign m_axi_bvalid = wr_data_cmplt;
	assign m_axi_rvalid = s_axi_rvalid_i;
	assign m_axi_awready = s_axi_awready_i;
	assign m_axi_wready = s_axi_wready_i;
	assign m_axi_arready = s_axi_arready_i;
endmodule
