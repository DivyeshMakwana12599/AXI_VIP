/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_checker.sv
Title 			: Checker for AXI 4 Protocol
Project 		: AMBA AXI-4 SV VIP
Created On  : 06-June-22
Developers  : Divyesh Makwana
Purpose 		: Checking the packet is Not violating the AXI 4 Protocol
 
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
  typedef enum bit {PASS, FAIL} RESULT_e;

  function RESULT_e check(ei_axi4_transaction tr);
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
      if(!check_write_signals(tr)) begin
        return FAIL;
      end
      if(!check_read_signals(tr)) begin
        return FAIL;
      end
    end
    return PASS;
  endfunction

  protected function RESULT_e check_write_signals();
    bit [6:0] transfer_size = 2 ** tr.awsize;
    bit [`BUS_BYTE_LANES - 1:0] golden_strb[];

    golden_strb = new[tr.awlen + 1];

    for(int i = 0; i <= tr.awlen; i++) begin
      golden_strb[i] = get_wstrb(
				.awaddr(tr.awaddr), 
				.awburst(tr.awburst), 
				.awsize(tr.awsize), 
				.awlen(tr.awlen), 
				.beat_no(i)
			);
    end


    if((((tr.awaddr - (tr.awaddr % transfer_size)) % 4096) + ((tr.awlen + 1) * transfer_size)) > 4096) begin
      $error();
      return FAIL;
    end
    if(tr.awburst == FIXED && tr.awlen > 15) begin
      return FAIL;
    end
    if(tr.awburst == WRAP && !(tr.awlen inside {1, 3, 7, 15})) begin
      return FAIL;
    end
    if(transfer_size > `BUS_WIDTH) begin
      return FAIL;
    end
    if(tr.awburst == RESERVED) begin
      return FAIL;
    end
    if(tr.wstrb == golden_strb) begin
      return FAIL;
    end
    if(!(tr.bresp inside {OKAY, SLVERR})) begin
      return FAIL;
    end
    if(tr.awburst == WRAP && (tr.awaddr % transfer_size)) begin
      return FAIL;
    end

    return PASS;
  endfunction

  protected function RESULT_e check_read_signals();
    bit [6:0] transfer_size = 2 ** tr.arsize;

    if((((tr.araddr - (tr.araddr % transfer_size)) % 4096) + ((tr.arlen + 1) * transfer_size)) > 4096) begin
      return FAIL;
    end
    if(tr.arburst == FIXED && tr.arlen > 15) begin
      return FAIL;
    end
    if(tr.arburst == WRAP && !(tr.arlen inside {1, 3, 7, 15})) begin
      return FAIL;
    end
    if(transfer_size > `BUS_WIDTH) begin
      return FAIL;
    end
    if(tr.arburst == RESERVED) begin
      return FAIL;
    end
    if(tr.arburst == WRAP && (tr.araddr % transfer_size)) begin
      return FAIL;
    end

    foreach(tr.rresp[i]) begin
      if(!(tr.rresp[i] inside {OKAY, SLVERR})) begin
        return FAIL;
      end
    end

    return PASS;
  endfunction

endclass : ei_axi4_checker_c