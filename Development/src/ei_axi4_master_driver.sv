class ei_axi4_master_driver_c;

  ei_axi4_transaction_c tr;

  ei_axi4_transaction_c write_address_queue[$];
  ei_axi4_transaction_c write_data_queue[$];
  ei_axi4_transaction_c write_response_queue[$]; 
  ei_axi4_transaction_c read_address_queue[$];
  ei_axi4_transaction_c read_data_queue[$];

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

      task get_trans_from_mailbox();
        gen2drv.get(tr);
        if(tr.transaction_type == WRITE) begin 
          write_address_queue.push_back(tr); 
        end 
        
        else if(tr.transaction_type == READ) begin 
          read_address_queue.push_back(tr);
        end 
      endtask : get_trans_from_mailbox

      task trigger_tasks();
        fork 
          write_address_channel();
          write_data_channel();
          write_response_channel();
          read_address_channel();
          read_data_channel();
        join_none
      endtask : trigger_tasks

  task run();
    trigger_tasks();
    forever begin
      get_trans_from_mailbox();
    end 
  endtask : run 

    task write_address_channel();

      ei_axi4_transaction_c write_address;

      forever begin 
        wait(write_address_queue.size() > 0);
        write_address = write_address_queue.pop_front();


        @(`VMST);
        `VMST.awvalid <= 1'b1;

        if(tr.errors == ERROR_WRAP_UNALLIGNED) begin 

        if((write_address.addr / 2 ** tr.size) * (2 ** tr.size)) begin 
          write_address.addr = write_address.addr + 1'b1; 
        end

        else begin 
          write_address.addr <= write_address.addr;
        end
        write_address.burst = WRAP;

        end// error_wrap_unaligned

        if(tr.errors == ERROR_4K_BOUNDARY) begin 

          write_address.addr = (write_address.addr - (write_address.addr % 4096) + 4096 - 1); 
          write_address.len = $urandom_range(1,255);
          write_address.burst = INCR;

        end 
        
        if(tr.errors == ERROR_FIXED_LEN) begin 

          write_address.burst = FIXED;

        if(write_address.len <= 15) begin 
          write_address.len = write_address.len + $urandom_range(16,255);
        end

        else begin 
          write_address.len = write_address.len;
        end

        end // error_fixed_len 

        if(tr.errors == ERROR_WRAP_LEN) begin 

        write_address.burst = WRAP;
  
        if((write_address.len == 1) | (write_address.len == 3) | (write_address.len == 7) | (write_address.len == 15)) begin 
          write_address.len = write_address.len + 1'b1;
        end

        else begin 
           write_address.len = write_address.len;
        end
        end // error_wrap_len 

        `VMST.awaddr <= write_address.addr;
        `VMST.awburst <= write_address.burst;
        `VMST.awlen <= write_address.len;
        `VMST.awsize <= write_address.size;

        @(`VMST iff(`VMST.awready <= 1'b1)); 
        `VMST.awvalid <= 1'b0;

        write_data_queue.push_back(write_address);
      end

    endtask : write_address_channel


      task write_data_channel();

        ei_axi4_transaction_c write_data;

        forever begin 
          wait(write_data_queue.size > 0);
          write_data = write_data_queue.pop_front();
          
          @(`VMST iff(`VMST.awready));
          `VMST.wvalid <= 1'b1;

          for(int i = 0; i <= write_data.len ; i++)begin 
            `VMST.wdata <= write_data.data[i];
            `VMST.wstrb <= write_data.wstrb[i];

            if(i == write_data.len)begin 
              `VMST.wlast <= 1'b1;
              $display("[MST DRV] --> .... @%0t WLAST Asserted",$time);
            end

            @(`VMST iff(`VMST.wready));

          end //for

          `VMST.wvalid <= 1'b0;
          `VMST.wlast <= 1'b0;
          
          $display("[MST DRV] --> .... @%0t WLAST Deasserted",$time);

          write_response_queue.push_back(write_data);
        end//forever 
        
      endtask : write_data_channel

      task write_response_channel();
      
        forever begin 
          wait(write_response_queue.size > 0);
          void'(write_response_queue.pop_front());

          @(`VMST iff(vif.bvalid == 1))
          `VMST.bready <= 1;
          @(`VMST);
          `VMST.bready <= 1'b0;
        end//forever 

      endtask : write_response_channel


      task read_address_channel();

        ei_axi4_transaction_c read_address;

        forever begin 
          wait(read_address_queue.size > 0);
          read_address = read_address_queue.pop_front();

          @(`VMST);
          vif.arvalid <= 1'b1;
          `VMST.araddr <= read_address.addr;
          `VMST.arlen <= read_address.len;
          `VMST.arsize <= read_address.size;
          `VMST.arburst <= read_address.burst;

          @(`VMST iff(`VMST.arready));
          `VMST.arvalid <= 1'b0;
          read_data_queue.push_back(read_address);
        end // forever 

      endtask : read_address_channel


      task read_data_channel();

        ei_axi4_transaction_c read_data;

        forever begin 
          wait(read_data_queue.size > 0);
          read_data = read_data_queue.pop_front();
          $display("time",$time);  

          `VMST.rready <= 1'b1;

          for(int i = 0 ; i <= read_data.len ; i++)begin 
            @(`VMST iff(`VMST.rvalid));
          $display("time",$time);  
          end// for

          //@(`VMST);
          `VMST.rready <= 1'b0;
          $display("time",$time);  
        end // forever 

      endtask : read_data_channel
        
endclass : ei_axi4_master_driver_c 

