/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_sanity_test.sv
Title         : testcase_03 for VIP testcases
Project       : AMBA AXI-4 SV VIP
Created On    : 16-June-22
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


//======== testcase: 03 =========================== SANITY TEST i.e [wr_fol_rd test] ====================//

class ei_axi4_sanity_test_c extends ei_axi4_base_test_c;

  ei_axi4_read_transaction_c rd_trans;
  ei_axi4_write_transaction_c wr_trans;
  ei_axi4_test_config_c test_cfg;
  
    
  /***
  //   Method name          : new()                 
  //   Parameters passed    : master and slave interface                
  //   Returned parameters  : None                        
  //   Description          : constructor       
  ***/
  function new(virtual `MST_INTF mst_vif, virtual `SLV_INTF slv_vif, virtual `MON_INTF mon_vif);
    super.new(mst_vif, slv_vif, mon_vif);
    test_cfg = new();
  endfunction
  
  
  /***
  //   Method name          : new()                 
  //   Parameters passed    : none               
  //   Returned parameters  : None                        
  //   Description          : randomize test_config class     
  ***/
  task build();
    `SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
  endtask
  
  
  /***
  //   Method name          : start()                 
  //   Parameters passed    : none               
  //   Returned parameters  : None                        
  //   Description          : passing write and read testcase handle to generator start method      
  ***/
  task start();
    super.run();
    for(int i = 0; i < test_cfg.total_num_trans; i++) begin
      if(i%2 == 0)begin
        wr_trans = new();
        env.mst_agt.mst_gen.start(wr_trans); 
      end
      else begin
        rd_trans = new();
        rd_trans.addr.rand_mode(0);
        rd_trans.burst.rand_mode(0);
        rd_trans.len.rand_mode(0);
        rd_trans.size.rand_mode(0);
        rd_trans.transaction_type = READ;
        rd_trans.addr  = wr_trans.addr; 
        rd_trans.burst = wr_trans.burst;  
        rd_trans.len   = wr_trans.len;  
        rd_trans.size  = wr_trans.size;
        rd_trans.specific_burst_type.constraint_mode(0);
        rd_trans.addr_type_c.constraint_mode(0);
        rd_trans.specific_transaction_length.constraint_mode(0);
        rd_trans.specific_transfer_size.constraint_mode(0);
        env.mst_agt.mst_gen.start(rd_trans);
      end
      wait(env.mst_agt.mst_mon.no_of_trans_monitored == i + 1);
    end
  endtask
    
    
  /***
  //   Method name          : new()                 
  //   Parameters passed    : master and slave interface                
  //   Returned parameters  : None                        
  //   Description          : constructor       
  ***/    
  task wrap_up();
    $display("SANITY TEST SELECTED");
    super.wrap_up();
  endtask
  
endclass :ei_axi4_sanity_test_c

