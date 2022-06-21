/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name 		: ei_axi4_test_c.sv
Title 			: test file for VIP
Project 		: AMBA AXI-4 SV VIP
Created On  	: 10-June-22
Developers  	: Jaspal Singh
E-mail          : Jaspal.Singh@einfochips.com
Purpose 		: To build environment and take testname as command line argument
				  
Assumptions 	: As per the Feature plan All the pins are not declared here
Limitations 	: 
Known Errors	: 
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
Revision		: 0.1
------------------------------------------------------------------------------*/
 
 class ei_axi4_test_c;

     virtual ei_axi4_interface vif;
     function new(virtual ei_axi4_interface vif);
        this.vif = vif;
     endfunction

     task run();
        //testcase-01
       if($test$plusargs("ei_axi4_READ_TEST")) begin
         ei_axi4_rd_test_c read_test;
         read_test = new(vif);
         read_test.build();
         read_test.start();
	     read_test.wrap_up();
       end

	//testcase-02
       else if($test$plusargs("ei_axi4_WRITE_TEST")) begin
	     ei_axi4_wr_test_c write_test;
         write_test = new(vif);
	     write_test.build();
	     write_test.start();
	     write_test.wrap_up();
       end
	   
	//testcase-03
       else if($test$plusargs("ei_axi4_SANITY_TEST")) begin
	     ei_axi4_sanity_test_c sanity_test;
         sanity_test = new(vif);
	     sanity_test.build();
	     sanity_test.start();
	     sanity_test.wrap_up();
       end      
	   
	//testcase-04
       else if($test$plusargs("ei_axi4_RANDOM_TEST")) begin
	     ei_axi4_random_test_c random_test;
         random_test = new(vif);
	     random_test.build();
	     random_test.start();
	     random_test.wrap_up();
       end

    //testcase-05
       else if($test$plusargs("ei_axi4_SEQ_WR_RD_TEST")) begin
	     ei_axi4_seq_wr_rd_test_c seq_wr_rd_test;
         seq_wr_rd_test = new(vif);
	     seq_wr_rd_test.build();
	     seq_wr_rd_test.start();
	     seq_wr_rd_test.wrap_up();
       end

    //testcase-05
       else if($test$plusargs("ei_axi4_4KB_BOUNDARY_TEST")) begin
	     ei_axi4_4kb_boundary_test_c 4kb_bndry_test;
         4kb_bndry_test = new(vif);
	     4kb_bndry_test.build();
	     4kb_bndry_test.start();
	     4kb_bndry_test.wrap_up();
       end


	
       else begin
         $display("\n----------PLEASE ENTER A TESTNAME TO PROCEED------------");
       end
     endtask

 endclass
