`timescale 100ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2021 10:17:05
// Design Name: 
// Module Name: config_dsp_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "config_dsp_tb.vh";
`include "addr_map.vh";
`include "vip_inst.vh";
`include "tasks.vh";

module config_dsp_tb();
    // Wires (ports)
    bit clk_in;
    bit delay_clk_200M;
    bit reset;
    bit enable_sw;
    bit [1:0] select_sw;
    wire X4_ADC_SCLK;
    wire X4_ADC_CSB;
    wire X4_ADC_DIR;
    wire X4_ADC_PDWN;
    wire X4_ADC_SDIO;
    wire X4_ADC_SYNC;
    wire X5_ADC_CSB;
    wire X5_ADC_DIR;
    wire X5_ADC_PDWN;
    wire X5_ADC_SCLK;
    wire X5_ADC_SDIO;
    wire X5_ADC_SYNC;
    wire adc_or_in_p_0;
    wire adc_or_in_n_0;
    wire adc_or_in_p_1;
    wire adc_or_in_n_1;
    wire adc_ready_0;
    wire adc_ready_1;
    reg  ask_spi;
    bit  clk_adc_p;
    wire clk_adc_n;
    //
    bit	 clk_adc_p_2;
    wire clk_adc_n_2;
    bit clk_adc_p_i;
    wire clk_adc_n_i;
    reg select_i;
    wire select_clk_i;
    //
    wire dco_p_0;
    wire dco_n_0;
    wire dco_p_1;
    wire dco_n_1;
    wire [13:0] data_in_p_0;
    wire [13:0] data_in_n_0;
    wire [13:0] data_in_n_1;
    wire [13:0] data_in_p_1;
// Module instantiation
    dsn_wrapper DUT(.*);        // Main design

    ad9643_sim #(
        .PERIOD_250(PERIOD_250)
    ) ad9643_sim_0(    // ADC_0 model
        .sclk(X4_ADC_SCLK)
        ,.csb(X4_ADC_CSB)
        ,.pdwn(X4_ADC_PDWN)
        ,.sync(X4_ADC_SYNC)
        ,.sdio(X4_ADC_SDIO)
        ,.clk_p(clk_adc_p_i)
        ,.clk_n(clk_adc_n_i)
        ,.dco_p(dco_p_0)
        ,.dco_n(dco_n_0)
        ,.or_p(adc_or_in_p_0)
        ,.or_n(adc_or_in_n_0)
        ,.data_p(data_in_p_0)
        ,.data_n(data_in_n_0)
        ); 

    ad9643_sim #(
        .PERIOD_250(PERIOD_250)
    )  ad9643_sim_1(    // ADC_1 model
        .sclk(X5_ADC_SCLK)
        ,.csb(X5_ADC_CSB)
        ,.pdwn(X5_ADC_PDWN)
        ,.sync(X5_ADC_SYNC)
        ,.sdio(X5_ADC_SDIO)
        ,.clk_p(clk_adc_p_i)
        ,.clk_n(clk_adc_n_i)
        ,.dco_p(dco_p_1)
        ,.dco_n(dco_n_1)
        ,.or_p(adc_or_in_p_1)
        ,.or_n(adc_or_in_n_1)
        ,.data_p(data_in_p_1)
        ,.data_n(data_in_n_1)

        );    

// Events
event reset_complete;
event vip_init_complete;
event data_sent;
event dsp_ready;
// Clock_FPGA
always #(PERIOD_100/2) clk_in <= ~clk_in;
// Clock_FPGA
always #(PERIOD_200/2) delay_clk_200M <= ~delay_clk_200M;
// Clock_ADC
always #(PERIOD_250/2) clk_adc_p <= ~clk_adc_p;
assign clk_adc_n = ~clk_adc_p;
// Clock_ADC_2
always #(PERIOD_250) clk_adc_p_2 <= ~clk_adc_p_2;



// Reset
initial begin
    reset <= 1;
    #(reset_time);
    @(posedge clk_in);
    reset <= 0;
    -> reset_complete;
end;

