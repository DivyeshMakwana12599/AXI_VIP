class ei_axi4_reference_model_c;

    mailbox#(ei_axi4_transaction_c) mon2ref;
    mailbox#(ei_axi4_transaction_c) ref2scb;

    bit [`DATA_WIDTH - 1:0] reference_memory [bit [`ADDR_WIDTH - 1 - (`ADDR_WIDTH / 8):0]];

    function new(mailbox#(ei_axi4_transaction_c) mon2ref, mailbox#(ei_axi4_transaction_c) ref2scb);
        this.mon2ref = mon2ref;
        this.ref2scb = ref2scb;
    endfunction

    task run();

    endtask

    function void wrap_up();

    endfunction
endclass
