/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_read_trans.sv
Title         : extended transaction class for write
Project       : AMBA AXI-4 SV VIP
Created On    : 20-June-22
Developers    : Jaspal Singh
E-mail        : Jaspal.Singh@einfochips.com
Purpose       : to seperate write and read related constraints or variables
          
Assumptions   : As per the Feature plan All the pins are not declared here
Limitations   : 
Known Errors  : 
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
Revision    : 0.1
------------------------------------------------------------------------------*/


class ei_axi4_read_transaction_c extends ei_axi4_transaction_c;

  ei_axi4_test_config_c test_cfg;
  
  /***
  //   Method name          : new()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : constructor     
  ***/
  function new();
    test_cfg = new();
  endfunction
  
  /***
  //   Method name          : pre_randomize()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : randomize test_config   
  ***/
  function void pre_randomize();
    `SV_RAND_CHECK(test_cfg.randomize());
  endfunction
  
  constraint addr_type_c {
    (test_cfg.addr_type) == ALIGNED -> ((addr % (1<<size)) == 1'b0);
    (test_cfg.addr_type) == UNALIGNED -> ((addr % (1<<size)) != 1'b0);
  }
  
  constraint specific_burst_type {
    (test_cfg.burst_type == burst); 
  }
  
  constraint specific_transaction_length {
    (test_cfg.transaction_length == len);
  }
  
  constraint specific_transfer_size {
    (test_cfg.transfer_size == size);
  }
  
  constraint transaction_type_read {
    transaction_type == READ;
  }
  
  function void post_randomize();
    super.post_randomize();
  endfunction
  
endclass :ei_axi4_read_transaction_c


