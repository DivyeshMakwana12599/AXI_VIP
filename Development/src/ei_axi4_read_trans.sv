class ei_axi4_read_transaction_c extends ei_axi4_transaction_c;

	ei_axi4_test_config_c test_cfg;
	
	function new();
	  test_cfg = new();
	endfunction
	
	function void pre_randomize();
		`SV_RAND_CHECK(test_cfg.randomize());
	endfunction
	
	constraint addr_type_c {
		(test_cfg.addr_type) == ALIGNED -> ((addr % size) == 1'b0);
		(test_cfg.addr_type) == UNALIGNED -> ((addr % size) != 1'b0);
	}
	
	constraint specific_burst_type_c {
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
	
endclass

