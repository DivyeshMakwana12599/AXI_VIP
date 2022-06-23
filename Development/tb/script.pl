#!/usr/bin/perl
# system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_RANDOM_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0 +burst_type=0 ");
# system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_SANTYI +total_num_trans=6 ");
#system("dve -full64 &")
# system("./simv -gui +ei_axi4_RANDOM_TEST +total_num_trans=6");
system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv +ei_axi4_SANITY_TEST +total_num_trans=10 +length=3 +size=2 +addr_type=0 +burst_type=0");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_READ_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0 +burst_type=1");
