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
  //bit unsigned [ DATA_WIDTH : 0 ] q_wdata[$];
  //bit unsigned [ DATA_WIDTH : 0 ] q_rdata[$];
  bit [31 : 0] q_awaddr[$];
  bit [31 : 0] q_araddr[$]; 

  ei_axi4_transaction_c read_tr;
  ei_axi4_transaction_c write_tr;
  virtual ei_axi4_interface vif;
  

/**
*\   Method name          : new()
*\   parameters passed    : virtual interface handle                      
*\   Returned parameters  : None
*\   Description          : function links virtual interface and also it builds
*\                          two handles of transaction class, read transaction
*\                          write transaction
**/

  function new(virtual ei_axi4_interface vif);
    this.vif    = vif; 
    read_tr     = new();
    write_tr    = new();
  endfunction

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
        write_response_run();
        read_address_run();
        read_data_run();
      join_any
      disable run_AXI_slave_driver;
      $display("[SLAVE_DRV]--> @%0t fork join disabled",$time);
    end
  endtask : run

/**
*\   Method name          : reset_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
**/

  task reset_run();
    @(`VSLV iff (vif.aresetn == 0)) begin
      `VSLV.awready     <= 0;
      `VSLV.arready     <= 0;
      `VSLV.wready      <= 0;
      `VSLV.bvalid      <= 0;
      `VSLV.rvalid      <= 0;
      q_awaddr.delete();
      q_araddr.delete();
    end
  endtask : reset_run


/**
*\   Method name          : write_address_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
**/

  task write_address_run();
     // write_addr2data.get(1);
    forever begin
      `VSLV.awready           <= 1;
      $display("[Write Address Channel] ........... --> @%0t AWREADY ASSERTED",$time);
      @(`VSLV iff(`VSLV.awvalid == 1)); 
      $display("[Write Address Channel] ........... --> @%0t AWVALID & AWREADY Handshaked ",$time);
       write_tr.addr           =  `VSLV.awaddr;
       write_tr.burst          =  `VSLV.awburst;
       write_tr.len            =  `VSLV.awlen;
       write_tr.size           =  `VSLV.awsize;
       calculate_write();
       @(`VSLV) `VSLV.awready <= 0;
      $display("[Write Address Channel] ........... --> @%0t AWREADY Deasserted",$time);
     end
   endtask : write_address_run

   function void calculate_write();
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
     burst_len          = write_tr.len + 1; //
     burst              = write_tr.burst;
     address_n          = start_addr;
     aligned_address    = ((start_addr/number_bytes))* number_bytes;

     if(burst == INCR) begin 
      for(int count = 1; count <= burst_len; count++) begin
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
      
      for(int i=1; i< burst_len; i++) begin 
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
   endfunction : calculate_write

/**
*\   Method name          : write_data_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
**/
  task write_data_run();
    forever begin
      @(`VSLV iff(q_awaddr.size != 0));
      case (write_tr.burst)
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
*\   Description          :
*\                         
*\                        
*\                         
**/
  task fixed_write();
    bit [`DATA_WIDTH :  0] mem_addr; // create memory for store data 
    `VSLV.wready        <= 1;  
    mem_addr            = (q_awaddr[0])/ 8;
    for(int i = 0; i < `BUS_BYTE_LANES; i++) begin
      @(`VSLV iff(`VSLV.wvalid == 1));
      write_tr.wstrb    =   new[1];
      write_tr.data     =   new[1];
      write_tr.wstrb[0] =   `VSLV.wstrb;
      write_tr.data[0]  =   `VSLV.wdata; 

      if(write_tr.wstrb[0][i] == 1 ) begin
        // if strobe is 1 then data is valid and store to memory
        slv_drv_mem[mem_addr][(8*i) + 7-:8] = write_tr.data[0][(8*i)+7 -: 8];
      end
    end
    foreach(slv_drv_mem[k]) begin
      $display("Slave Memory: Row[i]    = %0d",slv_drv_mem[k]);
    end

  endtask : fixed_write

/*
*\   Method name          : incr_write()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
**/
  task incr_write();
    bit [`DATA_WIDTH :  0] mem_addr; // create memory for store data 
    int count;
    `VSLV.wready        <= 1;
    $display("[WRITE DATA CHANNEL] ........... --> @%0t WREADY Asserted",$time);
    mem_addr            = q_awaddr.pop_front();
    mem_addr            = (q_awaddr.pop_front()) / 8;
    for(int i = 0; i < `BUS_BYTE_LANES; i++) begin
      @(`VSLV iff(`VSLV.wvalid == 1));
      $display("[WRITE DATA CHANNEL] ............ --> @%0t WVALID and WREADY Handshaked",$time);
      write_tr.wstrb    =   new[1];
      write_tr.data     =   new[1];
      write_tr.wstrb[0] =   `VSLV.wstrb;
      write_tr.data[0]  =   `VSLV.wdata; 

      if(write_tr.wstrb[0][i]==1) begin
        // if strobe is 1 then data is valid and store to memory
        slv_drv_mem[mem_addr][(8*i) + 7-:8] = write_tr.data[0][(8*i)+7 -: 8]; 
        $display("[WRITE DATA CHANNEL] ............ --> @%0t transfer no. %0d",$time,count+1);
        count++;
      end
    end
    foreach(slv_drv_mem[k]) begin
      $display("Slave Memory: Row[%0d]    = %0d",k,slv_drv_mem[k]);
      
    end
  endtask : incr_write


