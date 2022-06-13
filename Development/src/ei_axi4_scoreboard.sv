class ei_axi4_scoreboard_c;
    mailbox#(ei_axi4_transaction_c) slv_mon2scb;
    mailbox#(ei_axi4_transaction_c) ref2scb;

    function new(mailbox#(ei_axi4_transaction_c) ref2scb, mailbox#(ei_axi4_transaction_c) slv_mon2scb);
        this.ref2scb = ref2scb;
        this.slv_mon2scb = slv_mon2scb;
    endfunction

    task run();

    endtask
    function void wrap_up();

    endfunction
endclass
