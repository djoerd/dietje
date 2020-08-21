#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level22';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 6;
$TOTAL = 9;
$REPO = $STUDENT;

#
# Opgave 3.1
#
print "Task 22: (Security)\n";
system("find $REPO -name \"*.java\" -exec grep \"prepareStatement(\" \\{\\} \\; >$ASSIGN-prepared.tmp");
if (-s "$ASSIGN-prepared.tmp") {
   print "  Correct usage of prepared statements.\n";
   $points += 3;
}
else {
   print "  I did not find prepared statements in your code.\n";
   print "  The applications might be vulnerable to SQL injection.\n";

}
print "  I did not find any other security issues.\n";

give_feedback($points, $TOTAL);
