#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Getopt::Long;

my $top_file_path = '../tb/ei_axi4_top.sv';
my $compiler = 'vcs -sverilog -full64 -debug_access+r +error+20';
my $simulator = './simv';

system "$compiler $top_file_path";

# get all testcases names for 
open(TESTCASE, "<", "testcase.txt") or 
die("Create a file named testcase.txt containing all the testcase names");
my @testcase_name = <TESTCASE>;
close(TESTCASE);


foreach my $line(@testcase_name){
  chomp($line);
}

GetOptions(
  "gui" => \my $gui, 
  "testcase=i" => \my $testcase, 
  "burst=s" => \my $burst, 
  "address_type=s" => \my $address_type, 
  "size=i" => \my $size, 
  "length=i" => \my $length, 
  "num_of_tran=i" => \my $num_of_tran, 
  "help" => \my $help
);

# g - gui           - to run and open waveform i.e. gui
# t - testcase      - to give testcase as argument
# b - burst         - to provide burst type in form of string or integer
# a - address_type  - to provide address type in form of string or integer
# s - size          - to provide transfer size in form of integer
# l - length        - to provide transaction length in form of integer
# n - num_of_tran   - to give number of transactions to testbench
# h - help          - to print out manual/script for the tb 
#                     i.e. testcases and options

# subroutine to print out help for the script
sub printHelp {
  printTestcase();
  print  "USAGE: ./script.pl -<OPTIONS> <ARGUMENT>\n";
  printf "╔═%-20s═╦═%-65s═╦═%-15s═╗\n", "═"x20, "═"x65, "═"x15;
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "OPTIONS", "DESCRIPTION", "ARGUMENT TYPE";
  printf "╠═%-20s═╬═%-65s═╬═%-15s═╣\n", "═"x20, "═"x65, "═"x15;
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "--help, -h", "To print out manual/script for the tb.", "NO";
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "--gui, -g", "To run and open waveform i.e. gui.", "NO";
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "--testcase, -t", "To give testcase as argument.", "INTEGER";
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "--burst, -b", "To provide burst type in form of string or integer.", "STRING";
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "--size, -s", "To provide transfer size in form of integer.", "INTEGER";
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "--length, -l", "To provide transaction length in form of integer.", "INTEGER";
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "--address_type", "To provide address type in form of string or integer.", "STRING";
  printf "║ %-20s ║ %-65s ║ %-15s ║\n", "--num_of_tran, -n", "To give number of transactions to testbench.", "INTEGER";
  printf "╚═%-20s═╩═%-65s═╩═%-15s═╝\n", "═"x20, "═"x65, "═"x15;
  # printf "║ %-20s ║ %-65s ║ %-15s ║\n", "", "", ""; FORMAT
}

# parsing inputs 
if($help) {
  printHelp();
}
else {
  if($gui) {
    $simulator = $simulator . " -gui";
  }
  if($testcase) {
    $simulator = $simulator . " +$testcase_name[$testcase - 1]";
  }
  if($num_of_tran) {
    $simulator = $simulator . " +total_num_transactions=$num_of_tran";
  }
  if($burst) {
    $simulator = $simulator . " +burst_type=$burst";
  }
  if($size) {
    $simulator = $simulator . " +size=$size";
  }
  if($length) {
    $simulator = $simulator . " +length=$length";
  }
  if($address_type) {
    $simulator = $simulator . " +addr_type=$address_type";
  }
  if(!$testcase) {
    say "No Testcase passed printing testcase table pass index of testcase";
    say "./script -t <TESTCASE INDEX>";
    system "sleep 1";
    printTestcase();
    exit();
  }
  if(!$gui) {
    $simulator =~ s/-gui//;
    system "$simulator > output.log"
  } else {
    system $simulator
  }

}



# Subroutine for printing out all the testcases 
sub printTestcase {
  my $i = 0;
  my $no_of_testcase;
  my $max = 47;
  my $current;
  my $final_count;
  my $m;

  print("╔", "═"x45,"╦","═"x45,"═"x25,"╗\n");
  print("║"," "x45,"║"," "x70,"║\n");
  print("║\t\t TESTCASE_ID\t\t      ║\t\t\t\tTESTCASE_NAME", " "x31," ║\n");
  print("║"," "x45,"║"," "x70,"║\n");
  print("╠", "═"x45,"╬","═"x45,"═"x25,"╣\n");

  print("║", " "x45,"║"," "x70,"║\n");
  foreach (@testcase_name){
      if($i < 9){
          $current = length($testcase_name[$i]);
          $final_count = $max - $current;
          $m = $i + 1;
          print("║\t\t AXI_TEST_00$m\t\t      ║\t\t\t$testcase_name[$i]"," "x5," "x$final_count," ║\n"); 
          $i++;
      }
      if($i >= 9 && $i < 19){
          $current = length($testcase_name[$i]);
          $final_count = $max - $current;
          $m = $i + 1;
          print("║\t\t AXI_TEST_0$m\t\t     ║\t\t\t$testcase_name[$i]"," "x5," "x$final_count,"║\n"); 
          $i++;
      }
  }
  print("║", " "x45,"║"," "x70,"║\n");
  print("╚", "═"x45,"╩","═"x45,"═"x25,"╝\n");
}
