class c_407_2;
    bit[1:0] test_cfg_burst_type = 2'h0; // ( test_cfg.burst_type = $unit::burst_type_e::FIXED ) 
    bit[7:0] test_cfg_transaction_length = 8'hc;
    bit[2:0] test_cfg_transfer_size = 3'h5;
    bit[0:0] test_cfg_addr_type = 1'h0; // ( test_cfg.addr_type = $unit::addr_type_e::ALIGNED ) 
    randc bit[1:0] burst; // rand_mode = ON 
    randc bit[7:0] len; // rand_mode = ON 
    randc bit[31:0] addr; // rand_mode = ON 
    randc bit[2:0] size; // rand_mode = ON 
    rand bit[30:0] data_size_; // rand_mode = ON 

    constraint burst_type_ct_this    // (constraint_mode = ON) (../src/ei_axi4_transaction.sv:70)
    {
       (burst inside {2'h0 /* $unit::burst_type_e::FIXED */, 2'h1 /* $unit::burst_type_e::INCR */, 2'h2 /* $unit::burst_type_e::WRAP */});
    }
    constraint burst_wrap_len_ct_this    // (constraint_mode = ON) (../src/ei_axi4_transaction.sv:74)
    {
       (burst == 2'h2 /* $unit::burst_type_e::WRAP */) -> (len inside {1, 3, 7, 15});
    }
    constraint burst_fixed_len_ct_this    // (constraint_mode = ON) (../src/ei_axi4_transaction.sv:78)
    {
       (burst == 2'h0 /* $unit::burst_type_e::FIXED */) -> (len < 8'h10);
    }
    constraint burst_wrap_aligned_addr_ct_this    // (constraint_mode = ON) (../src/ei_axi4_transaction.sv:82)
    {
       (burst == 2'h2 /* $unit::burst_type_e::WRAP */) -> ((addr % (1 << size)) == 1'h0);
    }
    constraint transfer_size_ct_this    // (constraint_mode = ON) (../src/ei_axi4_transaction.sv:86)
    {
       ((1 << size) <= 8);
    }
    constraint boundary_4kb_ct_this    // (constraint_mode = ON) (../src/ei_axi4_transaction.sv:90)
    {
       ((((addr - (addr % (1 << size))) % 4096) + ((len + 1) * (1 << size))) <= 4096);
    }
    constraint data_arr_size_ct_this    // (constraint_mode = ON) (../src/ei_axi4_transaction.sv:94)
    {
       (data_size_ == (len + 1));
    }
    constraint addr_type_c_this    // (constraint_mode = ON) (../src/ei_axi4_read_trans.sv:13)
    {
       (test_cfg_addr_type == 1'h0 /* $unit::addr_type_e::ALIGNED */) -> ((addr % size) == 1'h0);
       (test_cfg_addr_type == 1'h1 /* $unit::addr_type_e::UNALIGNED */) -> ((addr % size) != 1'h0);
    }
    constraint specific_burst_type_c_this    // (constraint_mode = ON) (../src/ei_axi4_read_trans.sv:18)
    {
       (test_cfg_burst_type == burst);
    }
    constraint specific_transaction_length_this    // (constraint_mode = ON) (../src/ei_axi4_read_trans.sv:22)
    {
       (test_cfg_transaction_length == len);
    }
    constraint specific_transfer_size_this    // (constraint_mode = ON) (../src/ei_axi4_read_trans.sv:26)
    {
       (test_cfg_transfer_size == size);
    }
    constraint INTERNAL_13  // (constraint_mode = ON)
    {
       (burst inside {[2'h0 /* $unit::burst_type_e::FIXED */:2'h2 /* $unit::burst_type_e::WRAP */]});
    }
endclass

program p_407_2;
    c_407_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "z0z000xxxx10xzz0xz111zxx0z1x011zxxxxzzxxzzzxzxxxzzxzzzxxzxzzxzxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