/*
*\   Method name          : incr_write()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
**/
  task wrap_write();
   
     bit [`DATA_WIDTH :  0] mem_addr; // create memory for store data 
    `VSLV.wready      <= 1;  
    mem_addr          = (q_awaddr.pop_front() )/ 8;
    for(int i = 0; i < `BUS_BYTE_LANES; i++) begin
      @(`VSLV iff(`VSLV.wvalid == 1));
      write_tr.wstrb   =   new[1];
      write_tr.data    =   new[1];
      write_tr.wstrb[0]=   `VSLV.wstrb;
      write_tr.data[0] =   `VSLV.wdata; 

      if(write_tr.wstrb[0][i]==1) begin
        // if strobe is 1 then data is valid and store to memory
        slv_drv_mem[mem_addr][(8*i) + 7-:8] = write_tr.data[0][(8*i)+7 -: 8];
      end
    end
    foreach(slv_drv_mem[i]) begin
      $display("Slave Memory: Row[i]    = %0d",slv_drv_mem[i]);
    end
  endtask : wrap_write



/*
*\   Method name          : write_response_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
**/
  task write_response_run();
    forever begin
    `VSLV.wready       <= 1;
    @(`VSLV iff(`VSLV.wvalid && `VSLV.wlast));
    $display("[Write Response Run] .......... --> @%0t  WLAST detected",$time);
    @(`VSLV);
    `VSLV.wready       <= 0;
    `VSLV.bvalid       <= 1;
     write_tr.bresp = OKAY; 
    $display("[Write Response Run] .......... --> @%0t  BRESP with OKAY is asserted",$time);
    `VSLV.bresp        <= write_tr.bresp;
    @(`VSLV iff(`VSLV.bready == 1));
    @(`VSLV)`VSLV.bresp <= 'bz ;
  end
  endtask


/*
*\   Method name          : read_address_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
**/
  task read_address_run();
    forever begin
      $display("[SLV_DRV.READ_ADDRESS_CHANNEL] ................ --> @%0t ARREADY made 1 ",$time);
      `VSLV.arready    <= 1;
      @(`VSLV iff(`VSLV.arvalid == 1));
      $display("[SLV_DRV.READ_ADDRESS_CHANNEL] ................ --> @%0t Handshaking done ",$time);
      read_tr.addr    =  `VSLV.araddr;
      read_tr.burst   =  `VSLV.arburst;
      read_tr.len     =  `VSLV.arlen + 1;
      read_tr.size    =  `VSLV.arsize;
      calculate_read_address();
      `VSLV.arready <= 0;
    end
  endtask


/*
*\   Method name          : read_data_run()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
**/
  task read_data_run();
    forever begin
      @(`VSLV iff(q_araddr.size() != 0));
      $display("[SLV_DRV.READ_DATA_CHANNEL] ................  --> @%0t q_araddr = %0d and size = %0d",$time,q_araddr[0],q_araddr.size());
      for(int i = 0; i < read_tr.len; i++) begin
        if(vif.aresetn == 0) begin
           break;
        end
        else begin 
          `VSLV.rvalid    <= 1;
          $display("[SLV_DRV.READ_DATA_CHANNEL]................ --> @%0t RVALID Handshaking done ",$time);
          `VSLV.rdata     <= rdata(i);
           `VSLV.rresp    <= 0;
          if(i == read_tr.len - 1) begin
              `VSLV.rlast <= 1'b1;
                $display("[SLV_DRV.READ_DATA_CHANNEL] ................ --> @%0t RLAST Asserted ",$time);
          end
          @(`VSLV iff(`VSLV.rready));
        end
      end
      `VSLV.rvalid      <= 0;
      `VSLV.rlast       <= 0;

      $display("[SLV_DRV.READ_DATA_CHANNEL] ................  --> @%0t RLAST Deasserted ",$time);
      $display("[SLV_DRV.READ_DATA_CHANNEL] ................  --> @%0t q_araddr = %0d and size remains = %0d",$time,q_araddr[0],q_araddr.size());
    end
  endtask


