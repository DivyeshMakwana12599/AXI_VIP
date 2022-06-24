`define MON_CB vif.monitor_cb

class ei_axi4_monitor_c;
  bit tx_rx_monitor_cfg;

  virtual ei_axi4_interface.MON vif;

  mailbox#(ei_axi4_transaction_c) mon2ref; 
  mailbox#(ei_axi4_transaction_c) mon2scb;

  ei_axi4_checker_c axi4_checker;

  semaphore read_data_channel;
  semaphore write_data_channel;

  ei_axi4_transaction_c write_data_queue[$];
  ei_axi4_transaction_c write_response_queue[$];
  ei_axi4_transaction_c read_data_queue[$];

  int unsigned no_of_trans_monitored;

  function new(
    bit tx_rx_monitor_cfg,
    mailbox#(ei_axi4_transaction_c) mon2ref = null,
    mailbox#(ei_axi4_transaction_c) mon2scb = null,
    virtual ei_axi4_interface.MON vif
  );
    this.tx_rx_monitor_cfg = tx_rx_monitor_cfg;  
    if(mon2ref == null && tx_rx_monitor_cfg == 1'b0) begin
      $fatal("Connect Master Monitor to Reference Model");
    end
    else begin
      this.mon2ref = mon2ref;
    end
    if(mon2scb == null && tx_rx_monitor_cfg == 1'b1) begin
      $fatal("Connect Slave Monitor to Scoreboard");
    end
    else begin
      this.mon2scb = mon2scb;
    end
    this.vif = vif;
    axi4_checker = new();
  endfunction


  task run();
    forever begin
      fork
        begin : monitor_channels
          fork
            monitor_write_address_channel();
            monitor_write_data_channel();
            monitor_write_response_channel();
            monitor_read_address_channel();
            monitor_read_data_channel();
          join
        end
        begin : monitor_reset
          @(`MON_CB iff(!vif.aresetn));
        end
      join_any
      disable monitor_channels;
    end
  endtask

  task monitor_write_address_channel();
    ei_axi4_transaction_c wr_trans;
    forever begin
      @(`MON_CB iff(`MON_CB.awvalid && `MON_CB.awready));
      $display("@%0t write handshake occured -> %0d", $time, `MON_CB.awaddr );
      wr_trans = new();
      wr_trans.transaction_type = WRITE;
      wr_trans.addr = `MON_CB.awaddr;
      wr_trans.burst = `MON_CB.awburst;
      wr_trans.len = `MON_CB.awlen;
      wr_trans.size = `MON_CB.awsize;
      write_data_queue.push_back(wr_trans);
    end
  endtask

  task monitor_write_data_channel();
    ei_axi4_transaction_c wr_trans;

    forever begin

      wait_write_data_channel_handshake();

      wr_trans = write_data_queue.pop_front();
      wr_trans.data = new[wr_trans.len + 1];
      wr_trans.wstrb = new[wr_trans.len + 1];

      wr_trans.data[0] = `MON_CB.wdata;
      wr_trans.wstrb[0] = `MON_CB.wstrb;

      for(int i = 1; i <= wr_trans.len; i++) begin
        @(`MON_CB iff(`MON_CB.wready && `MON_CB.wvalid));
        wr_trans.data[i] = `MON_CB.wdata;
        wr_trans.wstrb[i] = `MON_CB.wstrb;
      end

      write_response_queue.push_back(wr_trans);

    end
  endtask

  task monitor_write_response_channel();
    ei_axi4_transaction_c wr_trans;
    forever begin

      wait_write_response_channel_handshake();

      wr_trans = write_response_queue.pop_front();
      wr_trans.bresp = `MON_CB.bresp;

      if(tx_rx_monitor_cfg == 1'b0) begin
        axi4_checker.check(wr_trans);
      end

      if(mon2ref != null) begin
        mon2ref.put(wr_trans);
        $display(wr_trans);
        wr_trans.print("MONITOR FOR WRITE");
        no_of_trans_monitored++;
        $display("no_of_trans_monitored = %0d", no_of_trans_monitored);
      end
    end

  endtask

  task monitor_read_address_channel();
    ei_axi4_transaction_c rd_trans;
    forever begin
      @(`MON_CB iff(`MON_CB.arvalid && `MON_CB.arready));
      $display("@%0t read handshake occured -> %0d", $time, `MON_CB.araddr );
      rd_trans = new();
      rd_trans.transaction_type = READ;
      rd_trans.addr = `MON_CB.araddr;
      rd_trans.burst = `MON_CB.arburst;
      rd_trans.len = `MON_CB.arlen;
      rd_trans.size = `MON_CB.arsize;
      read_data_queue.push_back(rd_trans);
    end
  endtask

  task monitor_read_data_channel();
    ei_axi4_transaction_c rd_trans;


    wait_read_data_channel_handshake();

    rd_trans = read_data_queue.pop_front();
    rd_trans.data = new[rd_trans.len + 1];
    rd_trans.rresp = new[rd_trans.len + 1];

    rd_trans.data[0] = `MON_CB.rdata;
    rd_trans.rresp[0] = `MON_CB.rresp;

    for(int i = 1; i <= rd_trans.len; i++) begin
      @(`MON_CB iff(`MON_CB.rready && `MON_CB.rvalid));
      rd_trans.data[i] = `MON_CB.rdata;
      rd_trans.rresp[i] = `MON_CB.rresp;
    end

    if(tx_rx_monitor_cfg == 1'b0) begin
      axi4_checker.check(rd_trans);
    end

    if(mon2scb != null) begin
      fork
        monitor_read_data_channel();
      join_none
      mon2scb.put(rd_trans);
      $display(rd_trans);
    end


    if(mon2ref != null) begin
      rd_trans.data.delete();
      rd_trans.rresp.delete();
      fork
        monitor_read_data_channel();
      join_none
      repeat(5) begin
        @(`MON_CB);
      end
      mon2ref.put(rd_trans);
      no_of_trans_monitored++;
      $display("no_of_trans_monitored = %0d", no_of_trans_monitored);
    end

  endtask
  
  task wait_write_data_channel_handshake();
      forever begin
        @(`MON_CB iff(`MON_CB.wvalid && `MON_CB.wready));
        if(write_data_queue.size() == 0 && tx_rx_monitor_cfg == 1'b0) begin
          $warning("[MONITOR] Write Data  Channel Handshake occured before \
Write Address channel handshake");
        end
        else begin
          break;
        end
      end
  endtask

  task wait_write_response_channel_handshake();
    forever begin
      @(`MON_CB iff(`MON_CB.bvalid && `MON_CB.bready));
      if(write_response_queue.size() == 0 && tx_rx_monitor_cfg == 1'b0) begin
        $warning("[MONITOR] Write Response occured before Write Data channel\
 handshake");
      end
      else begin
        break;
      end
    end
  endtask

  task wait_read_data_channel_handshake();
      forever begin
        @(`MON_CB iff(`MON_CB.rvalid && `MON_CB.rready));
        if(read_data_queue.size() == 0 && tx_rx_monitor_cfg == 1'b1) begin
          $warning("[MONITOR] Read Data Channel Handshake occured before Read \
Address channel handshake");
        end
        else begin
          break;
        end
      end
  endtask

endclass
