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
class ei_axi4_slave_agent_c;

  virtual ei_axi4_interface vif;		//virtual interface
  ei_axi4_slave_driver_c slv_drv;
  ei_axi4_slave_monitor_c slv_mon;
  mailbox#(ei_axi4_transaction_c) slv_mon2scb;
  ei_axi4_env_config_c env_cfg;

  function new( mailbox#(ei_axi4_transaction_c) slv_mon2scb, ei_axi4_env_config_c env_cfg );
    this.slv_mon2scb = slv_mon2scb;
    this.env_cfg = env_Cfg;
    if(env_cfg.slave_agent_active_passive_switch == ACTIVE) begin
      slv_drv = new(.vif(vif));
    end
    slv_mon = new(.vif(vif),.slv_mon2scb(slv_mon2scb));
  endfunction
  
  task run();
      if(env_cfg.slave_agent_active_passive_switch == ACTIVE) begin
        fork 
          slv_drv.run();
          slv_mon.run();
        join
      end
      

  endtask
endclass
