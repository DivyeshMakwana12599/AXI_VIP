class ei_axi4_random_test_c extends ei_axi4_base_test_c;

	ei_axi4_read_transaction_c rd_trans;
	ei_axi4_write_transaction_c wr_trans;
	ei_axi4_test_config_c test_cfg;
	
	function new(virtual ei_axi4_interface vif);
		super.new(vif);
		test_cfg = new();
	endfunction
	
	task build();
		`SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
	endtask
	
	task start();
	
		int rand_int    = test_cfg.total_num_trans;           //15
		int rand_wr_cnt = rand_int - $urandom_range(0,10);    //10
		int rand_rd_cnt = rand_int - rand_wr_cnt;             //15-10 = 5
		
		for(int i = 0; i < rand_wr_cnt; i++) begin
			wr_trans = new();
			env.mst_agt.mst_gen.start(wr_trans);
		end
		
		for(int i = 0; i < rand_rd_cnt; i++) begin
			rd_trans = new();
			env.mst_agt.mst_gen.start(rd_trans);
		end
		super.run();
	endtask
	
endclass
