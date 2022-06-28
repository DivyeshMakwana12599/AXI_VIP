class ei_axi4_sanity_test_c extends ei_axi4_base_test_c;

  ei_axi4_read_transaction_c rd_trans;
  ei_axi4_write_transaction_c wr_trans;
  ei_axi4_test_config_c test_cfg;
  
    //constructor
  function new(virtual ei_axi4_interface vif);
    super.new(vif);
    test_cfg = new();
  endfunction
  
  //build function
  task build();
    `SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
  endtask
  
  //run phase
  task start();
    super.run();
    for(int i = 0; i < test_cfg.total_num_trans; i++) begin
    if(i%2 == 0)begin
      wr_trans = new();
      env.mst_agt.mst_gen.start(wr_trans); 
    end
    else begin
      rd_trans = new();
      rd_trans.addr.rand_mode(0);
      rd_trans.burst.rand_mode(0);
      rd_trans.len.rand_mode(0);
      rd_trans.size.rand_mode(0);
      rd_trans.transaction_type = READ;
      rd_trans.addr  = wr_trans.addr; 
      rd_trans.burst = wr_trans.burst;  
      rd_trans.len   = wr_trans.len;  
      rd_trans.size  = wr_trans.size;
      rd_trans.specific_burst_type.constraint_mode(0);
      rd_trans.addr_type_c.constraint_mode(0);
      rd_trans.specific_transaction_length.constraint_mode(0);
      rd_trans.specific_transfer_size.constraint_mode(0);
      env.mst_agt.mst_gen.start(rd_trans);
    end
    end
    wait(test_cfg.total_num_trans == env.mst_agt.mst_mon.no_of_trans_monitored);
      $finish;
  endtask
    
    //wrap up phase    
    task wrap_up();
        $display("SANITY TEST SELECTED");
        super.wrap_up();
    endtask
  
endclass

