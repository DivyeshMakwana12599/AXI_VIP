/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_top.sv
Title 		: Top Module
Project 	: AMBA AXI-4 SV VIP
Created On  : 03-June-22
Developers  : Shivam Prasad
Purpose 	: Top module binds interface and Testbench Layers
 
Assumptions :
Limitations : 
Known Errors: 
-------------------------------------------------------------------------
-------------------------------------------------------------------------
Copyright (c) 2000-2022 eInfochips - All rights reserved
This software is authored by eInfochips and is eInfochips intellectual
property, including the copyrights in all countries in the world. This
software is provided under a license to use only with all other rights,
including ownership rights, being retained by eInfochips
This file may not be distributed, copied, or reproduced in any manner,
electronic or otherwise, without the express written consent of
eInfochips 
-------------------------------------------------------------------------------
Revision	:0.1
-------------------------------------------------------------------------------
*/

`include "../src/ei_axi4_include_all.svh"      

module ei_axi4_top;

  bit aclk;
  bit aresetn;
  time dummy_time;
  
  ei_axi4_interface pif(.aclk(aclk),.aresetn(aresetn));
  ei_axi4_test_c test;
 // ei_axi4_test_config_c cfg_t;
 
  always #(`PERIOD) aclk = ~aclk;
  
  /* To initialize the variables */
  initial begin 
    aresetn  = 1;
  end
  
   /* To build */
  initial begin
  //  dummy    = $value$plusargs("testname=%s", cfg_t.testname);
    test  =  new(pif);
    test.run();
   end
   initial begin
     if($test$plusargs("RESET")) begin
        dummy_time = $urandom_range(0,200);
        #(dummy_time) aresetn = 0;
        @(posedge aclk);
        aresetn      = 1;
     end
   end
  initial begin
    $dumpfile("dumpfile.vcd");
    $dumpvars;
  end

  initial begin
    #1000 $finish;
  end
endmodule : ei_axi4_top
