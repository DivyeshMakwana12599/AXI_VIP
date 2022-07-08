/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_write_Trans_c.sv
Title         : write_trans for VIP
Project       : AMBA AXI-4 SV VIP
Created On    : 10-June-22
Developers    : Jaspal Singh
E-mail        : Jaspal.Singh@einfochips.com
Purpose       : extended write trans from main transaction class for write operation
          
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
 
class ei_axi4_write_transaction_c extends ei_axi4_transaction_c;

  ei_axi4_test_config_c test_cfg;                   //handle of test config
  
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
  //   Method name          : pre_Randomize()                 
  //   Parameters passed    : none               
  //   Returned parameters  : None                        
  //   Description          : randomizing test_config class
  ***/
  function void pre_randomize();
    `SV_RAND_CHECK(test_cfg.randomize());
  endfunction
  
  //------------------ constraints as per our requirements and protocol -----------------------------------------//
  //for aligned and unaligned addressing
  constraint addr_type_c {
    (test_cfg.addr_type) == ALIGNED -> ((addr %(1<< size)) == 1'b0);
    (test_cfg.addr_type) == UNALIGNED -> ((addr % (1<< size)) != 1'b0);
  }
  
  //burst type i.e fixed, wrap, incr and reserved
  constraint specific_burst_type_c {
    (test_cfg.burst_type == burst); 
  }
  
  //transaction length
  constraint specific_transaction_length {
    (test_cfg.transaction_length == len);
  }
  
  //transfer size
  constraint specific_transfer_size {
    (test_cfg.transfer_size == size);
  }
  
  //transaction type
  constraint transaction_type_read {
    transaction_type == WRITE;
  }
  
  /***
  //   Method name          : post_randomize()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : randomize main transaction class 
  ***/
  function void post_randomize();
    super.post_randomize();
  endfunction
  
endclass :ei_axi4_write_transaction_c 






 

