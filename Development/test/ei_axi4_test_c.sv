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

class ei_axi4_test_c();
  virtual ei_axi4_interface vif;
  ei_axi4_environment env;
  ei_axi4_env_config_c env_cfg;
  ei_axi4_test_config_c test_cfg;

 
/**
/*   Method name          : new()
/*   Parameters passed    : physical interface
/*   Returned parameters  : None
/*   Description          : takes physical interface from top and links here
**/
  function new(ei_axi4_interface pif);
	this.vif    = pif;
	env_cfg     = new();
	
    if($test$plusargs("SANITY_TEST"))begin
      ei_axi4_sanity_test_c sanity_test;
      sanity_test = new();
      test_cfg    = sanity_test;
    end
    env = new(vif, env_cfg, test_cfg);
    env.vif  = pif;
    env.run();
  end

/**
/*   Method name          : env_build()
/*   Parameters passed    : None
/*   Returned parameters  : None
/*   Description          : Builds environment
**/
  task env_run();
    run_components;
  endtask : env_run
	
endclass : ei_axi4_test_c
