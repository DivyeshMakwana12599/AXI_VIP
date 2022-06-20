class ei_axi4_checker_cfg_c;

  string checker_description;
  enum bit {ON, OFF} disable_checker;
  enum bit {ELEVATED, DEMOTED} checker_mode;
  int eval_cnt;
  int fail_cnt;

  function new(string checker_description);
    this.checker_description = checker_description;
  endfunction

endclass
