/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name   : ei_axi4_slave_driver.sv
Title     : Slave Driver Class
Project   : AMBA AXI-4 SV VIP
Created On  : 07-June-22
Developers  : Shivam Prasad
Purpose   : Driver Class does handshaking and response for all channel 
        parallely.
        1. In write transaction, slave driver recives the 
           data from interface and writes in driver memory,
        2. In read trnsaction, driver will drive the (as per request
         generated by master) from its own memory to interface. 
         Modified    : 23/06/2022 by Shivam 
Assumptions : 
        
Limitations : Interleving is not supported here.
Known Errors: 
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
*/


class ei_axi4_slave_driver_c #(DATA_WIDTH = `DATA_WIDTH,
                               ADDR_WIDTH = `ADDR_WIDTH);
  localparam BUS_BYTE_LANES = DATA_WIDTH / 8;
  bit [ DATA_WIDTH - 1 : 0] slv_drv_mem [bit [ADDR_WIDTH - 1 : 0]];
  bit [31 : 0] q_awaddr[$]; 
  bit [31 : 0] q_araddr[$];
  //  bit [31 : 0] q_rec_awaddr[$];
  bit [31 : 0] q_rec_araddr[$];
  bit [ 1 : 0] q_arburst[$];
  bit [ 1 : 0] q_awburst[$];
  bit [ 6 : 0] q_arsize[$];
  bit [ 7 : 0] q_awlen[$];
  bit [ 7 : 0] q_arlen[$];
  bit is_error_write[$];
  bit is_error_read[$];
  int unsigned no_of_responce_channel;
  ei_axi4_transaction_c read_tr;
  ei_axi4_transaction_c write_tr;
  virtual `SLV_INTF vif; 

/**
*\   Method name          : new()
*\   parameters passed    : virtual interface handle                      
*\   Returned parameters  : None
*\   Description          : function links virtual interface and also it builds
*\                          two handles of transaction class, read transaction
*\                          write transaction
**/

  function new(virtual `SLV_INTF vif);
    this.vif    = vif;
    read_tr         = new();
    write_tr        = new();
    print_build;
  endfunction

/**
*\   Method name          : print_build()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This function prints the interface linking status,
*\                          Read and Write transaction handle memory allocation  
*\                          Status
**/
  function print_build;
    $display("---------------------------------------------------------------");
    $display("[SLV_DRV] \t\tVirtual Interface has been linked.");
    $display("[SLV_DRV] \t\tMemory allocated to Read Transaction handle");
    $display("[SLV_DRV] \t\tMemory allocated to Write Transaction handle");
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
      fork : run_AXI_slave_driver
        reset_run();
        write_address_run();
        write_data_run();
        sample_response();
        write_response_run();
        read_address_run();
        read_data_run();
      join_any
      disable run_AXI_slave_driver;
      $display("[SLAVE_DRV] \t\t@%0t fork join disabled",$time);
    end
  endtask : run

/**
*\   Method name          : reset_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : reset_run task make sures that all the slave hand -
*\                          shake signals gets deasserted when reset assertion
*\                          is detected.
*\                         
**/

  task reset_run();
    @(`VSLV iff (vif.aresetn == 0)) begin
    $display("---------------------------------------------------------------");
    $display("################# RESET HAS BEEN ASSERTED !! ##################");
    $display("################# SLAVE DRIVER HAS BEEN PAUSED !! #############");
    $display("---------------------------------------------------------------");
      vif.awready     <= 0;
      vif.arready     <= 0;
      vif.wready      <= 0;
      vif.bvalid      <= 0;
      vif.rvalid      <= 0;
      q_awaddr.delete();
      q_araddr.delete();
      //q_rec_awaddr.delete();
      q_rec_araddr.delete();
      q_awburst.delete();
      q_arsize.delete();
      q_awlen.delete();
      q_arlen.delete();
    end
  endtask : reset_run

