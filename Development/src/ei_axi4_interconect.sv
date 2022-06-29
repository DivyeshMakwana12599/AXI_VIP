module ei_axi4_interconnect(
  ei_axi4_master_interface mst_vif, 
  ei_axi4_slave_interface slv_vif,
  ei_axi4_monitor_interface mon_vif
);

    // WRITE ADDRESS CHANNEL
    assign slv_vif.awaddr  = mst_vif.awaddr;
    assign slv_vif.awburst = mst_vif.awburst;
    assign slv_vif.awlen   = mst_vif.awlen;
    assign slv_vif.awsize  = mst_vif.awsize;
    assign slv_vif.awvalid = mst_vif.awvalid;
    assign mst_vif.awready = slv_vif.awready;
    
    // WRITE DATA CHANNEL
    assign slv_vif.wdata   = mst_vif.wdata;
    assign slv_vif.wstrb   = mst_vif.wstrb;
    assign slv_vif.wlast   = mst_vif.wlast;
    assign slv_vif.wvalid  = mst_vif.wvalid;
    assign mst_vif.wready  = slv_vif.wready;


    // WRITE RESPONSE CHANNEL
    assign mst_vif.bvalid  = slv_vif.bvalid;
    assign mst_vif.bresp   = slv_vif.bresp;
    assign slv_vif.bready  = mst_vif.bready;

    // READ ADDRESS CHANNEL 
    assign slv_vif.araddr  = mst_vif.araddr;
    assign slv_vif.arburst = mst_vif.arburst;
    assign slv_vif.arlen   = mst_vif.arlen;
    assign slv_vif.arsize  = mst_vif.arsize;
    assign slv_vif.arvalid = mst_vif.arvalid;
    assign mst_vif.arready = slv_vif.arready;
    
    // READ DATA CHANNEL 
    assign mst_vif.rresp   = slv_vif.rresp; 
    assign mst_vif.rvalid  = slv_vif.rvalid;
    assign slv_vif.rready  = mst_vif.rready;
    assign mst_vif.rdata   = slv_vif.rdata;
    assign mst_vif.rlast   = slv_vif.rlast;

    // WRITE ADDRESS CHANNEL
    assign mon_vif.awaddr  = mst_vif.awaddr;
    assign mon_vif.awburst = mst_vif.awburst;
    assign mon_vif.awlen   = mst_vif.awlen;
    assign mon_vif.awsize  = mst_vif.awsize;
    assign mon_vif.awvalid = mst_vif.awvalid;
    assign mon_vif.awready = mst_vif.awready;
    
    // WRITE DATA CHANNEL
    assign mon_vif.wdata   = mst_vif.wdata;
    assign mon_vif.wstrb   = mst_vif.wstrb;
    assign mon_vif.wlast   = mst_vif.wlast;
    assign mon_vif.wvalid  = mst_vif.wvalid;
    assign mon_vif.wready  = mst_vif.wready;

    // WRITE RESPONSE CHANNEL
    assign mon_vif.bvalid  = mst_vif.bvalid;
    assign mon_vif.bresp   = mst_vif.bresp;
    assign mon_vif.bready  = mst_vif.bready;

    // READ ADDRESS CHANNEL 
    assign mon_vif.araddr  = mst_vif.araddr;
    assign mon_vif.arburst = mst_vif.arburst;
    assign mon_vif.arlen   = mst_vif.arlen;
    assign mon_vif.arsize  = mst_vif.arsize;
    assign mon_vif.arvalid = mst_vif.arvalid;
    assign mon_vif.arready = mst_vif.arready;
    
    // READ DATA CHANNEL 
    assign mon_vif.rresp   = mst_vif.rresp; 
    assign mon_vif.rvalid  = mst_vif.rvalid;
    assign mon_vif.rready  = mst_vif.rready;
    assign mon_vif.rdata   = mst_vif.rdata;
    assign mon_vif.rlast   = mst_vif.rlast;

endmodule : ei_axi4_interconnect
