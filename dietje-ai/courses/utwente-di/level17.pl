#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level17';

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
print "Task 17: (CSS framework)\n";
system ("find $REPO -name \"*.css\" | wc -l > $ASSIGN-css.tmp");
if (-s "$ASSIGN-css.tmp") {
    $points += 1;
    print "  Found some CSS files.\n";
}
else {
    print "  I did not find any CSS...\n";
}
system ("find $REPO -name \"bootstrap*.css\"  > $ASSIGN-bootstrap.tmp");
system ("find $REPO -name \"foundation*.css\" > $ASSIGN-foundation.tmp");
system ("find $REPO -name \"frameless.less\" > $ASSIGN-frameless.tmp");

if (-s "$ASSIGN-bootstrap.tmp") {
    $points += 4;
    print "  Found: Twitter bootstrap. Great CSS framework!\n";
}
elsif (-s "$ASSIGN-foundation.tmp") {
    $points += 4;
    print "  Found: Foundation. Interesting choice!\n";
}
elsif (-s "$ASSIGN-frameless.tmp") {
    $points += 4;
    print "  Found: Frameless. Why not?\n";
}
else {
    print "  I did not find a CSS framework.\n";
    print "  Maybe you used one that I do not know. Let me know.\n";
}

give_feedback($points, $TOTAL);
