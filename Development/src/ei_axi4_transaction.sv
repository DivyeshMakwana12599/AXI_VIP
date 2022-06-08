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

typedef enum bit [1:0] {FIXED, INCR, WRAP, RESERVED} BURST_TYPE_e;
typedef enum bit [1:0] {OKAY, EXOKAY, SLVERR, DECERR} RESPONSE_e;
typedef enum bit [1:0] {READ, WRITE, READ_WRITE} TRANSACTION_TYPE_e;
typedef enum bit {NO_ERROR, ERROR} ERROR_e;

class ei_axi4_transaction_c#(BUS_WIDTH = `BUS_WIDTH);

  localparam BUS_BYTE_LANES = BUS_WIDTH / 8;

	


	//-------Signal write read-------

	rand TRANSACTION_TYPE_e transaction_type;

	//-------Read Address Channel------- 		
	randc bit [31:0] 		araddr;
	randc BURST_TYPE_e	    arburst;
	randc bit [7:0]  		arlen;
	randc bit [2:0]  		arsize;
	bit        			    arvalid;
	bit        			 	arready;
	
	//-------Read Data Channel-------
	bit [BUS_WIDTH-1:0] rdata[];
	RESPONSE_e          rresp[];
	bit                 rlast;
	bit                 rvalid;
	bit                 rready;

  //-------Write Address Channel-------
	randc bit awaddr;
	randc bit [7:0] awlen;
	randc bit [2:0] awsize;
	randc BURST_TYPE_e awburst;
    bit awvalid;
	bit awready;
	
	//-------Write Data Channel------- 
	rand bit [BUS_WIDTH - 1:0] wdata[];
	rand bit [BUS_BYTE_LANES - 1:0] wstrb[];
	bit wlast;	// FIXME: is wlast needed in transaction class, if so should it be array?
	bit wvalid;
	bit wready;

	//-------Write Response Channel-------
	RESPONSE_e bresp;
	bit bvalid;	
	bit bready;

	rand ERROR_e error_4k_boundary;
	rand ERROR_e error_wrap_unaligned;
	rand ERROR_e error_wrap_len;
	rand ERROR_e error_fixed_len;
	rand ERROR_e error_early_termination;

	constraint error_ct {
		error_4k_boundary dist { ERROR := 1, NO_ERROR := 999 };
		error_wrap_unalligned dist { ERROR := 1, NO_ERROR := 999 };
		error_wrap_len dist { ERROR := 1, NO_ERROR := 999 };
		error_fixed_len dist { ERROR := 1, NO_ERROR := 999 };
		error_early_termination dist { ERROR := 1, NO_ERROR := 999 };
	}

	constraint burst_type_ct {
		awburst inside {FIXED, INCR, WRAP};
		arburst inside {FIXED, INCR, WRAP};
	}

	constraint burst_wrap_len_ct {
		(awburst == WRAP) -> (awlen inside {1, 3, 7, 15});
		(arburst == WRAP) -> (arlen inside {1, 3, 7, 15});
	}

	constraint burst_fixed_len_ct {
		(awburst == FIXED) -> (awlen < 16);
		(arburst == FIXED) -> (arlen < 16);
	}

	constraint burst_wrap_aligned_addr_ct {
		(awburst == WRAP) -> ((awaddr % (2 ** awsize)) == 1'b0);
		(arburst == WRAP) -> ((araddr % (2 ** arsize)) == 1'b0);
	}

	constraint transfer_size_ct {
		(2 ** awsize) <= BUS_WIDTH;
		(2 ** arsize) <= BUS_WIDTH;
	}

	constraint boundary_4kb_ct {
		(((awaddr - (awaddr % (2 ** awsize))) % 4096) + ((awlen + 1) * (2 ** awsize))) <= 4096;
		(((araddr - (araddr % (2 ** arsize))) % 4096) + ((arlen + 1) * (2 ** arsize))) <= 4096;
	}

	constraint data_arr_size_ct {
		wdata.size() == awlen + 1;
	}

	function void post_randomize();
		wstrb = new[awlen + 1];
		for(int i = 0; i <= awlen; i++) begin
			wstrb[i] = get_wstrb(
				.awaddr(awaddr), 
				.awburst(awburst), 
				.awsize(awsize), 
				.awlen(awlen), 
				.beat_no(i)
			);
		end
	endfunction

	function void copy(ref ei_axi4_master_transaction trans);
		trans = new this;
	endfunction : copy

endclass : ei_axi4_transaction_c