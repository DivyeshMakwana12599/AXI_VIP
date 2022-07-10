class ei_axi4_coverage_c;


  covergroup ei_axi4_write_cg with function sample(
    ei_axi4_transaction_c trans, 
    addr_type_e addr_type
  );

    ei_axi4_write_address_type_cp : coverpoint addr_type {
      bins aligned_addr   = {ALIGNED};
      bins unaligned_addr = {UNALIGNED};
    }

    ei_axi4_write_transfer_size_cp : coverpoint trans.size{
      bins size[] = {[0:$clog2(`BUS_BYTE_LANES)]};
    }
    ei_axi4_write_transaction_length_cp : coverpoint trans.len;
    ei_axi4_write_burst_type_cp : coverpoint trans.burst;

    ei_axi4_write_response_type_cp : 
      coverpoint trans.bresp {
        bins okay = {OKAY};
        bins slv_err = {SLVERR};
        illegal_bins invalid_resp = {DECERR, EXOKAY};
      }

    ei_axi4_write_transaction_length_transfer_size_cr : 
      cross ei_axi4_write_transaction_length_cp, 
            ei_axi4_write_transfer_size_cp;
    ei_axi4_write_burst_type_address_type_cr :
      cross ei_axi4_write_burst_type_cp, ei_axi4_write_address_type_cp {
        ignore_bins wrap_unaligned = ei_axi4_write_burst_type_address_type_cr 
        with (ei_axi4_write_burst_type_cp == WRAP && 
              ei_axi4_write_address_type_cp == UNALIGNED);
      }
    ei_axi4_write_burst_type_transfer_size_cr :
      cross ei_axi4_write_burst_type_cp, ei_axi4_write_transfer_size_cp;
    ei_axi4_write_burst_type_transaction_length_cr :
      cross ei_axi4_write_burst_type_cp, ei_axi4_write_transaction_length_cp{
        ignore_bins wrap_len = ei_axi4_write_burst_type_transaction_length_cr 
        with (ei_axi4_write_burst_type_cp == WRAP && 
            !(ei_axi4_write_transaction_length_cp inside {1, 3, 7, 15}));
        ignore_bins fixed_len = ei_axi4_write_burst_type_transaction_length_cr 
        with (ei_axi4_write_burst_type_cp == FIXED && 
             (ei_axi4_write_transaction_length_cp> 15));
      }

    ei_axi4_write_burst_type_response_type : 
      cross ei_axi4_write_burst_type_cp, ei_axi4_write_response_type_cp;
  endgroup

  covergroup ei_axi4_read_cg with function sample(
    ei_axi4_transaction_c trans, 
    addr_type_e addr_type
  );

    ei_axi4_read_address_type_cp : coverpoint addr_type {
      bins aligned_addr   = {ALIGNED};
      bins unaligned_addr = {UNALIGNED};
    }

    ei_axi4_read_transfer_size_cp : coverpoint trans.size{
      bins size[] = {[0:$clog2(`BUS_BYTE_LANES)]};
    }
    ei_axi4_read_transaction_length_cp : coverpoint trans.len{
      option.auto_bin_max = 1000;
      bins len[256] = {[0:$]};
    }
    ei_axi4_read_burst_type_cp : coverpoint trans.burst;
    ei_axi4_read_response_type_cp : 
      coverpoint trans.rresp[0] {
        bins okay = {OKAY};
        bins slv_err = {SLVERR};
        illegal_bins invalid_resp = {DECERR, EXOKAY};
      }

    ei_axi4_read_transaction_length_transfer_size_cr : 
      cross ei_axi4_read_transaction_length_cp, ei_axi4_read_transfer_size_cp;
    ei_axi4_read_burst_type_address_type_cr :
      cross ei_axi4_read_burst_type_cp, ei_axi4_read_address_type_cp {
        ignore_bins wrap_unaligned = ei_axi4_read_burst_type_address_type_cr 
        with (ei_axi4_read_burst_type_cp == WRAP && 
              ei_axi4_read_address_type_cp == UNALIGNED);
      }
    ei_axi4_read_burst_type_transfer_size_cr :
      cross ei_axi4_read_burst_type_cp, ei_axi4_read_transfer_size_cp;
    ei_axi4_read_burst_type_transaction_length_cr :
      cross ei_axi4_read_burst_type_cp, ei_axi4_read_transaction_length_cp{
        ignore_bins wrap_len = ei_axi4_read_burst_type_transaction_length_cr 
        with (ei_axi4_read_burst_type_cp == WRAP && 
            !(ei_axi4_read_transaction_length_cp inside {1, 3, 7, 15}));
        ignore_bins fixed_len = ei_axi4_read_burst_type_transaction_length_cr 
        with (ei_axi4_read_burst_type_cp == FIXED && 
             (ei_axi4_read_transaction_length_cp > 15));
      }

    ei_axi4_read_burst_type_response_type : 
      cross ei_axi4_read_burst_type_cp, ei_axi4_read_response_type_cp;
  endgroup

  function new();
    ei_axi4_write_cg = new();
    ei_axi4_read_cg = new();
  endfunction 

endclass
