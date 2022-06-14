
class ei_axi4_base_test_c;
	ei_axi4_environment_c env;
	ei_axi4_env_config_c env_cfg;
	virtual ei_axi4_interface vif;
	
	function new(virtual ei_axi4_interface vif);
		env_cfg = new();
        this.vif = vif;
		env = new(vif, env_cfg);
	endfunction
endclass


class ei_axi4_rd_test_c extends ei_axi4_base_test_c;

	ei_axi4_read_transaction_c rd_trans;
	ei_axi4_test_config_c test_cfg;
	
	function new(virtual ei_axi4_interface vif);
		super.new(vif);
        test_cfg = new();
		`SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
	endfunction
	
	task start();
		for(int i = 0; i < test_cfg.total_num_trans; i++) begin
            rd_trans = new();
			env.mst_agt.mst_gen.start(rd_trans);
		end
        env.run();
	endtask

endclass

