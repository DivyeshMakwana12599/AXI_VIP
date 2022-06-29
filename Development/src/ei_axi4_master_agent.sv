class ei_axi4_master_agent_c;

  virtual `MST_INTF vif;
  ei_axi4_env_config_c env_cfg;
  ei_axi4_master_generator_c mst_gen;
  ei_axi4_master_driver_c mst_drv;
  ei_axi4_monitor_c mst_mon;

  mailbox#(ei_axi4_transaction_c) mst_mon2ref;
  mailbox#(ei_axi4_transaction_c) mst_gen2drv;


  function new(mailbox#(ei_axi4_transaction_c) mst_mon2ref, virtual `MST_INTF vif, ei_axi4_env_config_c env_cfg);

    this.vif = vif;
    this.env_cfg = env_cfg;
    this.mst_mon2ref = mst_mon2ref;
    if(env_cfg.master_agent_active_passive_switch == ACTIVE) begin
	mst_gen2drv = new();
        mst_gen = new(mst_gen2drv);
        mst_drv = new(mst_gen2drv, vif);
        mst_mon = new(0, mst_mon2ref,,vif,);
    end
    else begin
        mst_mon = new(0, mst_mon2ref, ,vif,);
    end
    vif.awvalid = 1'b1;

  endfunction

  task run;
    fork
      mst_drv.run();
      mst_mon.run();
    join
  endtask

  function void wrap_up();

  endfunction
endclass : ei_axi4_master_agent_c
