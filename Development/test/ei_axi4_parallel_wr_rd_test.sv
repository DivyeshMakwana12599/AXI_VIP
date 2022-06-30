class ei_axi4_parallel_wr_rd_test_c extends ei_axi4_base_test_c;
    ei_axi4_read_transaction_c read_trans;
    ei_axi4_write_transaction_c write_trans;
    ei_axi4_read_write_transaction_c read_write_trans;
    ei_axi4_test_config_c test_cfg;

    function new(virtual `MST_INTF mst_vif, virtual `SLV_INTF slv_vif, virtual `MON_INTF mon_vif);
        super.new(mst_vif, slv_vif, mon_vif);
        test_cfg = new();
    endfunction : new

    task build();
        `SV_RAND_CHECK(test_cfg.randomize());
        $display("[TEST_C] : parallel_wr_rd_test");
    endtask : build

    task start();

        bit [31:0] write_address[$];
        bit [1:0]  write_burst[$];
        bit [3:0]  write_size[$];
        bit [7:0]  write_length[$];
       
        super.run();

        for(int i = 0 ; i < test_cfg.total_num_trans *2 -2 ; i++) begin 

            if(i == 0) begin 
                write_trans = new();
                env.mst_agt.mst_gen.start(write_trans);
//          write_trans.randomize();

 /*               $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                $display("wr_trans = ",write_trans);
                $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                $display("\n");
                $display("\n");
                $display("\n");
  */              
                write_address.push_back(write_trans.addr); 
                write_burst.push_back(write_trans.burst); 
                write_size.push_back(write_trans.size); 
                write_length.push_back(write_trans.len); 
            end 

            else if(i > 0 && i < test_cfg.total_num_trans * 2 - 3) begin 
                if(i % 2 != 0) begin
                    read_write_trans = new();
                    env.mst_agt.mst_gen.start(read_write_trans);
            //        read_write_trans.randomize();
            //        $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                    write_address.push_back(read_write_trans.addr);
                    write_burst.push_back(read_write_trans.burst);
                    write_size.push_back(read_write_trans.size);
                    write_length.push_back(read_write_trans.len);
             /*       $display("wr_rd_trans = ",read_write_trans);
                    $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                    $display("\n");
                    $display("\n");
                    $display("\n");*/
                end

                if(i % 2 == 0) begin 
                    read_write_trans = new();
                    read_write_trans.addr.rand_mode(0); 
                    read_write_trans.size.rand_mode(0); 
                    read_write_trans.len.rand_mode(0); 
                    read_write_trans.burst.rand_mode(0); 
                    //$display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                    read_write_trans.addr = write_address.pop_front();
                    read_write_trans.burst = write_burst.pop_front();
                    read_write_trans.size = write_size.pop_front();
                    read_write_trans.len = write_length.pop_front();
                    env.mst_agt.mst_gen.start(read_write_trans);
                   // read_write_trans.randomize();
                    /*$display("wr_rd_trans = ",read_write_trans);
                    $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                    $display("\n");
                    $display("\n");
                    $display("\n");*/
                end 

        /*        write_trans = new();
                //env.mst_agt.mst_gen.start(write_trans);
                
                write_address.push_back(write_trans.addr); 
                write_burst.push_back(write_trans.burst); 
                write_size.push_back(write_trans.size); 
                write_length.push_back(write_trans.len); 
                $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                $display("write_trans[read_write] = ",write_trans);
                $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                $display("\n");
                $display("\n");
                $display("\n");



                read_trans = new();
                read_trans.rand_mode(0);

                read_trans.addr = write_address.pop_front();
                read_trans.burst = write_burst.pop_front();
                read_trans.size = write_size.pop_front();
                read_trans.len = write_length.pop_front();
               
                $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                $display("read_trans[read_write] = ",read_trans);
                $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
                $display("\n");
                $display("\n");
                $display("\n");

                //env.mst_agt.mst_gen.start(read_trans);
         */   
            
            end 
            
           if(i == test_cfg.total_num_trans * 2 - 3) begin 
                read_trans = new();
                read_trans.rand_mode(0);

                read_trans.addr = write_address.pop_front();
                read_trans.burst = write_burst.pop_front();
                read_trans.size = write_size.pop_front();
                read_trans.len = write_length.pop_front();
             /*  $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
               $display("read_trans = ",read_trans);
               $display("\n");
               $display("\n");
               $display("\n");
               $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");*/
                env.mst_agt.mst_gen.start(read_trans);

            end   
        end
        wait((test_cfg.total_num_trans * 2) - 2 == env.mst_agt.mst_mon.no_of_trans_monitored);
    endtask : start 

    task wrap_up();
        super.wrap_up();
        $display("PARALLEL WRITE READ TESTCASE SELECTED");
    endtask : wrap_up
endclass : ei_axi4_parallel_wr_rd_test_c

