class ei_axi4_reference_model_c;

    ei_axi4_transaction_c tr;
    ei_axi4_transaction_c read_trans;

    int aligned_address;
    int memory_address;
    int no_of_bytes;
    bit [31:0] lower_wrap_boundary;
    bit [31:0] upper_wrap_boundary;
    
    mailbox#(ei_axi4_transaction_c) mst_mon2ref;
    mailbox#(ei_axi4_transaction_c) ref2scb;

    bit [`DATA_WIDTH - 1:0] reference_memory [bit [`ADDR_WIDTH - 1]];

    function new(mailbox#(ei_axi4_transaction_c) mst_mon2ref, mailbox#(ei_axi4_transaction_c) ref2scb);
        this.mst_mon2ref = mst_mon2ref;
        this.ref2scb = ref2scb;
    endfunction

    task run();
        
        forever begin
            mst_mon2ref.get(tr);
            no_of_bytes = 2 ** tr.size;
            $display("[reference_model] = %0p",tr);
            if(tr.transaction_type == WRITE) begin 
              write_to_memory();
            end 
            if(tr.transaction_type == READ) begin
              read_from_memory();
            end
          end
      endtask

    function write_to_memory();

            if(tr.burst == FIXED) begin 
                      fixed_burst_write();
                    end 

            if(tr.burst == INCR) begin
                      incr_burst_write(); 
                    end 

            if(tr.burst == WRAP) begin 
                      wrap_burst_write();
                    end 

          endfunction : write_to_memory
            
                function read_from_memory();

                    if(tr.burst == FIXED) begin 
                              fixed_burst_read();
                            end 

                    if(tr.burst == INCR) begin
                              incr_burst_read(); 
                            end 

                    if(tr.burst == WRAP) begin 
                              wrap_burst_read();
                            end   

                  endfunction : read_from_memory


                function fixed_burst_write();

                    aligned_address = tr.addr;
                    $display("addr = ", tr.addr);
                    $display("len = ", tr.len);
                    $display("size = ", tr.size);
                    $display("nsize = ", no_of_bytes);
                    $display("burst = ", tr.burst);

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = (aligned_address) / (8);
                        for(int j = 0 ; j <= `BUS_BYTE_LANES ; j++) begin
                            if(tr.wstrb[i][j] == 1'b1) begin 
                                reference_memory [memory_address] [(8 * j) + 7 -: 8] = tr.data[i][(8*j) + 7 -: 8];
                            end 
                        end 
                    end 
                  $display(reference_memory);

                endfunction : fixed_burst_write   
                
                function incr_burst_write();
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = (aligned_address) / (no_of_bytes);
                        for(int j = 0 ; j <= `BUS_BYTE_LANES ; j++) begin
                            if(tr.wstrb[i][j] == 1'b1) begin 
                                reference_memory [memory_address] [(8 * j) + 7 -: 8] = tr.data[i][(8*j) + 7 -: 8];
                            end 
                        end 
                            aligned_address = ((aligned_address / no_of_bytes) * no_of_bytes);
                            aligned_address = aligned_address + no_of_bytes;
                    end 
                
                endfunction : incr_burst_write   
                
                function wrap_burst_write();

                    aligned_address = tr.addr;
                    lower_wrap_boundary = (aligned_address - (aligned_address % (no_of_bytes * (tr.len + 1))));
                    upper_wrap_boundary = (lower_wrap_boundary + (no_of_bytes * (tr.len + 1)));

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = (aligned_address) / (no_of_bytes);
                        for(int j = 0 ; j <= `BUS_BYTE_LANES ; j++) begin
                            if(tr.wstrb[i][j] == 1'b1) begin 
                               reference_memory [memory_address] [(8*j) + 7 -: 8] = tr.data[i][(8*j) + 7 -: 8];
                            end 
                        end 
                            aligned_address = ((aligned_address / no_of_bytes) * no_of_bytes);
                            aligned_address = aligned_address + no_of_bytes;

                            if(aligned_address > upper_wrap_boundary) begin 
                                aligned_address = lower_wrap_boundary;
                            end  
                    end 

                endfunction : wrap_burst_write
                
                function fixed_burst_read();

                    read_trans = new();
                    read_trans.data = new[tr.len+1];
                    
                    aligned_address = tr.addr - (tr.addr % no_of_bytes);

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = aligned_address / 8;

                        for(int j = tr.addr; j <= aligned_address + no_of_bytes ; j++) begin 
                            read_trans.data [i][(8 * (j % 8)) + 7 -: 8] = reference_memory [memory_address] [(8 * (j % 8)) + 7 -: 8] ; 
                        end 
                    end 
                  read_trans.print("REF");
                  ref2scb.try_put(read_trans);

                endfunction : fixed_burst_read


                function incr_burst_read();

                    read_trans = new();
                    read_trans.data = new[tr.len];
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = aligned_address / 8;

                        for(int j = aligned_address ; j <= aligned_address + no_of_bytes ; j++) begin 
                            read_trans.data [i][(8 * (j % 8)) + 7 -: 8] = reference_memory [memory_address] [(8 * (j % 8)) + 7 -: 8] ; 
                        end 

                        aligned_address = ((aligned_address % no_of_bytes) / (no_of_bytes));
                        aligned_address = aligned_address + no_of_bytes;
                    end 
                  ref2scb.try_put(read_trans);

                endfunction : incr_burst_read

                function wrap_burst_read();

                    aligned_address = tr.addr;
                    lower_wrap_boundary = (aligned_address - (aligned_address % (no_of_bytes * (tr.len + 1))));
                    upper_wrap_boundary = (lower_wrap_boundary + (no_of_bytes * (tr.len + 1)));
                    
                    read_trans = new();
                    read_trans.data = new[tr.len];
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = aligned_address / 8;

                        for(int j = aligned_address ; j <= aligned_address + no_of_bytes ; j++) begin 
                            read_trans.data [i][(8 * (j % 8)) + 7 -: 8] = reference_memory [memory_address] [(8 * (j % 8)) + 7 -: 8];  
                        end 

                        aligned_address = ((aligned_address % no_of_bytes) / (no_of_bytes));
                        aligned_address = aligned_address + no_of_bytes;

                        if(aligned_address > upper_wrap_boundary) begin 
                            aligned_address = lower_wrap_boundary; 
                        end 
                    end 
                  ref2scb.try_put(read_trans);

                endfunction : wrap_burst_read

                function void wrap_up();
             
                endfunction

endclass : ei_axi4_reference_model_c
/*
ass ei_AXI_refrance_model;

  bit [`BUS_WIDTH-1:0] AXI_ref_mem[int]; // need of associative array

  ei_AXI_master_transaction tr; // create handle to get read/write packet
  ei_AXI_master_transaction read_tr; // create handle to send read packet

  mailbox#(ei_AXI_master_transaction) mon2ref; // mailbox for monitor to refernce model
  mailbox#(ei_AXI_master_transaction) ref2scb; // mailbox for refernce model to scoreboard

  function new( mailbox#(ei_AXI_master_transaction) mon2ref,mailbox#(ei_AXI_master_transaction) ref2scb);
    this.mon2ref = mon2ref;
    this.ref2scb = ref2scb;
  endfunction

  task run();
    forever 
    begin
      int aligned_address_w;
      mon2ref.get(tr);
      if(tr.AWVALID == 1) // check condition for AWVALID ( write condition)
        begin
          if(tr.AWBURST==2'b01) // check condition for INCREMENT type BURST
          begin  //increment
            
            aligned_address_w = (tr.AWADDR/(2**tr.AWSIZE))*(2**tr.AWSIZE); // Calculate aligned_address_w
              
            foreach(tr.wdata_arr[j])
              begin
                bit [31:0] mem_addr; // create memory for store data 
                mem_addr = aligned_address_w/8; // find mem_addr
                for(int i = 0; i < `DATA_BUS_BYTES; i++) 
                  begin
                    if(tr.wstrb_arr[j][i]==1) // for strobe condition
                      begin
                         AXI_ref_mem[mem_addr][(8*i) + 7-:8] = tr.wdata_arr[j][(8*i)+7-:8]; // if strobe is 1 then data is valid and store to memory
                      end
                  end
                aligned_address_w = aligned_address_w + 2**tr.AWSIZE; // for calculate next alinged address
              end
            end 
            
            if(tr.AWBURST==2'b10) begin // check condition for WRAP type BURST

              bit [31:0] lower_wrap_boundary_w; 
              bit [31:0] upper_wrap_boundary_w;
            
              lower_wrap_boundary_w = tr.AWADDR - (tr.AWADDR % ((2 ** tr.AWSIZE) * (tr.AWLEN + 1))); // calculate lower wrap boundary
              upper_wrap_boundary_w = (lower_wrap_boundary_w + ((2 ** tr.AWSIZE) * ((tr.AWLEN) + 1))); // calculate upper wrap boundary
              aligned_address_w = tr.AWADDR; // assign AWADDR is to alinged address
            
              foreach(tr.wdata_arr[j])begin
                bit [31:0] mem_addr;
                mem_addr = aligned_address_w/8; // calculate mem_addr location
                for(int i = 0; i < `DATA_BUS_BYTES; i++) begin
                  if(tr.wstrb_arr[j][i]==1) // check condition for strobe
                    begin
                       AXI_ref_mem[mem_addr][(8*i) + 7-:8] = tr.wdata_arr[j][(8*i)+7-:8]; //  if strobe is 1 then data is valid and store to memory
                    end
                end
            
              aligned_address_w = aligned_address_w + 2**tr.AWSIZE; // calculate alinged address
              if(aligned_address_w == upper_wrap_boundary_w) // check for if alinged address is equal to  upper wrap boundary or not 
                begin
                  aligned_address_w = lower_wrap_boundary_w; // if alined address is same as upper wrap boundary then go to lower boundary
                end
            end
            
          end
        end 

    if(tr.ARVALID == 1) // check condition for ARVALID ( read condition)
      begin

        int aligned_address_r;
        int lower_wrap_boundary_r;
        int upper_wrap_boundary_r;
        bit [31:0] mem_addr;

        if(tr.ARBURST==2'b01) // check condition for INCREMENT type BURST
          begin
            read_tr = new(); // allocate memory
            read_tr.rdata_arr = new[tr.ARLEN +1]; //assign memory to dynamic array 
            aligned_address_r = (tr.ARADDR/(2**tr.ARSIZE))*(2**tr.ARSIZE); //calculate aligned address
            for(int i = 0; i < tr.ARLEN+1;i++)
              begin
                mem_addr = aligned_address_r/8; // calculate mem_addr location
                
                for(int j = tr.ARADDR; j < aligned_address_r + 2**tr.ARSIZE ; j++)
                  begin
                    read_tr.rdata_arr[i][(8*(j%8))+7-:8] = AXI_ref_mem[mem_addr][(8*(j%8))+7-:8];
                  end
                      
                tr.ARADDR = aligned_address_r + (2 ** tr.ARSIZE);
                aligned_address_r = aligned_address_r + (2 ** tr.ARSIZE); //count next address
                
              end
          end
          
        if(tr.ARBURST==2'b10) // check condition for WRAP type BURST
          begin
            read_tr = new();
                      lower_wrap_boundary_r = tr.ARADDR - (tr.ARADDR % ((2 ** tr.ARSIZE) * (tr.ARLEN + 1)));//calculate lower boundary of wrap
                      upper_wrap_boundary_r = lower_wrap_boundary_r + ((2 ** tr.ARSIZE) * (tr.ARLEN + 1));  //calculate upper boundary of wrap
            
            read_tr.rdata_arr = new[tr.ARLEN +1]; //assign memory to dynamic array
            for(int i = 0 ; i < tr.ARLEN+1;i++)
              begin
                  mem_addr = tr.ARADDR/8; //find address location for read
                                 
                
                  for(int j = tr.ARADDR;j < tr.ARADDR + 2**tr.ARSIZE; j++)
                    begin 
                      read_tr.rdata_arr[i][(8*(j%8))+7-:8] = AXI_ref_mem[mem_addr][(8*(j%8))+7-:8]; //add data from memory to array
                    end
                  tr.ARADDR = tr.ARADDR + (2 ** tr.ARSIZE); //next aligned address for read 
                  if(tr.ARADDR == upper_wrap_boundary_r) //condition to go lower wrap address after upper boundary
                  begin
                    tr.ARADDR = lower_wrap_boundary_r;
                  end
              end
          end
        ref2scb.put(read_tr);  // putting to scoreboard
      end
    end
  endtask

endclass : ei_AXI_refrance_model*/
