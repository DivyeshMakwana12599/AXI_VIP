class ei_axi4_rd_test_c extends ei_axi4_base_test_c;

	ei_axi4_read_transaction_c rd_trans;
	ei_axi4_test_config_c test_cfg;
	
	function new(virtual ei_axi4_interface vif);
		super.new(vif);
		test_cfg = new();
	endfunction
	

	task build();
		`SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
	endtask
	
	task start();

		for(int i = 0; i < test_cfg.total_num_trans; i++) begin
			rd_trans = new();
			$display("inside task start");
			env.mst_agt.mst_gen.start(rd_trans);

		end
$display("READ TESTCASE = %p",rd_trans);
		super.run();
	endtask
	
endclass
