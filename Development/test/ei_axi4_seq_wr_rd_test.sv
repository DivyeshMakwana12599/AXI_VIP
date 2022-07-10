/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_seq_wr_rd_test.sv
Title         : testcase_05 for VIP testcases
Project       : AMBA AXI-4 SV VIP
Created On    : 23-June-22
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

//======== testcase: 05 =========================== SEQUENTIAL WR_RD  TEST i.e [sequential write read] ===============================//
class ei_axi4_seq_wr_rd_test_c extends ei_axi4_base_test_c;

    ei_axi4_read_transaction_c rd_trans;
    ei_axi4_write_transaction_c wr_trans;
    ei_axi4_test_config_c test_cfg;
    bit [31:0] tmp_addr_arr[$];                            //to store address during write operation
    bit [1:0] tmp_burst_arr[$];
    bit [7:0] tmp_len_arr[$];
    bit [2:0] tmp_size_arr[$];


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
    int count_len;  //to count total len during each transaction
    int j;          //len = len +1 , i.e to count num the added vakue during each transaction in len
    int m,n;
    
    super.run();
    //write operation, if num of trans odd then it write ((num/2)+1) and remaining for read
    for(int i = test_cfg.total_num_trans/2; i < test_cfg.total_num_trans; i++) begin
        $display("-----------------------------> i = %0d ",i);
        wr_trans = new();
        env.mst_agt.mst_gen.start(wr_trans);
        tmp_addr_arr.push_front(wr_trans.addr);      //to store addresses
        tmp_burst_arr.push_front(wr_trans.burst);
        tmp_len_arr.push_front(wr_trans.len);
        tmp_size_arr.push_front(wr_trans.size);
        count_len = count_len + wr_trans.len;
        //j++;
        m++;
    end
    //wait till write operation is performed if total num trans is even number 
    if(test_cfg.total_num_trans % 2 == 0)begin
      wait(env.mst_agt.mst_mon.no_of_trans_monitored == test_cfg.total_num_trans/2);
    end
    //if odd then 
    else begin
      wait(env.mst_agt.mst_mon.no_of_trans_monitored == test_cfg.total_num_trans/2 + 1);
    end

    //performing read operation after write 
    for(int i = 0; i < test_cfg.total_num_trans/2; i++) begin
        rd_trans = new();
        rd_trans.addr.rand_mode(0); //disable randomization
        rd_trans.burst.rand_mode(0);
        rd_trans.len.rand_mode(0);
        rd_trans.size.rand_mode(0);
        rd_trans.specific_burst_type.constraint_mode(0); //disable constraint mode
        rd_trans.addr_type_c.constraint_mode(0);
        rd_trans.specific_transaction_length.constraint_mode(0);
        rd_trans.specific_transfer_size.constraint_mode(0);
          
        rd_trans.transaction_type = READ;              //assigning transaction type
        rd_trans.addr   = tmp_addr_arr.pop_back();     //to get data from same location 
        rd_trans.burst  = tmp_burst_arr.pop_back();    
        rd_trans.len    = tmp_len_arr.pop_back();
        rd_trans.size   = tmp_size_arr.pop_back();
        env.mst_agt.mst_gen.start(rd_trans);           //passing transaction
        n++;
    end
        m = m + n;
        wait(env.mst_agt.mst_mon.no_of_trans_monitored == m); //wait till transaction completes

  endtask

  /***
  //   Method name          : wrap_up()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : summary      
  ***/
    task wrap_up();
        super.wrap_up(); //calling wrap_up task of base class
        $display("SEQUENTIAL WRITE READ TASK SELECTED");
    endtask
  
endclass


