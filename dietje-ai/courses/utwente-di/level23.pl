#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level23';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 8;
$REPO = $STUDENT;

#
# Opgave 3.1
#
print "Task 23: (Concurrency and Transactions)\n";
system("find $REPO -name \"*.java\" -exec grep \"commit(\" \\{\\} \\; >$ASSIGN-commit.tmp");
system("find $REPO -name \"*.java\" -exec grep \"rolback(\" \\{\\} \\; >$ASSIGN-rollback.tmp");
system("find $REPO -name \"*.java\" -exec grep \"setAutoCommit(\" \\{\\} \\; >$ASSIGN-autocommit.tmp");
system("find $REPO -name \"*.java\" -exec grep \"setTransactionIsolation(\" \\{\\} \\; >$ASSIGN-isolation.tmp");

if (-s "$ASSIGN-commit.tmp") {
   print "  Correct usage of commit.\n";
   $points++;
}
if (-s "$ASSIGN-rollback.tmp") {
   print "  Correct usage of rollback.\n";
   $points++;
}
if (-s "$ASSIGN-autocommit.tmp") {
   print "  Correct usage of setAutoCommit().\n";
   $points++;
}
if (-s "$ASSIGN-rollback.tmp") {
   print "  Correct usage of setTransactionIsolation().\n";
   $points++;
}
if ($points == 0) {
   print "  I did not find any usage of transactions.\n";
}
else { 
  $points += 4; 
}

give_feedback($points, $TOTAL);