/**
*\   Method name          : write_address_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task acts as axi write address channel. it 
*\                          asserts awready and waits for awvalid to be asserted
*\                          once this handshaking is done then it immediately 
*\                          scans for all the control signals on same clock tick
*\                          and store them in transaction write (write_tr)packet
*\                          Also it calls one function which calculates all the
*\                          next address and address byte lanes/boundary
**/

  task write_address_run();
    vif.awready           <= 0;
    forever begin
      `VSLV.awready           <= 1;
       $display("----------------------------------------------------------:---");
       $display("[SLV DRV - Write Address Channel] \t\t@%0t AWREADY Asserted",$time);
       @(`VSLV iff(`VSLV.awvalid == 1)); 
       $display("[Write Address Channel] \t\t@%0t AWVALID & AWREADY Handshaked ",$time);
       write_tr.addr           =  `VSLV.awaddr;
       write_tr.burst          =  `VSLV.awburst;
       write_tr.len            =  `VSLV.awlen + 1;
       write_tr.size           =  `VSLV.awsize;
       calculate_error_write();
       calculate_write_address();
       @(`VSLV) `VSLV.awready <= 0;
       $display("[Write Address Channel] \t\t@%0t AWREADY Deasserted",$time);
     end
   endtask : write_address_run

   function void calculate_error_write();
     if((((write_tr.addr - (write_tr.addr % write_tr.size)) % 4096) + ((write_tr.len) * (2**write_tr.size))) > 4096) begin
       is_error_write.push_back(1);
       return;
     end
     if(write_tr.burst == WRAP && !(write_tr.len inside {2,4,8,16}) ) begin
        is_error_write.push_back(1);
        return;
      end
      if(write_tr.burst == WRAP && write_tr.addr != ((write_tr.addr/(2**write_tr.size))* (2**write_tr.size))) begin
        is_error_write.push_back(1);
        return;
      end 
      if(write_tr.burst == FIXED && !(write_tr.len inside {[1:16]})) begin
        is_error_write.push_back(1);
        return;
      end

      is_error_write.push_back(0);
    endfunction : calculate_error_write
/**
*\   Method name          : calculate_write_address()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This function is called by write_address_run task. 
*\                          Here calculation of next address happens with  
*\                          accordance to burst type.  see following detals,
*\                            i. FIXED type Burst:  
*\                               Calculate Next write address as per length  
*\                               given by master and push these addresses into 
*\                               queue.
*\                           ii. INCR type Burst:
*\                               Calculate Next write address as per length 
*\                               given by master, calculate lower and uper byte
*\                               lane and push these calculated addresses into
*\                               queue.
*\                           ii. WRAP type Burst:
*\                               Calculate Next write address as per length 
*\                               given by master, calculate lower and uper wrap
*\                               boundary and push these calculated addresses 
*\                               into queue.
**/
   function void calculate_write_address();
     bit [31 : 0] start_addr;
     bit [31 : 0] aligned_address;
     bit [31 : 0] address_n;
     bit [ 1 : 0]  burst;
  
     int number_bytes;
     int burst_len;
     int lbl;
     int ubl;
     int lower_wb,upper_wb;

     start_addr         = write_tr.addr;
     number_bytes       = 2**write_tr.size;
     burst_len          = write_tr.len; 
     burst              = write_tr.burst;
     address_n          = start_addr;
     aligned_address    = ((start_addr/number_bytes))* number_bytes;
     if(burst == FIXED) begin
         q_awburst.push_back(burst);
         q_awlen.push_back(burst_len);
        // q_rec_awaddr.push_back(address_n);
       for(int count = 1; count <= burst_len; count++) begin
         q_awaddr.push_back(address_n);
       //  q_awsize.push_back(number_bytes);
       end
     end
     if(burst == INCR) begin 
         q_awburst.push_back(burst);
         q_awlen.push_back(burst_len);
         //q_rec_awaddr.push_back(address_n);
      for(int count = 1; count <= burst_len; count++) begin
         //q_awsize.push_back(number_bytes);
        if(count==1) begin
         q_awaddr.push_back(address_n); 
        end
        else begin
         address_n = aligned_address + ((count-1) * number_bytes); 
         q_awaddr.push_back(address_n); 
        end
      end
     end
  
    if(burst == WRAP) begin 
      lower_wb          = (start_addr/(number_bytes*burst_len))*(number_bytes*burst_len);
      upper_wb          = lower_wb + (number_bytes*burst_len);
      aligned_address   = start_addr;
      q_awaddr.push_back(start_addr);
      aligned_address   = ((start_addr/number_bytes))* number_bytes;
      q_awburst.push_back(burst);
      q_awlen.push_back(burst_len);
      //q_rec_awaddr.push_back(address_n);
      //q_awsize.push_back(number_bytes);
      
      for(int i = 1; i < burst_len; i++) begin 
        //q_awsize.push_back(number_bytes);
        address_n       = address_n + number_bytes;
        if(upper_wb == address_n) begin
          address_n     = lower_wb;
          q_awaddr.push_back(address_n);
        end
        else begin
          q_awaddr.push_back(address_n);  
        end     
       end
      end 
   endfunction : calculate_write_address

/**
*\   Method name          : write_data_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task acts as AXI write Data Channel. For Very
*\                          first transaction, task waits for to awaddr queue to
*\                          be filled with address then it calls three task 
*\                          (fixed_write, incr_write and wrap_type) based on 
*\                          first/current burst type. So respective task samples
*\                          the wdata from interface and stores them in memory
*\                          with respective burst type.
**/

  task write_data_run();
    vif.wready    <= 0;
    forever begin
      @(`VSLV iff(q_awaddr.size != 0));
     $display("[WRITE DATA CHANNEL] \t\t\t @%0t=====write queue = %0p",$time,q_awaddr);

      $display("[WRITE DATA CHANNEL] \t\tburst type = %0d",write_tr.burst);
     // case (write_tr.burst)
        case (q_awburst.pop_front()) 
          FIXED  : fixed_write();
          INCR   : incr_write();
          WRAP   : wrap_write();
        endcase
    end
      
  endtask : write_data_run

