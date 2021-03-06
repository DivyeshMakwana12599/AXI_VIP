class c_3_2;
    bit[1:0] test_cfg_burst_type = 2'h1; // ( test_cfg.burst_type = $unit::burst_type_e::INCR ) 
    bit[7:0] test_cfg_transaction_length = 8'ha3;
    bit[2:0] test_cfg_transfer_size = 3'h1;
    bit[0:0] test_cfg_addr_type = 1'h1; // ( test_cfg.addr_type = $unit::addr_type_e::UNALIGNED ) 
    bit[1:0] burst = 2'h0; // ( burst = $unit::burst_type_e::FIXED ) 
    randc bit[7:0] len; // rand_mode = ON 
    randc bit[31:0] addr; // rand_mode = ON 
    randc bit[2:0] size; // rand_mode = ON 
    rand bit[30:0] data_size_; // rand_mode = ON 
    randc bit[1:0] transaction_type; // rand_mode = ON 

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
       (transaction_type == 2'h0 /* $unit::transaction_type_e::READ */) -> (data_size_ == 0);
       (!(transaction_type == 2'h0 /* $unit::transaction_type_e::READ */)) -> (data_size_ == (len + 1));
    }
    constraint addr_type_c_this    // (constraint_mode = ON) (../src/ei_axi4_read_trans.sv:13)
    {
       (test_cfg_addr_type == 1'h0 /* $unit::addr_type_e::ALIGNED */) -> ((addr % (1 << size)) == 1'h0);
       (test_cfg_addr_type == 1'h1 /* $unit::addr_type_e::UNALIGNED */) -> ((addr % (1 << size)) != 1'h0);
    }
    constraint specific_burst_type_this    // (constraint_mode = ON) (../src/ei_axi4_read_trans.sv:18)
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
    constraint transaction_type_read_this    // (constraint_mode = ON) (../src/ei_axi4_read_trans.sv:30)
    {
       (transaction_type == 2'h0 /* $unit::transaction_type_e::READ */);
    }
    constraint INTERNAL_13  // (constraint_mode = ON)
    {
       (burst inside {[2'h0 /* $unit::burst_type_e::FIXED */:2'h2 /* $unit::burst_type_e::WRAP */]});
       (transaction_type inside {[2'h0 /* $unit::transaction_type_e::READ */:2'h2 /* $unit::transaction_type_e::WRITE */]});
    }
endclass

program p_3_2;
    c_3_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "10101zzzzxz0xz0x0zxxx101000z1z1xzzzxxxxxxxzzxxzzxzzzzzxxzxxzzzxz";
            obj.set_randstate(randState);
            obj.burst.rand_mode(0);
            obj.randomize();
        end
endprogram
