#!/usr/bin/perl

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_WRITE_TEST +total_num_trans=10");

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_READ_TEST");

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=4 ");

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_RANDOM_TEST");

#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui  +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=6 +length=3 +size=2");
system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=1");
