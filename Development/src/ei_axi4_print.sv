virtual class ei_axi4_print_c#(type T = bit);
  
  static function void print_header(
    transaction_type_e tran_type, 
    string component = ""
  );
    $display("+=============================================================\
============================+");
    $display("| Transaction Type : %10s %12s @%5t %37s |", tran_type.name(), 
             (component.len() ? $sformatf("[%0s]", component) : ""), $time, "");
    $display("+=============================================================\
============================+");
    $display("| %6s | %15s | %30s | %4s | %20s |", 
             "Sr No ", "Name", "Type", "Size", "Value");
    $display("+=============================================================\
============================+");
  endfunction
  
  static function void print_item(int sr_no, string identifier, T data);
    $display("| %5d. | %15s | %30s | %4d | %20p |", sr_no, identifier, 
            $typename(data), $bits(data), data);
  endfunction
  
  static function void print_last_item(int sr_no, string identifier, T data);
    $display("| %5d. | %15s | %30s | %4d | %20p |",sr_no, identifier, 
            $typename(data), $bits(data), data);
    $display("+=============================================================\
============================+");
  endfunction
  

  static function void print_empty_item(string identifier, T data);
    $display("| %6s | %15s | %30s | %4d | %20p |","", identifier, 
            $typename(data), $bits(data), data);
  endfunction

  static function void print_empty_last_item(
    string identifier, 
    T data
  );
    $display("| %6s | %15s | %30s | %4d | %20p |", "", identifier, 
            $typename(data), $bits(data), data);
    $display("+=============================================================\
============================+");
  endfunction


  static function void print_array(int sr_no, string identifier, T data[]);
    string str;
    str = {identifier, "[0]"};
    if(data.size() == 0) begin
      print_last_item(sr_no, str, data[0]);
    end
    else begin
      print_item(sr_no, str, data[0]);
    end
    
    foreach(data[i]) begin
      if(i > 0) begin
        $sformat(str, {identifier, "[%0d]"}, i);
        print_empty_item(str, data[i]);
      end
    end
    $sformat(str, {identifier, "[%0d]"}, $size(data) - 1);
  endfunction
  
  static function void print_array_last(int sr_no, string identifier, T data[]);
    string str;
    str = {identifier, "[0]"};
    if(data.size() == 0) begin
      print_last_item(sr_no, str, data[0]);
    end
    else begin
      print_item(sr_no, str, data[0]);
    end
    
    foreach(data[i]) begin
      if(i > 0 && i != ($size(data) - 1)) begin
        $sformat(str, {identifier, "[%0d]"}, i);
        print_empty_item(str, data[i]);
      end
    end
    $sformat(str, {identifier, "[%0d]"}, $size(data) - 1);
    if($size(data) > 0) begin
      print_empty_last_item(str, data[$size(data) - 1]);
    end
  endfunction

endclass

