#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level21';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 4;
$TOTAL = 5;
$REPO = $STUDENT;

#
# Opgave 3.1
#
print "Task 21: (Ethics report)\n";
system("find $REPO -name \"ethics.pdf\" >$ASSIGN-ethics.tmp");
if (-s "$ASSIGN-ethics.tmp") {
   print "  Found the ethics report. Well done.\n";
   $points++;
}
else {
   print "  I did not find your ethics.pdf report under 'design'.\n";
}

print "  As a computerized professor, I don't know much about ethics.\n";
print "  Except of course Asimov's laws...\n";
print "  Fortunately, Prof. Falgoust checked your ethics reports.\n";

give_feedback($points, $TOTAL);
