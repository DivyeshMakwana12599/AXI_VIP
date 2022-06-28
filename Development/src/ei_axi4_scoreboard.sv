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
      $display("got from reference");
      golden_trans.print("GOLDEN");
      slv_mon2scb.get(trans);
      $display("got from monitor");
      trans.print("TRAN");
      if(trans.compare(golden_trans)) begin
        $display("@%0t Transaction Passed!", $time);
        passed_transaction++;
      end
      else begin
        $display("@%0t Transaction Failed!", $time);
        failed_transaction++;
      end
    end
  endtask

  function void wrap_up();
    $display("No. of transaction passed : %0d",passed_transaction);
  endfunction
endclass
