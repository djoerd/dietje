#!/usr/bin/perl -w

use DBI;
use Cwd 'abs_path';
use File::Basename;

$PATH = dirname(abs_path($0)); 
$USER = 'djoerd';
$PASS = 'password';
$ASSIGN = 'assign01';

if ($#ARGV != 0) { 
  print "Failed grading: Student id not provided.\n";
  die;
}
else {
  $STUDENT = $ARGV[0];
}
$REPO = 'datainfo';
$TASK = 'practicum01';

$points = 0;
$TOTAL = 17;

system ("rm -rf $REPO");
system ("rm -rf *.tmp");

#
# Opgave 1.1
#
print "Assignment 1.1:\n";
if (system("git clone https://$USER:$PASS\@github.com/$STUDENT/$REPO >/dev/null") == 0) {
  $points++;
  print "  Ok.\n";
} else {
  print "  Error: Cannot access https://github.com/$STUDENT/$REPO\n"; 
  #exit 0;
}


#
# Get commit email
#
my $real_email = 'unknown@unknown.utwente.nl';
my $dbh = DBI->connect(
  "DBI:mysql:dietje:localhost", "dietje", "", {'RaiseError' => 1});
my $sth = $dbh->prepare("SELECT s.email FROM student s WHERE s.sid = ?");
$sth->execute($STUDENT);
my @row;
if (@row = $sth->fetchrow_array()) {
    $real_email = $row[0];
}


#
# Opgave 1.2
#
print "Assignment 1.2:\n";
if (assert_file_exists ("  Error", "$REPO/$TASK")) { exit 0; }
system("cd $REPO; git log >../$ASSIGN-1-2.tmp");
if (open(I, "$ASSIGN-1-2.tmp")) {
  while (<I>) {
    chop;
    if (/^Author: (.+)$/i) {
      $identities{$1}++; 
    }
  }
  close I;
}
foreach $id (keys %identities) {
  if ($id !~ /$real_email/i) {
    print "Error: Identity in commit ($id)\n";
    print "does not use your registered email address ($real_email)\n";
    print "See the git documentation (use: git congig)\n";
    $points -= 1; # $identities{$id};  # Only place where we remove points, because this can be used to cheat!
  }
}

if (assert_file_exists ("  Warning", "$REPO/README.md", "  Ok.") == 0) {
  system("cat $REPO/README.md | wc -l >$ASSIGN-readme.tmp");
  if (assert_at_least("  Tip: add some lines to README.md", "$ASSIGN-readme.tmp", "1") == 0) {
    $points++;
  }
}


#
# Opgave 1.3 (we only check the existence of the file)
#
print "Assignment 1.3:\n";
if (assert_file_exists("Error", "$REPO/$TASK/tom.sql", "  Ok.")) { exit 0; }


