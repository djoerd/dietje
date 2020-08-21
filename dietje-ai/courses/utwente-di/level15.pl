#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level15';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 6;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 
#
print "Task 15: (Restful web services)\n";
system ("find $REPO -name \"pom.xml\" -exec grep -i \"jersey\" \\{\\} \\; >$ASSIGN-jersey.tmp");
if (-s "$ASSIGN-jersey.tmp") {
  $points++;
}
else {
  print "  No jersey-container-servlet dependency in pom.xml.\n";
}
system ("find $REPO -name \"*.java\" -exec grep \"javax.ws\" \\{\\} \\; | wc -l > $ASSIGN-ws.tmp");
if (assert_at_least("  Usage of web services in java code", "$ASSIGN-ws.tmp", "1")) {
  $points += 3;
  print "  I found usage of jersey in java code.\n";
}
system("find $REPO -name \"*.java\" -exec grep 'setContentType(' \\{\\} \\; | grep 'xml' >$ASSIGN-xml.tmp");
system("find $REPO -name \"*.java\" -exec grep -e 'Produces.*MediaType.TEXT_XML' \\{\\} \\; >>$ASSIGN-xml.tmp");
system("find $REPO -name \"*.java\" -exec grep 'setContentType(' \\{\\} \\; | grep 'json' >$ASSIGN-json.tmp");
system("find $REPO -name \"*.java\" -exec grep 'Produces.*MediaType.APPLICATION_JSON' \\{\\} \\; >>$ASSIGN-json.tmp");

if (-s "$ASSIGN-xml.tmp") {
  $points++;
  print "  I found usage of XML in java code.\n";
}
if (-s "$ASSIGN-json.tmp") {
  $points++;
  print "  I found usage of JSON in java code.\n";
}

give_feedback($points, $TOTAL);
