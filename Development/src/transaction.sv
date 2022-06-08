/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_master_transaction.sv
Title 			: Master Transaction Class
Project 		: AMBA AXI-4 SV VIP
Created On  : 03-June-22
Developers  : Meet Fichadia
Purpose 		: Transaction Class contains AXI pin description and declaration
 
Assumptions : As per the Feature plan All the pins are not declared here
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
Revision:0.1
-------------------------------------------------------------------------------
*/

import ei_axi4_helper_functions::*;

typedef enum bit [1:0] {FIXED, INCR, WRAP} burst_type_e;
typedef enum bit [1:0] {OKAY, EXOKAY, SLVERR, DECERR} response_e;
typedef enum bit [1:0] {READ, WRITE, READ_WRITE} transaction_type_e;
typedef enum bit [2:0] {NO_ERROR, ERROR_4K_BOUNDARY, ERROR_WRAP_UNALLIGNED, ERROR_WRAP_LEN, ERROR_FIXED_LEN, ERROR_EARLY_TERMINATION} possible_errors_e;

class ei_axi4_transaction_c#(DATA_WIDTH = `DATA_WIDTH , ADDR_WIDTH = `ADDR_WIDTH);

  localparam BUS_BYTE_LANES = DATA_WIDTH / 8;

	
	//-------Signal write read-------

	rand transaction_type_e transaction_type;

	//-------Read and write Address Channel------- 		
	randc bit [ADDR_WIDTH - 1:0] 		addr;
	randc burst_type_e	    burst;
	randc bit [7:0]  		len;
	randc bit [2:0]  		size;

	
	//-------Read Data Channel-------
	bit [DATA_WIDTH-1:0]           data[];
	response_e                      resp[];
	rand bit [BUS_BYTE_LANES - 1:0] wstrb[];


	//-------Write Response Channel-------
	response_e bresp;

    rand possible_errors_e errors;


	constraint error_ct {
		errors dist {{ERROR_4K_BOUNDARY, 
		ERROR_WRAP_UNALLIGNED, 
		ERROR_WRAP_LEN, 
		ERROR_FIXED_LEN, 
		ERROR_EARLY_TERMINATION} /= 1, 
		NO_ERROR /= 999};
	}

	constraint burst_type_ct {
		burst inside {FIXED, INCR, WRAP};
	}

	constraint burst_wrap_len_ct {
		(burst == WRAP) -> (len inside {1, 3, 7, 15});
	}

	constraint burst_fixed_len_ct {
		(burst == FIXED) -> (len < 16);
	}

	constraint burst_wrap_aligned_addr_ct {
		(burst == WRAP) -> ((addr % (2 ** size)) == 1'b0);
	}

	constraint transfer_size_ct {
		(2 ** size) <= DATA_WIDTH;
	}

	constraint boundary_4kb_ct {
		(((addr - (addr % (2 ** size))) % 4096) + ((len + 1) * (2 ** size))) <= 4096;
	}

	constraint data_arr_size_ct {
		data.size() == len + 1;
	}

	function void post_randomize();
		wstrb = new[len + 1];
		for(int i = 0; i <= len; i++) begin
			wstrb[i] = get_wstrb(
				.awaddr(addr), 
				.awburst(burst), 
				.awsize(size), 
				.awlen(len), 
				.beat_no(i)
			);
		end
	endfunction

	function void copy(ref ei_axi4_master_transaction trans);
		trans = new this;
	endfunction : copy

endclass : ei_axi4_transaction_c