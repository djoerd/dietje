#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level19';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 5;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 
#
print "Task 19: (Team work)\n";
system("cd $REPO; git log | grep -e \"^Author:\" >../$ASSIGN-team.tmp; cd ..");
open(I, "$ASSIGN-team.tmp") or die "Woops!";
while (<I>) {
  if (/<([^>]+)>/) {
    $email = $1;
    $contributor{$email}++;
  }
  if (/: ([^<]+) </) {
    if (!defined($name{$email})) { $name{$email} = $1; }
  }
}
close I;

$best = 0; $total = 0;
foreach $key (keys %contributor) {
  printf "  %s: %d commits\n", $name{$key}, $contributor{$key};
  $points++;
  $total += $contributor{$key};
  if ($best < $contributor{$key}) {
    $best = $contributor{$key};
  }
}
print "\n";
print "  $points team members contributed.\n";
if ($points > 5) { 
  $TOTAL = $points; 
  print "  ... that's more than I expected!\n";
}

if ($total < 30) { 
  print "  Less than 30 commits in total. That is really disappointing...\n";
  $TOTAL *= 2;
}
elsif ($total < 50) {
  print "  Less than 50 commits in total. That is disappointing...\n";
  $TOTAL *= 1.5;
}
elsif ($total < 100) {
  $TOTAL *= 1.1;
}


print "\n";
foreach $key (keys %contributor) {
  if ($contributor{$key} < $total / 100) {
    printf "  %s contributed less than 1%% of all commits\n", $name{$key};
    $points--;
  }
  elsif ($contributor{$key} < $total / 20) {
    printf "  %s contributed less than 5%% of all commits\n", $name{$key};
    $points -= 0.5;
  }
  elsif ($contributor{$key} < $total / 10) {
    printf "  %s contributed less than 10%% of all commits\n", $name{$key};
    $points -= 0.25;
  }
}

print "\n";
foreach $key (keys %contributor) {
  if ($total > 100 && $contributor{$key} > $total / 4) {
    printf "  Well done, %s!\n", $name{$key};
  }
}



give_feedback($points, $TOTAL);
