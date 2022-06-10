/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_checker.sv
Title       : Checker for AXI 4 Protocol
Project     : AMBA AXI-4 SV VIP
Created On  : 06-June-22
Developers  : Divyesh Makwana
Purpose     : Checking the packet is Not violating the AXI 4 Protocol
 
Assumptions : 
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

class ei_axi4_checker_c;


  /**
  *\ function check
  *\ Note: checker function for AXI-4 Packet
  */
  function RESULT_e check(ei_axi4_transaction_c tr);
    if(tr.transaction_type == WRITE) begin
      if(!check_write_signals(tr)) begin
        return FAIL;
      end
    end
    else if(tr.transaction_type == READ) begin
      if(!check_read_signals(tr)) begin
        return FAIL;
      end
    end
    else if(tr.transaction_type == READ_WRITE) begin
      tr.transaction_type = WRITE;
      if(!check_write_signals(tr)) begin
        return FAIL;
      end
      if(!check_read_signals(tr)) begin
        return FAIL;
      end
    end
    tr.transaction_type = READ_WRITE;
    return PASS;
  endfunction

  /**
  *\ function check_write_signals
  *\ Note: checker function for write packet
  */
  protected function RESULT_e check_write_signals();
    bit [`BUS_BYTE_LANES - 1:0] golden_strb[];

    golden_strb = new[tr.len + 1];
    for(int i = 0; i <= tr.len; i++) begin
      golden_strb[i] = get_wstrb(tr.addr, tr.burst, tr.size, tr.len, i);
    end

    if(!check_common_signals()) begin
      return FAIL;
    end


    if(tr.wstrb == golden_strb) begin
      $error("[AXI4_CHECK_001] Approriate wstrb must be there for every transfer");
      return FAIL;
    end
    if(!(tr.bresp inside {OKAY, SLVERR})) begin
      $error("[AXI4_CHECK_001] bresp must be OKAY or SLVERR");
      return FAIL;
    end

    return PASS;
  endfunction

  /**
  *\ function check_read_signals
  *\ Note: checker function for read packet
  */
  protected function RESULT_e check_read_signals();

    if(!check_common_signals()) begin
      return FAIL;
    end

    foreach(tr.rresp[i]) begin
      if(!(tr.rresp[i] inside {OKAY, SLVERR})) begin
        $error("[AXI4_CHECK_001] rresp must be OKAY or SLVERR for every transfer");
        return FAIL;
      end
    end

    return PASS;
  endfunction

  /**
  *\ function check_read_signals
  *\ Note: checker function for all the common signals
  *\       of AXI-4 i.e., len, size, burst, addr
  */
  protected function RESULT_e check_common_signals();
    bit [6:0] transfer_size = 2 ** tr.size;

    // check if the addr is crossing 4KB boundary
    if((((tr.addr - (tr.addr % transfer_size)) % 4096
      ) + ((tr.len + 1) * transfer_size)) > 4096) begin
      $error("[AXI4_CHECK_001] Address must not cross 4KB Boundary!");
      return FAIL;
    end

    // check for burst type FIXED the len must be less than 15
    if(tr.burst == FIXED && tr.len > 15) begin
      $error("[AXI4_CHECK_00%0d] For FIXED burst type \"len\" must be between 0 to 15", tr.transaction_type == WRITE ? 2 : 3);
      return FAIL;
    end

    // check for burst type WRAP the transaction len be 
    // must be in the power of 2
    if(tr.burst == WRAP && !(tr.len inside {1, 3, 7, 15})) begin
      $error("[AXI4_CHECK_001] For WRAP burst type \"len\" must be 1, 3, 7, 15");
      return FAIL;
    end

    // check transfer size must be less than DATA_WIDTH
    if(transfer_size > `DATA_WIDTH) begin
      $error("[AXI4_CHECK_001] No. of transfer within a single burst must be lesser then the data bus width");
      return FAIL;
    end


    // check the burst type must not be RESERVED
    if(tr.burst == 2'b11) begin
      $error("[AXI4_CHECK_001] Burst must not be equal to 2'b11 i.e., RESERVED");
      return FAIL;
    end

    // check for burst type WRAP the address must only be aligned
    if(tr.burst == WRAP && (tr.addr % transfer_size)) begin
      $error("[AXI4_CHECK_001] For WRAP burst type address must be Aligned");
      return FAIL;
    end
  endfunction

endclass : ei_axi4_checker_c
