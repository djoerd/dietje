#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level14';

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
print "Task 14: (JSP and servlets)\n";
system ("find $REPO -name \"pom.xml\" -exec grep -i \"javax.servlet\" \\{\\} \\; >$ASSIGN-servlet.tmp");
if (-s "$ASSIGN-servlet.tmp") {
  $points++;
}
else {
  print "  No javax.servlet dependency in pom.xml.\n";
}
system ("find $REPO -name \"*.jsp\" | wc -l > $ASSIGN-jsp.tmp");
if (assert_at_least("  JSP pages", "$ASSIGN-jsp.tmp", "1")) {
  $points++;
}

give_feedback($points, $TOTAL);
