/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	    : ei_axi4_master_generator.sv
Title 			: Master Generator Class 
Project 		: AMBA AXI-4 SV VIP
Created On      : 03-June-22
Developers      : Meet Fichadia
Purpose 		: Generator class generates the stimulus and pass it to driver via mailbox 
 
Assumptions     :
Limitations     : 
Known Errors    : 
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
  
  ei_axi4_transaction_c tr;
  mailbox #(ei_axi4_transaction_c) gen2drv;
 
  ei_axi4_test_config_c cfg_t_t;
  
  bit [2:0]  transfer_size;			//size of trasnfer
  bit [7:0]  transaction_length;
  int        num_trans;
	
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
	this.gen2drv            = gen2drv;
    this.cfg_t              = cfg_t;
    this.transfer_size 		= cfg_t.transfer_size;
    this.transaction_length = cfg_t.transaction_length;
	this.num_trans          = cfg_t.total_num_trans;
  endfunction
          
	////////////////////////////////////////////////////////////////////////////////
	//   Method name          : run()											  //	
	//   Parameters passed    : none                							  //
	//   Returned parameters  : None											  //
	//   Description          : to generate packet as per testcase requirement    //
	////////////////////////////////////////////////////////////////////////////////		    
  task ei_axi4_generator_c::run();
    begin
      tr = new();////////
      $display("%t, TXGEN::RUN PHASE", $time);
      repeat(num_trans)begin
            
      case(cfg_t.transfer_type)
			WRITE :
               begin
				    if(!tr.randomize() with {
						(cfg_t.random_burst_type == 1'b0)         -> (tr.awburst == cfg_t.burst_type);
						(cfg_t.random_transfer_size == 1'b0)      -> (tr.awsize == cfg_t.transfer_size);
						(cfg_t.random_transaction_length == 1'b0) -> (tr.awlen == cfg_t.transaction_length);
						(cfg_t.random_address_type == 1'b0)       -> (tr.awaddr == cfg_t.addr_type);
					})begin
					  $fatal("Randomization Failed");
					  end
						tr.awvalid    = 1;
						tr.wvalid     = 1;
						gen2drv.put(tr);
				end
				
			 READ :
				begin
						tr.arvalid    = 1;
						tr.rvalid     = 1;
						tr.awvalid    = 0;
						tr.wvalid     = 0;
						gen2drv.put(tr);	
                end
        endcase
        end
      end
  endtask :run
    
         
                 
                 
              
          
          
          
          
  

/*
class ei_axi4_master_generator_c;
    ei_axi4_transaction_c tr;
    ei_axi4_transaction_c blueprint;
    ei_axi4_test_config t_cfg;

    mailbox gen2drv #(ei_axi4_transaction_c);

    function new(mailbox gen2drv #(ei_axi4_transaction_c));
    
        this.gen2drv = gen2drv
        t_cfg = new();
    
    endfunction : new

    task run();
        @(vif.MTR.master_cb);
        repeat(t_cfg.total_no_of_transaction) begin 
            tr = new();
            if(!tr.randomize()) begin // if 1 
                $display("Randomization Failed !!!!!");
            end // if 1

            else begin // else 1 
                tr.copy(blueprint)
                gen2drv.put(blueprint);
            end // else 1
        end // repeat
    
    endtask : run
endclass : ei_axi4_master_generator_c

*/