#
# Opgave 1.4 
#
print "Assignment 1.4:\n";
if (system("cat $REPO/$TASK/tom.sql | sqlite3 2>$ASSIGN-1-4-err.tmp") == 0) {
  $points++;
} else {
  print "  SQL errors in $TASK/tom.sql:\n";
  system ("cat $ASSIGN-1-4-err.tmp");
  exit 0;
}
# Check number of rows and number of distinct ids:
$points_before = $points;
system ("cat $PATH/$ASSIGN-4-1.sql | sqlite3 -init $REPO/$TASK/tom.sql >$ASSIGN-4-1.tmp");
assert_equals("  Error: Number of rows in table docent", "$ASSIGN-4-1.tmp", "4");
system ("cat $PATH/$ASSIGN-4-2.sql | sqlite3 -init $REPO/$TASK/tom.sql >$ASSIGN-4-2.tmp");
assert_equals("  Error: Distinct values of docent_id in docent", "$ASSIGN-4-2.tmp", "4");
system ("cat $PATH/$ASSIGN-4-3.sql | sqlite3 -init $REPO/$TASK/tom.sql >$ASSIGN-4-3.tmp");
assert_equals("  Error: Number of rows in table thema", "$ASSIGN-4-3.tmp", "6");
system ("cat $PATH/$ASSIGN-4-4.sql | sqlite3 -init $REPO/$TASK/tom.sql >$ASSIGN-4-4.tmp");
assert_equals("  Error: Distinct values of thema_id in thema", "$ASSIGN-4-4.tmp", "6");
$query = file_content("$REPO/$TASK/tom.sql");
if ($query =~ /insert[^\(]+\([^\(;]+;/i) {
  print "Tip: Always include the columns names in the insert statement.\n";
  print "This way, your queries will still work if the schema is\n";
  print "altered, for instance if later a column is added.\n";
}
else {
  $points++;
}
if ($points == $points_before + 4) {
  print "  Ok.\n";
}
elsif ($points >= $points_before + 4) {
  print "  Well done.\n";
}


#
# Opgave 1.5 and 1.6
#
print "Assignment 1.5:\n";
if (assert_file_exists("Error", "$REPO/$TASK/di.sql")) { exit 0; };
print "  Ok.\n";
# find the commits in which di.sql whas changed:
system("cd $REPO; git log $TASK/di.sql | grep '^commit' >../$ASSIGN-hashes.tmp");
if (open(I, "$ASSIGN-hashes.tmp") ) {
  @lines = <I>;
  close I;
  $nr = 0; 
  foreach (reverse @lines) {
    $nr++;
    chop;
    ($comm, $hash) = split;
    system("cd $REPO; git checkout -b branch$nr $hash");
    # Assignment 1.5: to check if '24' appears in any comment
    system("grep '\\-\\-' $REPO/$TASK/di.sql >>$ASSIGN-5-1.tmp"); # BEWARE: double excaping!
    # Assignment 1.6: to check if 'join' was not used any where:
    system("cat $REPO/$TASK/di.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'join' >>$ASSIGN-6-1.tmp");
    # Overall: to check if any query produces an error.
    system("cat $REPO/$TASK/di.sql | sqlite3 -init $PATH/$ASSIGN-7-1.sql 1>>/dev/null 2>>$ASSIGN-err-all.tmp");
  }
  assert_equals("  Warning: A comment should contain the number of rows", "$ASSIGN-5-1.tmp", "24");
}
else {
  print "Prof. Dietje says: 'Woops, my AI program crashed.";
  die;
}


#
# Opgave 1.6
#
print "Assignment 1.6:\n";
print "  Ok.\n";
if (-s "$ASSIGN-6-1.tmp") {
  print "  Warning: Use the WHERE-clause instead of explicit JOIN.\n";
}
else {
  $points++;
}


#
# Opgave 1.7
#
print "Assignment 1.7:\n";
system ("cd datainfo; git checkout HEAD");
system("cat $REPO/$TASK/di.sql | sqlite3 -init $PATH/$ASSIGN-7-1.sql 1>>$ASSIGN-7-1.tmp 2>>$ASSIGN-err7-1.tmp");
if (-s "$ASSIGN-err7-1.tmp") {
  print "  Error: SQL errors:\n";
  system ("cat $ASSIGN-err7-1.tmp");
}
elsif (-s "$ASSIGN-7-1.tmp") {
  print "  Not ok. Your query selects too many rows.\n";
}
else {
  $points++;
  print "  Ok.\n";
}


#
# Overall
#
system("cd $REPO; git log | grep '^commit' | wc -l >../$ASSIGN-commits.tmp");
assert_at_least("Warning: Number of commits in repository", "$ASSIGN-commits.tmp", "6");
if (-s "$ASSIGN-err-all.tmp") {
  print "Warning: Some of your commits for di.sql give SQL errors.\n";
  system("cat $ASSIGN-err-all.tmp");
}
else {
  $points++;
}

print "\n";
if ($points < 0) { $points = 0; }
print "Points: $points\n";
if ($points > $TOTAL) { $points = $TOTAL; }
printf "Grade: %1.1f\n", 10 * $points / $TOTAL;



sub assert_equals {
  $assertion = shift @_;
  $file      = shift @_;
  $expected  = shift @_;
  $result = file_content($file);
  if ($result =~ $expected ) {
    $points++;
  } else {
    print "$assertion. Got $result; expected $expected.\n";
  }
}

sub assert_at_least {
  $assertion = shift @_;
  $file      = shift @_;
  $expected  = shift @_;
  $result = file_content($file);
  if ($result >= $expected ) {
    $points++;
  } else {
    print "$assertion. Got $result; expected at least $expected.\n";
  }
}

sub file_content {
  $file_name = shift @_;
  open (I, $file_name) or die "Wooops: $file_name!";
  my @result = <I>;
  my $result = join " ", @result;
  $result =~ s/\n//;
  return $result;
}


sub assert_file_exists {
  $message = shift @_;
  $file_name = shift @_;
  $response = shift @_;
  if (-e $file_name) {
    if ($response) { print "  Ok.\n"; }
    $points++;
    return 0;
  } else {
    print "$message: $file_name does not exist.\n";
    return 1; 
  }
}

