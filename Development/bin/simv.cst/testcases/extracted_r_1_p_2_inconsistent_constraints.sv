class c_1_2;
    bit[31:0] total_num_trans = 32'h1f4;

    constraint reasonable_this    // (constraint_mode = ON) (../test/ei_axi4_test_config.sv:43)
    {
       (total_num_trans inside {[1:100]});
    }
endclass

program p_1_2;
    c_1_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "z1x1001111xzxxx1000zz0z1zz00zxx1xxzzxxzzxzzxzxzxxzxzxzzxzzxzxzzz";
            obj.set_randstate(randState);
            obj.total_num_trans.rand_mode(0);
            obj.randomize();
        end
endprogram
