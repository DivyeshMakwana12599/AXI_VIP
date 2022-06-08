
/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name 		: ei_axi4_test_config.sv
Title 			: Configuration file for VIP testcases
Project 		: AMBA AXI-4 SV VIP
Created On  	: 05-June-22
Developers  	: Jaspal Singh
E-mail          : jaspal.singh@einfochips.com
Purpose 		: Configuration file for VIP Environment
 
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


//declaring enum for transfer type, address type and burst type
typedef enum bit[1:0] {READ, WRITE, WRITE_READ, READ_WRITE) transfer_type_e;
typedef enum {aligned, unaligned} addr_type_e;
typedef enum {FIXED, INCR, WRAP, RESERVE} burst_type_e;

//parameterized test_config class
class ei_axi4_test_config_c #(int BUS_WIDTH =`BUS_WIDTH);

	int total_num_trans;				//to count total number of transaction
	int passed_trans;					//count passed transaction
	int failed_trans;					//count failed transaction
	
	bit [2:0] transfer_size;			//size of trasnfer
	bit [7:0] transaction_length;		//length of transaction
    transfer_type_e transfer_type;		//type of transfer
	addr_type_e     addr_type;			//align, unaligned
    burst_type_e    burst_type;			//fixed, incr, wrap, reserve
	
	bit random_transfer_size;			//1 = enable randomization, 0 =  disable rand mode
	bit random_transaction_length;		
	bit random_burst_type;
	bit random_address_type;
	
	string testname;					//to take testname as argument
	
endclass :ei_axi4_test_config_c


//testcases
class ei_axi4_sanity_test extends ei_axi4_test_config_c;
	
	//constructor
	function new();
		if($value$plusargs("size=%0d", transfer_size);
			else
			  $fatal("invalid input");
		if($value$plusargs("size=%0d", transaction_length);
			else
			  $fatal("invalid input");
	
		burst_type 		= FIXED;		//assign burst type
		addr_type  		= aligned;		//aligned, unaligned
		total_num_trans = 2;			//num of transactions
		testname   		= "ei_axi4_SANITY_TEST";
	endfunction 

endclass : ei_axi4_sanity_test_c
