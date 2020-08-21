#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
#$ASSIGN = 'level03';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 1;
$REPO = $STUDENT;

#
# Opgave 3.1
#
print "Task 3: (Daily standups)\n";
print "  You did the daily standups. Well done.\n";
$points++;

give_feedback($points, $TOTAL);
