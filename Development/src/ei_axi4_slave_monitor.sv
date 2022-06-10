class ei_axi4_slave_monitor_c;
  virtual ei_axi4_interface vif;
  mailbox#(ei_axi_transaction_c) slv_mon2scb;

  function new(virtual ei_axi4_interface vif, mailbox#(ei_axi_transaction_c) slv_mon2scb);
    this.vif = vif;
    this.slv_mon2scb = slv_mon2scb;
  endfunction

  task run();
    
  endtask

  function void wrap_up();

  endfunction
endclass
