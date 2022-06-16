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
	 $display("READ TESTCASE SELECTED");
       end

	//testcase-02
       else if($test$plusargs("ei_axi4_WRITE_TEST")) begin
	 ei_axi4_wr_test_c write_test;
         write_test = new(vif);
	 write_test.build();
	 write_test.start();
	 $display("WRITE TESTCASE SELECTED");
       end
	   
	//testcase-03
       else if($test$plusargs("ei_axi4_SANITY_TEST")) begin
	 ei_axi4_sanity_test_c sanity_test;
         sanity_test = new(vif);
	 sanity_test.build();
	 sanity_test.start();
	 $display("SANITY TESTCASE SELECTED");
       end      
	   
	//testcase-04
       else if($test$plusargs("ei_axi4_RRANDOM_TEST")) begin
	 ei_axi4_random_test_c random_test;
         random_test = new(vif);
	 random_test.build();
	 random_test.start();
	 $display("RANDOM WR_RD TESTCASE SELECTED");
       end
	   
     
       else begin
         $display("\n----------PLEASE ENTER A TESTNAME TO PROCEED------------");
       end
     endtask

 endclass
