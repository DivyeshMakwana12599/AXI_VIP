/**
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name   : ei_axi4_slave_driver.sv
Title       : Slave Driver Class
Project     : AMBA AXI-4 SV VIP
Created On  : 07-June-22
Developers  : Shivam Prasad
Purpose     : Driver Class does handshaking and response for all channel 
              parallely.
              1. In write transaction, slave driver recives the 
                 data from interface and writes in driver memory,
              2. In read trnsaction, driver will drive the (as per request
                 generated by master) from its own memory to interface. 
        
-------------------------------------------------------------------------
-------------------------------------------------------------------------
Copyright (c) 2000-2022 eInfochips - All rights reserved
This software is authored by eInfochips and is eInfochips intellectual
property, including the copyrights in all countries in the world. This
software is provided under a license to use only with all other rights,
including ownership rights, being retained by eInfochips
This file may not be distributed, copied, or reproduced in any manner,
electronic or otherwise, without the express written consent of
eInfochips 
-------------------------------------------------------------------------------
Revision  : 0.1
-------------------------------------------------------------------------------
**/


class ei_axi4_slave_driver_c #(DATA_WIDTH = `DATA_WIDTH,
                               ADDR_WIDTH = `ADDR_WIDTH);
  //Declaration 
  bit [ DATA_WIDTH - 1 : 0] slv_drv_mem [bit [ADDR_WIDTH - 1 : 0]];
  ei_axi4_transaction_c write_data_queue[$];
  ei_axi4_transaction_c read_data_queue[$];
  ei_axi4_transaction_c write_response_queue[$];
  virtual `SLV_INTF vif; 

