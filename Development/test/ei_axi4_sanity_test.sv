class ei_axi4_sanity_test_c extends ei_axi4_base_test_c;

	ei_axi4_read_transaction_c rd_trans;
	ei_axi4_write_transaction_c wr_trans;
	ei_axi4_test_config_c test_cfg;
	
	function new(virtual ei_axi4_interface vif);
		super.new(vif);
		test_cfg = new();
	endfunction
	
	
	task build();
		`SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
		$display("[TEST_c] : sanity test");
	endtask
	
	
	task start();
		
		for(int i = 0; i < test_cfg.total_num_trans; i++) begin
		$display("[TEST_c] : sanity test");
		if(i%2 == 0)begin
            wr_trans = new();
			env.mst_agt.mst_gen.start(wr_trans);
		end
		else begin
            rd_trans = new();
			rd_trans.rand_mode(0);
			rd_trans.addr  = wr_trans.addr;
			rd_trans.data  = wr_trans.data;	
			rd_trans.burst = wr_trans.burst;	
			rd_trans.len   = wr_trans.len;	
			rd_trans.size  = wr_trans.size;	
			
			env.mst_agt.mst_gen.start(rd_trans);
		end
		end
		super.run();
	endtask
	
endclass
