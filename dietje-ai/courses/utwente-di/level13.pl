#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level13';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 2;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 13
#
print "Task 13: (Test-driven development)\n";
system("find $REPO -name \"pom.xml\" -exec dirname \\{\\} \\; >$ASSIGN-pom.tmp");
if (-s "$ASSIGN-pom.tmp") {
  $dir = file_content("$ASSIGN-pom.tmp");
  $dir =~ s/\s.*$//g;
}
else {
  $dir = $REPO;
}
if (assert_file_exists ("  Warning", "$dir/pom.xml", "  Ok.")) {
  system ("cat $dir/pom.xml | grep -i \"junit\" >$ASSIGN-junit.tmp");
  if (-s "$ASSIGN-junit.tmp") {
    print "  JUnit found in pom.xml.\n";
  }
  else {
    print "  No JUnit dependency in pom.xml.\n";
    $TOTAL++;
  }
}

system ("find $REPO -name \"*.java\" -exec grep -l \"org.junit\" \\{\\} \\; | wc -l > $ASSIGN-test.tmp");
if (assert_at_least("  Add unit tests", "$ASSIGN-test.tmp", "1")) {
  $points++;
  my $nr_of_tests = file_content("$ASSIGN-test.tmp");
  if ($nr_of_tests > 1) {
     printf "  You have %d unit tests.\n", $nr_of_tests;
     $points++;
  }
  else { 
     print "  Only one unit test?\n";
  }
}
print "  I cannot assess test-driven development, currently.\n";
print "  Ask a professor of flesh and blood.\n";

give_feedback($points, $TOTAL);
