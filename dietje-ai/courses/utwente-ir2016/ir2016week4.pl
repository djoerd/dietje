#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'ir2016week4';
$REPO = 'ir2016';
$TASK = 'runs';

if ($#ARGV < 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 50;

system ("rm -rf $REPO"); # we're going to do a fresh install
system ("rm -rf *.tmp");
 
#
# Check git
#
#print "Checking git repository.\n";
if (git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
#  print "  Ok.\n";
} else {
  print "  Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}

#
#  Check for dataset, if so abort!
#
system ("find $REPO/ -name 'collection.txt' >find_collection.out");
if (-s "find_collection.out") {
  print "  Error: I found 'collection.txt'.\n";
  print "  Please remove the data from your repository!\n";
  print "  I will grade the assignment when the data is removed.\n"; 
  goto fullyDone;
}


#
# See if src exists.
#
print "Checking script. (week 4)\n";
if (assert_file_exists("  Error", "$REPO/src/", "  Ok.")) {
  $points += 10; # total 10
} else {
  print "  Before I continue, please add the src/ directory with the code for Elastic Search.\n";
  goto fullyDone;
}

#
#  Baseline run
#
print "Checking baseline run. (week 4)\n";
$base_score = 0;
if (assert_file_exists("  Error", "$REPO/$TASK/")) {
  if (assert_file_exists ("  Error", "$REPO/$TASK/baseline.run", "  Ok.")) {
    $points += 10; # total 20
    $base_score = evaluate_run("$REPO/$TASK/baseline.run");
  } else {
    print "  Before I continue, please add: runs/baseline.run.\n";
    goto fullyDone;
  }
}

$points += $base_score;

fullyDone:  #  spaghetti ends here


give_feedback($points, $TOTAL);

sub evaluate_run {
    $score = 0;
    $_ = shift;
    ($result_dir, $result_file) = m/^(.*)\/([^\/]+)$/;
    

    system("/home/hiemstra/Tools/ir2015/evaluate.sh $result_dir/$result_file >$result_file.out 2>$result_file.err");
    if (-s "$result_file.err") {
      system("echo '  Error for $result_file'");
      system("cat $result_file.err | sed -e 's/trec\_/  /'");
    } else {
      system("echo '  Results for $result_file'");
      system("cat $result_file.out");
    }
    open(I, "$result_file.out") or die "Something is really wrong!";
    $mrr = 0;
    while (<I>) {
      chop;
      if (/recip.*? ([\.0-9]+)$/) {
        $mrr = $1;
      }
    }
    close I;
    if ($mrr > 0) {
      $score += 5;
      if ($mrr > 0.4) {
        print "  Excellent!\n";
        $score += 40; # max 45
      } else {
        $score += $mrr * 100; # baseline gives 30 
      }
      if ($mrr > 0.3 and $mrr <= 0.35) {
        print "  Well done.\n";
      }
      if ($mrr > 0.35 and $mrr <= 0.4) {
        print "  Great work!\n";
      }
    }
    return $score;
}
  
