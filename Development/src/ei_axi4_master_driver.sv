class ei_axi4_master_driver_c();
    
    ei_axi4_transaction_c tr;

    ei_axi4_transaction_c queue[$];

    mailbox #(ei_axi4_transaction_c) gen2drv;

    virtual ei_axi4_interface_c vif;

    semaphore sema0,sema1;

    function new();

        this.genrdrv = gen2drv;
        this.vif = vif;
        sema0 = new(1);
        sema1 = new(1);

    endfunction : new

    task run();
        
        forever begin 
            gen2drv.get(tr);
            fork//1
            // check logic in fork join_any
            if(tr.transaction_type == WRITE)begin
                write_queue.push_back(tr);
                write_address_task();
                // join none this task only
                fork//2
                    write_data_task();
                    write_response_task();
                join_none//2 
            end 

            if(tr.transaction_type == READ)begin
                // push in read queue
                read_queue.push_back(tr);
                read_address(); 
            fork//3
                read_data(); // join none here only 
            join_none//3
            end 

            /*if(tr.transaction_type == READ_WRITE)beg
            end*/
            join_any // 1
        end // forever
    
    endtask : run

    task write_address();
        @(`VMST);
        vif.awvalid <= 1'b1;
        vif.awaddr <= write_queue[0].addr;
        vif.awburst <= write_queue[0].burst;
        vif.awlen <= write_queue[0].len;
        vif.awsize <= write_queue[0].size;

        @(`VMST iff(vif.awready <= 1'b1))begin 
            vif.awvalid <= 1'b0;
            vif.wlast <= 1'b0;
            vif.awaddr <= 'bx;
        end // iff(awready)

    endtask : write_address 

    task write_data_task();
        
        sema.get(1);   

        @(`VMST);
        vif.wvalid <= 1'b1;

        for(int i = 0; i <= tr.len ; i++)begin 
            vif.wdata <= tr.data[i];
            vif.wstrb <= tr.wstrb[i];

            if(i == tr.len)begin 
                vif.wlast <= 1'b1;
            end

            @(`VMST iff(vif.wready));

        end //for

        //if(vif.wlast == 1'b1)begin
        @(`VMST iff(wlast == 1'b1))begin

            @(`VMST);
            vif.wvalid <= 1'b0;
            vif.wlast <= 1'b0;
            vif.wdata <= 'bx;
            vif.wstrb <= 'bx;
            vif.bready <= 1'b1;

        end // if(wlast)

    endtask : write_data_task

    task write_esponse_task();
      //  @(`VMST iff(vif.wlast == 1))begin 
            @(`VMST iff(vif.bvalid <= 1))begin 
                //vif.bready <= 1;
                @(`VMST);
                vif.bready <= 1'b0;
            end //iff(wlast)
        end //iff(bvalid)
        sema.put(1);
    endtask : write_response_task 

endclass : ei_axi4_master_driver_c 
