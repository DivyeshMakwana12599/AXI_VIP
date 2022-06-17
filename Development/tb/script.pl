#!/usr/bin/perl

#<<<<<<< HEAD
system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_WRITE_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0 +burst_type=1");
#=======
#<<<<<<< HEAD
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=2 +length=3 +size=2 +addr_type=0 +burst_type=1");
#=======
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_READ_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0 +burst_type=1");
#>>>>>>> 00bf00c740d7f1a34ee74f10d8bd2c9c77df1e6d
#>>>>>>> 58098a03df5bf881f29393e23171646eee5c87d2
