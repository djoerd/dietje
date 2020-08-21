#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'ir2016week2';
$REPO = 'ir2016';
$TASK = 'runs';

if ($#ARGV < 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 10;

#system ("rm -rf $REPO"); # we're going to do a fresh install
#system ("rm -rf *.tmp");
 
#
# Check git
#
if (git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
  # print "  Ok.\n";  
} else {
  print "  Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}


#
# Check reports 1
#
print "Checking report 1. (week 2)\n";
if (assert_file_exists("  Error", "$REPO/doc/")) {
  if (assert_file_exists ("  Error", "$REPO/doc/report1.pdf", "  Ok.")) {
    $points += 10; #total 10
  } else {
    print "  Before I continue, please add doc/report1.pdf.\n";
    goto fullyDone;
  }
} else {
  print "  Before I continue, please add the doc/ directory with the NDA.\n";
  goto fullyDone;
}


fullyDone:  #  spaghetti ends here


give_feedback($points, $TOTAL);

  
