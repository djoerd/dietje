#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level04';

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
# Opgave 4
#
print "Task 4: (Project description)\n";
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

  if (assert_file_exists ("  Warning", "$dir/project.pdf", "  Ok.")) {
    $points++;
  }
}


give_feedback($points, $TOTAL);
