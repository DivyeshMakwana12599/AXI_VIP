/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_random_test.sv
Title         : testcase_04 for VIP testcases
Project       : AMBA AXI-4 SV VIP
Created On    : 20-June-22
Developers    : Jaspal Singh
E-mail        : Jaspal.Singh@einfochips.com
Purpose       : To test the design functionality
          
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

class ei_axi4_random_test_c extends ei_axi4_base_test_c;

  ei_axi4_read_transaction_c rd_trans;
  ei_axi4_write_transaction_c wr_trans;
  ei_axi4_test_config_c test_cfg;
  
  /***
  //   Method name          : new()                 
  //   Parameters passed    : master, monitor  and slave interface                
  //   Returned parameters  : None                        
  //   Description          : constructor       
  ***/
  function new(virtual `MST_INTF mst_vif, virtual `SLV_INTF slv_vif, virtual `MON_INTF mon_vif);
    super.new(mst_vif, slv_vif, mon_vif);
    test_cfg = new();
  endfunction
  
  /***
  //   Method name          : build()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : randomize test config      
  ***/
  task build();
    `SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
  endtask
  
  /***
  //   Method name          : start()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : main task   
  ***/
  task start();
    super.run();  //calling run task of base class
    for(int i = 0; i < test_cfg.total_num_trans; i++) begin
      wr_trans = new();
      rd_trans = new(); 
          
      //randomly select write or read transaction
      randsequence(main)
        main  : write | read; 
        write : {env.mst_agt.mst_gen.start(wr_trans);}; //passing write transaction
        read  : {env.mst_agt.mst_gen.start(rd_trans);}; //passing read transaction
      endsequence
      wait(env.mst_agt.mst_mon.no_of_trans_monitored == i + 1); //wait for transaction to complete
    end
  endtask


  /***
  //   Method name          : wrap_up()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : wrap up task   
  ***/
   task wrap_up();
     super.wrap_up(); //calling wrap_up task of base class
     $display("RANDOM TESTCASE SELECTED");
   endtask
  
endclass :ei_axi4_random_test_c



