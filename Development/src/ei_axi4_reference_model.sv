class ei_axi4_reference_model_c;

    ei_axi4_transaction_c tr;
    ei_axi4_transaction_c read_trans;

    bit [`ADDR_WIDTH - 1:0] aligned_address;
    bit [`ADDR_WIDTH - 1:0] memory_address;
    bit [7:0] no_of_bytes;
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
                      if(tr.bresp == SLVERR) begin 
                        reference_memory [memory_address] = 'h0000_0000;
                      end 
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
                        memory_address = (aligned_address) / (`BUS_BYTE_LANES);
                      if(tr.bresp == SLVERR) begin 
                        reference_memory [memory_address] = 'h0000_0000;
                      end 
                        for(int j = 0 ; j <= `BUS_BYTE_LANES ; j++) begin
                            if(tr.wstrb[i][j] == 1'b1) begin 
                                reference_memory [memory_address] [(8 * j) + 7 -: 8] = tr.data[i][(8*j) + 7 -: 8];
                            end 
                        end 
                            aligned_address = ((aligned_address / no_of_bytes) * no_of_bytes);
                            aligned_address = aligned_address + no_of_bytes;
                    end 
                
                endfunction : incr_burst_write   
/*                
                function wrap_burst_write();

                    aligned_address = tr.addr;
                    lower_wrap_boundary = (aligned_address - (aligned_address % (no_of_bytes * (tr.len + 1))));
                    upper_wrap_boundary = (lower_wrap_boundary + (no_of_bytes * (tr.len + 1)));
                    //lower_wrap_boundary = (aligned_address / (no_of_bytes * tr.len)) * (no_of_bytes * tr.len);
                    //upper_wrap_boundary = lower_wrap_boundary + (no_of_bytes * tr.len);

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = (aligned_address) / (`BUS_BYTE_LANES);
                        for(int j = 0 ; j < `BUS_BYTE_LANES ; j++) begin
                            if(tr.wstrb[i][j] == 1'b1) begin 
                               reference_memory [memory_address] [(8*j) + 7 -: 8] = tr.data[i][(8*j) + 7 -: 8];
                                $display("[write wrap burst]bracket_values = ",(8*j)+7);
                            end 
                        end 

                            //aligned_address = ((aligned_address / no_of_bytes) * no_of_bytes);
                            aligned_address = aligned_address + no_of_bytes;

                            if(aligned_address > upper_wrap_boundary) begin 
                                aligned_address = lower_wrap_boundary;
                            end  
                    end 

                endfunction : wrap_burst_write
 */               
                function void wrap_burst_write();

                            bit [31:0] lower_wrap_boundary; 
                            bit [31:0] upper_wrap_boundary;
                        
                            lower_wrap_boundary = tr.addr - (tr.addr % ((2 ** tr.size) * (tr.len + 1))); // calculate lower wrap boundary
                            upper_wrap_boundary = (lower_wrap_boundary + ((2 ** tr.size) * ((tr.len) + 1))); // calculate upper wrap boundary
                            aligned_address =tr.addr; // assign AWADDR is to alinged address
                        
                            foreach(tr.data[j])begin
                                bit [31:0] memory_address;
                                memory_address = aligned_address/8; // calculate mem_addr location
                                if(tr.bresp == SLVERR) begin 
                                  reference_memory [memory_address] = 'h0000_0000;
                                end 
                                for(int i = 0; i < `BUS_BYTE_LANES; i++) begin
                                    if(tr.wstrb[j][i]==1) // check condition for strobe
                                        begin
                                             reference_memory[memory_address][(8*i) + 7-:8] = tr.data[j][(8*i)+7-:8]; //  if strobe is 1 then data is valid and store to memory
                                        end
                                end
                        
                            aligned_address = aligned_address + 2**tr.size; // calculate alinged address
                            if(aligned_address == upper_wrap_boundary) // check for if alinged address is equal to  upper wrap boundary or not 
                                begin
                                    aligned_address = lower_wrap_boundary; // if alined address is same as upper wrap boundary then go to lower boundary
                                end
                            end 
                endfunction : wrap_burst_write
                

                function fixed_burst_read();

                    read_trans = new();
                    read_trans.data = new[tr.len + 1];
                    read_trans.rresp = new[tr.len + 1];
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = aligned_address / (`BUS_BYTE_LANES);


                      if(tr.burst == FIXED && tr.len > 15) begin 
                        read_trans.rresp[i] = SLVERR;
                      end 

                      else begin 
                        read_trans.rresp[i] = OKAY;
                      end 

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
                    read_trans.data = new[tr.len + 1];
                    read_trans.rresp = new[tr.len + 1];
                    
                    aligned_address = tr.addr;

                    for(int i = 0 ; i <= tr.len ; i++) begin 
                        memory_address = aligned_address / (`BUS_BYTE_LANES);

                      $display("reference_model address -=-==-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-= > = ",tr.addr);
                      if(((tr.addr % 4096) + ((tr.len+1) * (2**tr.size))) > 4096) begin
                        $display("4kb_boundary error if confdition dnskjfhbvhjAVDOKFDLISAGIDGSAISKFKUDSFKADS");
                         read_trans.rresp[i] = SLVERR;
                      end 
                      
                      else begin 
                        $display("4kb_boundary if confdition dnskjfhbvhjAVDOKFDLISAGIDGSAISKFKUDSFKADS");
                        read_trans.rresp[i] = OKAY;
                      end 

                        for(bit [`ADDR_WIDTH:0] j = aligned_address ; j < ((aligned_address - (aligned_address % no_of_bytes)) + no_of_bytes) ; j++) begin 
                            read_trans.data [i][(8 * (j % 8)) + 7 -: 8] = 
                              reference_memory [memory_address] 
                                 [(8 * (j % 8)) + 7 -: 8];
                        end 

                        aligned_address = ((aligned_address / no_of_bytes) * (no_of_bytes));
                        aligned_address = aligned_address + no_of_bytes;
                    end 

                endfunction : incr_burst_read


                function void wrap_burst_read();
                  bit [`ADDR_WIDTH - 1 : 0] address;
                  address = tr.addr;
                    $display("reference_memory = ",reference_memory);
                      read_trans = new();
                      lower_wrap_boundary = tr.addr - (tr.addr % ((2 ** tr.size) * (tr.len + 1)));//calculate lower boundary of wrap
                      upper_wrap_boundary = lower_wrap_boundary + ((2 ** tr.size) * (tr.len + 1));  //calculate upper boundary of wrap

                        read_trans.data = new[tr.len + 1]; //assign memory to dynamic array
                        read_trans.rresp = new[tr.len + 1];
                        for(int i = 0 ; i < tr.len+1 ; i++)
                            begin
                                    memory_address = address/8; //find address location for read

                              
                                    $display("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=->>>>>>>>> tr.addr = ",tr.addr);
                                    if(tr.burst == WRAP && !(tr.len inside {1,3,7,15})) begin 
                                      read_trans.rresp[i] = SLVERR;
                                    end 

                                    else if(tr.burst == WRAP && address != ((address/2 ** tr.size) * (2 ** tr.size))) begin 
                                      read_trans.rresp[i] = SLVERR;
                                    end 

                                    else begin 
                                    read_trans.rresp[i] = OKAY;
                                    end 


                                    for(bit [31:0] j = address ; j < address + 2**tr.size; j++)
                                        begin 
                                            read_trans.data[i][(8*(j%8))+7-:8] = reference_memory[memory_address][(8*(j%8))+7-:8]; //add data from memory to array
                                            // $display("bracket value is = ",(8*(j%8))+7);
                                        end
                                    address = address + (2 ** tr.size); //next aligned address for read 
                                    if(address == upper_wrap_boundary) //condition to go lower wrap address after upper boundary
                                    begin
                                        address = lower_wrap_boundary;
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