/*
*\   Method name          : calculate_read_address()
*\   parameters passed    : None                      
*\   Returned parameters  : None
*\   Description          :
*\                         
*\                        
*\                         
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
     burst_len = read_tr.len + 1; 
     burst = read_tr.burst;
     address_n = start_addr;
     aligned_address = ((start_addr/number_bytes))* number_bytes;

     if(burst == INCR) begin 
      for(int count = 1; count < burst_len; count++) begin
        if(count==1) begin
         q_araddr.push_back(address_n);
       //  $display("[calculate_read_address] --> %0t q_araddr[%0d] = %0d",$time,count-1,q_araddr[count-1]);
        end
        else begin
         address_n = aligned_address + ((count-1) * number_bytes); 
         q_araddr.push_back(address_n);
       //  $display("[calculate_read_address] --> %0t q_araddr[%0d] = %0d",$time,count-1,q_araddr[count-1]);
        end
      end
     end
  
    if(burst == WRAP) begin 
      lower_wb          = (start_addr/(number_bytes*burst_len))*(number_bytes*burst_len);
      upper_wb          = lower_wb + (number_bytes*burst_len);
      aligned_address   = start_addr;
      q_araddr.push_back(start_addr);
      aligned_address   = ((start_addr/number_bytes))* number_bytes;
     
      for(int i=1; i< burst_len; i++) begin
      
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
function bit [63 : 0] rdata(int i);
    
    bit [31 : 0] addr; // Start addres
    bit [ 3 : 0] data_bus_bytes = 8;
    bit [ 2 : 0] lbl, ubl;
    bit [31 : 0] aligned_address;
    int          number_bytes;
    bit [63 : 0] len_sel_r;
    int          mem_addr_r;
    
    len_sel_r         = {8{8'hff}};
    number_bytes      = 2 ** read_tr.size;
       
    if(i == 0) begin
      addr            = q_araddr.pop_front();
      mem_addr_r      = addr / data_bus_bytes;
      aligned_address = (addr/number_bytes) * number_bytes;
      lbl             = addr - ((addr / data_bus_bytes))* data_bus_bytes;
      ubl             = aligned_address + (number_bytes - 1'b1) -
                                    ((addr / data_bus_bytes)) * data_bus_bytes;
      
      len_sel_r       = len_sel_r << ((data_bus_bytes - 1) - ubl + lbl) * 8;             // len_sel mask creation 
      len_sel_r       = len_sel_r >> ((data_bus_bytes - 1) - ubl) * 8;
      rdata           = slv_drv_mem[mem_addr_r] & len_sel_r;
    
    end
    else begin
      addr            = q_araddr.pop_front();
      lbl             = addr - ((addr / data_bus_bytes))* data_bus_bytes;
      ubl             = lbl + number_bytes-1'b1;
      
      mem_addr_r      = addr / data_bus_bytes;
      len_sel_r       = len_sel_r << ((data_bus_bytes - 1) - ubl + lbl) * 8;             // len_sel mask creation 
      len_sel_r       = len_sel_r >> ((data_bus_bytes - 1) - ubl) * 8;
      rdata           = slv_drv_mem[mem_addr_r] & len_sel_r;      
    end
  endfunction :rdata
endclass : ei_axi4_slave_driver_c
