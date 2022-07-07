class ei_axi4_checker_db_c;

  ei_axi4_checker_cfg_c check_cfg[string];

  function void register_checker(string checker_id, string checker_description);
    check_cfg[checker_id] = new(checker_description);
  endfunction

  function void disable_checker(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      check_cfg[checker_id].disable_checker = ei_axi4_checker_cfg_c::OFF;
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void enable_check(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      check_cfg[checker_id].disable_checker = ei_axi4_checker_cfg_c::ON;
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void pass(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      if(check_cfg[checker_id].disable_checker == ei_axi4_checker_cfg_c::ON) begin
        check_cfg[checker_id].eval_cnt++;
      end
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void fail(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      if(check_cfg[checker_id].disable_checker == ei_axi4_checker_cfg_c::ON) begin
        check_cfg[checker_id].fail_cnt++;
        if(
          check_cfg[checker_id].checker_mode == ei_axi4_checker_cfg_c::ELEVATED
        ) begin
          $error(checker_id,, check_cfg[checker_id].checker_description);
        end
        else begin
          $info(checker_id,, check_cfg[checker_id].checker_description);
        end
      end
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void demote_checker(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      check_cfg[checker_id].checker_mode = ei_axi4_checker_cfg_c::DEMOTED;
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void elevate_checker(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      check_cfg[checker_id].checker_mode = ei_axi4_checker_cfg_c::ELEVATED;
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void report();
    if(check_cfg.size) begin
      $display("+================================================================================================================================+");
      $display("| %-18s | %-75s | %-12s | %-12s |", "CHECKER ID", "DESCRIPTION", "FAIL COUNT", "PASS COUNT");
      $display("+================================================================================================================================+");
      foreach(check_cfg[i]) begin
        $display("| %-18s | %-75s | %-12d | %-12d |", i, check_cfg[i].checker_description, check_cfg[i].fail_cnt, check_cfg[i].eval_cnt);
      end
      $display("+================================================================================================================================+");
    end
    else begin
      $display("Nothing to report no checker registered.");
    end
  endfunction
endclass

// module test();
  // ei_axi4_checker_db_c checker_db = new();
// 
  // initial begin
    // checker_db.report();
  // end
// endmodule
