//======== testcase: 05 =========================== SEQUENTIAL WR_RD  TEST i.e [sequential write read] ===============================//
class ei_axi4_seq_wr_rd_test_c extends ei_axi4_base_test_c;

	ei_axi4_read_transaction_c rd_trans;
	ei_axi4_write_transaction_c wr_trans;
	ei_axi4_test_config_c test_cfg;
    int tmp_addr_arr[$];                            //to store address during write operation
	
	function new(virtual ei_axi4_interface vif);
		super.new(vif);
		test_cfg = new();
	endfunction
	
	task build();
		`SV_RAND_CHECK(test_cfg.randomize()); // for no of iteration only
	endtask
	
	
	task start();
		super.run();
        //write operation, if num of trans odd then it write ((num/2)+1) and remaining for read
		for(int i = test_cfg.total_num_trans/2; i < test_cfg.total_num_trans; i++) begin
			wr_trans = new();
            tmp_addr_arr.push_front(wr_trans.addr);      //to store addresses
			env.mst_agt.mst_gen.start(wr_trans);
		end
		
		for(int i = 0; i < test_cfg.total_num_trans/2; i++) begin
		    rd_trans = new();
			rd_trans.addr.rand_mode(0);
            rd_trans.burst.rand_mode(0);
            rd_trans.len.rand_mode(0);
            rd_trans.size.rand_mode(0);
            rd_trans.transaction_type = READ;
			rd_trans.addr  = tmp_addr_arr.pop_back();     //to get data from same location	
			rd_trans.burst = wr_trans.burst;	
			rd_trans.len   = wr_trans.len;	
			rd_trans.size  = wr_trans.size;	
			env.mst_agt.mst_gen.start(rd_trans);
		end
	endtask

    task wrap_up();
        $display("SEQUENTIAL WRITE READ TASK SELECTED");
    endtask
	
endclass

