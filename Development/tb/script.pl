#!/usr/bin/perl
system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0 +burst_type=0 >> output.log");
#system("dve -full64 &")
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=2 +length=3 +size=2 +addr_type=0 +burst_type=1");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_READ_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0 +burst_type=1");
