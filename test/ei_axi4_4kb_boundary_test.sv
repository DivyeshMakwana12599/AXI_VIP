/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_4kb_boundary_test.sv
Title         : testcase_06 for VIP testcases
Project       : AMBA AXI-4 SV VIP
Created On    : 19-June-22
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


//======== testcase: 06 =========================== 4KB BOUNDARY TEST i.e [4kb boundary] ====================//
class ei_axi4_4k_boundary_test_c extends ei_axi4_base_test_c;

  ei_axi4_read_transaction_c rd_trans;
  ei_axi4_write_transaction_c wr_trans;
  ei_axi4_test_config_c test_cfg;
  
  function new(virtual ei_axi4_master_interface mst_vif, virtual ei_axi4_slave_interface slv_vif);
    super.new(mst_vif, slv_vif);
    test_cfg = new();
  endfunction
  
  task build();
    `SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
  endtask
  
  /***
  //   Method name          : start()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : random write read       
  ***/
  task start();
      super.run();

    for(int i = 0; i < test_cfg.total_num_trans; i++) begin
      wr_trans = new();
      rd_trans = new();

      wr_trans.errors.rand_mode(0);
      rd_trans.errors.rand_mode(0); 
      wr_trans.error_ct.constraint_mode(0);
      rd_trans.error_ct.constraint_mode(0);
      wr_trans.errors = ERROR_4K_BOUNDARY;
      rd_trans.errors = ERROR_4K_BOUNDARY;
    

      randsequence(main)
        main  : write | read;
        write : {env.mst_agt.mst_gen.start(wr_trans);};
        read  : {env.mst_agt.mst_gen.start(rd_trans);};
      endsequence

     $display(wr_trans.errors.name);
    end
  endtask

  /***
  //   Method name          : start()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : random write read       
  ***/
    task wrap_up();
         $display("4KB BOUNDARY TESTCASE SELECTED");
    endtask
  
endclass :ei_axi4_4k_boundary_test_c 
