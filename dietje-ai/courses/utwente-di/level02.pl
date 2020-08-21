#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level02';

if ($#ARGV != 0) { 
  print "Failed grading: Student id not provided.\n";
  die;
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 1;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 2.1
#
print "Task 2: (Trello)\n";
if (assert_file_exists ("  Warning", "$REPO/README.md", "  Ok.")) {
  system("cat $REPO/README.md | grep \"trello.com\" | wc -l >$ASSIGN-readme.tmp");
  if (assert_at_least("  Add your Trello board to README.md", "$ASSIGN-readme.tmp", "1")) {
    $points++;
  }
}


give_feedback($points, $TOTAL);
