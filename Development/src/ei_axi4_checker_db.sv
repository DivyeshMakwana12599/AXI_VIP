class checker_db_c;

  checker_cfg_c check_cfg[string];

  function void register_checker(string checker_id, string checker_description);
    check_cfg[checker_id] = new(checker_id, checker_description);
  endfunction

  function void disable_checker(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      check_cfg[checker_id].disable_checker = checker_cfg_c::OFF;
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void enable_check(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      check_cfg[checker_id].disable_checker = checker_cfg_c::ON;
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void pass(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      if(check_cfg[checker_id].disable_checker == checker_cfg_c::ON) begin
        check_cfg[checker_id].eval_cnt++;
      end
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

  function void fail(string checker_id);
    if(check_cfg.exists(checker_id)) begin
      if(check_cfg[checker_id].disable_checker == checker_cfg_c::ON) begin
        check_cfg[checker_id].eval_cnt++;
        check_cfg[checker_id].fail_cnt++;
        $error(checker_id,, check_cfg[checker_id].checker_description);
      end
    end
    else begin
      $display("Checker Not Regestered! i.e., %s", checker_id);
    end
  endfunction

endclass
