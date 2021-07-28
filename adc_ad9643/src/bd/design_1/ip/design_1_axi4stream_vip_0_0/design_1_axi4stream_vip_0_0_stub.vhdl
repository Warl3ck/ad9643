-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Thu Jul 15 13:45:48 2021
-- Host        : DESKTOP-IAAFL3G running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               x:/Netlist/project_1/project_1.srcs/sources_1/bd/design_1/ip/design_1_axi4stream_vip_0_0/design_1_axi4stream_vip_0_0_stub.vhdl
-- Design      : design_1_axi4stream_vip_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tsbv484-2L
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_axi4stream_vip_0_0 is
  Port ( 
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tready : out STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end design_1_axi4stream_vip_0_0;

architecture stub of design_1_axi4stream_vip_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,aresetn,s_axis_tvalid[0:0],s_axis_tready[0:0],s_axis_tdata[31:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axi4stream_vip_v1_1_7_top,Vivado 2020.1";
begin
end;