/**
*\   Method name          : fixed_write()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task is called from write_data_run task.
*\                          when transaction's burst type is fixed this task 
*\                          gets executed. First,it asserted wready and waits 
*\                          for handshaking. Once handshaking is done,
*\                          it samples wstrb and wdata from interface and then
*\                          it writes into memory according to provided strobe 
*\                          and address.
**/
  task fixed_write();
    bit [`DATA_WIDTH :  0] mem_addr; // dummy memory 
    int unsigned len = q_awlen.pop_front();
    //$display("[Fixed Write] \t\t\t\t Inside the fixed write");
    `VSLV.wready        <= 1;  
    for(int i = 0; i < len; i++) begin
      @(`VSLV iff(`VSLV.wvalid == 1));
      $display("[FIXED WRITE] \t\t\tWVALID and WREADY Handshaked");
      mem_addr          = (q_awaddr.pop_front())/ 8;
      write_tr.wstrb    =   new[1];
      write_tr.data     =   new[1];
      write_tr.wstrb[0] =   `VSLV.wstrb;
      write_tr.data[0]  =   `VSLV.wdata;
      //$display("[FIXED WRITE] \t\t\t\t wstrb = %0p",write_tr.wstrb);
      //$display("[FIXED WRITE] \t\t\t\t wdata = %0p",write_tr.data);
      if(!is_error_write[0]) begin
        for(int j = 0; j < `BUS_BYTE_LANES; j++) begin
          if(write_tr.wstrb[0][j] == 1 ) begin
          // if strobe is 1 then data is valid and store to memory
          slv_drv_mem[mem_addr][(8*j) + 7-:8] = write_tr.data[0][(8*j)+7 -: 8];
        end
      end
    end
  end
   /* foreach(slv_drv_mem[k]) begin
      $display("################################################");
      $display("Slave Memory: Row[%0d]    = %0d",k,slv_drv_mem[k]);
    end
    */

  endtask : fixed_write


/*
*\   Method name          : incr_write()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task is called from write_data_run task.
*\                          when transaction's burst type is increment this task 
*\                          gets executed. First,it asserted wready and waits 
*\                          for handshaking. Once handshaking is done,
*\                          it samples wstrb and wdata from interface and then
*\                          it writes into memory according to provided strobe 
*\                          and address. Note that we have calculated the all
*\                          next address for all the transfer in function
*\                          "calculate_write_address" and stored them in queue.
**/
  task incr_write();
    bit [`DATA_WIDTH :  0] mem_addr; // create memory for store data 
    int count,len;
    len                 =  q_awlen.pop_front(); 
    `VSLV.wready        <= 1;
    //$display("[WRITE DATA CHANNEL] \t\t@%0t WREADY Asserted",$time);
    for(int i = 0; i < len; i++) begin
      @(`VSLV iff(`VSLV.wvalid == 1));
      mem_addr            = (q_awaddr.pop_front())/8;
      //$display("[WRITE DATA CHANNEL] \t\t@%0t WVALID and WREADY Handshaked",$time);
      write_tr.wstrb    =   new[1];
      write_tr.data     =   new[1];
      write_tr.wstrb[0] =   `VSLV.wstrb;
      write_tr.data[0]  =   `VSLV.wdata; 
      if(!is_error_write[0]) begin
        for(int j = 0; j < `BUS_BYTE_LANES; j++) begin
          if(write_tr.wstrb[0][j]==1) begin
            // if strobe is 1 then data is valid and store to memory
            slv_drv_mem[mem_addr][(8*j) + 7-:8] = write_tr.data[0][(8*j)+7 -: 8];  
          end
        end
      end
    end
   /* foreach(slv_drv_mem[k]) begin
      $display("Slave Memory: Row[%0d]    = %0d",k,slv_drv_mem[k]);
      
    end
    */
  endtask : incr_write


