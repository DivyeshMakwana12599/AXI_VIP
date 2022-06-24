//======== testcase: 04 =========================== RANDOM TEST i.e [random write read] ==============================================//
class ei_axi4_random_test_c extends ei_axi4_base_test_c;

  ei_axi4_read_transaction_c rd_trans;
  ei_axi4_write_transaction_c wr_trans;
  ei_axi4_test_config_c test_cfg;
  
  function new(virtual ei_axi4_interface vif);
    super.new(vif);
    test_cfg = new();
  endfunction
  
  task build();
    `SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
  endtask
  
  
  task start();
    int rand_int = test_cfg.total_num_trans;           //15
      super.run();

    for(int i = 0; i < rand_int; i++) begin
      wr_trans = new();
      rd_trans = new();
      
          
      randsequence(main)
      main  : write | read;
      write : {env.mst_agt.mst_gen.start(wr_trans);};
      read  : {env.mst_agt.mst_gen.start(rd_trans);};
      endsequence
    end
      $finish;
  endtask

    task wrap_up();
         $display("RANDOM TESTCASE SELECTED");
    endtask
  
endclass :ei_axi4_random_test_c

