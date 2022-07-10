#!/usr/bin/perl


for my $i(0..255) {
    $void = `./script.pl -t ei_axi4_READ_TEST -n 1 -l $i -s 0 -cov -m 2>&1 /dev/null`;
}
system "head urgReport/grpinfo.txt";
