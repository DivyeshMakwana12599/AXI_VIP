/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_base_test.sv
Title         : base test for VIP testcases
Project       : AMBA AXI-4 SV VIP
Created On    : 15-June-22
Developers    : Jaspal Singh
E-mail        : Jaspal.Singh@einfochips.com
Purpose       : To build the environment and test functionality of design
          
Assumptions   : As per the Feature plan All the pins are not declared here
Limitations   : 
Known Errors  : 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2000-2022 eInfochips - All rights reserved
This software is authored by eInfochips and is eInfochips intellectual
property, including the copyrights in all countries in the world. This
software is provided under a license to use only with all other rights,
including ownership rights, being retained by eInfochips
This file may not be distributed, copied, or reproduced in any manner,
electronic or otherwise, without the express written consent of
eInfochips 
--------------------------------------------------------------------------------
Revision    : 0.1
------------------------------------------------------------------------------*/

virtual class ei_axi4_base_test_c;
	
    ei_axi4_environment_c env;
	ei_axi4_env_config_c env_cfg;

  /***
  //   Method name          : new()                 
  //   Parameters passed    : master and slave interface               
  //   Returned parameters  : None                        
  //   Description          : constructor      
  ***/
  function new(virtual `MST_INTF mst_vif, virtual `SLV_INTF slv_vif, virtual `MON_INTF mon_vif);
	env_cfg  = new();
	env      = new(mst_vif, slv_vif, mon_vif, env_cfg);
  endfunction
	
  /***
  //   Method name          : run()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : to run the environment in background, fork join_none     
  ***/
	virtual task run();
	  fork
        env.run();
      join_none
	endtask

    pure virtual task build();
    pure virtual task start();
	
  /***
  //   Method name          : start()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : calling environment wrap_up function       
  ***/
    virtual task wrap_up();
      env.wrap_up();
    endtask :wrap_up

endclass :ei_axi4_base_test_c
