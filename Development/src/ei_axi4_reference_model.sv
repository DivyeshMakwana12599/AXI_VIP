class ei_axi4_reference_model_c;

    ei_axi4_transaction_c tr;
    ei_axi4_transaction_c read_trans;

    bit [`ADDR_WIDTH - 1:0] aligned_address;
    bit [`ADDR_WIDTH - 1:0] memory_address;
    int no_of_bytes;
    bit [`ADDR_WIDTH - 1:0] lower_wrap_boundary;
    bit [`ADDR_WIDTH - 1:0] upper_wrap_boundary;
    
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

                if(tr.transaction_type == WRITE) begin 
                    write_to_memory();
                end 

                if(tr.transaction_type == READ) begin 
                    read_from_memory();
                    ctrl_signals();
                    ref2scb.put(read_trans);
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

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = (aligned_address) / (`BUS_BYTE_LANES);
                      $display("-----------------------------------------------------");
                        $displayh("mem addr = %h", memory_address);
                        $displayh("tr addr = %h", aligned_address);
                        $displayh(unsigned'((aligned_address) / `BUS_BYTE_LANES));
                        $displayh(unsigned'((aligned_address) / (`BUS_BYTE_LANES)));
                        $displayh(aligned_address / 8);
                      $display("-----------------------------------------------------");
                        for(int j = 0 ; j <= `BUS_BYTE_LANES ; j++) begin
                            if(tr.wstrb[i][j] == 1'b1) begin 
                                reference_memory [memory_address] [(8 * j) + 7 -: 8] = tr.data[i][(8*j) + 7 -: 8];
                            end 
                        end 
                    end 

                endfunction : fixed_burst_write   
                
                function incr_burst_write();
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = (aligned_address) / `BUS_BYTE_LANES;
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
                        memory_address = (aligned_address) / `BUS_BYTE_LANES;
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

                  $display("memory = ",reference_memory);
                    read_trans = new();
                    read_trans.data = new[tr.len + 1];
                    read_trans.rresp = new[tr.len + 1];
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = aligned_address / (`BUS_BYTE_LANES);
                      read_trans.rresp[i] = OKAY;

                        for(
                          bit [31:0] j = aligned_address ; 
                          j < (aligned_address - 
                               (aligned_address % no_of_bytes)) + 
                               no_of_bytes ; j++) begin 
                            read_trans.data [i][(8 * (j % 8)) + 7 -: 8] = 
                              reference_memory [memory_address] 
                                 [(8 * (j % 8)) + 7 -: 8] ; 
                        end 
                    end 

                endfunction : fixed_burst_read

                function incr_burst_read();

                    read_trans = new();
                    read_trans.data = new[tr.len];
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = aligned_address / `BUS_BYTE_LANES;

                        for(int j = aligned_address ; j <= aligned_address + no_of_bytes ; j++) begin 
                            read_trans.data [i][(8 * (j % 8)) + 7 -: 8] = reference_memory [memory_address] [(8 * (j % 8)) + 7 -: 8] ; 
                        end 

                        aligned_address = ((aligned_address % no_of_bytes) / (no_of_bytes));
                        aligned_address = aligned_address + no_of_bytes;
                    end 

                endfunction : incr_burst_read

                function wrap_burst_read();

                    aligned_address = tr.addr;
                    lower_wrap_boundary = (aligned_address - (aligned_address % (no_of_bytes * (tr.len + 1))));
                    upper_wrap_boundary = (lower_wrap_boundary + (no_of_bytes * (tr.len + 1)));
                    
                    read_trans = new();
                    read_trans.data = new[tr.len];
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = aligned_address / `BUS_BYTE_LANES;

                        for(int j = aligned_address ; j <= aligned_address + no_of_bytes ; j++) begin 
                            read_trans.data [i][(8 * (j % 8)) + 7 -: 8] = reference_memory [memory_address] [(8 * (j % 8)) + 7 -: 8];  
                        end 

                        aligned_address = ((aligned_address % no_of_bytes) / (no_of_bytes));
                        aligned_address = aligned_address + no_of_bytes;

                        if(aligned_address > upper_wrap_boundary) begin 
                            aligned_address = lower_wrap_boundary; 
                        end 
                    end 

                endfunction : wrap_burst_read

                function void ctrl_signals();

                    read_trans.addr = tr.addr;
                    read_trans.len = tr.len;
                    read_trans.size = tr.size;
                    read_trans.burst = tr.burst;

                endfunction : ctrl_signals 

                function void wrap_up();
             
                endfunction

endclass : ei_axi4_reference_model_c
