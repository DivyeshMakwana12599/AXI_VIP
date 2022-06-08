class ei_axi4_master_driver_c;

    ei_axi4_transaction_c tr;

    mailbox #(ei_axi4_transaction_c) gen2drv;

    virtual ei_axi4_interface vif;

    function new(mailbox #(ei_axi4_transaction_c) gen2drv, virtual ei_axi4_interface vif);
        this.gen2drv = gen2drv;
        this.vif = vif;
    endfunction : new

    task run();

        forever begin 
            //@(vif.MON.master_cb);
            //@(vif.master_cb);
            gen2drv.get(tr);
            tr.copy(blueprint);

            if(blueprint.transaction_type == WRITE) begin 
                write_address_task();
                write_data_task();
                write_response_task();
            end 

            if(blueprint.transaction_type == READ) begin 
                read_address_task();
                read_data_task();
            end 
        end // forever

    endtask : run 


    task write_address_task();
        
        @(vif.MTR.master_cb);

        vif.awvalid <= 1;
        vif.awaddr <= blueprint.awaddr;
        vif.awburst <= blueprint.awburst;
        vif.awlen <= blueprint.awlen;
        vif.awsize <= blueprint.awsize;

        //@(vif.MTR.master_cb);
        if(blueprint.awvalid == 1) begin 
            @(vif.awready);
            vif.awvalid <= 1'b0;
            vif.wvalid <= 1'b1;
            vif.wlast <= 1'b0;
            vif.awaddr <= 1'bx;
        end 

    endtask : write_address_task

    task write_data_task();

        @(vif.wready);
        
        for(int i = 0 ; i <= AWLEN ; i++) begin 
            vif.wdata <= blueprint.wdata[i]; 
            vif.wstrb <= blueprint.wstrb[i];

            if(i == blueprint.AWLEN) begin 
                vif.wlast <= 1;
            end 

            if(vif.wlast == 1) begin 
            @(vif.MTR.master_cb);
            vif.wlast <= 1'b0;
            vif.wvalid <= 1'b0;
            vif.wdata <= 1'bx;
            vif.wstrb <= 1'bx;
            end // wlast
        end // for loop
    
    endtask : write_data_task

    task write_response_task();

        if(vif.wlast == 1) begin 
            @(vif.bvalid);
            vif.bready <= 1;

            if(blueprint.bready == 1'b1) begin 
                @(vif.MTR.master_cb);
                vif.bready <= 0;
            end // bready
        end // wlast


    endtask : write_response_task

    task read_address_task();
        @(vif.MTR.master_cb);
        vif.arvalid <= 1;
        vif.araddr <= blueprint.araddr;
        vif.arburst <= blueprint.arburst;
        vif.arlen <= blueprint.arlen;
        vif.arsize <= blueprint.arsize;

        if(blueprint.arvalid == 1'b1) begin 
            @(vif.arready); // wait for arready to be asserted
            vif.arvalid <= 1'b0;
            vif.rready <= 1'b1;
            vif.rlast <= 1'b0;
            vif.araddr <= 1'bx;
        end // arvalid

    endtask : read_address_task

    task read_data_task();

        @(vif.rvalid);

        for (int i = 0 ; i <= blueprint.ARLEN ; i++) begin 
            vif.rdata <= blueprint.rdata[i];
            vif.rresp <= blueprint.rresp[i];

            if(i = blueprint.arlen) begin 
                vif.rlast <= 1;
            end 
        end 

        if(vif.rlast == 1'b1) begin 
            @(vif.MTR.master_cb);
            vif.rlast <= 1'b0;
            vif.rready <= 1'b0;
            vif.rdata <= 1'b0;
        end 

    endtask : read_data_task 
endclass : ei_axi4_master_driver_c