/*
*\   Method name          : incr_write()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task is called from write_data_run task.
*\                          when transaction's burst type is wrap,then this task 
*\                          gets executed. First,it asserted wready and waits 
*\                          for handshaking. Once handshaking is done,
*\                          it samples wstrb and wdata from interface and then
*\                          it writes into memory according to provided strobe 
*\                          and address. Note that we have calculated the all
*\                          next address for all the transfer in function
*\                          "calculate_write_address" and stored them in queue.                    
**/
  task wrap_write();
    int len;
    bit [`DATA_WIDTH :  0] mem_addr; // create memory for store data 
    `VSLV.wready      <= 1;  
    len               = q_awlen.pop_front(); 
    for(int i = 0; i < len; i++) begin
      @(`VSLV iff(`VSLV.wvalid == 1));
      mem_addr         = (q_awaddr.pop_front() )/ 8;
      write_tr.wstrb   =   new[1];
      write_tr.data    =   new[1];
      write_tr.wstrb[0]=   `VSLV.wstrb;
      write_tr.data[0] =   `VSLV.wdata; 
      if(!is_error_write[0]) begin
        for(int j = 0; j < `BUS_BYTE_LANES; j++) begin
          if(write_tr.wstrb[0][j]==1) begin
            // if strobe is 1 then data is valid and store to memory
            slv_drv_mem[mem_addr][(8*j) + 7-:8] = write_tr.data[0][(8*j)+7 -: 8];
          end
        end
      end
    end
  endtask : wrap_write



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
   // int unsigned addr;
    //int unsigned len; 
    //bit [6:0] transfer_size;
    bit is_error = is_error_write.pop_front();
    vif.bvalid         <= 0;
    //vif.bresp          <= 'bz;
    forever begin
      `VSLV.wready         <= 1;
     // len                  = q_awlen[0];
     // transfer_size        = q_awsize[0];
      wait(no_of_responce_channel != 0);
     // addr                 = q_rec_awaddr.pop_front(); 
      $display("[Write Response Run] \t\t@%0t  WLAST detected",$time);
      @(`VSLV);
      if(is_error) begin
        `VSLV.bvalid      <= 1;
        `VSLV.bresp       <= SLVERR; 
      end
      else begin
        `VSLV.bvalid      <= 1;
        `VSLV.bresp       <= OKAY; 
      end
      @(`VSLV iff(`VSLV.bready == 1));
      `VSLV.bvalid        <= 1'b0;
      no_of_responce_channel--;
    end
  endtask

/**
*\   Method name          : sample_response()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : this task counts number of wlast encountered during
*\                          write transactions.
**/                        

  task sample_response();
    forever begin
      @(`VSLV iff(`VSLV.wlast && `VSLV.wvalid));
      no_of_responce_channel++;
    end
  endtask

/**
*\   Method name          : read_address_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This task acts as axi read address channel. it 
*\                          asserts arready and waits for arvalid to be asserted
*\                          once this handshaking is done then it immediately 
*\                          scans for all the control signals on same clock tick
*\                          and store them in transaction read (read_tr)packet
*\                          Also it calls one function which calculates all the
*\                          next address and address byte lanes/boundary
**/                        
  task read_address_run();
    int cnt = 1 ;
    vif.arready      <= 0;
    forever begin
      $display("[SLV_DRV.READ_ADDRESS_CHANNEL] \t\t@%0t ARREADY Asserted ",$time);
      `VSLV.arready    <= 1;
      @(`VSLV iff(`VSLV.arvalid == 1));
      $display("[SLV_DRV.READ_ADDRESS_CHANNEL] \t\t@%0t ARVALID & ARREADY Handshaking done ",$time);
      read_tr.addr    =  `VSLV.araddr;
      read_tr.burst   =  `VSLV.arburst;
      read_tr.len     =  `VSLV.arlen + 1;
      read_tr.size    =  `VSLV.arsize;
      $display("[SLV_DRV.READ_ADDRESS_CHANNEL] \t\t@%0t Address[%0d] = %0d ",$time,cnt,`VSLV.araddr);
      calculate_error_read();
      calculate_read_address();
      `VSLV.arready <= 0;
      cnt++;
    end
  endtask

  function void calculate_error_read();
    if((((read_tr.addr - (read_tr.addr % read_tr.size)) % 4096) + ((read_tr.len) * (2**read_tr.size))) > 4096) begin
      is_error_read.push_back(1);
      return;
     end
    if(read_tr.burst == WRAP && !(read_tr.len inside {2,4,8,16}) ) begin
      is_error_read.push_back(1);
      return;
    end
    if(read_tr.burst == WRAP && read_tr.addr != ((read_tr.addr/(2**read_tr.size))* (2**read_tr.size))) begin
      is_error_read.push_back(1);
      return;
    end
    if(read_tr.burst == FIXED && !(read_tr.len inside {[1:16]})) begin
      is_error_read.push_back(1);
      return;
    end
    is_error_read.push_back(0);
    endfunction : calculate_error_read
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
    // int unsigned addr;
    int unsigned len;
    bit is_error;
    // bit [ 1 : 0] burst;
    //bit [6:0] transfer_size;
    vif.rvalid      <= 0;
    vif.rlast       <= 0;
    vif.rdata       <= 0;
    forever begin
      @(`VSLV iff(q_araddr.size() != 0));
     // addr           = q_rec_araddr.pop_front(); 
      //transfer_size  = q_arsize[0];
      is_error      = is_error_read.pop_front();
      len            = q_arlen.pop_front();
      //burst          = q_arburst.pop_front();
      //$display("[READ DATA CHANNEL] \t\t\t @%0t=====read queue = %0p",$time,q_araddr);
      //$display("[SLV_DRV.READ_DATA_CHANNEL] \t\t@%0t q_araddr = %0d and size = %0d",$time,q_araddr[0],q_araddr.size());
      for(int i = 0; i < len; i++) begin 
          `VSLV.rvalid    <= 1;
          $display("[SLV_DRV.READ_DATA_CHANNEL] \t\t@%0t RVALID & RREADY Handshaking done ",$time);
          if(is_error) begin
            #0 `VSLV.rdata   <= 0;
            `VSLV.rresp      <= SLVERR; 
          end
          else begin
            #0 `VSLV.rdata     <= rdata(i);
            `VSLV.rresp      <= OKAY;
          end
       
          if(i == len - 1) begin
              `VSLV.rlast <= 1'b1;
              $display("[SLV_DRV.READ_DATA_CHANNEL] \t\t@%0t RLAST Asserted ",$time);
          end
          @(`VSLV iff(`VSLV.rready));
      end
      `VSLV.rvalid      <= 0;
      `VSLV.rlast       <= 0;
      `VSLV.rresp       <= 'bz;
     // `VSLV.rdata       <= 'bx;
      $display("[SLV_DRV.READ_DATA_CHANNEL] \t\t@%0t RLAST Deasserted ",$time);
      //$display("[SLV_DRV.READ_DATA_CHANNEL] \t\t@%0t RRESEP gone High Impedance",$time);
      //$display("[SLV_DRV.READ_DATA_CHANNEL] \t\t@%0t q_araddr = %0d and size remains = %0d",$time,q_araddr[0],q_araddr.size());
    end
  endtask


/**
*\   Method name          : calculate_read_address()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          : This function is called by read_address_run task. 
*\                          Here calculation of next address happens with  
*\                          accordance to burst type.  see following detals,
*\                            i. FIXED type Burst:  
*\                               Calculate Next read address as per length  
*\                               given by master and push these addresses into 
*\                               queue.
*\                           ii. INCR type Burst:
*\                               Calculate Next read address as per length 
*\                               given by master, calculate lower and uper byte
*\                               lane and push these calculated addresses into
*\                               queue.
*\                           ii. WRAP type Burst:
*\                               Calculate Next read address as per length 
*\                               given by master, calculate lower and uper wrap
*\                               boundary and push these calculated addresses 
*\                               into queue.
**/
  function void calculate_read_address();
     bit [31 : 0] start_addr;
     bit [31 : 0] aligned_address;
     bit [31 : 0] address_n;
     bit [ 1 : 0] burst;
  
     int number_bytes;
     int burst_len;
     int lbl;
     int ubl;
     int lower_wb,upper_wb;

     start_addr = read_tr.addr;
     number_bytes = 2**read_tr.size;
     burst_len = read_tr.len; 
     burst = read_tr.burst;
     address_n = start_addr;
     aligned_address = ((start_addr/number_bytes))* number_bytes;
     
     if(burst == FIXED) begin
       q_arlen.push_back(burst_len);
       for(int count = 1;count <= burst_len; count++) begin
         q_arsize.push_back(number_bytes);
         q_araddr.push_back(address_n);
       end
     end
     if(burst == INCR) begin 
       q_arlen.push_back(burst_len);
       for(int count = 1; count <= burst_len; count++) begin
         if(count==1) begin
           q_araddr.push_back(address_n);
           q_arsize.push_back(number_bytes);
           $display("[calculate_read_address] --> %0t q_araddr[%0d] = %0d",$time,count-1,q_araddr[count-1]);
         end
         else begin
           address_n = aligned_address + ((count-1) * number_bytes); 
           q_araddr.push_back(address_n);
           q_arsize.push_back(number_bytes);
           $display("[calculate_read_address] --> %0t q_araddr[%0d] = %0d",$time,count-1,q_araddr[count-1]);
         end
       end
    end
  
    if(burst == WRAP) begin 
      lower_wb          = (start_addr/(number_bytes*burst_len))*(number_bytes*burst_len);
      upper_wb          = lower_wb + (number_bytes*burst_len);
      aligned_address   = start_addr;
      q_araddr.push_back(start_addr);
      q_arsize.push_back(number_bytes);
      q_arlen.push_back(burst_len);
      aligned_address   = ((start_addr/number_bytes))* number_bytes;    
      // $display("[burst type] \t\t\t\tWRAP");
      for(int i=1; i< burst_len; i++) begin
        q_arsize.push_back(number_bytes);
        address_n = address_n + number_bytes;
        if(upper_wb == address_n) begin
          address_n     = lower_wb;
          q_araddr.push_back(address_n);
        end
        else begin
          q_araddr.push_back(address_n);  
        end     
       end
      end
      /*
      $display("#############################################################");
      $display("[Calc. Read Add.] --> @%0t q_araddr = %0p",$time,q_araddr);
      $display("[Calc. Read Add.] --> @%0t q_arlen  = %0p",$time,q_arlen);
      $display("[Calc. Read Add.] --> @%0t q_arsize = %0p",$time,q_arsize);
      $display("#############################################################");
      */
   endfunction : calculate_read_address

 /*
*\   Method name          : rdata()
*\   parameters passed    : integer index                       
*\   Returned parameters  : return data width values
*\   Description          :
*\                         
*\                        
*\                         
**/  
  function bit [`DATA_WIDTH : 0] rdata(int i);
    
    bit [31 : 0] addr; // Start addres
    bit [ 3 : 0] data_bus_bytes = `BUS_BYTE_LANES;
    bit [ 3 : 0] lbl, ubl;
    bit [31 : 0] aligned_address;
    int          number_bytes;
    bit [63 : 0] len_sel_r;
    int          mem_addr_r;
    
    len_sel_r         = {8{8'hff}};
    number_bytes      = q_arsize.pop_front();  
    if(i == 0) begin
      addr              = q_araddr.pop_front();
      mem_addr_r        = addr / data_bus_bytes;
      aligned_address   = (addr/number_bytes) * number_bytes;
      lbl               = addr - ((addr / data_bus_bytes))* data_bus_bytes;
      ubl               = aligned_address + (number_bytes - 1'b1) -
                                    ((addr / data_bus_bytes)) * data_bus_bytes;

      len_sel_r       = len_sel_r << ((data_bus_bytes - 1) - ubl + lbl) * 8;             // len_sel mask creation 
      len_sel_r       = len_sel_r >> ((data_bus_bytes - 1) - ubl) * 8;
      rdata           = slv_drv_mem[mem_addr_r] & len_sel_r;
      /*
      $display("=============================================================");
      $display("[RDATA] \t\t @%0t --> size = %0d",$time,number_bytes);
      $display("[RDATA] \t\t @%0t --> addr = %0d",$time,addr);
      $display("[RDATA] \t\t @%0t --> lbl  = %0d",$time,lbl);
      $display("[RDATA] \t\t @%0t --> ubl  = %0d",$time,ubl);
      $display("[RDATA] \t\t @%0t --> %0dst beat rdata = %0h ",$time,i,rdata);
      $display("=============================================================");
      */
    end
    else begin
      addr            = q_araddr.pop_front();
      lbl            = addr % data_bus_bytes;
      ubl             = lbl + number_bytes-1'b1;
      if(ubl > 7) begin
        ubl = 7;
      end
      
      mem_addr_r      = addr / data_bus_bytes;
      len_sel_r       = len_sel_r << (data_bus_bytes - 1 - ubl + lbl) * 8;             // len_sel mask creation 
      len_sel_r       = len_sel_r >> (data_bus_bytes - 1 - ubl) * 8;
      rdata           = slv_drv_mem[mem_addr_r] & len_sel_r; 
      /*
      $display("=============================================================");
      $display("[RDATA] \t\t @%0t --> size = %0d",$time,number_bytes);
      $display("[RDATA] \t\t @%0t --> addr = %0d",$time,addr);
      $display("[RDATA] \t\t @%0t --> lbl  = %0d",$time,lbl);
      $display("[RDATA] \t\t @%0t --> ubl  = %0d",$time,ubl);
      $display("[RDATA] \t\t @%0t --> %0dst beat rdata = %0h ",$time,i,rdata);
      $display("=============================================================");
      */
    end
  endfunction :rdata
endclass : ei_axi4_slave_driver_c
