class c_1_2;
    bit[31:0] total_num_trans = 32'hb;

    constraint reasonable_this    // (constraint_mode = ON) (../test/ei_axi4_test_config.sv:74)
    {
       (total_num_trans inside {[1:10]});
    }
endclass

program p_1_2;
    c_1_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "x01xxzxxxx11z1z0z00xx0xzzx010z0xxxxzzxzxzzzxxzxzxxxxzxxxxzzzzzxz";
            obj.set_randstate(randState);
            obj.total_num_trans.rand_mode(0);
            obj.randomize();
        end
endprogram
