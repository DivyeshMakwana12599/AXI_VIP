/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name 		: ei_axi4_master_generator_c.sv
Title 			: generator file for VIP testcases
Project 		: AMBA AXI-4 SV VIP
Created On  	: 10-June-22
Developers  	: Jaspal Singh
E-mail          : Jaspal.Singh@einfochips.com
Purpose 		: Transaction Class randomize the properties of transaction class having 'rand' prefix keyword
			      and then it create a copy of randomized data, then put them into mailbox to transfer to driver
				  
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


class ei_axi4_master_generator_c;
	
  mailbox #(ei_axi4_transaction_c) gen2drv;  	//mailbox for transafer data from generator to driver
  ei_axi4_transaction_c trans;
  
    /***
	//   Method name          : new() i.e constructor							  	
	//   Parameters passed    : mailbox and test_config							  
	//   Returned parameters  : None											  
	//   Description          : take argument from environment class 			  
	***/
  function new(mailbox #(ei_axi4_transaction_c) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task start(ei_axi4_transaction_c trans);
     $display("[GEN] ==================== Randomizing ========================");
    `SV_RAND_CHECK(trans.randomize());
    trans.print();
    gen2drv.put(trans.copy());
  endtask

endclass :ei_axi4_master_generator_c;

