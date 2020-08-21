#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level16';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 5;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 
#
print "Task 16: (JDBC)\n";
system ("find $REPO -name \"pom.xml\" -exec grep -i \"postgresql\" \\{\\} \\; >$ASSIGN-jdbc.tmp");
if (-s "$ASSIGN-jdbc.tmp") {
  $points++;
}
else {
  print "  No postgresql dependency in pom.xml.\n";
}
system ("find $REPO -name \"*.java\"  -exec grep \"java.sql\" \\{\\} \\; | wc -l > $ASSIGN-sql.tmp");
if (assert_at_least("  Usage of java.sql in java code", "$ASSIGN-sql.tmp", "1")) {
  $points += 2;
  print "  Found usage of JDBC in java code.\n";
}
system ("find $REPO -name \"*.java\"  -exec grep \"org.postgresql.Driver\" \\{\\} \\; | wc -l > $ASSIGN-driver.tmp");
if (assert_at_least("  Usage of Postgresql Driver in java code", "$ASSIGN-driver.tmp", "1")) {
  $points += 2;
}

give_feedback($points, $TOTAL);
