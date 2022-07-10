/*--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
File name     : ei_axi4_read_trans_c.sv
Title         : read_trans for VIP
Project       : AMBA AXI-4 SV VIP
Created On    : 10-June-22
Developers    : Jaspal Singh
E-mail        : Jaspal.Singh@einfochips.com
Purpose       : to extend the main transaction for read only and write constraints as per required by READ operation
          
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
  //   Method name          : pre_Randomize()                 
  //   Parameters passed    : none                
  //   Returned parameters  : None                        
  //   Description          : randomize test_config     
  ***/
  function void pre_randomize();
    `SV_RAND_CHECK(test_cfg.randomize());
  endfunction
  
  //------------------ writing constraint as per our requrement for read and as per protocol --------------------------//
  //for address type i.e if burst type  aligned then gen only aligned address else unaligned
  constraint addr_type_c {
      (test_cfg.addr_type) == ALIGNED -> ((addr % (1<<size)) == 1'b0);
      (test_cfg.addr_type) == UNALIGNED -> ((addr % (1<<size)) != 1'b0);
  }
  
  //for burst type
  constraint specific_burst_type {
    (test_cfg.burst_type == burst); 
  }
  
  //for transaction length
  constraint specific_transaction_length {
    (test_cfg.transaction_length == len);
  }
  
  //for transafer size
  constraint specific_transfer_size {
    (test_cfg.transfer_size == size);
  }
  
  //for transaction type
  constraint transaction_type_read {
    transaction_type == READ;
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
  
endclass :ei_axi4_read_transaction_c 


