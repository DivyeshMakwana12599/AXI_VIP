class ei_axi4_base_test_c;
	ei_axi4_environment_c env;
	ei_axi4_env_config_c env_cfg;

	virtual ei_axi4_master_interface mst_vif;
	virtual ei_axi4_slave_interface slv_vif;
	
	function new(virtual ei_axi4_master_interface mst_vif, virtual ei_axi4_slave_interface slv_vif);
		env_cfg  = new();
		this.mst_vif = mst_vif;
        this.slv_vif = slv.vif;
		env      = new(mst_vif, slv_vif, env_cfg);
	endfunction
	
	task run();
		fork
      env.run();
		join_none
	endtask 
	
    task wrap_up();
        env.wrap_up();
    endtask :wrap_up

endclass
