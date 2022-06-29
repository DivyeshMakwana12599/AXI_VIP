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

  ei_axi4_checker_db_c checker_db;

  function new();
    checker_db = new();
    // Registering the Checker
    checker_db.register_checker(
      "AXI4_CHECK_001", 
      "Address must not cross 4 KB Boundary"
    );
    checker_db.register_checker(
      "AXI4_CHECK_002", 
      "For Fixed burst type AWLEN must be between 0 to 15"
    );
    checker_db.register_checker(
      "AXI4_CHECK_003", 
      "For Fixed burst type ARLEN must be between 0 to 15"
    );
    checker_db.register_checker(
      "AXI4_CHECK_004", 
      "For WRAP burst type AWLEN must be 1, 3, 7 and 15 only"
    );
    checker_db.register_checker(
      "AXI4_CHECK_005", 
      "For WRAP burst type ARLEN must be 1, 3, 7 and 15 only"
    );
    // checker_db.register_checker(
      // "AXI4_CHECK_006", 
      // "For INCR burst type AWLEN must be between 0 to 255"
    // );
    // checker_db.register_checker(
      // "AXI4_CHECK_007", 
      // "For INCR burst type ARLEN must be between 0 to 255"
    // );
    checker_db.register_checker(
      "AXI4_CHECK_008", 
      "Transfer size - AWSIZE must be lesser than Data Bus Width"
    );
    checker_db.register_checker(
      "AXI4_CHECK_009", 
      "Transfer size - ARSIZE must be lesser than Data Bus Width"
    );
    checker_db.register_checker(
      "AXI4_CHECK_010", 
      "AWBURST must not be equal to 2'b11 (RESERVED)"
    );
    checker_db.register_checker(
      "AXI4_CHECK_011", 
      "ARBURST must not be equal to 2'b11 (RESERVED)"
    );
    checker_db.register_checker(
      "AXI4_CHECK_012", 
      "Approriate WSTRB must be there"
    );
    checker_db.register_checker(
      "AXI4_CHECK_013", 
      "BRESP must be OKAY or SLVERR for every transaction"
    );
    checker_db.register_checker(
      "AXI4_CHECK_014", 
      "RRESP must be OKAY or SLVERR for every transfer of transaction"
    );
    checker_db.register_checker(
      "AXI4_CHECK_015", 
      "For WRAP burst type AWADDR must be Aligned address only"
    );
    checker_db.register_checker(
      "AXI4_CHECK_016", 
      "For WRAP burst type ARADDR must be Aligned address only"
    );
  endfunction

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
    return PASS;
  endfunction

  /**
  *\ function check_write_signals
  *\ Note: checker function for write packet
  */
  protected function RESULT_e check_write_signals(ei_axi4_transaction_c tr);

    bit [`BUS_BYTE_LANES - 1:0] golden_strb[];

    golden_strb = new[tr.len + 1];
    for(int i = 0; i <= tr.len; i++) begin
      golden_strb[i] = get_wstrb(tr.addr, tr.burst, tr.size, tr.len, i);
    end

    if(!check_common_signals(tr)) begin
      return FAIL;
    end


    if(tr.wstrb != golden_strb) begin
      checker_db.fail("AXI4_CHECK_012");
      return FAIL;
    end
    else begin
      checker_db.pass("AXI4_CHECK_012");
    end

    if(!(tr.bresp inside {OKAY, SLVERR})) begin
      checker_db.fail("AXI4_CHECK_013");
      return FAIL;
    end
    else begin
      checker_db.pass("AXI4_CHECK_013");
    end

    return PASS;
  endfunction

  /**
  *\ function check_read_signals
  *\ Note: checker function for read packet
  */
  protected function RESULT_e check_read_signals(ei_axi4_transaction_c tr);
    bit isError;

    if(!check_common_signals(tr)) begin
      return FAIL;
    end

    foreach(tr.rresp[i]) begin
      if(!(tr.rresp[i] inside {OKAY, SLVERR})) begin
        isError = 1'b1;
        checker_db.fail("AXI4_CHECK_014");
        return FAIL;
      end
    end
    if(!isError) begin
      checker_db.pass("AXI4_CHECK_014");
    end

    return PASS;
  endfunction

  /**
  *\ function check_read_signals
  *\ Note: checker function for all the common signals
  *\       of AXI-4 i.e., len, size, burst, addr
  */
  protected function RESULT_e check_common_signals(ei_axi4_transaction_c tr);
    bit [6:0] transfer_size = 2 ** tr.size;

    // check if the addr is crossing 4KB boundary
    if((((tr.addr - (tr.addr % transfer_size)) % 4096
    ) + ((tr.len + 1) * transfer_size)) > 4096) begin
      checker_db.fail("AXI4_CHECK_001");
      return FAIL;
    end
    else begin
      checker_db.pass("AXI4_CHECK_001");
    end

    // check for burst type FIXED the len must be less than 15
    if(tr.burst == FIXED && tr.len > 15) begin
      if(tr.transaction_type == WRITE) begin
        checker_db.fail("AXI4_CHECK_002");
      end
      else begin
        checker_db.fail("AXI4_CHECK_003");
      end
      return FAIL;
    end
    else begin
      if(tr.transaction_type == WRITE) begin
        checker_db.pass("AXI4_CHECK_002");
      end
      else begin
        checker_db.pass("AXI4_CHECK_003");
      end
    end

    // check for burst type WRAP the transaction len be 
    // must be in the power of 2
    if(tr.burst == WRAP && !(tr.len inside {1, 3, 7, 15})) begin
      if(tr.transaction_type == WRITE) begin
        checker_db.fail("AXI4_CHECK_004");
      end
      else begin
        checker_db.fail("AXI4_CHECK_005");
      end
      return FAIL;
    end
    else begin
      if(tr.transaction_type == WRITE) begin
        checker_db.pass("AXI4_CHECK_004");
      end
      else begin
        checker_db.pass("AXI4_CHECK_005");
      end
    end

    // check transfer size must be less than DATA_WIDTH
    if(transfer_size > `DATA_WIDTH) begin
      if(tr.transaction_type == WRITE) begin
        checker_db.fail("AXI4_CHECK_008");
      end
      else begin
        checker_db.fail("AXI4_CHECK_009");
      end
      return FAIL;
    end
    else begin
      if(tr.transaction_type == WRITE) begin
        checker_db.pass("AXI4_CHECK_008");
      end
      else begin
        checker_db.pass("AXI4_CHECK_009");
      end
    end

    // check the burst type must not be RESERVED
    if(tr.burst == 2'b11) begin
      if(tr.transaction_type == WRITE) begin
        checker_db.fail("AXI4_CHECK_010");
      end
      else begin
        checker_db.fail("AXI4_CHECK_011");
      end
      return FAIL;
    end
    else begin
      if(tr.transaction_type == WRITE) begin
        checker_db.pass("AXI4_CHECK_010");
      end
      else begin
        checker_db.pass("AXI4_CHECK_011");
      end
    end

    // check for burst type WRAP the address must only be aligned
    if(tr.burst == WRAP && (tr.addr % transfer_size)) begin
      if(tr.transaction_type == WRITE) begin
        checker_db.fail("AXI4_CHECK_015");
      end
      else begin
        checker_db.fail("AXI4_CHECK_016");
      end
      return FAIL;
    end
  endfunction

  function void report();
    checker_db.report();
  endfunction

endclass : ei_axi4_checker_c