/**
*\   Method name          : new()
*\   parameters passed    : virtual interface handle                      
*\   Returned parameters  : None
*\   Description          : function links virtual interface which was passed
*\                          from slave agent
**/

  function new(virtual `SLV_INTF vif);
    this.vif    = vif;
    print_build;
  endfunction

/**
*\   Method name          : print_build()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This function prints the interface linking status.
**/
  function print_build;
    $display("---------------------------------------------------------------");
    $display("[SLV_DRV] \t\tVirtual Interface has been linked.");
    $display("---------------------------------------------------------------");
  endfunction : print_build

/**
*\   Method name          : run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : this task contains multiple task within fork 
*\                          join_any which are following AXI Protocol for 
*\                          reset,write address,write data,write response, 
*\                          read address, read data
**/

  task run();
    forever begin
      reset();
      fork : run_AXI_slave_driver
        @(negedge vif.aresetn);
        write_address_run();
        write_data_run();
        write_response_run();
        read_address_run();
        read_data_run();
      join_any
      disable run_AXI_slave_driver;
    end
  endtask : run


/**
*\   Method name          : reset()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : this task resets slave driver and erases the control
*\                          signals and queues.
*\                         
*\                          
**/
  task reset();
      $display("[SLV_DRV] \t\t@%0t --> fork join disabled",$time);
      $display("-------------------------------------------------------------");
      $display("################ RESET HAS BEEN ASSERTED !! #################");
      $display("############### SLAVE DRIVER HAS BEEN PAUSED !! #############");
      $display("-------------------------------------------------------------");
      vif.awready      <= 0;
      vif.arready      <= 0;
      vif.wready       <= 0;
      vif.bvalid       <= 0;
      vif.rvalid       <= 0;
      write_data_queue.delete();
      read_data_queue.delete();
      write_response_queue.delete();
      wait(vif.aresetn == 1);
      $display("################ RESET HAS BEEN DEASSERTED !! ############## ");
      $display("-------------------------------------------------------------");
  endtask
/**
*\   Method name          : write_address_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task acts as axi write address channel. it 
*\                          asserts awready and waits for awvalid to be asserted
*\                          once this handshaking is done then it immediately 
*\                          scans for all the control signals on same clock tick
*\                          and store them in transaction write packet
**/

  task write_address_run();
    // transaction class 
    ei_axi4_transaction_c write_trans;
    vif.awready               <= 0;
      @(`VSLV);
    forever begin
      `VSLV.awready           <= 1;
       $display("------------------------------------------------------------");
       $display("[Write Address Channel]",
                " \t\t@%0t --> AWREADY Asserted",$time);
       @(`VSLV iff(`VSLV.awvalid == 1)); 
       write_trans               = new();
       $display("[Write Address Channel]",
                " @%0t --> AWVALID & AWREADY Handshaked ",$time);
       // sample the interface and make the packet
       write_trans.addr          =  `VSLV.awaddr;
       write_trans.burst         =  `VSLV.awburst;
       write_trans.len           =  `VSLV.awlen;
       write_trans.size          =  `VSLV.awsize;
       write_data_queue.push_back(write_trans);
       $display("[Write Address Channel]",
                " @%0t --> write data queue = %0p",$time,write_data_queue);
       $display("------------------------------------------------------------");
     end
   endtask : write_address_run

/**
*\   Method name          : write_data_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task acts as AXI write Data Channel. For Very
*\                          first transaction, task waits for to write data
*\                          queue to be filled with address and control signals
*\                          after that write data channel starts functioning
**/

  task write_data_run();
    //declaration of varaibles 
    bit [`ADDR_WIDTH - 1 : 0] addr;
    bit [`ADDR_WIDTH - 1 : 0] alligned_addr;
    bit [`ADDR_WIDTH - 1 : 0] mem_addr;
    ei_axi4_transaction_c write_trans;
    vif.wready       = 0;
    //wait for one clock as reset gets asserted
      @(`VSLV);
    
    forever begin
      //if write data queue is empty then wait here.
      wait(write_data_queue.size > 0);
      // pop queue and store locally
      write_trans      = write_data_queue.pop_front();
      //Assert wready, as a indicator that salve is ready to accept the data
      `VSLV.wready     <= 1;
      alligned_addr   = write_trans.addr - 
                                    (write_trans.addr % (2**write_trans.size));
  
      //identify the protocol violated transactions 
      calculate_error_write(write_trans);

      //rotate for loop as per transaction lenghth
      for(int i = 0; i < write_trans.len + 1; i++) begin
        @(`VSLV iff(`VSLV.wvalid == 1 ));

        //FIXED
        if(write_trans.burst == FIXED) begin        
          addr     =  write_trans.addr;
          mem_addr = addr/(`BUS_BYTE_LANES);
        end
        
        //INCREMENTAL
        else if(write_trans.burst == INCR ) begin
          if(i == 0) begin
            addr   = write_trans.addr;
            mem_addr = addr/(`BUS_BYTE_LANES);
          end
          else begin
            addr   = alligned_addr + (i * (2**write_trans.size));
            mem_addr   = addr / (`BUS_BYTE_LANES);
          end
        end

        //WRAP
        else if(write_trans.burst == WRAP) begin
          bit [`ADDR_WIDTH - 1 : 0] lwb      = write_trans.addr - 
          ( write_trans.addr % ((write_trans.len + 1) * (2**write_trans.size)));
          
          bit [`ADDR_WIDTH - 1 : 0] uwb      = lwb +  
                                ((write_trans.len + 1) * (2**write_trans.size));
          if(i == 0) begin
            addr = write_trans.addr;
          end
          else begin
            addr       += (2** write_trans.size);
          end
          //if upper wrap boundary gets crossed than start with lower wrap bound.
          if(addr == uwb) begin
            addr   =  lwb;
          end
          mem_addr = addr/ (`BUS_BYTE_LANES);
        end
        
      //if there is no error in transaction then store the data into slave memory
        if(write_trans.errors == NO_ERROR) begin  
          for(int j = 0; j < `BUS_BYTE_LANES; j++) begin
            if(`VSLV.wstrb[j] == 1 ) begin
              slv_drv_mem[mem_addr][(8*j) + 7-:8] = `VSLV.wdata[(8*j)+7 -: 8];
            end
          end
        end
      end
      //push back the packet into write reponse queue for write response
      write_response_queue.push_back(write_trans);
    end
      
  endtask : write_data_run


/**
*\   Method name          : write_response_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : this task gives write response for every transaction
*\                          if successful transaction has occured then slave  
*\                          will send response as "OKAY". Also if there is any
*\                          successful/unsuccessful transaction with any
*\                          protocol violation (i.e crossing 4KB Boundary,
*\                          invalid size of transfer) then slave will respond
*\                          with "SLVERR". Note that, we are asserting bvalid 
*\                          signal while asserting write response (bresp) and 
*\                          keeping these signal asserted until master sends 
*\                          bready signal.
**/
  task write_response_run();
    ei_axi4_transaction_c write_trans;
    vif.bvalid         = 0 ;
      @(`VSLV);
    
    forever begin
      // As soon as a queue gets filled start the reponse
      wait(write_response_queue.size > 0);
      write_trans      = write_response_queue.pop_back();
      @(`VSLV);
      `VSLV.bvalid      <= 1;
      if(write_trans.errors != NO_ERROR) begin
        `VSLV.bresp     <= SLVERR;
      end
      else begin
        `VSLV.bresp     <= OKAY;
      end
      @(`VSLV iff(`VSLV.bready == 1));
      `VSLV.bvalid      <= 0;
    end
  endtask

/**
*\   Method name          : calculate_error_error_write()
*\   parameters passed    : write transaction packet                      
*\   Returned parameters  : None
*\   Description          : this functions identifies the possible errorenous
*\                          transaction. if there is one then this function will
*\                          set "errors" named enum.
*\                       
**/
   function void calculate_error_write(ei_axi4_transaction_c write_tr);
     if((((write_tr.addr - (write_tr.addr % (2 ** write_tr.size))) % 4096) + 
                          ((write_tr.len+1) * (2**write_tr.size))) > 4096) begin
       write_tr.errors    =  ERROR_4K_BOUNDARY;
       $display("[SLV DRV]", 
            " [WRITE CHANNEL] ERROR DETECTED : 4K BOUNDARY CROSSING DETECTED ");
       return;
     end
     if(write_tr.burst == WRAP && !(write_tr.len inside {1,3,7,15}) ) begin
       write_tr.errors    = ERROR_WRAP_LEN;
       $display("[SLV DRV]",
               " [WRITE CHANNEL] ERROR DETECTED : ERROR IN WRAP LEN DETECTED ");
        return;
      end
      if(write_tr.burst == WRAP && write_tr.addr != 
                ((write_tr.addr/(2**write_tr.size))* (2**write_tr.size))) begin
        write_tr.errors   = ERROR_WRAP_UNALLIGNED;
       $display("[SLV DRV]",
                " [WRITE CHANNEL] ERROR WRAP UNALLIGNED DETECTED ");
        return;
      end 
      if(write_tr.burst == FIXED && !(write_tr.len inside {[0:15]})) begin
        write_tr.errors   = ERROR_FIXED_LEN;
       $display("[SLV DRV]",
                " [WRITE CHANNEL] ERROR FIXED LEN DETECTED ");
        return;
      end

    endfunction : calculate_error_write

/**
*\   Method name          : read_address_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task acts as axi read address channel. it 
*\                          asserts arready and waits for arvalid to be asserted
*\                          once this handshaking is done then it immediately 
*\                          scans for all the control signals on same clock tick
*\                          and store them in transaction read packet
**/                        
  task read_address_run();
    ei_axi4_transaction_c read_trans;
    vif.arready                 <= 0;
      @(`VSLV);
    forever begin
      `VSLV.arready             <= 1;
       $display("--------------------------------------------------------:---");
       @(`VSLV iff(`VSLV.arvalid == 1)); 
       read_trans                = new();
       $display("[Write Address Channel]",
                " @%0t ARVALID & ARREADY Handshaked ",$time);
       read_trans.addr           =  `VSLV.araddr;
       read_trans.burst          =  `VSLV.arburst;
       read_trans.len            =  `VSLV.arlen;
       read_trans.size           =  `VSLV.arsize;
       read_data_queue.push_back(read_trans);
     end
   endtask : read_address_run

/*
*\   Method name          : read_data_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : this task is acting as AXI read data channel. After
*\                          succesful handshaking of rvalid and rready, as per
*\                          control signal provided by master, this task will 
*\                          drive rdata to slave interface.
**/
  task read_data_run();
    //local required varialbles 
    bit [`ADDR_WIDTH - 1 : 0] addr;
    bit [`ADDR_WIDTH - 1 : 0] alligned_addr;
    bit [`ADDR_WIDTH - 1 : 0] mem_addr;
    ei_axi4_transaction_c read_trans;
    vif.rvalid          = 0;
    vif.rlast           = 0;
    vif.rdata           = 0;
    @(`VSLV);

    forever begin
      //wait till read transaction gets initiated or queue gets filled
      wait(read_data_queue.size > 0);
      read_trans         = read_data_queue.pop_front();
      alligned_addr      = read_trans.addr - 
                                      (read_trans.addr % (2**read_trans.size));
         
      for(int i = 0; i < read_trans.len + 1 ; i++) begin
        `VSLV.rvalid     <= 1;

        //FIXED Burst
        if(read_trans.burst  == FIXED) begin
          mem_addr       = read_trans.addr/(`BUS_BYTE_LANES);
          addr           = read_trans.addr;
        end
        
        // INCREMENTAL Burst
        else if(read_trans.burst  == INCR) begin
          if(i == 0) begin
            addr         = read_trans.addr;
            mem_addr     = addr/(`BUS_BYTE_LANES);
          end
          else begin 
            addr         = alligned_addr + (i * (2**read_trans.size));
            mem_addr     = addr / (`BUS_BYTE_LANES);
          end
        end
        
        //WRAP Burst
        else if(read_trans.burst  == WRAP) begin
          bit [`ADDR_WIDTH - 1 : 0] lwb      = read_trans.addr - 
            ( read_trans.addr % ((read_trans.len + 1) * (2**read_trans.size)));
          
          bit [`ADDR_WIDTH - 1 : 0] uwb      = lwb +  
                                  ((read_trans.len + 1) * (2**read_trans.size));
          if(i == 0) begin
            addr      = read_trans.addr;
          end
          else begin
            addr      +=  ((2** read_trans.size));
          end
          if(addr == uwb) begin
            addr      =  lwb;
          end
          mem_addr    = addr/ (`BUS_BYTE_LANES);
        end

        //calculate or identify errorneous transaction
        calculate_error_read(read_trans);

        read_trans.data    = new[1];
        for(bit [31:0] j = addr; 
            j < (addr - (addr % (2**read_trans.size))) 
            + (2**read_trans.size) ; j++) begin
         read_trans.data[0][(8*(j % 8)) + 7 -: 8] = slv_drv_mem[mem_addr][(8*(j % 8)) + 7 -: 8];
        end

        //if errorneous transaction detected then send rdata with value '0'
        if(read_trans.errors == NO_ERROR) begin 
          `VSLV.rdata       <=   read_trans.data[0];
        end
        else begin
          `VSLV.rdata       <=  0;
        end

        //if last beat/transfer then assert rlast
        if(i == read_trans.len) begin 
          `VSLV.rlast     <= 1;
        end
        else begin
          `VSLV.rlast     <= 0;
        end
        
        //if errorneous transaction detected then send slave error in read response 
        if(read_trans.errors != NO_ERROR) begin
          `VSLV.rresp     <= SLVERR;
        end
        else begin 
          `VSLV.rresp     <= OKAY;
        end
        @(`VSLV iff(`VSLV.rready == 1));
      end
      `VSLV.rvalid    <= 0;
      `VSLV.rlast     <= 0;
      @(`VSLV);
    end
   endtask : read_data_run


/**
*\   Method name          : calculate_error_read()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : this functions identifies the possible errorenous
*\                          transaction. if there is one then this function will
*\                          set "errors" named enum.
**/
   function void calculate_error_read(ei_axi4_transaction_c read_tr);
     if((((read_tr.addr - (read_tr.addr % (2 ** read_tr.size))) % 4096) + 
                            ((read_tr.len+1) * (2**read_tr.size))) > 4096) begin
       read_tr.errors =  ERROR_4K_BOUNDARY;
       $display("[SLV DRV]",
             " [READ CHANNEL] ERROR DETECTED : 4K BOUNDARY CROSSING DETECTED ");
       return;
     end
     if(read_tr.burst == WRAP && !(read_tr.len inside {1,3,7,15}) ) begin
       read_tr.errors = ERROR_WRAP_LEN;
       $display("[SLV DRV]",
                " [READ CHANNEL] ERROR DETECTED : ERROR IN WRAP LEN DETECTED ");
       return;
     end
     if(read_tr.burst == WRAP && read_tr.addr 
                != ((read_tr.addr/(2**read_tr.size))* (2**read_tr.size))) begin
       read_tr.errors = ERROR_WRAP_UNALLIGNED;
       $display("[SLV DRV] [READ CHANNEL] ERROR WRAP UNALLIGNED DETECTED ");
       return;
     end 
     if(read_tr.burst == FIXED && !(read_tr.len inside {[0:15]})) begin
       read_tr.errors = ERROR_FIXED_LEN;
       $display("[SLV DRV] [READ CHANNEL] ERROR FIXED LEN DETECTED ");
       return;
     end

    endfunction : calculate_error_read
endclass : ei_axi4_slave_driver_c

