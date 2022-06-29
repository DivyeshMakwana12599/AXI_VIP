//======== testcase: 05 =========================== SEQUENTIAL WR_RD  TEST i.e [sequential write read] ===============================//
class ei_axi4_seq_wr_rd_test_c extends ei_axi4_base_test_c;

    ei_axi4_read_transaction_c rd_trans;
    ei_axi4_write_transaction_c wr_trans;
    ei_axi4_test_config_c test_cfg;
    bit [31:0] tmp_addr_arr[$];                            //to store address during write operation
    bit [1:0] tmp_burst_arr[$];
    bit [7:0] tmp_len_arr[$];
    bit [2:0] tmp_size_arr[$];
  
  function new(virtual ei_axi4_master_interface mst_vif, virtual ei_axi4_slave_interface slv_vif);
    super.new(mst_vif, slv_vif);
    test_cfg = new();
  endfunction
  
  task build();
    `SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
  endtask
  
  
  task start();
       int count_len;
        int j;
    super.run();
       //write operation, if num of trans odd then it write ((num/2)+1) and remaining for read
    for(int i = test_cfg.total_num_trans/2; i < test_cfg.total_num_trans; i++) begin
        $display("-----------------------------> i = %0d ",i);
        wr_trans = new();

        env.mst_agt.mst_gen.start(wr_trans);
        tmp_addr_arr.push_front(wr_trans.addr);      //to store addresses
        tmp_burst_arr.push_front(wr_trans.burst);
        tmp_len_arr.push_front(wr_trans.len);
        tmp_size_arr.push_front(wr_trans.size);
        //env.mst_agt.mst_gen.start(wr_trans);
        count_len = count_len + wr_trans.len;
        j++;
    end
    
    #((count_len+4+j)*10);
    j =0;

    for(int i = 0; i < test_cfg.total_num_trans/2; i++) begin
        rd_trans = new();
        rd_trans.addr.rand_mode(0);
        rd_trans.burst.rand_mode(0);
        rd_trans.len.rand_mode(0);
        rd_trans.size.rand_mode(0);
        rd_trans.specific_burst_type.constraint_mode(0);
        rd_trans.addr_type_c.constraint_mode(0);
        rd_trans.specific_transaction_length.constraint_mode(0);
        rd_trans.specific_transfer_size.constraint_mode(0);
          
        rd_trans.transaction_type = READ;
        rd_trans.addr   = tmp_addr_arr.pop_back();     //to get data from same location 
        rd_trans.burst  = tmp_burst_arr.pop_back();
        rd_trans.len    = tmp_len_arr.pop_back();
        rd_trans.size   = tmp_size_arr.pop_back();
        env.mst_agt.mst_gen.start(rd_trans);
        //$display("[SEQ_RD] : ",rd_trans);
    end
      //wait(test_cfg.total_num_trans == env.mst_agt.mst_mon.no_of_trans_monitored);
  endtask

    task wrap_up();
        $display("SEQUENTIAL WRITE READ TASK SELECTED");
    endtask
  
endclass


