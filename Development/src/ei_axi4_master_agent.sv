class ei_axi4_master_agent_c;

    ei_axi4_master_generator_c mst_gen;
    ei_axi4_master_driver_c mst_drv;
    ei_axi4_master_monitor_c mst_mon;

    virtual ei_axi4_interface vif;
    ei_axi4_env_config_c env_cfg;
    ei_axi4_test_config_c test_cfg;
    

  mailbox#(ei_axi4_transaction_c) mst_mon2ref;

  function new(mailbox#(ei_axi4_transaction_c) mst_mon2ref, virtual ei_axi4_interface vif, ei_axi4_env_config_c env_cfg, ei_axi4_test_config_c test_cfg);

    this.vif = vif;
    this.env_cfg = env_cfg;
    this.test_cfg = test_cfg;
    this.mst_mon2ref = mst_mon2ref;

  endfunction

    task run();
        
        if (env_cfg.master_agent_active_passive_switch == ACTIVE)begin 
            fork : active
            mst_gen.run();
            mst_drv.run();
            mst_mon.run();
            join_any : active
        end 

        else begin 
            mst_mon.run();
        end 
        
    endtask : run

  function void wrap_up();

  endfunction
endclass : ei_axi4_master_agent_c
