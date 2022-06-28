class ei_axi4_base_test_c#(type mst_intf = ei_axi4_master_interface, type slv_intf = ei_axi4_slave_interface);
	ei_axi4_environment_c env;
	ei_axi4_env_config_c env_cfg;

	virtual mast_intf mst_vif;
	virtual slv_intf slv_vif;
	
	function new(virtual mst_intf mst_vif, virtual slv_intf slv_vif);
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
