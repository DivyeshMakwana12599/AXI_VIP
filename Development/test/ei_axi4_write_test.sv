//====== testcase: 02 ============================= WRITE TEST ====================================================================//
class ei_axi4_wr_test_c extends ei_axi4_base_test_c;

	ei_axi4_write_transaction_c wr_trans;
	ei_axi4_test_config_c test_cfg;
	
	function new(virtual ei_axi4_master_interface mst_vif, virtual ei_axi4_slave_interface slv_vif);
		super.new(mst_vif, slv_vif);
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
    $display(test_cfg.total_num_trans);
    $display(env.mst_agt.mst_mon.no_of_trans_monitored);
    //wait(test_cfg.total_num_trans == env.mst_agt.mst_mon.no_of_trans_monitored);
    //$finish;
	endtask

    task wrap_up();
         $display("WRITE TESTCASE SELECTED");
    endtask

	
endclass
