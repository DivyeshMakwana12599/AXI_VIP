class ei_axi4_scoreboard_c;
    mailbox#(ei_axi4_transaction_c) mon2scb;
    mailbox#(ei_axi4_transaction_c) ref2scb;

    function new(mailbox#(ei_axi4_transaction_c) ref2scb, mailbox#(ei_axi4_transaction_c) mon2scb);
        this.ref2scb = ref2scb;
        this.mon2scb = mon2scb;
    endfunction

    task run();

    endtask
    function void wrap_up();

    endfunction
endclass
