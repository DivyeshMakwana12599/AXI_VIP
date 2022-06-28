#!/usr/bin/perl
#--------------------------  SANITY TEST CASE
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=6 +length=3");

#-------------------------- Sequential Write Read
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=4 +length=3 +size=3 +burst_type=1 +addr_type=0");
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=4 +length=3 +size=3 +burst_type=1 +addr_type=0");

system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_SANITY_TEST +total_num_trans=6");
system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST ");
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=4 ");

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_RANDOM_TEST");
