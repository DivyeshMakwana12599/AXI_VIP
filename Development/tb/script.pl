#!/usr/bin/perl

<<<<<<< HEAD
system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +total_num_trans=2 +length=3 +size=2 +addr_type=0 +burst_type=1");
=======
system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +ei_axi4_SANITY_TEST +length=3 +size=2 +addr_type=0 +burst_type=1");
>>>>>>> cf0cecadb90bd05d7631c59270da2df8c6d6e1fa