// AXIS Master VIPs initialization
initial begin
    `axi_vip_init(conf_agent, config_dsp_tb.DUT.dsn_i.axi4stream_vip_config, master, AXI4STREAM)
    `axi_vip_init(slv_agent, config_dsp_tb.DUT.dsn_i.axi4stream_vip_dsp, slave, AXI4STREAM)
    `axi_vip_init(gpmc_agent, config_dsp_tb.DUT.dsn_i.axi_vip_0, master, AXI)
    -> vip_init_complete;
end 


   BUFGMUX #(
   )
   BUFGMUX_inst 
   (
      .O(clk_adc_p_i),   	// 1-bit output: Clock output
      .I0(clk_adc_p), 		// 1-bit input: Clock input (S=0)
      .I1(clk_adc_p_2), 	// 1-bit input: Clock input (S=1)
      .S(select_clk_i)    	// 1-bit input: Clock select
   );

assign select_clk_i = select_i;
assign clk_adc_n_i = ~clk_adc_p_i;

initial begin
	select_i <= 1'b0;
	#(7999.974);
	select_i <= 1'b1;
end


// Input data process
initial begin
    ask_spi <= 0;
    @(reset_complete);
    #(PERIOD_100*5);
    send_config(.block(spi), .start(0), .stop(3), .conf_word({ <<byte{SPI_WRITE, SPI_WLEN, ADC_SPI_GDIV, 8'h1}}));
    $display ("!---------------------------!");
    $display ("Datapack sent");
    $display ("!---------------------------!");
    #(PERIOD_100 * 10);
    @(config_dsp_tb.DUT.dsn_i.AXIS_SPI_AD9643_0.inst.x4_drvAD9643.adcSyncDelay == 0)
    $display("Got timeout!");
    #(PERIOD_100 * 10);
    @(posedge clk_in);
    ask_spi <= 1;
    @(posedge clk_in);
    ask_spi <= 0;
    #PERIOD_100;
    @(X4_ADC_SYNC == 1)
    -> data_sent;
end

// Config ADC Controllers
initial begin
    @(reset_complete);
    #150;
    axi4_word_write(.addr(ADC_0), .data(32'hFFFFFFF0));
//    #100;
//    axi4_word_write(.addr(ADC_0), .data(32'hFFFFFFFF));
    #50;
    axi4_word_write(.addr(ADC_1), .data(32'hFFFFFFF0));
    #50;
end 

// Output data process
axi4stream_monitor_transaction slv_mon_trans;
axi4stream_ready_gen ready_gen;
xil_axi4stream_data_beat out_tdata;
bit out_tlast;
int outFileID;

initial begin 
    outFileID = $fopen(OUTPUT_DATA_FILE, "w");
    @(reset_complete);
    #(PERIOD_100*30);
    ready_gen = slv_agent.driver.create_ready("ready_gen");
    ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_OSC);
    ready_gen.set_high_time(50);
    ready_gen.set_low_time(5);
    slv_agent.driver.send_tready(ready_gen);
    -> dsp_ready;
    forever begin
        slv_agent.monitor.item_collected_port.get(slv_mon_trans);
        out_tdata = slv_mon_trans.get_data_beat();
        out_tlast = slv_mon_trans.get_last;

        $fdisplay(outFileID, "%h", out_tdata[OUTPUT_WIDTH-1:0]);
        
        if (out_tlast) begin
            $fdisplay(outFileID,"#");
        end
    end
end

// Enable AXIS Switch 
    initial begin
        @(dsp_ready);
        #100;
        enable_sw = 1;
        select_sw = 2'b01;
    end

// STOP process
    initial begin
        @(data_sent);
        #1000;
        $fclose (outFileID);
        $stop;
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
event config_complete;
event read_config_complete;

// Signals
    bit [(CONF_WIDTH*CONF_LENGTH-1):0]   pixdet_conf_array   [0:CONF_NUMBER-1];
    bit[31:0] data_out;

    initial 
	begin
		ext_reset_300 = 0;
		#(reset_time);
        @(posedge clk_300);
		ext_reset_300 = 1;
	end

    assign dcm_locked_xdma_250 = 1;

// Start_en
    initial begin
        L2_time_delay_dly_cntr_val <= 0;
        #(reset_time);
        L2_time_delay_dly_cntr_val <= 1;
    end;
/*
// Config process
    initial begin
        @(posedge ext_reset_xdma_250);
        #150;
        axi4_file_write(.filename("binary_dma.mem"), .mem_length(MEM_LENGTH), .start_addr(DDR_Addr), .len(TA_LENGTH-1));	
        #50;
        axi4_word_write(.addr(DDR_Addr), .data(32'hFFFFFFFF));
        #50;
        axi4_word_write(.addr(DMA_Addr + XAXIDMA_CR_OFFSET), .data(XAXIDMA_CR_RESET_MASK));
        #50;
        axi4_word_read(.addr(DMA_Addr + XAXIDMA_CR_OFFSET), .data_out(data_out));
        #10;
        while (data_out & XAXIDMA_CR_RESET_MASK !=0) begin
            axi4_word_read(.addr(DMA_Addr + XAXIDMA_CR_OFFSET), .data_out(data_out));
            #10;
        end
        #10;
        axi4_word_read(.addr(DDR_Addr + 32'h4), .data_out(data_out));
        #10;
        axi4_word_write(.addr(DMA_Addr + XAXIDMA_CDESC_OFFSET), .data(data_out));
        #10;
        axi4_word_write(.addr(DMA_Addr + XAXIDMA_CR_OFFSET), .data(XAXIDMA_CR_RUNSTOP_MASK));
        #10;
        axi4_word_read(.addr(DMA_Addr + XAXIDMA_SR_OFFSET), .data_out(data_out));
        #10;
        while (data_out & XAXIDMA_HALTED_MASK !=0) begin
            axi4_word_read(.addr(DMA_Addr + XAXIDMA_SR_OFFSET), .data_out(data_out));
            #10;
        end
        axi4_word_read(.addr(DMA_Addr + XAXIDMA_CR_OFFSET), .data_out(data_out));
        #10;
        axi4_word_write(.addr(DMA_Addr + XAXIDMA_CR_OFFSET), .data(data_out | (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK)));
        #10;
        axi4_word_read(.addr(DDR_Addr + 32'h8), .data_out(data_out));
        #10;
        axi4_word_write(.addr(DMA_Addr + XAXIDMA_TDESC_OFFSET), .data(data_out));
    end 
*/
/*
// Input data process
    initial begin
        // @(posedge DUT.dsn_i.DSPsubsys.inp_switch_subsys.data_tready_in); 
        @(reset_complete);
        forever begin    
            #(PERIOD_250*5);
            send_file(.filename(INPUT_DATA_FILE), .start(INPUT_DATA_START), .stop(INPUT_DATA_STOP), .last_enable(0));
            $display ("Datapack sent");
            #PERIOD_250;
            -> data_sent;
        end
    end

// Interrupt acknowledge
    initial begin
        @(reset_complete);
        forever begin
            @(usr_irq_req_0);
            #50;
            usr_irq_ack_0 = 1;
            #(PERIOD_250);
            usr_irq_ack_0 = 0;
            #50;
            usr_irq_ack_0 = 1;
            #(PERIOD_250);
            usr_irq_ack_0 = 0;
        end
    end

/*
    // PT data process
    axi4stream_monitor_transaction pt_mon_trans;
    xil_axi4stream_data_byte InputData[4];
    bit mon_tlast;
    string filename = SEGM_TO_PIXDET_DATA_FILE;
    int fileID;

    initial begin 
        fileID = $fopen(filename, "w");
        @(posedge cfg_done_segm);
        #(PERIOD_250*5);
        forever begin
            pt_agent.monitor.item_collected_port.get(pt_mon_trans);
            pt_mon_trans.get_data(InputData);
            mon_tlast =  pt_mon_trans.get_last;
            $fdisplay(fileID, "%h", {InputData[3], InputData[2], InputData[1], InputData[0]});
            
            if (mon_tlast) begin
                $fdisplay(fileID,"#");
            end
        end
    end
    
    // Output data process
    axi4stream_monitor_transaction slv_mon_trans;
    xil_axi4stream_data_beat out_tdata;
    bit out_tlast;
    int outFileID;
    
    initial begin 
        outFileID = $fopen(PIXDET_OUTPUT_DATA_FILE, "w");
        slv_agent = new("slave data vip agent", config_dsp_tb.DUT.dsn_i.out_vip.inst.IF);
        slv_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
        slv_agent.set_agent_tag("Slave VIP");
        slv_agent.set_verbosity(slv_agent_verbosity);
        slv_agent.start_monitor();
        @(posedge cfg_done_segm);
        #(PERIOD_250*5);
        forever begin
            slv_agent.monitor.item_collected_port.get(slv_mon_trans);
            out_tdata = slv_mon_trans.get_data_beat();
            out_tlast = slv_mon_trans.get_last;

            $fdisplay(outFileID, "%h", out_tdata[OUTPUT_WIDTH-1:0]);
            
            if (out_tlast) begin
                $fdisplay(outFileID,"#");
            end
        end
    end

    initial begin
        $monitor($time, " Value of dsp_done_pixdet is = %d", DUT.dsn_i.DSPsubsys.dsp_done_pixdet);
    end
*/

