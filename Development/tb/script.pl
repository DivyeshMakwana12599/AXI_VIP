#!/usr/bin/perl

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=6 +length=3");

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_WRITE_TEST +total_num_trans=10");

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_READ_TEST");

#system("./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0");
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=4 ");

system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_4K_BOUNDARY_TEST  +total_num_trans=4");

##system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui  +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=4 +length=3");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv +ei_axi4_SANITY_TEST +total_num_trans=4 +length=7 +size=3 +addr_type=0 +burst_type=0");
##system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_READ_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0 +burst_type=1");
##system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui  +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=4 +length=3");
##system("./simv -gui +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=4 +length=4 +size=3 +addr_type=0 +burst_type=0");
##system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=1");
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=4 ");

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv  +ei_axi4_ERROR_WRAP_UNALIGNED_TEST +total_num_trans=100");
#system("./simv +total_num_trans=20  -gui +ei_axi4_PARALLEL_WR_RD_TEST");

#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv   +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=6 +length=3 +size=2");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=5");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_ERROR_WRAP_UNALIGNED_TEST +total_num_trans=5");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_ERROR_FIXED_LEN_TEST +total_num_trans=5");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_ERROR_WRAP_LEN_TEST +total_num_trans=5");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_ERROR_EARLY_TERMINATION_TEST +total_num_trans=5");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_PARALLEL_WR_RD_TEST +total_num_trans=4 +length=3");

#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui  +ei_axi4_PARALLEL_WR_RD_TEST");
