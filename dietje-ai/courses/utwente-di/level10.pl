#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level10';

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
print "Task 10: (Sprint retrospective)\n";
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
  system("find $dir -iname \"*retro*\" | wc -l >$ASSIGN-retro.tmp");
  if (assert_at_least("  Add sprint retrospective report to the meeting directory", "$ASSIGN-retro.tmp", "4")) {
    print "  Found sprint retrospective reports. Well done!\n";
    $points++;
  }
  else {
    print "  I looked for 'retro' in your file names.\n";
  }
  my $number = file_content("$ASSIGN-retro.tmp");
  if ($number > 0) { $points += $number; }
}

give_feedback($points, $TOTAL);
