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
