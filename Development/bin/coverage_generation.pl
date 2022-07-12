#!/usr/bin/perl


for my $len (130..255) {
  system "./simv +ei_axi4_SANITY_TEST +total_num_trans=5 +length=$len +size=0";
  system "urg -dir ./simv.vdb -dir ./mergedir.vdb -dbname mergedir/merged -format both";
}
system "head urgReport/grpinfo.txt";
