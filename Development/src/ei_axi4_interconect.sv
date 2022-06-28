module ei_axi4_interconnect(ei_axi4_master_interface mst_vif, ei_axi4_slave_interface slv_vif);

    // WRITE ADDRESS CHANNEL
    assign mst_vif.awaddr  = slv_vif.awaddr;
    assign mst_vif.awburst = slv_vif.awburst;
    assign mst_vif.awlen   = slv_vif.awlen;
    assign mst_vif.awsize  = slv_vif.awsize;
    assign mst_vif.awvalid = slv_vif.awvalid;
    assign mst_vif.awready = slv_vif.awready;
    
    // WRITE DATA CHANNEL
    assign mst_vif.wdata   = slv_vif.wdata;
    assign mst_vif.wstrb   = slv_vif.wstrb;
    assign mst_vif.wlast   = slv_vif.wlast;
    assign mst_vif.wvalid  = slv_vif.wready;

    // WRITE RESPONSE CHANNEL
    assign mst_vif.bvalid  = slv_vif.bvalid;
    assign mst_vif.bresp   = slv_vif.bresp;
    assign mst_vif.bready  = slv_vif.bready;

    // READ ADDRESS CHANNEL 
    assign mst_vif.araddr  = slv_vif.araddr;
    assign mst_vif.arburst = slv_vif.arburst;
    assign mst_vif.arlen   = slv_vif.arlen;
    assign mst_vif.arsize  = slv_vif.arsize;
    assign mst_vif.arvalid = slv_vif.arvalid;
    assign mst_vif.arready = slv_vif.arready;
    
    // READ DATA CHANNEL 
    assign mst_vif.rresp   = slv_vif.rresp; 
    assign mst_vif.rvalid  = slv_vif.rvalid;
    assign mst_vif.rready  = slv_vif.rready;
    assign mst_vif.rdata   = slv_vif.rdata;
    assign mst_vif.rlast   = slv_vif.rlast;

endmodule : ei_axi4_interconnect
