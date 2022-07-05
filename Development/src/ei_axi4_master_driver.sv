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

  function new(mailbox #(ei_axi4_transaction_c) gen2drv, virtual `MST_INTF vif);
    this.gen2drv = gen2drv;
    this.vif = vif;
  endfunction : new

      task get_trans_from_mailbox();
        forever begin
        gen2drv.get(tr);
        if(tr.transaction_type == WRITE) begin 
          write_address_queue.push_back(tr); 
        end 
        
        else if(tr.transaction_type == READ) begin 
          read_address_queue.push_back(tr);
        end 
        end // forever 
      endtask : get_trans_from_mailbox

      task reset();  // as it is asynchronous reset thread so we used vif instead of `VMST 
          vif.awvalid <= 0;
          vif.wvalid <= 0;
          vif.arvalid <= 0;
          vif.rready <= 0;
          vif.bready <= 0;
          write_address_queue.delete();
          read_address_queue.delete(); 
          wait(vif.aresetn == 1'b1);
      endtask : reset

      task run();
        forever begin
           reset();
           fork : driver_run
              get_trans_from_mailbox();
              write_address_channel();
              write_data_channel();
              write_response_channel();
              read_address_channel();
              read_data_channel();
             @(negedge vif.aresetn);
           join_any 
           disable driver_run;                 
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

        write_address.burst = WRAP;
        end// error_wrap_unaligned

        else if(tr.errors == ERROR_4K_BOUNDARY) begin 

          $display("################## ERROR INJECTED - WRAP  4K Boundary#####################");
          write_address.addr = (write_address.addr - (write_address.addr % 4096) + 4096 - 1); 
          write_address.len = $urandom_range(1,255);
          write_address.burst = INCR;

        end 
        
        else if(tr.errors == ERROR_FIXED_LEN) begin 

          write_address.burst = FIXED;

        if(write_address.len <= 15) begin 
          write_address.len = write_address.len + $urandom_range(16,255);
        end

        end // error_fixed_len 

        else if(tr.errors == ERROR_WRAP_LEN) begin 

        write_address.burst = WRAP;

        if(((write_address.len == 1) | (write_address.len == 3) | (write_address.len == 7) | (write_address.len == 15))) begin 
          write_address.len = write_address.len + 1'b1;
        end
        end // error_wrap_len 

        $display("------- write_address = %0h", write_address.addr);
        $display("------- write burst = %0h", write_address.burst);
        $display("------- write_len = %0h", write_address.len);
        $display("------- write_size = %0h", write_address.size);
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
          `VMST.arvalid <= 1'b1;

        if(tr.errors == ERROR_WRAP_UNALLIGNED) begin 
          if((read_address.addr / 2 ** tr.size) * (2 ** tr.size)) begin 
            read_address.addr = read_address.addr + 1'b1; 
          end
          read_address.burst = WRAP;
        end// error_wrap_unaligned

        if(tr.errors == ERROR_4K_BOUNDARY) begin 
          read_address.addr = (read_address.addr - (read_address.addr % 4096) + 4096 - 1); 
          read_address.len = $urandom_range(1,255);
          read_address.burst = INCR;
        end 
        
        else if(tr.errors == ERROR_FIXED_LEN) begin 

          read_address.burst = FIXED;

        if(read_address.len <= 15) begin 
          read_address.len = read_address.len + $urandom_range(16,255);
        end
        end // error_fixed_len 

        else if(tr.errors == ERROR_WRAP_LEN) begin 

        read_address.burst = WRAP;  

        if(((read_address.len == 1) | (read_address.len == 3) | (read_address.len == 7) | (read_address.len == 15))) begin 
          read_address.len = read_address.len + 1'b1;
        end
        end // error_wrap_len 

        //$display("-------> write_address = %0h", read_address.addr);
        //$display("-------> write burst = %0h", read_address.burst);
        //$display("-------> write_len = %0h", read_address.len);
        //$display("-------> write_size = %0h", read_address.size);
          `VMST.araddr <= read_address.addr;
          `VMST.arlen <= read_address.len;
          `VMST.arsize <= read_address.size;
          `VMST.arburst <= read_address.burst;
       //   $display("LILILILILILILILILILILILILILILILILILI    >>>>>>>>>>>   driven address = ",vif.araddr);
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

          `VMST.rready <= 1'b0;
          $display("time",$time);  
        end // forever 

      endtask : read_data_channel
        
endclass : ei_axi4_master_driver_c 

