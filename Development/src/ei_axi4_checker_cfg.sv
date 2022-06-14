class ei_axi4_checker_cfg_c;

  string checker_description;
  enum bit {ON, OFF} disable_checker;
  int eval_cnt;
  int fail_cnt;

  function new(string checker_description);
    this.checker_description = checker_description;
  endfunction

endclass
