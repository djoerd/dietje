#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'db03';
$REPO = 'databases';
$TASK = 'session03';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 17;

system ("rm -rf $REPO"); # we're going to do a fresh install
system ("rm -rf *.tmp");

#
# Git
#
unless (git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
  print "Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}
if (!assert_file_exists("  Error", "$REPO/$TASK/")) {
  goto fullyDone;
}


#
# Opgave 3a
#
print "Exercise 3 a-j\n";
if (assert_file_exists("  Error", "$REPO/$TASK/result3a-j.sql")) {
  system("cat $PATH/$ASSIGN-a-j.sql $REPO/$TASK/result3a-j.sql | sed -e \"s/'*TRUE'*/1/i\" | sed -e \"s/'*FALSE'*/0/i\" >$ASSIGN-a-j.tmp");
  if (check_fd('a', 0, $ASSIGN, "multiple vehicles can have the same capacity")) { $points++; }
  if (check_fd('b', 1, $ASSIGN, 'the capacity of a vehicle is unique (see "de" in line 3)')) { $points++; }
  if (check_fd('c', 0, $ASSIGN, 'for a combination of delivery address and invoice (factuur) multiple parcels can be delivered/indicated')) { $points++; }
  if (check_fd('d', 1, $ASSIGN, 'a parcel belongs to exactly (maximum) 1 delivery address (line 7) and at maximum 1 invoice (line c)')) { $points++; }
  if (check_fd('e', 1, $ASSIGN, 'a parcel belongs to exactly one amount of money (line 5) en exactly receiver (line 4, also line 6)')) { $points++; }
  if (check_fd('f', 0, $ASSIGN, 'a delivery person can be entitled to drive multiple vehicles; the case does not exclude this anywhere')) { $points++; }
  if (check_fd('g', 0, $ASSIGN, 'multiple delivery persons can be entitled to drive a vehicle (with a certain capacity); the case does not exclude this')) { $points++; }
  if (check_fd('h', 1, $ASSIGN, 'multiple delivery persons can belong to a vehicle, so this is not a *functional* dependency. We therefore need to decide if the following is true: BVCPGOAF = VB join VCPGOAF? If we know the vehicle, then there is no dependency between delivery persons B and capacity C of the vehicle. There is also no dependency between delivery persons and parcels, delivery persons and amount of money, etc. The Multi-Valued Dependency is therefore true')) { $points++; }
  if (check_fd('i', 1, $ASSIGN, 'each functional dependency is also a multi-valued dependency (see also Task b above)')) { $points++; }
  if (check_fd('j', 1, $ASSIGN, 'multiple delivery persons can belong to a vehicle, so this is not a *functional* dependency. However, BVCPGOAF = VBC join VPGOAF is true following a similar line of reasoning as for Task h'))  { $points++; }
}


#
# Opgave 3k
#
print "\n";
print "Exercise 3k\n";
if (assert_file_exists("  Error", "$REPO/$TASK/result3k-m.sql")) {
  system("cat $PATH/$ASSIGN-k-m.sql $REPO/$TASK/result3k-m.sql >$ASSIGN-k-m.tmp");
  if (check_violation('ABC', 'EF', 'F', $ASSIGN, 0, 'the left hand side contains a key, because ABC+ = ABCDEF')) { $points++; }
  if (check_violation('E',   'D',  'F', $ASSIGN, 1, 'the left hand side contains no key, E+ = EDA (and the right hand side is not contained in the left hand side)')) { $points++; }
  if (check_violation('D',   'A',  'F', $ASSIGN, 1, 'D+ = DA')) { $points++; }
}
else {
  goto fullyDone;
}


#
# Opgave 3l and 3k
#
print "\n";
print "Exercise 3l\n";
system("echo \"INSERT INTO R1(D, E) values (0, 0);\" | sqlite3.8 -init $REPO/$TASK/exercise3k-m.sql 2>$ASSIGN-k-err.tmp | wc -l > $ASSIGN-k-all.tmp");
if (!-s "$ASSIGN-k-err.tmp") {
  print "  You chose to eliminate the functional dependency E->D.\n";
  $points++;
  if (check_violation('E', 'D', 'F1', $ASSIGN, 0, 'because the left hand side is the key')) { $points++; }
  if (check_violation('ABC', 'EF', 'F2', $ASSIGN, 0, 'the left hand side contains a key, because ABC+ = ABCEF')) { $points++; }
  if (check_violation('E', 'A', 'F2',  $ASSIGN, 1, 'E->A is not in F, but it is in F+ because E->D and D->A. E is not a key of ABCEF'))  { $points++; }
}
else {
  system("echo \"INSERT INTO R1(A, D) values (0, 0);\" | sqlite3.8 -init $REPO/$TASK/exercise3k-m.sql 2>$ASSIGN-k-err2.tmp | wc -l > $ASSIGN-k-all2.tmp");
  if (!-s "$ASSIGN-k-err.tmp") {
    print "  You chose to eliminate D->A.\n";
    print "  Therefore ABC -> EF is no longer valid.\n";
    $points++;
    if (check_violation('D', 'A', 'F1', $ASSIGN, 0, 'because the left hand side is the key')) { $points++; }
    if (check_violation('BCD', 'EF', 'F2', $ASSIGN, 0, 'the left hand side contains a key, because BCD+ = BCDEF')) { $points++; }
    if (check_violation('E', 'D', 'F2',  $ASSIGN, 1, 'E is not a key of BCDEF'))  { $points++; }
  }
  else  {
    print "  You did not split the table R correctly.\n";
  }
}

print "\n";
print "Exercise 3m\n";
print "  See the old exams on Blackboard for similar questions.\n";

fullyDone:  #  spaghetti ends here

give_feedback($points, $TOTAL);


sub check_fd {
  my $subtask   = shift;
  my $answer = shift;
  my $prefix = shift;
  my $motivation = shift;
  my $ok = 0;
  my $query = "SELECT * FROM Problem1 WHERE task = '$subtask'";
  print "  Task $subtask:";
  system("echo \"$query;\" | sqlite3.8 -init $prefix-a-j.tmp 2>$prefix-$subtask-err.tmp | wc -l > $prefix-$subtask-all.tmp");
  if (assert_equals(" Number of answers for task '$subtask'", "$prefix-$subtask-all.tmp", "1")) {
    $query .= " AND result = $answer";
    system("echo \"$query;\" | sqlite3.8 -init $prefix-a-j.tmp > $prefix-$subtask-this.tmp");
    if (-s "$prefix-$subtask-this.tmp") {
       print " correct";
       $ok = 1;
    }
    else {
       print " incorrect"; 
    }
    print ", this dependency is ";
    if ($answer) { print "true"; } else { print "false"; } 
    print ", because $motivation\n";
  }
  elsif (-s "$prefix-$subtask-err.tmp") {
    print "  Found SQL errors:\n";
    system("cat $prefix-$subtask-err.tmp");
  }
  return $ok;
}


sub check_violation {
  my $left   = shift;
  my $right = shift;
  my $table = shift;
  my $prefix = shift;
  my $answer = shift;
  my $motivation = shift;
  my $ok = 0;
  my $query = "SELECT * FROM $table WHERE x = '$left' AND y = '$right'";
  print "  Functional dependency $left -> $right:";
  system("echo \"$query;\" | sed -s 's/\xEF\xBB\xBF//' | sqlite3.8 -init $prefix-k-m.tmp 2>$prefix-$left$right-err.tmp | wc -l > $prefix-$left$right-all.tmp");
  if (assert_equals(" Number of answers for FD $left -> $right", "$prefix-$left$right-all.tmp", "1")) {
    $query .= " AND violation = $answer";
    system("echo \"$query;\" | sqlite3.8 -init $prefix-k-m.tmp > $prefix-$left$right-this.tmp");
    if (-s "$prefix-$left$right-this.tmp") {
       print " correct";
       $ok = 1;
    }
    else {
       print " incorrect";
    }
    print ", this dependency ";
    if (!$answer) { print "does NOT violate"; } else { print "violates"; }
    print " the BCNF condition, because $motivation\n";
  }
  elsif (-s "$prefix-$left$right-err.tmp") {
    print "  Found SQL errors:\n";
    system("cat $prefix-$left$right-err.tmp");
  }
  else {
    print "  Tip: $motivation\n";
  }
  return $ok;
}



sub system_me {
  my $comm = shift;
  print STDERR "$comm\n";
  system ($comm);
}
  


