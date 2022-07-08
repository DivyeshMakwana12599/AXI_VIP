/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_parallel_wr_rd_test.sv
Title         : testcase_06 for VIP testcases
Project       : AMBA AXI-4 SV VIP
Created On    : 30-June-22
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


//======== testcase: 06 =========================== PARALLEL WRITE READ TEST i.e [parallel wr rd test] ====================//

class ei_axi4_parallel_wr_rd_test_c extends ei_axi4_base_test_c;

  ei_axi4_read_transaction_c rd_trans;
  ei_axi4_write_transaction_c wr_trans;
  ei_axi4_test_config_c test_cfg;
  
    
  /***
  //   Method name          : new()                 
  //   Parameters passed    : master, slave and monitor                
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
    super.run(); //calling run task of base test class
    for(int i = 0; i < test_cfg.total_num_trans; i++) begin
        //making first transaction of write type
        if(i == 0) begin
                wr_trans = new();
                env.mst_agt.mst_gen.start(wr_trans); 
        end
        //making last transaction of read type
        else if(i == test_cfg.total_num_trans - 1)begin
                rd_trans = new();
                rd_trans.addr.rand_mode(0);         //disable randomization 
                rd_trans.burst.rand_mode(0);
                rd_trans.len.rand_mode(0);
                rd_trans.size.rand_mode(0);
                rd_trans.transaction_type = READ;  //assign transaction type
                rd_trans.addr  = wr_trans.addr;    //assigning write transaction to read transaction properties
                rd_trans.burst = wr_trans.burst;  
                rd_trans.len   = wr_trans.len;  
                rd_trans.size  = wr_trans.size;
                rd_trans.specific_burst_type.constraint_mode(0); //disable constraints
                rd_trans.addr_type_c.constraint_mode(0);
                rd_trans.specific_transaction_length.constraint_mode(0);
                rd_trans.specific_transfer_size.constraint_mode(0);
                env.mst_agt.mst_gen.start(rd_trans);   //passing rd_trans tp generator
        end
        //in between making write read transaction
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
                wr_trans = new();
                env.mst_agt.mst_gen.start(wr_trans); 
        end
        if(i == 0 || i == test_cfg.total_num_trans - 1) begin
            wait(env.mst_agt.mst_mon.no_of_trans_monitored == i + 1); //wait to complete transaction
        end
        else begin
            wait(env.mst_agt.mst_mon.no_of_trans_monitored == i + 2);
        end
    end
  endtask
    
    
  /***
  //   Method name          : new()                 
  //   Parameters passed    : master and slave interface                
  //   Returned parameters  : None                        
  //   Description          : constructor       
  ***/    
  task wrap_up();
    $display("PARALLEL WRITE READ TEST SELECTED");
    super.wrap_up(); //calling wrap_up task of base test class
  endtask
  
endclass :ei_axi4_parallel_wr_rd_test_c

