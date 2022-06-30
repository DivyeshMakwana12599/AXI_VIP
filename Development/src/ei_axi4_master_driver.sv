class ei_axi4_master_driver_c;
    
    ei_axi4_transaction_c tr;

    ei_axi4_transaction_c write_queue[$];
    ei_axi4_transaction_c read_queue[$];

    mailbox #(ei_axi4_transaction_c) gen2drv;
    int write_running_index, read_running_index;
    virtual `MST_INTF vif;
    semaphore sema_write,sema_read,sema_response;

    function new(mailbox #(ei_axi4_transaction_c) gen2drv, virtual `MST_INTF vif);
        this.gen2drv = gen2drv;
        this.vif = vif;
        sema_write = new(1);
        sema_read = new(1);
        sema_response = new(1);

        vif.awaddr = 0;
        vif.awvalid = 0;
        vif.awburst = FIXED;
        vif.awlen = 0;
        vif.awsize = 0;
        vif.wvalid = 0;
        vif.wdata = 0;
        vif.wstrb = 0;
        vif.wlast = 0;

        vif.arvalid = 0;
        vif.arburst = FIXED;
        vif.arlen = 0;
        vif.arsize = 0;
        vif.araddr = 0;
        vif.rready = 0;
        vif.bready = 0;
         
    endfunction : new

    task run();
        forever begin
            gen2drv.get(tr);
            fork//1
                begin //1
                        if(tr.transaction_type == WRITE)begin
                            write_queue.push_back(tr);
                                $display("write_queue = %0p",tr.data);
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
        
      inject_error();

        `VMST.awaddr <= write_queue[write_running_index].addr;
        `VMST.awburst <= write_queue[write_running_index].burst;
        `VMST.awlen <= write_queue[write_running_index].len;
        `VMST.awsize <= write_queue[write_running_index].size;
        write_running_index++;
        
      @(`VMST iff(`VMST.awready <= 1'b1)) 
        `VMST.awvalid <= 1'b0;
//        `VMST.awaddr <= 'bx;
        
    endtask : write_address_task 

    task write_data_task();
        
        sema_write.get(1);   

        @(`VMST iff(`VMST.awready));
        `VMST.wvalid <= 1'b1;

        for(int i = 0; i <= write_queue[0].len ; i++)begin 
            `VMST.wdata <= write_queue[0].data[i];
            `VMST.wstrb <= write_queue[0].wstrb[i];

            if(i == write_queue[0].len)begin 
                `VMST.wlast <= 1'b1;
                $display("[MST DRV] --> .... @%0t WLAST Asserted",$time);
            end

            @(`VMST iff(`VMST.wready));
                
        end //for

        //if(`VMST.wlast == 1'b1)begin
       // @(`VMST iff(`VMST.wlast == 1'b1))
            `VMST.wvalid <= 1'b0;
            `VMST.wlast <= 1'b0;
             $display("[MST DRV] --> .... @%0t WLAST Deasserted",$time);
 //           `VMST.wdata <= 'bx;
  //          `VMST.wstrb <= 'bx;

            write_queue.pop_front();
            $display(write_queue.size,$time);
            write_running_index--;
    
            sema_write.put(1);
    endtask : write_data_task

    task write_response_task();
            sema_response.get(1);
      //  @(`VMST iff(vif.wlast == 1))begin 
            @(`VMST iff(vif.bvalid == 1))
                `VMST.bready <= 1;
                @(`VMST);
                `VMST.bready <= 1'b0;
      //  @(`VMST iff(`VMST.wlast == 1)) 
            //@(`VMST iff(`VMST.wready && `VMST.wlast)) //FIXME : here removed wvalid check is ot okay or not ? 
            //`VMST.bready <= 1'b1;
               
            //@(`VMST);
            //`VMST.bready <= 1'b0;

        //    write_queue.pop_front();
          //  $display(write_queue.size,$time);
            //write_running_index--;
    
            sema_response.put(1);
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
     // $display("Hello");
        `VMST.arvalid <= 1'b0;
   //     `VMST.araddr <= 'bx;
       // `VMST.rlast <= 1'b0;
    endtask : read_address_task
        
    task read_data_task();
        
        sema_read.get(1);

        `VMST.rready <= 1'b1;
       // @(`VMST iff(`VMST.arready));

       // `VMST.rready <= 1'b1; //changes by [SP]
 
        for(int i = 0 ; i <= read_queue[0].len ; i++)begin 

            @(`VMST iff(`VMST.rvalid));

        end// for
      
        `VMST.rready <= 1'b0;

        read_queue.pop_front();
        read_running_index --;
        sema_read.put(1);
        
    endtask : read_data_task

    
    function void inject_error();

      case(tr.errors)
        ///////////////////// for wrap unalligned errorneous scenario //////////////////////////
        ERROR_WRAP_UNALLIGNED : begin

        if((write_queue[write_running_index].addr / 2 ** tr.size) * (2 ** tr.size)) begin 
          write_queue[write_running_index].addr = write_queue[write_running_index].addr + 1'b1; 
        end

        else begin 
          write_queue[write_running_index].addr <= write_queue[write_running_index].addr;
        end
        write_queue[write_running_index].burst = WRAP;

        end// error_wrap_unaligned

        ///////////////////// for 4kb boundary cross errorneous scenario //////////////////////////
        ERROR_4K_BOUNDARY : begin
          write_queue[write_running_index].addr = (write_queue[write_running_index].addr - (write_queue[write_running_index].addr % 4096) + 4096 - 1); 
          write_queue[write_running_index].len = $urandom_range(1,255);
          write_queue[write_running_index].burst = INCR;
        end// error_4k_boundary 
        
        ///////////////////// for fixed length errorneous scenario //////////////////////////
        ERROR_FIXED_LEN : begin
          write_queue[write_running_index].burst = FIXED;

        if(write_queue[write_running_index].len <= 15) begin 
          write_queue[write_running_index].len = write_queue[write_running_index].len + $urandom_range(16,255);
        end

        else begin 
          write_queue[write_running_index].len <= write_queue[write_running_index].len;
        end
        end//error_fixed_len

        ///////////////////// for wrap length errorneous scenario //////////////////////////
        ERROR_WRAP_LEN : begin

        write_queue[write_running_index].burst = WRAP;
  
        if((write_queue[write_running_index].len == 1) | (write_queue[write_running_index].len == 3) | (write_queue[write_running_index].len == 7) | (write_queue[write_running_index].len == 15)) begin 
          write_queue[write_running_index].len = write_queue[write_running_index].len + 1'b1;
        end

        else begin 
           write_queue[write_running_index].len <= write_queue[write_running_index].len;
        end
        end//error_wrap_len
      endcase

    endfunction

endclass : ei_axi4_master_driver_c 
