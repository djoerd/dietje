#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level09';

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
# Opgave 9
#
print "Task 9: (Sprint review presentations)\n";
system("find $REPO -iname \"meeting*\" -type d > $ASSIGN-meeting.tmp");
$dir = file_content("$ASSIGN-meeting.tmp");
$dir =~ s/\s.*$//g;
if ($dir !~ /[a-z]/) {
    print "  Your repository does not have a directory 'meeting'.\n";
}
else {
  $points++;
  if ($dir !~ /meeting$/) {
    print "  Warning: found directory '$dir' instead of '$STUDENT/meeting'.\n";
  }
  system("find $dir -iname \"review*\" | wc -l >$ASSIGN-review.tmp");
  if (assert_at_least("  Add review presentations to the meeting directory", "$ASSIGN-review.tmp", "5")) {
    print "  Found sprint review presentations. Well done.\n";
  }
  my $number = file_content("$ASSIGN-review.tmp");
  if ($number > 0) { $points += $number; }
}

give_feedback($points, $TOTAL);
