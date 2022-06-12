class ei_axi4_master_monitor_c;
    
    ei_axi4_transaction_c tr;
    virtual ei_axi4_interface vif;
    mailbox #(ei_axi4_transaction_c) mst_mon2ref;

    function new(mailbox #(ei_axi4_transaction_c) mst_mon2ref, virtual ei_axi4_interface vif);
       
        this.mst_mon2ref = mst_mon2ref;
        this.vif = vif;

    endfunction : new

    task run();

    endtask : run

endclass : ei_axi4_master_monitor_c
