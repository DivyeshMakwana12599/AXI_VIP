class ei_axi4_read_write_transaction_c extends ei_axi4_transaction_c;

    ei_axi4_test_config_c test_cfg;

    function new();
        test_cfg = new();
    endfunction : new

    function void pre_randomize();
        `SV_RAND_CHECK(test_cfg.randomize());
    endfunction : pre_randomize

    constraint transaction_type_write_read{
        transaction_type == READ_WRITE; 
    }

    function void post_randomize();
        super.post_randomize();
    endfunction : post_randomize

endclass : ei_axi4_read_write_transaction_c
