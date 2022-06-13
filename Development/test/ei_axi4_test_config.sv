<<<<<<< HEAD
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
`include "/home/jaspal.singh/systemverilog/sv_project/AXI_VIP/Development/src/ei_axi4_macros.sv"
`include "/home/jaspal.singh/systemverilog/sv_project/AXI_VIP/Development/src/ei_axi4_transaction.sv"
//declaring enum for transfer type, address type and burst type
//typedef enum {WR_RD, SEQ_WR_RD, PRLL_WR_RD, RANDOM} transfer_type_e;
//typedef enum {ALIGNED, UNALIGNED} addr_type_e;
//typedef enum {FIXED, INCR, WRAP, RESERVE} burst_type_e;

//parameterized test_config class
class ei_axi4_test_config_c ;

	rand int unsigned total_num_trans;		//to count total number of transaction
	
	rand bit [2:0] transfer_size;			//size of trasnfer
	rand bit [7:0] transaction_length;		//length of transaction
    rand transfer_type_e transfer_type;		//type of transfer
	rand addr_type_e     addr_type;			//align, unaligned
    rand burst_type_e    burst_type;		//fixed, incr, wrap, reserve
	
	/***
	//   Method name          : post_randomize()								  	
	//   Parameters passed    : none       										  
	//   Returned parameters  : None											  
	//   Description          : take command line argument                        
	***/
	function void post_randomize();
	   if($value$plusargs("size=%0d", transfer_size));
		else begin
		  $fatal("invalid input");
		end
		
		if($value$plusargs("length=%0d", transaction_length));
		else begin
		  $fatal("invalid input");
		end
	    
		if($value$plusargs("transfer_type=%0s", transfer_type));
		else begin
		  $fatal("invalid input");
		end
	    
		if($value$plusargs("burst_type=%0s", burst_type));
		else begin
		  $fatal("invalid input");
		end
	    
		if($value$plusargs("addr_type=%0s", addr_type));
		else begin
		  $fatal("invalid input");
		end
	endfunction
	
endclass :ei_axi4_test_config_c


//testcases
class ei_axi4_sanity_test_c extends ei_axi4_transaction_c;
	
	ei_axi4_test_config_c test_cfg;
	
	/***
	//   Method name          : new()											  	
	//   Parameters passed    : none       										  
	//   Returned parameters  : None											  
	//   Description          : creating object of test_config class              
	***/
	function new();
		test_cfg = new();
	endfunction 
	
    /***
	//   Method name          : pre_randomize()									  	
	//   Parameters passed    : none       										  
	//   Returned parameters  : None											  
	//   Description          : randomize the config class every time during test 
	**/
	function void pre_randomize();
		test_cfg.randomize();
		transaction_type = !transaction_type //write..read...write..read...
		if(transaction_type == read)begin
			rand_mode(0);
			wdata.delete();
		end
		else if(test_cfg.addr_type == aligned)begin
			align_address.constraint_mode(1);
			unaligned_address.constraint_mode(0);
			default_address.constraint_mode(0);
		end
	    else if(test_cfg.addr_type == unaligned)begin
			align_address.constraint_mode(0);
			unaligned_address.constraint_mode(1);
			default_address.constraint_mode(0);
		end
		else begin
			align_address.constraint_mode(0);
			unaligned_address.constraint_mode(0);
			default_address.constraint_mode(1);
		end
	endfunction
	
	/***
	//   Method name          : post_randomize()								  
	//   Parameters passed    : none       										  
	//   Returned parameters  : None											  
	//   Description          : assign the value of config class into base class  
	***/
	function void post_randomize();
		this.burst_type         = test_cfg.burst_type;
		this.transfer_type      = test_cfg.transfer_type;
		this.transfer_size      = test_cfg.transfer_size;
		this.transaction_length = test_cfg.transaction_length;
	endfunction
	
endclass : ei_axi4_sanity_test_c
=======

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
//typedef enum {WR_RD, SEQ_WR_RD, PRLL_WR_RD, RANDOM} transfer_type_e;
//typedef enum {ALIGNED, UNALIGNED} addr_type_e;
//typedef enum {FIXED, INCR, WRAP, RESERVE} burst_type_e;

//parameterized test_config class

class ei_axi4_test_config_c ;

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
	
	string testname;					//for identification testcase
	
    task display();
        $display("=======================================");
        $display("== TESTNAME : %20s ===",testname);
        $display("=======================================");
    endtask

endclass :ei_axi4_test_config_c


//testcases
class ei_axi4_sanity_test_c extends ei_axi4_test_config_c;
	
	/***
	//   Method name          : new()											  	
	//   Parameters passed    : none       										  
	//   Returned parameters  : None											  
	//   Description          : take command line argument for size and length    
	***/
    function new();
        if($value$plusargs("size=%d", transfer_size))begin
            $display("transfer size = %d", transfer_size);
        end
		else begin
		  $fatal("invalid input");
		end
		
        if($value$plusargs("length=%0d", transaction_length))begin
            $display("transfer length = %0d", transaction_length);
        end
		else begin
		  $fatal("invalid input");
		end
		
		random_burst_type   = 1;			//fixed,incr,wrap
		random_address_type = 1;		    //aligned, unaligned
		total_num_trans     = 2;			//num of transactions
        transfer_type       = WR_RD;
		testname   		    = "ei_axi4_SANITY_TEST";
	endfunction

endclass : ei_axi4_sanity_test_c
>>>>>>> 0deee2096ed89583bc60a20244fc304c951bb24c
