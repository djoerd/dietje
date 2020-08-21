#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level18';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 1;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 
#
print "Task 18: (Login)\n";
system ("find $REPO -exec grep -l -e \"<input [^>]*type=[\\\'\\\"]password\" \\{\\} \\; >$ASSIGN-login.tmp");
if (-s "$ASSIGN-login.tmp") {
    $points += 1;
    print "  Found code for passwords:\n";
    system ("head -5 $ASSIGN-login.tmp");
}
else {
    print "  I did not find any login code ...\n";
    print "  Let me know if I missed anything.\n";
}

give_feedback($points, $TOTAL);
