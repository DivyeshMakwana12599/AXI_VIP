/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_top.sv
Title 		: Top Module
Project 	: AMBA AXI-4 SV VIP
Created On      : 03-June-22
Developers      : Shivam Prasad
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

`include "ei_axi4_include_all.sv" 

`define PERIOD 5
`define VERBOSITY LOW                      // `"`VERBOSITY`"
`define ASSERTION ON
`define COVERAGE ON
`define BUS_WIDTH 32
`define AXI_VERSION AXI4

`define SV_RAND_CHECK(r) \
	do begin \
		if ((r)) begin \
			$display("%s:%0d: Randomization passed %b", \
			`__FILE__, `__LINE__, r); \
		end \
end while (0)
         
module ei_axi4_top;

  bit aclk;
  bit aresetn;
  bit dummy;
  
  ei_axi4_interface_c pif(.aclk(aclk),.aresetn(aresetn));
  ei_axi4_test_config_c test(pif);
  ei_axi4_test_config_c cfg_t;
  
  always #PERIOD aclk =~aclk;
  
  initial begin 
    ARESETn = 1;   
  end
  
  initial begin
      dummy = $value$plusargs("testname=%s", cfg_t.testname);
	  test = new(pif);
    end
  
  initial begin
  
	$dumpfile("dumpfile.vcd");
	$dumpvars;
  end
  
endmodule : ei_axi_top