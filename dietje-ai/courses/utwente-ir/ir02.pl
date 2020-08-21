#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'ir02';
$REPO = 'ir2015';
$TASK = 'final';

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
#print "Checking git repository.\n";
if (git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
  $points = 4;
  #print "  Ok.\n";
} else {
  print "  Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}


#
#  Now the real stuff!
#
print "Checking final runs. (week 8)\n";
system ("find $REPO/$TASK/ >find_files2.out");
$max_score = 0;
$nr_runs = 0;
open(FI, "find_files2.out") or die "Wat nu?";
while (<FI>) {
  chop;
  if (/[0-9A-za-z]/) {
    unless ($_ =~ /\/$/) {
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
  $points += 100; # total 50
}
if ($nr_runs >= 3) {
  system("echo '  Checking at maximum 3 runs.'");
} elsif ($max_score == 0) {
  system("echo '  No runs found.'");
}


fullyDone:  #  spaghetti ends here


give_feedback($points, $TOTAL);

sub evaluate_run {
    $score = 0;
    $_ = shift;
    ($result_dir, $result_file) = m/^(.*)\/([^\/]+)$/;
    

    system("/home/hiemstra/Tools/ir2015/final.sh $result_dir/$result_file >$result_file.out 2>$result_file.err");
    if (-s "$result_file.err") {
      system("echo '  Error for $result_file'");
      system("cat $result_file.err | sed -e 's/trec\_/  /'");
    } else {
      system("echo '  Received: $result_file'");
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
    return 5;
}

sub unused {
    if ($mrr > 0) {
      $score += 5;
      if ($mrr > 0.23) {
        if ($mrr > 0.35) {
          print "  Excellent!\n";
          $score += 40; # max 90
        } else {
          $score += ($mrr - 0.23) * 333; 
        }
      }
      if ($mrr > 0.25 and $mrr <= 0.30) {
        print "  Well done.\n";
      }
      if ($mrr > 0.30 and $mrr <= 0.35) {
        print "  Great work!\n";
      }
    }
    return $score;
}
 
