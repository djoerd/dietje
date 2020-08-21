#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'db01';
$REPO = 'databases';
$TASK = 'session01';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 14;

system ("rm -rf $REPO"); # we're going to do a fresh install
system ("rm -rf *.tmp");
 
#
# Opgave 1a
#
print "Exercise 1a: (git)\n";
if (git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
  $points += 1;
  print "  Ok.\n";
} else {
  print "  Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}


#
# Opgave 1b
#
print "Exercise 1b: (README.md)\n";
if (assert_file_exists ("  Warning", "$REPO/README.md", "  Ok.")) {
  system("cat $REPO/README.md | wc -l >$ASSIGN-readme.tmp");
  if (assert_at_least("  Add some lines to README.md", "$ASSIGN-readme.tmp", "2")) {
    $points++;
  }
}


#
# Opgave 1c (we only check the existence of the file)
#
print "Exercise 1c (tom.sql)\n";
print "  I only check if the file exists:\n";
assert_file_exists("  Error", "$REPO/$TASK/");
if (assert_file_exists("  Error", "$REPO/$TASK/tom.sql", "  Ok.")) { 
  $points++;
}
else {
  print "Please add tom.sql before I check the remaining exercises.\n";
  goto fullyDone;  # spaghetti code!
}

#
# Opgave 1d 
#
print "Exercise 1d: (insert statements)\n";
if (system("cat $REPO/$TASK/tom.sql | sed -s 's/\xEF\xBB\xBF//' | sqlite3.8 2>$ASSIGN-1-4-err.tmp") == 0) {
  $points++;
}
if (-s "$ASSIGN-1-4-err.tmp") {
  print "  SQL errors in $TASK/tom.sql:\n";
  system ("cat $ASSIGN-1-4-err.tmp | sed -e 's/[^a-z0-9\\sA-Z:\\.,]/ /g'");
  print "\nPlease fix the SQL errors before I check the remaining exercises.\n";
  print "Please note: Your tom.sql file has to be a plain text file with SQL statements.\n";
  goto fullyDone;
}
# Check number of rows and number of distinct ids:
$points_before = $points;
system ("cat $PATH/$ASSIGN-4-1.sql | sqlite3.8 -init $REPO/$TASK/tom.sql >$ASSIGN-4-1.tmp");
if (assert_equals("  Error: Number of rows in table docent", "$ASSIGN-4-1.tmp", "4")) { $points++; }
system ("cat $PATH/$ASSIGN-4-2.sql | sqlite3.8 -init $REPO/$TASK/tom.sql >$ASSIGN-4-2.tmp");
if (assert_equals("  Error: Distinct values of docent_id in docent", "$ASSIGN-4-2.tmp", "4")) { $points++; }
system ("cat $PATH/$ASSIGN-4-3.sql | sqlite3.8 -init $REPO/$TASK/tom.sql >$ASSIGN-4-3.tmp");
if (assert_equals("  Error: Number of rows in table thema", "$ASSIGN-4-3.tmp", "6")) { $points++; }
system ("cat $PATH/$ASSIGN-4-4.sql | sqlite3.8 -init $REPO/$TASK/tom.sql >$ASSIGN-4-4.tmp");
if (assert_equals("  Error: Distinct values of thema_id in thema", "$ASSIGN-4-4.tmp", "6")) { $points++; }
$query = file_content("$REPO/$TASK/tom.sql");
if ($query =~ /insert[^\(]+\([^\(;]+;/i) {
  print "  Tip: Always include the columns names in the insert statement.\n";
  print "  This way, your queries will still work if the schema is\n";
  print "  altered, for instance if later a column is added.\n";
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
#  Opgave 1e (and prepare for 1f)
#
print "Exercise 1e: (di.sql)\n";
if (!assert_file_exists("  Error", "$REPO/$TASK/di.sql")) {
  goto fullyDone;
}
# find the commits in which di.sql whas changed:
system("cd $REPO; git log $TASK/di.sql | grep '^commit' >../$ASSIGN-hashes.tmp");
system("cd $REPO; git checkout -b dietje-new");

if (open(I, "$ASSIGN-hashes.tmp") ) {
  @lines = <I>;
  close I;
  $nr = 0; 
  foreach (reverse @lines) {
    $nr++;
    chop;
    ($comm, $hash) = split;
    system("cd $REPO; git checkout $hash");
    # Assignment 1.5: to check if '24' appears in any comment
    system("grep '\\-\\-' $REPO/$TASK/di.sql >>$ASSIGN-5-1.tmp"); # BEWARE: double excaping!
    # Assignment 1.6: to check if 'join' was not used any where:
    system("cat $REPO/$TASK/di.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'join' >>$ASSIGN-6-1.tmp");
    # Overall: to check if any query produces an error.
    system("cat $REPO/$TASK/di.sql | sqlite3.8 -init $PATH/$ASSIGN-7-1.sql 1>>/dev/null 2>>$ASSIGN-err-all.tmp");
    # Check if WHERE was used
    system("cat $REPO/$TASK/di.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'where' >>$ASSIGN-6-2.tmp");
  }
  if (-s "$ASSIGN-err-all.tmp") {
     print "  SQL errors:\n";
     system("cat $ASSIGN-err-all.tmp");
  }
  else {
    $points++;
    if (assert_equals("  Warning: A comment should contain the number of rows", "$ASSIGN-5-1.tmp", "24")) {
        $points++;
        print "  Ok.\n";
    }
  }
}
else {
  die "Prof. Dietje says: 'Woops, my AI program crashed.";
}
system("cd $REPO; git checkout dietje-new");


#
#  Opgave 1f
#
print "Exercise 1f: (WHERE-clause)\n";
if (-s "$ASSIGN-6-1.tmp") {
  print "  Warning: Use the WHERE-clause instead of explicit JOIN.\n";
}
if (-s "$ASSIGN-6-2.tmp") {
  print "  Ok.\n";
  $points++;
}
else {
  print "  No WHERE-clause found in di.sql\n";
}


# 
# Opgave 1g
#
print "Exercise 1g (Dr. Luis):\n";
system("cat $REPO/$TASK/di.sql | sqlite3.8 -init $PATH/$ASSIGN-7-1.sql 1>>$ASSIGN-7-1.tmp 2>>$ASSIGN-err7-1.tmp");
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


fullyDone:  #  spaghetti ends here

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


give_feedback($points, $TOTAL);
