#!/usr/bin/perl

my $MIN = 10;

my $seconds = 300;
if ($#ARGV >= 0) {
  $seconds = $ARGV[0];
}
if ($seconds < $MIN) {
  $seconds = $MIN;
}

while(1) {
  print STDERR "Check now\n";
  system("./check_submits2.pl");
  sleep $seconds;
}
