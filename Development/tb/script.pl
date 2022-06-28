#!/usr/bin/perl
#--------------------------  SANITY TEST CASE
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=6 +length=3");

#-------------------------- Sequential Write Read
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=4 +length=3 +size=3 +burst_type=1 +addr_type=0");
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=4 +length=3 +size=3 +burst_type=1 +addr_type=0");

system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_4K_BOUNDARY_TEST ");
system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_4K_BOUNDARY_TEST ");
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=4 ");

#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_RANDOM_TEST");

#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui  +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=6 +length=3 +size=2");
system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=1");
#system("vcs -sverilog -full64 -debug_access+r  +error+20 ei_axi4_top.sv && ./simv +ei_axi4_4KB_BOUNDARY_TEST +total_num_trans=6 ");
<<<<<<< HEAD
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui  +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=4 +length=3");
=======
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=4 +length=7 +size=3 +addr_type=0 +burst_type=0");
system("./simv -gui +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=4 +length=4 +size=3 +addr_type=0 +burst_type=0");
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_READ_TEST +total_num_trans=4 +length=3 +size=2 +addr_type=0 +burst_type=1");
system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui  +ei_axi4_SEQ_WR_RD_TEST +total_num_trans=4 +length=3");
>>>>>>> 338cebdb5a9d1243b7c756910a4ed7807d3f1a4f
#system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv  +ei_axi4_4K_BOUNDARY_TEST +total_num_trans=1");
