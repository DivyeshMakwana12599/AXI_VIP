/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_slave_driver.sv
Title 		: Slave Driver Class
Project 	: AMBA AXI-4 SV VIP
Created On  : 07-June-22
Developers  : Shivam Prasad
Purpose 	: Driver Class does handshaking and response for all channel 
			  parallely.
			  1. In write transaction, slave driver recives the 
			     data from interface and writes in driver memory,
			  2. In read trnsaction, driver will drive the (as per request
				 generated by master) from its own memory to interface. 
 
Assumptions : 
			  
Limitations : Interleving is not supported here.
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
Revision	: 0.1
-------------------------------------------------------------------------------
*/


class ei_axi4_slave_driver_c #(DATA_WIDTH = `DATA_WIDTH , ADDR_WIDTH = `ADDR_WIDTH);
  localparam BUS_BYTE_LANES = DATA_WIDTH / 8;
  bit [ DATA_WIDTH - 1 : 0] slv_drv_mem [bit [ADDR_WIDTH - 1:0]];;
  ei_axi4_transaction_c read_tr;
  ei_axi4_transaction_c write_tr;

  virtual ei_axi4_interface vif;

  function new(virtual ei_axi4_interface vif);
    this.vif  = vif;
    read_tr   = new();
    write_tr  = new();
  endfunction

  task run();

  endtask : run
endclass : ei_axi4_slave_driver_c
