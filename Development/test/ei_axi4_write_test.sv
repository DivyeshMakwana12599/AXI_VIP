//====== testcase: 02 ============================= WRITE TEST ====================================================================//
class ei_axi4_wr_test_c extends ei_axi4_base_test_c;

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
        super.run();
		for(int i = 0; i < test_cfg.total_num_trans; i++) begin
			wr_trans = new();
			env.mst_agt.mst_gen.start(wr_trans);
		end
	endtask

    task wrap_up();
         $display("READ TESTCASE SELECTED");
    endtask

	
endclass
