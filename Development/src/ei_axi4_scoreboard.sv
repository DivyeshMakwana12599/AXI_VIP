class ei_axi4_scoreboard_c;

  mailbox#(ei_axi4_transaction_c) slv_mon2scb;
  mailbox#(ei_axi4_transaction_c) ref2scb;

  int passed_transaction;
  int failed_transaction;

  function new(mailbox#(ei_axi4_transaction_c) ref2scb, mailbox#(ei_axi4_transaction_c) slv_mon2scb);
    this.ref2scb = ref2scb;
    this.slv_mon2scb = slv_mon2scb;
  endfunction

  task run();
    ei_axi4_transaction_c golden_trans;
    ei_axi4_transaction_c trans;
    forever begin
      ref2scb.get(golden_trans);
      slv_mon2scb.get(trans);
      if(trans.compare(golden_trans)) begin
        $display("Transaction Passed!");
        passed_transaction++;
      end
      else begin
        $display("Transaction Failed!");
        failed_transaction++;
      end
    end
  endtask

  function void wrap_up();

  endfunction
endclass
