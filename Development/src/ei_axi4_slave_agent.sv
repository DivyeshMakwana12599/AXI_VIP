/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_slave_agent.sv
Title 		: Slave Agent
Project 	: AMBA AXI-4 SV VIP
Created On  : 06-June-22
Developers  : Shivam Prasad
Purpose 	: Slave Agent contains Slave Driver, Slave Receive Monitor. It acts as AXI4 slave
 
Assumptions :
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
Revision	:0.1
-------------------------------------------------------------------------------
*/
class ei_axi4_slave_agent();

	virtual ei_axi4_interface vif;		//virtual interface
	ei_axi4_slave_driver s_drv;
    ei_axi4_slave_monitor s_mon;
	mailbox#(ei_axi4_transaction) mon2scb;
	ei_axi4_env_config env_cfg;
	
	function new( mailbox#(ei_axi4_transaction) mon2scb, ei_axi4_env_config env_cfg );
		s_drv = new();
		s_mon = new();
		this.mon2scb = mon2scb;
		this.env_cfg = env_Cfg;
		
	endfunction
	
	 function void build();

       if(env_cfg.slave_agent_active_passive_switch == ACTIVE) begin
            s_drv = new();
        end
        s_mon = new(mon2scb);
    endfunction  
	
	task run();
	
	endtask
	
	
endclass