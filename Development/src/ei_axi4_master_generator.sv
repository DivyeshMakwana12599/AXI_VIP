/*--------------------------------------------------------------------------------
----------------------------------------------------------------------------------
File name 		: ei_axi4_generator_c.sv
Title 			: Generator file for VIP testcases
Project 		: AMBA AXI-4 SV VIP
Created On  	: 06-June-22
Developers  	: Jaspal Singh
E-mail          : jaspal.singh@einfochips.com
Purpose 		: Generator file for VIP Environment
 
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

class ei_axi4_mst_generator_c;
  
  ei_axi4_transaction_c tr, temp1, temp2;
  mailbox #(ei_axi4_transaction_c) gen2drv;
 
  ei_axi4_test_config_c cfg_t;
  
  bit [2:0]  transfer_size;			//size of trasnfer
  bit [7:0]  transaction_length;
  bit toggle_wr_rd;
	
  extern function new(mailbox #(ei_axi4_transaction_c) gen2drv, ei_axi4_test_config_c cfg_t);
  extern task run();
  
endclass :ei_axi4_mst_generator_c
          
		  
	////////////////////////////////////////////////////////////////////////////////
	//   Method name          : new()											  //	
	//   Parameters passed    : mailbox and test_config							  //
	//   Returned parameters  : None											  //
	//   Description          : take argument from environment class 			  //
	////////////////////////////////////////////////////////////////////////////////
  function ei_axi4_generator_c::new(mailbox #(ei_axi4_transaction_c) gen2drv, ei_axi4_test_config_c cfg_t);
	tr 						= new();
	this.gen2drv            = gen2drv;
    this.cfg_t              = cfg_t;
    this.transfer_size 		= cfg_t.transfer_size;
    this.transaction_length = cfg_t.transaction_length;
  endfunction
          
	////////////////////////////////////////////////////////////////////////////////
	//   Method name          : run()											  //	
	//   Parameters passed    : none                							  //
	//   Returned parameters  : None											  //
	//   Description          : to generate packet as per testcase requirement    //
	////////////////////////////////////////////////////////////////////////////////		    
  task ei_axi4_generator_c::run();
    begin
      $display("%t, GEN::RUN PHASE", $time);
      repeat(cfg.total_num_trans)begin
            
      case(cfg_t.transfer_type)
			WR_RD :
               begin
				    if(!tr.randomize() with {
						(cfg_t.random_burst_type         == 1'b0)  -> (tr.burst == cfg_t.burst_type);
						(cfg_t.random_transfer_size      == 1'b0)  -> (tr.size  == cfg_t.transfer_size);
						(cfg_t.random_transaction_length == 1'b0)  -> (tr.len   == cfg_t.transaction_length);
						(cfg_t.random_address_type       == 1'b0)  -> (tr.addr  == cfg_t.addr_type);
						tr.transaction_type              == ~toggle_wr_rd;
					})begin
					  $fatal("Randomization Failed");
					  end
						if(tr.transaction_type == WRITE)begin
							temp1 = new tr;
							gen2drv.put(temp1);
							end
						
						if(tr.transaction_type == READ)begin
						   	temp2 = new temp1;
					        temp2.wdata.delete();
							gen2drv.put(temp2);
							end
				end
        endcase
        end
      end
  endtask :run
