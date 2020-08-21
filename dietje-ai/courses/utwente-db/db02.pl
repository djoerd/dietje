#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'db02';
$REPO = 'databases';
$TASK = 'session02';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 15;

system ("rm -rf $REPO"); # we're going to do a fresh install
system ("rm -rf *.tmp");
 

#
# Git
#
unless (git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
  print "Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}
assert_file_exists("  Error", "$REPO/$TASK/");


#
# Opgave 2a
#
print "Exercise 2a: (movies with high ratings)\n";
if (test_query("$REPO/$TASK/result2a.sql", "$ASSIGN-1")) { $points++; }



#
# Opgave 2b
#
print "Exercise 2b: (rewriting a query)\n";
if (test_query("$REPO/$TASK/result2b.sql", "$ASSIGN-2")) { 
  $points++; 
  system("cat $REPO/$TASK/result2b.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'exists' >$ASSIGN-2-1.tmp");
  if (-s "$ASSIGN-2-1.tmp") {   
    print "  Error: In your final query, the subquery (using EXISTS)\n";
    print "  can be removed using the Shunting rule.\n";
  }
  else { 
    $points++;
  }
  system("cat $REPO/$TASK/result2b.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'person' >$ASSIGN-2-2.tmp");
  if (-s "$ASSIGN-2-2.tmp") { 
    print "  Error: In your final query, the table Person can be removed,\n";
    print "  using the Foreign key constraint rule.\n";
  }   
  else {
    $points++;
  }
}

#
# Opgave 2c
#
print "Exercise 2c: (persons that wrote a movie without a director)\n";
if (test_query("$REPO/$TASK/result2c.sql", "$ASSIGN-3")) { 
  $points++; 
  system("cat $REPO/$TASK/result2c.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'not exists' >$ASSIGN-3-1.tmp");
  if (-s "$ASSIGN-3-1.tmp") {
    $points++;
  }
  else {
    print "  Use 'NOT EXISTS (SELECT * FROM Directs ...' to get movies without a director.\n";
  }
  system("cat $REPO/$TASK/result2c.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'person' >$ASSIGN-3-2.tmp");
  system("cat $REPO/$TASK/result2c.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'writes' >>$ASSIGN-3-2.tmp");
  system("cat $REPO/$TASK/result2c.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'directs' >>$ASSIGN-3-2.tmp");
  system("cat $ASSIGN-3-2.tmp | wc -l >$ASSIGN-3-3.tmp");
  if (assert_equals("  Error: Use the tables Person, Writes and Directs", "$ASSIGN-3-3.tmp", "3")) { 
    system("cat $REPO/$TASK/result2c.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'movie' >$ASSIGN-3-3.tmp");
    if (-s "$ASSIGN-3-3.tmp") {
      print "  Error: In your final query, the table Movie can be removed.\n";
      print "  Use the Foreign key constraint rule.\n";
    }
    else {
      $points++;
    }
  }
}


#
# Opgave 2d
#
print "Exercise 2d: (writers of which ALL movies are without a director)\n";
if (test_query("$REPO/$TASK/result2d.sql", "$ASSIGN-4")) { 
  $points++; 
  system("cat $REPO/$TASK/result2d.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'not exists' >$ASSIGN-4-1.tmp");
  if (-s "$ASSIGN-4-1.tmp") {
    $points++;
  }
  else {
    print "  Tip: if all movies by the writer do not have a director,\n";
    print "  Then there is not a movie by the writer that does have a director.\n";
  }
  system("cat $REPO/$TASK/result2d.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'person' >$ASSIGN-4-2.tmp");
  system("cat $REPO/$TASK/result2d.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'movie'  >>$ASSIGN-4-2.tmp");
  system("cat $REPO/$TASK/result2d.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'writes' >>$ASSIGN-4-2.tmp");
  system("cat $REPO/$TASK/result2d.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'directs' >>$ASSIGN-4-2.tmp");
  system("cat $ASSIGN-4-2.tmp | wc -l >$ASSIGN-4-3.tmp");
  if (assert_at_least("  Error: Use the tables Person, Movie, Writes and Directs", "$ASSIGN-4-3.tmp", "4")) { 
    $points++; 
  }
}


#
# Opgave 2e
#
print "Exercise 2e: (persons that directed at least 2 action movies)\n";
if (test_query("$REPO/$TASK/result2e.sql", "$ASSIGN-5")) { $points++; }


#
# Opgave 2f
#
print "Exercise 2f: (number of movies)\n";
if (test_query("$REPO/$TASK/result2f.sql", "$ASSIGN-6")) { 
  $points++; 
  system("cat $REPO/$TASK/result2f.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'having' >$ASSIGN-6-1.tmp");
  if (!-s "$ASSIGN-6-1.tmp") {
    print "  Tip: Use a GROUP BY query with HAVING.\n";
  }
}


#
# Opgave 2g
#
print "Exercise 2g: (different runtimes)\n";
if (test_query("$REPO/$TASK/result2g.sql", "$ASSIGN-7")) { 
  $points++;
  system("cat $REPO/$TASK/result2g.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'having' >$ASSIGN-7-1.tmp");
  if (!-s "$ASSIGN-7-1.tmp") { 
    print "  Tip: Use a GROUP BY query with HAVING.\n";
  }
}

#
# Opgave 2h
#
print "Exercise 2h: (acting directors)\n";
if (test_query("$REPO/$TASK/result2h.sql", "$ASSIGN-8")) { 
  $points++; 
  system("cat $REPO/$TASK/result2h.sql | sed -e 's/\\-\\-.*\$//' | grep -i 'order' >$ASSIGN-8-1.tmp");
  if (!-s "$ASSIGN-8-1.tmp") {
    print "  Error: Use ORDER BY.\n";
  }
  else {
    $points++;
  }
}




fullyDone:  #  spaghetti ends here



give_feedback($points, $TOTAL);



sub test_query {
  $query = shift;
  $prefix = shift;
  $ok = 0;

  if (assert_file_exists("  Error", $query)) {
    system ("cat $query | sed -s 's/\xEF\xBB\xBF//' | sqlite3.8 -init  $PATH/$ASSIGN-movies.sql 2> $prefix-err.tmp | sort >$prefix-result.tmp");
    if (-s "$prefix-err.tmp") {
      print "  SQL errors:\n";
      system ("cat $prefix-err.tmp");
    }
    else {
      if (!system("diff $prefix-result.tmp $PATH/$prefix-answer.out >$prefix-diff.tmp")) {
        $ok = 1;
        print "  Ok.\n";
      }
      else {
        print "  Error: your query gives the wrong results.\n";
        print "Got:\n";
        system ("cat $prefix-result.tmp");
        print "Expected:\n";
        system ("cat $PATH/$prefix-answer.out");
      }
    }
  }
  return $ok;
}


