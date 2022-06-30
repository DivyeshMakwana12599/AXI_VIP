/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_test_c.sv
Title         : test file for VIP
Project       : AMBA AXI-4 SV VIP
Created On    : 10-June-22
Developers    : Jaspal Singh
E-mail        : Jaspal.Singh@einfochips.com
Purpose       : To take testname as command line argument and build the testcase then run them
          
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
 
 class ei_axi4_test_c;

     ei_axi4_base_test_c base_test;
	
     virtual `MST_INTF mst_vif;
     virtual `SLV_INTF slv_vif;
     virtual `MON_INTF mon_vif;
     
  /***
  //   Method name          : new()                 
  //   Parameters passed    : master and slave virtual interface                
  //   Returned parameters  : None                        
  //   Description          : constructor     
  ***/
     function new(virtual `MST_INTF mst_vif, virtual `SLV_INTF slv_vif, virtual `MON_INTF mon_vif);
        this.mst_vif = mst_vif;
        this.slv_vif = slv_vif;
	    this.mon_vif = mon_vif;
     endfunction

    
  /***
  //   Method name          : run()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : test class to take testname as argument, build, run,wrap up        
  ***/
     task run();
       //testcase-01
       if($test$plusargs("ei_axi4_READ_TEST")) begin
         ei_axi4_rd_test_c read_test;
         read_test = new(mst_vif,slv_vif,mon_vif);
         base_test = read_test;
       end

       //testcase-02
       else if($test$plusargs("ei_axi4_WRITE_TEST")) begin
         ei_axi4_wr_test_c write_test;
         write_test = new(mst_vif,slv_vif,mon_vif);
         base_test  = write_test;
       end
     
       //testcase-03
       else if($test$plusargs("ei_axi4_SANITY_TEST")) begin
         ei_axi4_sanity_test_c sanity_test;
         sanity_test = new(mst_vif,slv_vif,mon_vif);
         base_test = sanity_test;
         
       end      
     
       //testcase-04
       else if($test$plusargs("ei_axi4_RANDOM_TEST")) begin
         ei_axi4_random_test_c random_test;
         random_test = new(mst_vif,slv_vif,mon_vif);
         base_test   = random_test;
       end

       //testcase-05
       else if($test$plusargs("ei_axi4_SEQ_WR_RD_TEST")) begin
         ei_axi4_seq_wr_rd_test_c seq_wr_rd_test;
         seq_wr_rd_test = new(mst_vif,slv_vif,mon_vif);
         base_test      = seq_wr_rd_test;
       end

       //testcase-06
       else if($test$plusargs("ei_axi4_PARALLEL_WR_RD_TEST")) begin
         ei_axi4_parallel_wr_rd_test_c prll_wr_rd_test;
         prll_wr_rd_test = new(mst_vif,slv_vif,mon_vif);
         base_test       = prll_wr_rd_test;
       end

//============================================= ERRORNEOUS SCENARIO =========================================================//
       //testcase-07
       else if($test$plusargs("ei_axi4_4K_BOUNDARY_TEST")) begin
         ei_axi4_4k_boundary_test_c bndry_4k_test;
         bndry_4k_test = new(mst_vif,slv_vif,mon_vif);
         base_test = bndry_4k_test;
       end
       
       //testcase-08
       else if($test$plusargs("ei_axi4_ERROR_WRAP_UNALIGNED_TEST")) begin
         ei_axi4_error_wrap_unaligned_test_c err_wrp_unaligned_test;
         err_wrp_unaligned_test = new(mst_vif,slv_vif,mon_vif);
         base_test = err_wrp_unaligned_test;
       end

       //testcase-09
       else if($test$plusargs("ei_axi4_ERROR_FIXED_LEN_TEST")) begin
         ei_axi4_error_fixed_len_test_c  err_fixed_len_test;
         err_fixed_len_test = new(mst_vif,slv_vif,mon_vif);
         base_test = err_fixed_len_test;
       end

       //testcase-10
       else if($test$plusargs("ei_axi4_ERROR_WRAP_LEN_TEST")) begin
         ei_axi4_error_wrap_len_test_c  err_wrp_len_test;
         err_wrp_len_test = new(mst_vif,slv_vif,mon_vif);
         base_test = err_wrp_len_test;
       end

  
       //testcase-10
       else if($test$plusargs("ei_axi4_ERROR_EARLY_TERMINATION_TEST")) begin
         ei_axi4_error_early_termination_test_c  err_early_termination_test;
         err_early_termination_test = new(mst_vif,slv_vif,mon_vif);
         base_test = err_early_termination_test;
       end

        
       else begin
         $display("\n----------PLEASE ENTER A TESTNAME TO PROCEED------------");
       end
       base_test.build();
       base_test.start();
     endtask

    
  /***
  //   Method name          : wrap_up()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : to print summary      
  ***/
     task wrap_up();
        $display("TEST WRAP UP");
     	base_test.wrap_up();
     endtask : wrap_up


 endclass :ei_axi4_test_c

