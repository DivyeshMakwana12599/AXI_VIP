class ei_axi4_master_driver_c;
    
    ei_axi4_transaction_c tr;

    ei_axi4_transaction_c write_queue[$];
    ei_axi4_transaction_c read_queue[$];

    mailbox #(ei_axi4_transaction_c) gen2drv;
    int write_running_index, read_running_index;
    virtual ei_axi4_interface vif;
    semaphore sema0,sema1;

    function new(mailbox #(ei_axi4_transaction_c) gen2drv, virtual ei_axi4_interface vif);
        this.gen2drv = gen2drv;
        this.vif = vif;
        sema0 = new(1);
        sema1 = new(1);

    endfunction : new
/**
    task run();
        forever begin 
            tr = new();
            gen2drv.get(tr);
            $display("[interface] transaction = %0p",tr);

            if(tr.transaction_type == READ)begin 
                `VMST.arvalid <= 1'b1;
                $display("[interface] arvalid = %0p",vif.arvalid);
                `VMST.araddr <= tr.addr;
                $display("[interface] araddr = %0p", vif.araddr);
            end 
        end 
    endtask : run**/
    

    task run();
        //$display("......................hello"); 
        forever begin
         //   $display("??????????????????hkkkkkkkello");
            gen2drv.get(tr);
            // $display(tr);
            fork//1
            // check logic in fork join_any
                begin //1
                        if(tr.transaction_type == WRITE)begin
                            write_queue.push_back(tr);
                            write_address_task();
                         fork//2
                            write_data_task();
                            write_response_task();
                         join_none//2 
                        end 
                end //1

                begin //2
                    
                        if(tr.transaction_type == READ)begin
                            read_queue.push_back(tr);
                            read_address_task(); 
                            fork//3
                                 read_data_task(); // join none here only 
                            join_none//3
                        end
                end //2

                begin //3

                        if(tr.transaction_type == READ_WRITE)begin
                            fork//4
                                write_address_task();
                                read_address_task();
                            join//4

                            fork //5
                                write_data_task();
                                write_response_task();
                                read_data_task();
                            join_none//5

                        end
                end//3
            join // 1
        end // forever
        #5;
    
    endtask : run

    task write_address_task();
        @(`VMST);
        `VMST.awvalid <= 1'b1;
       // $display("write_running_index = %0d",write_running_index);
      //  $display("write_queue = %0p",write_queue);

        `VMST.awaddr <= write_queue[write_running_index].addr;
        `VMST.awburst <= write_queue[write_running_index].burst;
        `VMST.awlen <= write_queue[write_running_index].len;
        `VMST.awsize <= write_queue[write_running_index].size;
        write_running_index++;

        @(`VMST iff(`VMST.awready <= 1'b1)) 
        `VMST.awvalid <= 1'b0;
        `VMST.wlast <= 1'b0;
        

    endtask : write_address_task 

    task write_data_task();
        
        sema0.get(1);   

        //@(`VMST iff(`VMST.awready));
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
       // @(`VMST iff(`VMST.wlast == 1'b1))
            `VMST.wvalid <= 1'b0;
            `VMST.wlast <= 1'b0;
            `VMST.wdata <= 'bx;
            `VMST.wstrb <= 'bx;

    endtask : write_data_task

    task write_response_task();
    
      //  @(`VMST iff(vif.wlast == 1))begin 
            @(`VMST iff(vif.bvalid <= 1))
                `VMST.bready <= 1;
                @(`VMST);
                `VMST.bready <= 1'b0;
      //  @(`VMST iff(`VMST.wlast == 1)) 
            //@(`VMST iff(`VMST.wready && `VMST.wlast)) //FIXME : here removed wvalid check is ot okay or not ? 
            //`VMST.bready <= 1'b1;
               
            //@(`VMST);
            //`VMST.bready <= 1'b0;

            write_queue.pop_front();
            write_running_index--;
    
            sema0.put(1);
    endtask : write_response_task 


    task read_address_task();
        
        @(`VMST);
        vif.arvalid <= 1'b1;
        `VMST.araddr <= read_queue[read_running_index].addr;
        `VMST.arlen <= read_queue[read_running_index].len;
        `VMST.arsize <= read_queue[read_running_index].size;
        `VMST.arburst <= read_queue[read_running_index].burst;
        read_running_index ++;
        
        @(`VMST iff(`VMST.arready));
      $display("Hello");
        `VMST.arvalid <= 1'b0;
       // `VMST.rlast <= 1'b0;
    endtask : read_address_task
        
    task read_data_task();
        
        sema1.get(1);

        `VMST.rready <= 1'b1;
        @(`VMST iff(`VMST.arready));

       // `VMST.rready <= 1'b1; //changes by [SP]
 
        for(int i = 0 ; i <= read_queue[0].len ; i++)begin 

            @(`VMST iff(`VMST.rvalid));

        end// for
      
        `VMST.rready <= 1'b0;

        read_queue.pop_front();
        read_running_index --;
        sema1.put(1);
        
    endtask : read_data_task

    
endclass : ei_axi4_master_driver_c 
