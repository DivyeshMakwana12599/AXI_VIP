#!/usr/bin/perl

system("vcs -sverilog -full64 -debug_access+r ei_axi4_top.sv && ./simv -gui +READ_TEST +length=3 +size=2 +addr_type=0 +burst_type=1 > output.log");
