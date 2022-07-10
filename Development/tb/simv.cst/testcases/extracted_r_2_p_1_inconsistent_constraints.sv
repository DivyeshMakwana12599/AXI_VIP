class c_2_1;
    randc bit[2:0] transfer_size; // rand_mode = ON 
    randc bit[7:0] transaction_length; // rand_mode = ON 
    bit[0:0] addr_type = 1'h1; // ( addr_type = $unit::addr_type_e::UNALIGNED ) 
    bit[1:0] burst_type = 2'h2; // ( burst_type = $unit::burst_type_e::WRAP ) 

    constraint addr_type_c_this    // (constraint_mode = ON) (../test/ei_axi4_test_config.sv:39)
    {
       (addr_type == 1'h1 /* $unit::addr_type_e::UNALIGNED */) -> (transfer_size > 3'h0);
    }
    constraint wrap_len_ct_this    // (constraint_mode = ON) (../test/ei_axi4_test_config.sv:45)
    {
       (burst_type == 2'h2 /* $unit::burst_type_e::WRAP */) -> (transaction_length inside {1, 3, 7, 15});
    }
    constraint burst_fixed_len_ct_this    // (constraint_mode = ON) (../test/ei_axi4_test_config.sv:49)
    {
       (burst_type == 2'h0 /* $unit::burst_type_e::FIXED */) -> (transaction_length < 8'h10);
    }
    constraint transfer_size_ct_this    // (constraint_mode = ON) (../test/ei_axi4_test_config.sv:53)
    {
       ((1 << transfer_size) <= (64 / 8));
    }
    constraint wrap_unaligned_ct_this    // (constraint_mode = ON) (../test/ei_axi4_test_config.sv:57)
    {
       (burst_type == 2'h2 /* $unit::burst_type_e::WRAP */) -> (addr_type == 1'h0 /* $unit::addr_type_e::ALIGNED */);
    }
    constraint burst_type_ct_this    // (constraint_mode = ON) (../test/ei_axi4_test_config.sv:61)
    {
       (burst_type inside {2'h0 /* $unit::burst_type_e::FIXED */, 2'h1 /* $unit::burst_type_e::INCR */, 2'h2 /* $unit::burst_type_e::WRAP */});
    }
    constraint INTERNAL_7  // (constraint_mode = ON)
    {
       (addr_type inside {1'h0 /* $unit::addr_type_e::ALIGNED */, 1'h1 /* $unit::addr_type_e::UNALIGNED */});
       (burst_type inside {[2'h0 /* $unit::burst_type_e::FIXED */:2'h2 /* $unit::burst_type_e::WRAP */]});
    }
endclass

program p_2_1;
    c_2_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "z1zxz11zx0xz10101zzz110z0z1zz0zxxxxzxzzxzzxxxzzxxxxxxxzxxxxxzxxz";
            obj.set_randstate(randState);
            obj.addr_type.rand_mode(0);
            obj.burst_type.rand_mode(0);
            obj.randomize();
        end
endprogram
