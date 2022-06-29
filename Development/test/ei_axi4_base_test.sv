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

class ei_axi4_base_test_c;
	
    ei_axi4_environment_c env;
	ei_axi4_env_config_c env_cfg;

	virtual `MST_INTF mst_vif;
	virtual `SLV_INTF slv_vif;
  virtual `MON_INTF mon_vif;
	
  /***
  //   Method name          : new()                 
  //   Parameters passed    : master and slave interface               
  //   Returned parameters  : None                        
  //   Description          : constructor      
  ***/
	function new(
    virtual `MST_INTF mst_vif, 
    virtual `SLV_INTF slv_vif, 
    virtual `MON_INTF mon_vif
  );
		env_cfg      = new();
		this.mst_vif = mst_vif;
    this.slv_vif = slv_vif;
		env          = new(mst_vif, slv_vif, mon_vif,env_cfg);
    mst_vif.awvalid = 1'b1;
    slv_vif.awready = 1'b1;
	endfunction
	
  /***
  //   Method name          : run()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : to run the environment in background, fork join_none     
  ***/
	task run();
		fork
          env.run();
		join_none
	endtask 
	
  /***
  //   Method name          : start()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : random write read       
  ***/
    task wrap_up();
        env.wrap_up();
    endtask :wrap_up

endclass :ei_axi4_base_test_c
