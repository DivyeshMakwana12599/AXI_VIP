/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_environment.sv
Title 		: Environment
Project 	: AMBA AXI-4 SV VIP
Created On  : 07-June-22
Developers  : Shivam Prasad
Purpose 	: Environment class contains Slave agent, Master agent, Reference Model, checker and Scoreboard.
 
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

class ei_axi4_environment_c;

  ei_axi4_master_agent_c mst_agt;
  ei_axi4_slave_agent_c slv_agt;
  ei_axi4_reference_model_c ref_model;
  ei_axi4_scoreboard_c scb;
  ei_axi4_env_config_c env_cfg;

  mailbox#(ei_axi4_transaction_c) slv_mon2scb;
  mailbox#(ei_axi4_transaction_c) mst_mon2ref;
  mailbox#(ei_axi4_transaction_c) ref2scb;

  virtual `SLV_INTF slv_vif;
  virtual `MST_INTF mst_vif;
  virtual `MON_INTF mon_vif;


/**
*\   Method name          : new()
*\   arameters passed     : interface vif
*\   Returned parameters  : None
*\   Description          : links virtual interface,mailboxs and builds slave agent
*\                          components
**/
  function new(
    virtual `MST_INTF mst_vif, 
    virtual `SLV_INTF slv_vif, 
    virtual `MON_INTF mon_vif ,
    ei_axi4_env_config_c env_cfg
  );
    this.mst_vif = mst_vif;
    this.slv_vif = slv_vif;
    this.mon_vif = mon_vif;

    this.env_cfg = env_cfg;
  	mst_mon2ref       = new(); 
    slv_mon2scb       = new();	
    ref2scb           = new();
    ref_model         = new(.ref2scb(ref2scb),.mst_mon2ref(mst_mon2ref));
    scb               = new(.ref2scb(ref2scb),.slv_mon2scb(slv_mon2scb));
    mst_agt           = new(.mst_mon2ref(mst_mon2ref),.env_cfg(env_cfg),.mst_vif(mst_vif), .mon_vif(mon_vif));
    slv_agt           = new(.slv_mon2scb(slv_mon2scb),.env_cfg(env_cfg),.slv_vif(slv_vif), .mon_vif(mon_vif));
  endfunction

/**
*\   Method name          : run()
*\   Parameters passed    : None
*\   Returned parameters  : None
*\   Description          : runs environment components
**/	
  task run();
	
    fork
	  mst_agt.run();
	  slv_agt.run();
	  scb.run();
	  ref_model.run();
    join
  endtask : run
  
  task wrap_up();
    scb.wrap_up();
    mst_agt.wrap_up();
  endtask : wrap_up

endclass :ei_axi4_environment_c

