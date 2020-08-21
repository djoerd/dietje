#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level05';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 3;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 4
#
print "Task 5: (Use case diagram)\n";
system("find $REPO -iname \"design*\" -type d > $ASSIGN-design.tmp");
$dir = file_content("$ASSIGN-design.tmp");
$dir =~ s/\s.*$//g;
if ($dir !~ /[a-z]/) {
    print "  Your repository does not have a directory 'design'.\n";
}
else {
  if ($dir !~ /design$/) {
    print "  Warning: found directory '$dir' instead of '$STUDENT/design'.\n";
  }

  system("find $dir -name \"*.vpp\" | wc -l >$ASSIGN-usecase1.tmp");
  if (assert_at_least("  Add use case diagram as vpp file to the design directory", "$ASSIGN-usecase1.tmp", "1")) {
    if ($points == 0) { $points++; }
    $points++;
  }
  system("find $dir -name \"*.xmi\" | wc -l >$ASSIGN-usecase2.tmp");
  if (assert_at_least("  Add use case diagram as xmi file to the design directory", "$ASSIGN-usecase2.tmp", "1")) {
    if ($points == 0) { $points++; }
    $points++;
  }
}

give_feedback($points, $TOTAL);
