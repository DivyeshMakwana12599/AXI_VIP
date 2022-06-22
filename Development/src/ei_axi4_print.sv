virtual class ei_axi4_print_c#(type T = bit);
  
  static function void print_header();
    $display("+=========================================================+");
    $display("| %6s | %15s | %10s | %4s | %8s |", 
             "Sr No ", "Name", "Type", "Size", "Value");
    $display("+=========================================================+");
  endfunction
  
  static function void print_item(int sr_no, string identifier, T data);
    $display("| %5d. | %15s | %10s | %4d | %8p |", sr_no, identifier, 
            $typename(data), $bits(data), data);
  endfunction
  
  static function void print_last_item(int sr_no, string identifier, T data);
    $display("| %5d. | %15s | %10s | %4d | %8p |",sr_no, identifier, 
            $typename(data), $bits(data), data);
    $display("+=========================================================+");
  endfunction
  

  static function void print_empty_item(string identifier, T data);
    $display("| %6s | %15s | %10s | %4d | %8p |","", identifier, 
            $typename(data), $bits(data), data);
  endfunction

  static function void print_empty_last_item(
    string identifier, 
    T data
  );
    $display("| %6s | %15s | %10s | %4d | %8p |", "", identifier, 
            $typename(data), $bits(data), data);
    $display("+=========================================================+");
  endfunction


  static function void print_array(int sr_no, bit hello);
    string str;
    str = {identifier, "[0]"};
    printItem(sr_no, str, data[0]);
    
    foreach(data[i]) begin
      if(i > 0 && i != ($size(data) - 1)) begin
        $sformat(str, {identifier, "[%0d]"}, i);
        print_empty_item(str, data[i]);
      end
    end
    $sformat(str, {identifier, "[%0d]"}, $size(data) - 1);
    print_empty_last_item(str, data[$size(data) - 1]);
  endfunction
  
endclass

