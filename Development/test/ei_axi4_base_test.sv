class ei_axi4_base_test_c;
	ei_axi4_environment_c env;
	ei_axi4_env_config_c env_cfg;
	virtual ei_axi4_interface vif;
	
	function new(virtual ei_axi4_interface vif);
		env_cfg  = new();
		this.vif = vif;
		env      = new(vif, env_cfg);
	endfunction
	
	task run();
		fork
		env.run();
		join_none
	endtask 
	
endclass
