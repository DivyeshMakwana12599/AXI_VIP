/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_transaction.sv
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

class ei_axi4_transaction_c#(DATA_WIDTH = `DATA_WIDTH , ADDR_WIDTH = `ADDR_WIDTH);

  localparam DATA_BUS_BYTES = DATA_WIDTH / 8;

	
	//-------Signal write read-------

	rand transaction_type_e transaction_type;

	//-------Read and write Address Channel------- 		
	randc bit [ADDR_WIDTH - 1:0]    addr;
	randc burst_type_e	            burst;
	randc bit [7:0]  		        len;
	randc bit [2:0]  		        size;

	
	//-------Read Data Channel-------
	rand bit [DATA_WIDTH-1:0]       data[];
	response_e                      rresp[];
	bit [DATA_BUS_BYTES - 1:0]      wstrb[];


	//-------Write Response Channel-------
	response_e                      bresp;

  rand possible_errors_e errors;


	constraint error_ct {
		errors dist {{ERROR_4K_BOUNDARY, 
		ERROR_WRAP_UNALLIGNED, 
		ERROR_WRAP_LEN, 
		ERROR_FIXED_LEN, 
		ERROR_EARLY_TERMINATION} :/ 1, 
		NO_ERROR :/ 999};
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
		((2 ** size) <= DATA_BUS_BYTES );
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

    function void print();



        $display("----------------------------------------");
        $display("             TRANSACTION_TYPE           ");
        $display("----------------------------------------");

        $write("Transaction_type = %0s",transaction_type.name);



        $display("----------------------------------------");
        $display("             ERROR_TYPE                 ");
        $display("----------------------------------------");
      
        $display("errors = %0s", errors.name);



        $display("----------------------------------------");
        $display("             ADDRESS SIGNALS            ");
        $display("----------------------------------------");

        $display("addr = %0h", addr);
        $display("len = %0d", len);
        $display("size = %0d", size);
        $display("burst = %0s", burst.name);



        $display("----------------------------------------"); 
        $display("               DATA SIGNALS             ");
        $display("----------------------------------------");
        
        foreach(data[i]) begin
            $display("data[%0d] = %h", i, data[i]);
        end

        if(transaction_type inside {WRITE, READ_WRITE}) begin
        	foreach(wstrb[i]) begin
            		$display("wstrb[%0d] = \t %b",i, wstrb[i]);
        	end
      end 


        $display("----------------------------------------"); 
        $display("           RESPONSE SIGNALS             ");
        $display("----------------------------------------");
 
        if(transaction_type inside {READ, READ_WRITE}) begin
            foreach(rresp[i]) begin
                $display("rresp[%0d] = %0s", i,  rresp[i].name);
            end
        end
        if(transaction_type inside {WRITE, READ_WRITE}) begin
            $display("bresp = %0s", bresp.name);
        end


    endfunction : print

	function ei_axi4_transaction_c copy(ei_axi4_transaction_c trans = null);
    if(trans == null) begin
      copy = new();
    end
    else begin
      $cast(copy, trans);
    end
    copy = new this;
	endfunction : copy

  function bit compare(ei_axi4_transaction_c trans);
    if(burst == FIXED) begin
      return(
        this.data[$size(data) - 1] == trans.data[$size(trans.data) - 1] && 
        this.data.size() == trans.data.size() &&
        this.len == trans.len &&
        this.addr == trans.addr &&
        this.burst == trans.burst &&
        this.size == trans.size &&
        this.rresp == trans.rresp
      );
    end
    else begin
      return(
        this.data == trans.data &&
        this.len == trans.len &&
        this.addr == trans.addr &&
        this.burst == trans.burst &&
        this.size == trans.size &&
        this.rresp == trans.rresp
      );
    end
  endfunction
    

endclass : ei_axi4_transaction_c

