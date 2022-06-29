interface ei_axi4_monitor_interface #(
  int DATA_WIDTH =`DATA_WIDTH, 
  int ADDR_WIDTH = `ADDR_WIDTH
)(
    input bit aclk,
    input bit aresetn
);
	
    localparam BUS_BYTE_LANES = DATA_WIDTH/8;


    logic [ADDR_WIDTH - 1:0] awaddr;
    logic [7:0] awlen;
    logic [2:0] awsize;
    burst_type_e awburst;
    logic awvalid;
    logic awready;
	
    logic [DATA_WIDTH - 1:0] wdata;
    logic [BUS_BYTE_LANES - 1:0] wstrb;
    logic wlast;
    logic wvalid;
    logic wready;

    response_e bresp;
    logic bvalid;	
    logic bready;
	
    // read address channel 		
    logic [31:0] araddr;
    burst_type_e arburst;
    logic [7:0] arlen;
    logic [2:0] arsize; 
    logic arvalid;
    logic arready;
	
    // read data channel
    logic [DATA_WIDTH - 1:0] rdata;
    response_e rresp;
    logic rlast;
    logic rvalid;
    logic rready; 


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

    modport MON (
      clocking monitor_cb,
      input aresetn
    );

endinterface
