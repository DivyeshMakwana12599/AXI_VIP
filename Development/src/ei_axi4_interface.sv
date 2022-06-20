/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_interface.sv
Title 		: Master Transaction Class
Project 	: AMBA AXI-4 SV VIP
Created On  : 03-June-22
Developers  : Sandip Mali
Purpose 	: Transaction Class contains AXI pin description and declaration
 
Assumptions : As per the Feature plan All the pins are not declared here
Limitations : 
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
Revision:0.1
-------------------------------------------------------------------------------
*/

interface ei_axi4_interface #(int DATA_WIDTH =`DATA_WIDTH, int ADDR_WIDTH = `ADDR_WIDTH)(
    input bit aclk,
    input bit aresetn);
	
    localparam BUS_BYTE_LANES = DATA_WIDTH/8;


    logic [ADDR_WIDTH - 1:0] awaddr;
    logic [7:0] awlen;
    logic [2:0] awsize;
    logic [1:0] awburst;
    logic awvalid;
    logic awready;
	
    logic [DATA_WIDTH - 1:0] wdata;
    logic [BUS_BYTE_LANES - 1:0] wstrb;
    logic wlast;
    logic wvalid;
    logic wready;

    logic [1:0] bresp;
    logic bvalid;	
    logic bready;
	
    // read address channel 		
    logic [31:0] araddr;
    logic [1:0] arburst;
    logic [7:0] arlen;
    logic [2:0] arsize; 
    logic arvalid;
    logic arready;
	
    // read data channel
    logic [DATA_WIDTH - 1:0] rdata;
    logic [1:0] rresp;
    logic rlast;
    logic rvalid;
    logic rready; 

    clocking master_driver_cb @(posedge aclk); 
      default input #1 output #1; 
		
      // write address channel 
      output awaddr;
      output awlen;
      output awsize;
      output awburst;
      output awvalid;
      input awready;
		
      // write data channel 
      output wdata;
      output wstrb;
      inout  wlast;
      output wvalid;
      input  wready;

      //write response channel
      input bresp;
      input bvalid;	
      output bready;
		
      // read address channel 		
      output araddr;
      output arburst;
      output arlen;
      output arsize;
      output arvalid;
      input  arready;
	
      // read data channel
      input  rdata;
      input  rresp;
      input  rlast;
      input  rvalid;
      output rready; 
	
    endclocking : master_driver_cb

    clocking slave_driver_cb @(posedge aclk);
	
      default input #1 output #1; 
		
      // write address channel 
      input awaddr;
      input awlen;
      input awsize;
      input awburst;
      input awvalid;
      output awready;
		
      // write data channel 
      input wdata;
      input wstrb;
      input wlast;
      input wvalid;
      output wready;

      //write response channel
      output bresp;
      output bvalid;	
      input bready;
	
      // read address channel 		
      input araddr;
      input arburst;
      input arlen;
      input arsize;
      input arvalid;
      output arready;
	
      // read data channel
      output rdata;
      output rresp;
      output rlast;
      output rvalid;
      input rready;
 
    endclocking : slave_driver_cb

    clocking monitor_cb @(posedge aclk);       // clocking block for monitor  
      default input #1 output #1; 
		
      // write address channel 
      input awaddr;
      input awlen;
      input awsize;
      input awburst;
      input awvalid;
      input awready;
		
      // write data channel 
      input wdata;
      input wstrb;
      input wlast;
      input wvalid;
      input wready;

      //write response channel
      input bresp;
      input bvalid;	
      input bready;
		
      // read address channel 		
      input araddr;
      input arburst;
      input arlen;
      input arsize;
      input arvalid;
      input arready;
	
      // read data channel
      input rdata;
      input rresp;
      input rlast;
      input rvalid;
      input rready;
		
    endclocking : monitor_cb

    modport MST (
      clocking master_driver_cb,
      input aresetn, 
      output arvalid,
      output awvalid,
      output wvalid
    );
  
    modport SLV (
      clocking slave_driver_cb,
      input aresetn,
      output rvalid,
      output bvalid
    );

    modport MON (
      clocking monitor_cb,
      input aresetn
    );

endinterface : ei_axi4_interface
