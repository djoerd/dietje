#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'ir2016week1';
$REPO = 'ir2016';
$TASK = 'runs';

if ($#ARGV < 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 30;

system ("rm -rf $REPO"); # we're going to do a fresh install
system ("rm -rf *.tmp");
 
#
# Check git
#
print "Checking git repository.\n";
if (git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
  $points += 5; #total 5
  print "  Ok.\n";
} else {
  print "  Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}


#
# Check README.md
#
print "Checking README.md.\n";
if (assert_file_exists ("  Error", "$REPO/README.md", "  Ok.")) {
  system("cat $REPO/README.md | wc -l >$ASSIGN-readme.tmp");
  if (assert_at_least("  Add some lines to README.md", "$ASSIGN-readme.tmp", "2")) {
    $points += 5; # total 10
  }
}

#
# Check NDA and reports
#
print "Checking NDA \n";
if (assert_file_exists("  Error", "$REPO/doc/")) {
  if (assert_file_exists ("  Error", "$REPO/doc/nda-signed.pdf", "  Ok.")) {
    $points += 20; #total 30
  } else {
    print "  Before I continue, please add the non-disclosure agreement.\n";
  }
} else {
  print "  Before I continue, please add the doc/ directory with the NDA.\n";
}

fullyDone:  #  spaghetti ends here

give_feedback($points, $TOTAL);
  
