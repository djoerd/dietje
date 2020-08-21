#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level11';

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
# Opgave 
#
print "Task 11: (The code compiles with maven)\n";

system("find $REPO -name \"pom.xml\" -exec dirname \\{\\} \\; | grep -v 'target/' >$ASSIGN-pom.tmp");
if (-s "$ASSIGN-pom.tmp") {
  $dir = file_content("$ASSIGN-pom.tmp");
  $dir =~ s/\s.*$//g;
  $back = $dir;
  $back =~ s/[^\/]+/../g;
  print STDERR "Dir: $dir, $back\n";
}
else {
  $dir = $REPO; $back = "..";
}
if (assert_file_exists ("  Warning", "$dir/pom.xml", "  Ok.")) {
  $points++;
  if (-d "$dir/target") {
    print "  Warning: do not put the 'target' in your repository.\n";
    print "  These files will be generated at compile time.\n";
    $points -= 0.5;
  }
  system ("cd $dir; mvn compile >$back/$ASSIGN-mvn.tmp; cd - >/dev/null");
  system ("cat $ASSIGN-mvn.tmp | grep \"\\[ERROR\\]\"> $ASSIGN-error.tmp");
  if (-s "$ASSIGN-error.tmp") {
    print "  Compile error:\n";
    system("cat $ASSIGN-error.tmp");
  }
  else { 
    $points++;
  }
}

give_feedback($points, $TOTAL);
