/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_env_config.sv
Title 			: Configuration file for VIP Environment
Project 		: AMBA AXI-4 SV VIP
Created On  : 03-June-22
Developers  : Divyesh Makwana
Purpose 		: Configuration file for VIP Environment
 
Assumptions : As per the Feature plan All the pins are not declared here
Limitations : 
Known Errors: 
-------------------------------------------------------------------------
-------------------------------------------------------------------------
Copyright (c) 2000-2022 eInfochips - All rights reserved
This software is authored by eInfochips and is eInfochips intellectual
property, including the copyrights in all countries in the world. This
software is provided under a license to use only with all other rights,
including ownership rights, being retained by eInfochips
This file may not be distributed, copied, or reproduced in any manner,
electronic or otherwise, without the express written consent of
eInfochips 
-------------------------------------------------------------------------------
Revision:0.1
-------------------------------------------------------------------------------
*/

class ei_axi4_env_config_c;

  // The set the following properties to a value to configure the environment
  AGENT_TYPE_e master_agent_active_passive_switch;
  AGENT_TYPE_e slave_agent_active_passive_switch;

  // 0 (index) -> slave lower boundary
  // 1 (index) -> slave upper boundary
  bit [31:0] slave_address_range [2];

  enum bit {OFF, ON} checker_on_off_switch;

  // configuration for our project
  function new();
    master_agent_active_passive_switch = ACTIVE;
    slave_agent_active_passive_switch = ACTIVE;
    checker_on_off_switch = ON;

    slave_address_range[0] = 32'h0;
    slave_address_range[1] = 32'hffff_ffff_ffff_ffff;
  endfunction

endclass : ei_axi4_env_config_c
