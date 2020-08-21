#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'db05';
$REPO = 'databases';
$TASK = 'session05';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 10;

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
# Opgave 5a
#
print "Exercise 5a\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise5a.sql")) {
  system("cat $REPO/$TASK/exercise5a.sql | sqlite3.8 >/dev/null 2>$ASSIGN-a.tmp");
  if (-s "$ASSIGN-a.tmp") {
    print "  SQL Errors:\n";
    system ("cat $ASSIGN-a.tmp");
  }
  else {
    my $result = read_file_no_comments("$REPO/$TASK/exercise5a.sql");
    if (($result =~ /primary key *\( *isbn *\)/i) or ($result =~ /isbn[^,]*primary key/i)) {
       print "  Ok, Table Boek has PRIMARY KEY(isbn)\n";
       $points++;
    }
    else {
       print "  Not ok, Table Boek should have PRIMARY KEY(isbn)\n";
    }
    if ($result =~ /REFERENCES *Boek *\( *isbn *\)/i) {
       print "  Ok, Table Exemplaar has FOREIGN KEY(isbn) REFERENCES Boek(isbn)\n";
       $points++;
       if ($result =~ /ON DELETE CASCADE/i) {
         print "  Ok, Foreign key uses ON DELETE CASCADE.\n";
         $points++;
       }
       else {
         print "  Not ok: What happens if we delete a row from Boek?\n";
       }
       if ($result =~ /ON UPDATE CASCADE/i) {
         print "  Ok, Foreign key uses ON UPDATE CASCADE.\n";
         $points++;
       }
       else {
         print "  Not ok: What happens if we update a row from Boek?\n";
       }
       if ($result =~ /DEFERRABLE/) {
         if ($result =~ /NOT DEFERRABLE/i) { 
            print "  Bonus: You added 'NOT DEFERRABLE'!\n";
         }
         else {
            print "  Error: the key constraint should be NOT DEFERRABLE.\n";
         } 
       }
    }
    else {
       print "  Ok, Table Exemplaar should have FOREIGN KEY(isbn) REFERENCES Boek(isbn)\n";
    }
  }
}



#
# Opgave 5b
#
print "Exercise 5b\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise5b.sql")) {
  system("cat $REPO/$TASK/exercise5b.sql | sqlite3.8 -init $REPO/$TASK/exercise5a.sql >/dev/null 2>$ASSIGN-b.tmp");
  if (-s "$ASSIGN-b.tmp") {
    print "  > ";
    system ("cat $ASSIGN-b.tmp");
    my $results = read_file("$ASSIGN-b.tmp");
    if ($results =~ /unique constraint failed/i) {
       print "  Well done, you failed a primary key constraint.\n";
       $points++;
    }
  }
}


#
# Opgave 5c
#
print "Exercise 5c\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise5c.sql")) {
  system("cat $PATH/$ASSIGN-pragma-fk.sql $REPO/$TASK/exercise5c.sql | sqlite3.8 -init $REPO/$TASK/exercise5a.sql >/dev/null 2>$ASSIGN-c.tmp");
  if (-s "$ASSIGN-c.tmp") {
    print "  > ";
    system ("cat $ASSIGN-c.tmp");
    my $results = read_file("$ASSIGN-c.tmp");
    if ($results =~ /foreign key constraint failed/i) {
       print "  Well done, you failed a foreign key constraint.\n";
       $points++;
    }
    elsif ($results =~ /drop table boek/i) {
       print "  Ok. Dropping Table Boek violates the foreign key constraint.\n";
       $points++;
    }
  }
}

#
# Opgave 5d
#
print "Exercise 5d\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise5d.sql")) {
  system("cat $PATH/$ASSIGN-pragma-fk.sql $REPO/$TASK/exercise5d.sql | sqlite3.8 -init $REPO/$TASK/exercise5a.sql >/dev/null 2>$ASSIGN-d.tmp");
  if (-s "$ASSIGN-d.tmp") {
    print "  SQL errors: ";
    system ("cat $ASSIGN-d.tmp");
  }
  else { 
    my $results = read_file_no_comments("$REPO/$TASK/exercise5d.sql");
    if ($results =~ /UPDATE Boek SET isbn/i) {
      print "  Ok.\n";
      $points++;
    }
    else {
      print "  Not ok. Maybe you updated the wrong table?\n";
    }
  }
}

#
# Opgave 5e
#
print "Exercise 5e\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise5e.sql")) {
  system("cat $PATH/$ASSIGN-pragma-fk.sql $REPO/$TASK/exercise5e.sql | sqlite3.8 -init $REPO/$TASK/exercise5a.sql >/dev/null 2>$ASSIGN-e.tmp");
  if (-s "$ASSIGN-e.tmp") {
    print "  SQL errors: ";
    system ("cat $ASSIGN-e.tmp");
  }
  else {
    print "  Ok.\n";
    $points++;
  }
}

#
# Opgave 5f
#
print "Exercise 5f\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise5f.sql")) {
  print "  Ok. (I only check the existence of the file, see  the old\n"; 
  print "  exams on Blackboard for similar questions and answers)\n";
  $points++;
}


#
# Opgave 5g
#
print "Exercise 5g\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise5g.sql")) {
  print "  Ok. (I only check the existence of the file, see  the old\n";
  print "  exams on Blackboard for similar questions and answers)\n";
  $points++;
}


#
# Opgave 5h i
#
if (-s "$REPO/$TASK/exercise5h.sql") {
  print "Bonus exercises\n";
  print "  Great, you did the bonus question";
  $points++;
  if (-s "$REPO/$TASK/exercise5i.sql") {
    print "s!\n";
    $points++;
  } 
  else {
    print "!\n";
  }
}


fullyDone:  #  spaghetti ends here

give_feedback($points, $TOTAL);


sub system_me {
  my $comm = shift;
  print STDERR "$comm\n";
  system ($comm);
}
  
sub read_file {
   my $file = shift;
   open(I, $file);
   my $result = "";
   while (<I>) {
     s/ +/ /g;
     $result .= $_;
   }
   close I;
   return $result;
}

sub read_file_no_comments {
   my $file = shift;
   open(I, $file);
   my $result = "";
   while (<I>) {
     s/\-\-.*//;
     s/\n/ /;
     $result .= $_;
   }
   close I;
   return $result;
}
