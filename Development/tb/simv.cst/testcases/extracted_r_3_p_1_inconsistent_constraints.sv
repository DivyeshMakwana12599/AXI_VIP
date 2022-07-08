class c_3_1;
    rand bit[2:0] errors = 3'h4; // rand_mode = OFF  // ( errors = $unit::possible_errors_e::ERROR_FIXED_LEN ) 

    constraint error_ct_this    // (constraint_mode = ON) (../src/ei_axi4_transaction.sv:59)
    {
       (errors dist {15'h14e5 :/ 1, 3'h0 /* $unit::possible_errors_e::NO_ERROR */ :/ 999});
    }
endclass

program p_3_1;
    c_3_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "zz1xxxxzz10z0z1x11xz0xzzzzzzz011xxzxxzxxxzxxzzzxzzzxzzzxxxzzzzzx";
            obj.set_randstate(randState);
            obj.errors.rand_mode(0);
            obj.randomize();
        end
endprogram
