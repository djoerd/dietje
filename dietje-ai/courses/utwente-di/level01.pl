#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'djoerd';
$PASS = 'password';
$ASSIGN = 'level01';

if ($#ARGV != 0) { 
  print "Failed grading: Student id not provided.\n";
  die;
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 3;
$REPO = $STUDENT;

system ("rm -rf $REPO"); # we're going to do a fresh install
system ("rm -rf *.tmp");
 
#
# Opgave 1.1
#
print "Task 1.1 (github):\n";
if (git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO)) {
  $points += 2;
  print "  Ok.\n";
} else {
  print "  Error: Cannot access https://github.com/utwente-di/$STUDENT\n"; 
  #exit 0;
}


#
# Opgave 1.2
#
print "Task 1.2: (README.md)\n";
if (assert_file_exists ("  Warning", "$REPO/README.md", "  Ok.")) {
  system("cat $REPO/README.md | wc -l >$ASSIGN-readme.tmp");
  if (assert_at_least("  Add some lines to README.md", "$ASSIGN-readme.tmp", "2")) {
    $points++;
  }
}


give_feedback($points, $TOTAL);
