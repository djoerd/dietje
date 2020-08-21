#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level12';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 4;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 12
#
print "Task 12: (Unit tests)\n";
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
    $points += 1;
    $TOTAL += 1;
  }
  else {
    print "  No JUnit dependency in pom.xml.\n";
  }
}

system ("find $REPO -name \"*.java\" | wc -l > $ASSIGN-main.tmp");
system ("find $REPO -name \"*.java\" -exec grep -l \"org.junit\" \\{\\} \\; | wc -l > $ASSIGN-test.tmp");
if (assert_at_least("  Add unit tests", "$ASSIGN-test.tmp", "1")) {
  $points++;
}
my $nr_of_tests = file_content("$ASSIGN-test.tmp");
if ($nr_of_tests > 0) {
   printf "  You have %d unit tests.\n", $nr_of_tests;
   if ($nr_of_tests > 1) { $points++; }
   if ($nr_of_tests > 3) { $points++; }

  my $nr_of_main = file_content("$ASSIGN-main.tmp");
  if ($nr_of_main && $nr_of_main - $nr_of_tests > $nr_of_tests) {
     printf "  You have unit tests for roughly %d %% of your code.\n", ($nr_of_tests * 102) / ($nr_of_main - $nr_of_tests);
     $TOTAL += 3 * (1 - ($nr_of_tests / ($nr_of_main - $nr_of_tests))); 
  }
  #else {
  #  $points += $nr_of_tests;
  #  $TOTAL += $nr_of_tests;
  #}
}

give_feedback($points, $TOTAL);
