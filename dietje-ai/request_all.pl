#!/usr/bin/perl

use strict;

for (my $i = 0; $i <= 20; $i++) {
  my $student = substr("0$i", -2);
  for (my $j = 1; $j <= 23; $j++) {
    my $level = substr("0$j", -2);
    my $command = "curl -d 'course=utwente-di&nickname=di$student&assignment=level$level' http://dietje.org/services/request.json";
    print "$command\n";
    system ($command); 
    print "\n";
  }
}

