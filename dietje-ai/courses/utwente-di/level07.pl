#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level07';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 4;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 7
#
print "Task 7: (SQL database schema)\n";
system("find $REPO -iname \"design*\" -type d > $ASSIGN-design.tmp");
$dir = file_content("$ASSIGN-design.tmp");
$dir =~ s/\s.*$//g;
if ($dir !~ /[a-z]/) {
    print "  Your repository does not have a directory 'design'.\n";
}
else {
  if ($dir !~ /design$/) {
    print "  Warning: found directory '$dir' instead of '$STUDENT/design'.\n";
  }
  if (assert_file_exists ("  Warning", "$dir/schema.sql", "  Ok.")) {
    $points++;
    system ("sqlite3 < $dir/schema.sql 2>$ASSIGN-error.tmp");
    if (-s "$ASSIGN-error.tmp") {
      print "  SQL error (checked with sqlite3 instead of PostgreSQL):\n";
      system("cat $ASSIGN-error.tmp");
    }
    else { 
      $points++;
    }

    # Check for primary key constraints
    system ("cat $dir/schema.sql | grep -i \"primary key\" >$ASSIGN-pk.tmp");
    if (-s "$ASSIGN-pk.tmp") {
      $points++;
      print "  Primary keys found.\n";
    }
    else { 
      print("  Please add primary key constraints to your schema.");
    } 

    system ("cat $dir/schema.sql | grep -i \"foreign key\" >$ASSIGN-fk.tmp");
    if (-s "$ASSIGN-fk.tmp") {
      $points++;
      print "  Foreign keys found.\n";
    }
    else {
      print("Please add foreign key constraints to your schema.");
    } 
  }

}
give_feedback($points, $TOTAL);
