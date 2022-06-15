
/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name 		: ei_axi4_test_config.sv
Title 			: Configuration file for VIP testcases
Project 		: AMBA AXI-4 SV VIP
Created On  	: 12-June-22
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

/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name 		: ei_axi4_test_config.sv
Title 			: Configuration file for VIP testcases
Project 		: AMBA AXI-4 SV VIP
Created On  	: 10-June-22
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
//typedef enum {WR_RD, SEQ_WR_RD, PRLL_WR_RD, RANDOM} transfer_type_e;
//typedef enum {ALIGNED, UNALIGNED} addr_type_e;
//typedef enum {FIXED, INCR, WRAP, RESERVE} burst_type_e;

//parameterized test_config class
class ei_axi4_test_config_c ;

	rand int unsigned total_num_trans;		//to count total number of transaction
	
	rand bit [2:0] transfer_size;			//size of trasnfer
	rand bit [7:0] transaction_length;		//length of transaction
	rand addr_type_e     addr_type;			//align, unaligned
  rand burst_type_e    burst_type;		//fixed, incr, wrap, reserve	
	
	//constraint reasonable {total_num_trans inside {[1:10]};}
  constraint reasonable {total_num_trans == 1;}
  constraint wrap_len_ct {
    (burst_type == WRAP) -> (transaction_length inside {1, 3, 7, 15});
  }

  constraint transfer_size_ct{
    (2 ** transfer_size) <= `BUS_BYTE_LANES;
  }
	
	////////////////////////////////////////////////////////////////////////////////
	//   Method name          : post_randomize()								                  //	
	//   Parameters passed    : none       										                    //
	//   Returned parameters  : None											                        //
	//   Description          : take command line argument                        //
	////////////////////////////////////////////////////////////////////////////////
	function new();
		if($value$plusargs("num_of_trans=%0d", total_num_trans)) begin
			total_num_trans.rand_mode(0);
		end
		else begin
			total_num_trans.rand_mode(1);
		end
		
		if($value$plusargs("size=%0d", transfer_size)) begin
			transfer_size.rand_mode(0);
		end
		else begin
			transfer_size.rand_mode(1);
		end
		
		if($value$plusargs("length=%0d", transaction_length)) begin
			transaction_length.rand_mode(0);
		end
		else begin
			transaction_length.rand_mode(1);
		end
	    
		if($value$plusargs("burst_type=%0s", burst_type)) begin
			burst_type.rand_mode(0);
		end
		else begin
			burst_type.rand_mode(1);
		end
	    
		if($value$plusargs("addr_type=%0s", addr_type)) begin
			addr_type.rand_mode(0);
		end
		else begin
			addr_type.rand_mode(1);
		end
	endfunction
	
endclass :ei_axi4_test_config_c


