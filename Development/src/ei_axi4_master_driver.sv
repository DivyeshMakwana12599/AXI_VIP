class ei_axi4_master_driver_c;
    
    ei_axi4_transaction_c tr;

    ei_axi4_transaction_c queue[$];

    mailbox #(ei_axi4_transaction_c) gen2drv;

    int running_index;

    virtual ei_axi4_interface_c `VMST;

    semaphore sema0,sema1;

    function new();

        this.genrdrv = gen2drv;
        this.`VMST = `VMST;
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
        `VMST.awvalid <= 1'b1;
        `VMST.awaddr <= write_queue[running_index].addr;
        `VMST.awburst <= write_queue[running_index].burst;
        `VMST.awlen <= write_queue[running_index].len;
        `VMST.awsize <= write_queue[running_index].size;
        running_index++;

        @(`VMST iff(`VMST.awready <= 1'b1)) 
            `VMST.awvalid <= 1'b0;
            `VMST.wlast <= 1'b0;
        

    endtask : write_address 

    task write_data_task();
        
        sema.get(1);   

        @(`VMST iff(`VMST.awready);
        `VMST.wvalid <= 1'b1;

        for(int i = 0; i <= write_queue[0].len ; i++)begin 
            `VMST.wdata <= write_queue[0].data[i];
            `VMST.wstrb <= write_queue[0].wstrb[i];

            if(i == write_queue[0].len)begin 
                `VMST.wlast <= 1'b1;
            end

            @(`VMST iff(`VMST.wready));

        end //for

        //if(`VMST.wlast == 1'b1)begin
        @(`VMST iff(wlast == 1'b1))
            @(`VMST);
            `VMST.wlast <= 1'b0;
            `VMST.write_queue[0].wdata <= 'bx;
            `VMST.write_queue[0].wstrb <= 'bx;

    endtask : write_data_task

    task write_esponse_task();
      //  @(`VMST iff(`VMST.wlast == 1)) 
            @(`VMST iff(`VMST.wvalid && `VMST.wready && `VMST.wlast)) 
            `VMST.bready <= 1'b1;
               
            @(`VMST);
            `VMST.bready <= 1'b0;

            write_queue.pop_front();
            running_index--;
    
            sema.put(1);
    endtask : write_response_task 
endclass : ei_axi4_master_driver_c 
