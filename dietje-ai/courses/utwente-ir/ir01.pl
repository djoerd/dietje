#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'ir01';
$REPO = 'ir2015';
$TASK = 'runs';

if ($#ARGV < 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 90;

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
print "Checking NDA and reports. (week 1 and 2)\n";
if (assert_file_exists("  Error", "$REPO/doc/")) {
  if (assert_file_exists ("  Error", "$REPO/doc/nda-signed.pdf", "  Ok.")) {
    $points += 5; #total 15
  } else {
    print "  Before I continue, please add the non-disclosure agreement.\n";
    goto fullyDone;
  }
  if (assert_file_exists ("  Error", "$REPO/doc/report1.pdf", "  Ok.")) {
    $points += 5; #total 20
    assert_file_exists ("  Warning", "$REPO/doc/report2.pdf", "  Ok.");
    assert_file_exists ("  Warning", "$REPO/doc/report3.pdf", "  Ok.");
  }
} else {
  print "  Before I continue, please add the doc/ directory with the NDA.\n";
  goto fullyDone;
}

#
# See if src exists.
#
print "Checking script. (week 4)\n";
if (assert_file_exists("  Error", "$REPO/src/", "  Ok.")) {
  $points += 5; # total 25
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
    $points += 5; # total 30
    $base_score = evaluate_run("$REPO/$TASK/baseline.run");
  } else {
    print "  Before I continue, please add: runs/baseline.run.\n";
    goto fullyDone;
  }
}

#
#  Now the real stuff!
#
print "Checking your test runs. (week 6 and 7)\n";
system ("find $REPO/$TASK/ >find_files.out");
$max_score = 0;
$nr_runs = 0;
open(FI, "find_files.out") or die "Wat nu?";
while (<FI>) {
  chop;
  if (/[0-9A-za-z]/) {
    unless ($_ =~ /\/baseline.run$/ or $_ =~ /\/$/) {
      $nr_runs += 1;
      $score = evaluate_run($_);
      if ($score > $max_score) { 
        $max_score = $score;
      } 
      if ($nr_runs >= 3) {
        last;
      }
    }
  }
}
close FI;
if ($nr_runs > 0) {
  $points += 5; # total 35
}
if ($nr_runs >= 3) {
  system("echo '  Checking at maximum 3 runs.'");
} elsif ($max_score == 0) {
  system("echo '  No more runs found.'");
}
if ($base_score > $max_score) {
  $max_score = $base_score;
}
$points += $max_score; # total 90


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
      if ($mrr > 0.25) {
        if ($mrr > 0.4) {
          print "  Excellent!\n";
          $score += 50; # max 55
        } else {
          $score += ($mrr - 0.25) * 366; # max 55
        }
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
  
