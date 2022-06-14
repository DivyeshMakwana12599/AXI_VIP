`define MON_CB vif.monitor_cb

class ei_axi4_monitor_c;

  bit tx_rx_monitor_cfg;

  virtual ei_axi4_interface.MON vif;

  mailbox#(ei_axi4_transaction_c) mon2ref; 
  mailbox#(ei_axi4_transaction_c) mon2scb;

  ei_axi4_checker_c axi4_checker;

  semaphore read_data_channel;
  semaphore write_data_channel;

  function new(
    bit tx_rx_monitor_cfg,
    mailbox#(ei_axi4_transaction_c) mon2ref = null,
    mailbox#(ei_axi4_transaction_c) mon2scb = null,
    virtual ei_axi4_interface.MON vif
  );
    this.tx_rx_monitor_cfg = tx_rx_monitor_cfg;  
    if(mon2ref != null) begin
      this.mon2ref = mon2ref;
    end
    if(mon2scb != null) begin
      this.mon2scb = mon2scb;
    end
    this.vif = vif;
    axi4_checker = new();
  endfunction

  task run();
    forever begin
      read_data_channel = new(1);
      write_data_channel = new(1);
      fork
        begin : read_channel
          monitor_read_channel();
        end
        begin : write_channel
          monitor_write_channel();
        end
        begin : reset
          @(`MON_CB iff(!vif.aresetn));
        end
      join_any
      disable read_channel;
      disable write_channel;
    end
  endtask

  task monitor_read_channel();
    ei_axi4_transaction_c rd_trans;
    forever begin
      @(`MON_CB iff(`MON_CB.arvalid && `MON_CB.arready));
      rd_trans = new();
      rd_trans.transaction_type = READ;
      rd_trans.addr = `MON_CB.araddr;
      rd_trans.burst = `MON_CB.arburst;
      rd_trans.len = `MON_CB.arlen;
      rd_trans.size = `MON_CB.arsize;
      fork
        monitor_read_data_channel(rd_trans);
      join_none
    end
  endtask

  task monitor_read_data_channel(ei_axi4_transaction_c rd_trans);

    rd_trans.rresp = new[rd_trans.len + 1];
    rd_trans.data = new[rd_trans.len + 1];

    read_data_channel.get(1);

    for(int i = 0; i <= rd_trans.len; i++) begin
      @(`MON_CB iff(`MON_CB.rvalid && `MON_CB.rready));
      rd_trans.rresp[i] = `MON_CB.rresp;
      rd_trans.data[i] = `MON_CB.rdata;
    end

    read_data_channel.put(1);

    if(axi4_checker.check(rd_trans) == FAIL) begin
      return;
    end
    for(int i = 0; i <= rd_trans.len; i++) begin
      if(rd_trans.rresp[i] != OKAY) begin
        return;
      end
    end
    if(mon2ref != null) begin
      mon2ref.put(rd_trans);
    end
    if(mon2scb != null) begin
      mon2scb.put(rd_trans);
    end
  endtask

  task monitor_write_channel();
    ei_axi4_transaction_c wr_trans;
    forever begin
      @(`MON_CB iff(`MON_CB.awvalid && `MON_CB.awready));
      wr_trans = new();
      wr_trans.transaction_type = WRITE;
      wr_trans.addr = `MON_CB.awaddr;
      wr_trans.burst = `MON_CB.awburst;
      wr_trans.len = `MON_CB.awlen;
      wr_trans.size = `MON_CB.awsize;
      fork
        monitor_write_data_channel(wr_trans);
      join_none
    end
  endtask

  task monitor_write_data_channel(ei_axi4_transaction_c wr_trans);

    wr_trans.data = new[wr_trans.len + 1];
    wr_trans.wstrb = new[wr_trans.len + 1];

    write_data_channel.get(1);

    for(int i = 0; i <= wr_trans.len; i++) begin
      @(`MON_CB iff(`MON_CB.wvalid && `MON_CB.wready));
      wr_trans.data[i] = `MON_CB.wdata;
      wr_trans.wstrb[i] = `MON_CB.wstrb;
    end

    write_data_channel.put(1);

    @(`MON_CB iff(`MON_CB.bvalid && `MON_CB.bready));
    wr_trans.bresp = `MON_CB.bresp;

    if(wr_trans.bresp != OKAY) begin
      return;
    end

    if(mon2ref != null) begin
      mon2ref.put(wr_trans);
    end
    if(mon2scb != null) begin
      mon2scb.put(wr_trans);
    end

  endtask

endclass : ei_axi4_monitor_c
