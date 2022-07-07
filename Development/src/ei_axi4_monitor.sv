`define MON_CB mon_vif.monitor_cb

class ei_axi4_monitor_c;
  bit tx_rx_monitor_cfg;

  virtual `MON_INTF.MON mon_vif;

  mailbox#(ei_axi4_transaction_c) mon2ref; 
  mailbox#(ei_axi4_transaction_c) mon2scb;

  ei_axi4_checker_c axi4_checker;

  ei_axi4_transaction_c write_data_queue[$];
  ei_axi4_transaction_c write_response_queue[$];
  ei_axi4_transaction_c read_data_queue[$];

  ei_axi4_coverage_c axi4_coverage;

  int unsigned no_of_trans_monitored;

  function new(
    bit tx_rx_monitor_cfg,
    mailbox#(ei_axi4_transaction_c) mon2ref = null,
    mailbox#(ei_axi4_transaction_c) mon2scb = null,
    virtual `MON_INTF.MON mon_vif
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

    if(tx_rx_monitor_cfg == 1'b0) begin
      axi4_coverage = new();
      axi4_checker = new();
    end

    this.mon_vif = mon_vif;

  endfunction


  task run();
    forever begin
      reset();
      fork : monitor_run
        begin
          monitor_write_address_channel();
        end
        begin
          monitor_write_data_channel();
        end
        begin
          monitor_write_response_channel();
        end
        begin
          monitor_read_address_channel();
        end
        begin
          monitor_read_data_channel();
        end
        begin
          @(negedge mon_vif.aresetn);
        end
      join_any
      disable monitor_run;
    end
  endtask

  task reset();
    if(read_data_queue.size()) begin
      no_of_trans_monitored++;
      $display("no_of_trans_monitored reset = %0d", no_of_trans_monitored);
    end
    if(write_data_queue.size()) begin
      no_of_trans_monitored++;
      $display("no_of_trans_monitored reset = %0d", no_of_trans_monitored);
    end
    if(write_response_queue.size()) begin
      no_of_trans_monitored++;
      $display("no_of_trans_monitored reset = %0d", no_of_trans_monitored);
    end
    read_data_queue.delete();
    write_data_queue.delete();
    write_response_queue.delete();
    wait(mon_vif.aresetn == 1'b1);
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

    forever begin

      wait_write_data_channel_handshake();

      write_data_queue[0].data = new[write_data_queue[0].len + 1];
      write_data_queue[0].wstrb = new[write_data_queue[0].len + 1];

      write_data_queue[0].data[0] = `MON_CB.wdata;
      write_data_queue[0].wstrb[0] = `MON_CB.wstrb;

      for(int i = 1; i <= write_data_queue[0].len; i++) begin
        @(`MON_CB iff(`MON_CB.wready && `MON_CB.wvalid));
        write_data_queue[0].data[i] = `MON_CB.wdata;
        write_data_queue[0].wstrb[i] = `MON_CB.wstrb;
      end

      write_response_queue.push_back(write_data_queue.pop_front());

    end
  endtask

  task monitor_write_response_channel();
    ei_axi4_transaction_c wr_trans;
    forever begin

      wait_write_response_channel_handshake();

      write_response_queue[0].bresp = `MON_CB.bresp;

      if(tx_rx_monitor_cfg == 1'b0) begin
        axi4_checker.check(write_response_queue[0]);
        axi4_coverage.ei_axi4_write_cg.sample(
          write_response_queue[0], 
          (write_response_queue[0].addr % (2 ** write_response_queue[0].size)) 
          == 1'b0 ? ALIGNED : UNALIGNED
        );
      end

      wr_trans = write_response_queue.pop_front();

      if(tx_rx_monitor_cfg == 1'b0) begin
        mon2ref.put(wr_trans);
        wr_trans.print("MONITOR FOR WRITE");
        #0 no_of_trans_monitored++;
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

    read_data_queue[0].data = new[read_data_queue[0].len + 1];
    read_data_queue[0].rresp = new[read_data_queue[0].len + 1];

    read_data_queue[0].data[0] = `MON_CB.rdata;
    read_data_queue[0].rresp[0] = `MON_CB.rresp;

    for(int i = 1; i <= read_data_queue[0].len; i++) begin
      @(`MON_CB iff(`MON_CB.rready && `MON_CB.rvalid));
      read_data_queue[0].data[i] = `MON_CB.rdata;
      read_data_queue[0].rresp[i] = `MON_CB.rresp;
    end

    rd_trans = read_data_queue.pop_front();

    if(tx_rx_monitor_cfg == 1'b0) begin
      axi4_checker.check(rd_trans);
      axi4_coverage.ei_axi4_read_cg.sample(
        rd_trans, 
        (rd_trans.addr % (2 ** rd_trans.size)) == 1'b0 ? ALIGNED : UNALIGNED
      );
    end

    if(tx_rx_monitor_cfg == 1'b1) begin
      mon2scb.put(rd_trans);
      monitor_read_data_channel();
    end


    if(tx_rx_monitor_cfg == 1'b0) begin
      rd_trans.data.delete();
      rd_trans.rresp.delete();
      repeat(5) begin
        @(`MON_CB);
      end
      mon2ref.put(rd_trans);
      #0 no_of_trans_monitored++;
      $display("no_of_trans_monitored = %0d", no_of_trans_monitored);
      monitor_read_data_channel();
    end

  endtask
  
  task wait_write_data_channel_handshake();
      forever begin
        @(`MON_CB iff(`MON_CB.wvalid && `MON_CB.wready));
        if(write_data_queue.size() == 0) begin
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
      if(write_response_queue.size() == 0) begin
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
        if(read_data_queue.size() == 0) begin
          $warning("[MONITOR] Read Data Channel Handshake occured before Read \
Address channel handshake");
        end
        else begin
          break;
        end
      end
  endtask

  function void wrap_up();
    if(!tx_rx_monitor_cfg && tx_rx_monitor_cfg == 1'b0) begin
      axi4_checker.report();
    end
  endfunction

endclass
