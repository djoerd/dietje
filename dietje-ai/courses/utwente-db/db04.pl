#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
#$ASSIGN = 'db04';
$REPO = 'databases';
$TASK = 'session04';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 4;

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
# Opgave 4a
#
print "Exercise 4a\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise4a.sql")) {
   print "  I only look at the comments with 'read1(x)', etc.\n";
   my $result = read_file("$REPO/$TASK/exercise4a.sql");
   if ($result =~ /read2\(x\).*?write1\(x\).*?write2\(x\)/) { 
     print "  Ok.\n";
     $points++;
   }
   elsif ($result =~ /read1\(x\).*?write2\(x\).*?write1\(x\)/) { 
     print "  Ok.\n";
     $points++;
   }
   else {
     print "  Not ok.\n";
     print "  Tip: Two read actions from different transactions can always be swapped.\n";
     print "  If one or both actions from different two transactions are a write,\n"; 
     print "  then they can be swapped if one accesses x and the other y.\n";
     print "  If the schedule is serialisable, then all actions of transaction 1 can be\n";
     print "  moved to one side, and all actions of transaction 2 to the other side.\n"; 
   } 
}


#
# Opgave 4b
#
print "Exercise 4b\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise4b.sql")) {
   print "  I only look at the comments with 'read1(x)', etc.\n";
   my $result = read_file("$REPO/$TASK/exercise4b.sql");
   print STDERR "DEBUG INFO: $result\n";
   if ($result =~ /write1\(x\).*?read2\(x\)/) {
     print "  Ok: Transaction 1 writes x; then Transaction 2 reads x.\n";
     print "  If Transaction 1 aborts, then Transaction 2 did a dirty read.\n";
     print "  (in fact, if it does not abort, it is still a dirty read.)\n";
     $points++;
   }
   else {
     print "  Not ok.\n";
     print "  Tip: Transaction 2 does a dirty read, if Transaction 1 wrote a\n";
     print "  value earlier, but (Transaction 1) did not commit (or abort) yet.\n";
   }
}


#
# Opgave 4c
#
print "Exercise 4c\n";
if (assert_file_exists("  Error", "$REPO/$TASK/exercise4cT1.sql")) {
  if (assert_file_exists("  Error", "$REPO/$TASK/exercise4cT2.sql")) {

    print "  Transaction 1:";
    my $result = read_file_no_comments("$REPO/$TASK/exercise4cT1.sql");
    if (($result =~ /read_uncommitted *= *0/i) or ($result =~ /read committed/i)) {
      print " Ok.\n";
      $points++;
    }
    elsif (($result =~ /read_uncommitted *= *1/i) or ($result =~ /read uncommitted/i)) {
      print "  Not ok.\n";
      print "  Tip: Transaction 1 is not allowed to do a dirty read.\n";
    } 
    elsif (($result =~ /serializable/i) or ($result =~ /repeatable read/) or ($result =~ /snapshot/i)) {
      print "  Not ok.\n";
      print "  Tip: Try to restrict Transaction 1 minimally.\n";
    }
    else {
      print "  Not ok.\n";
      print "  Explicitly set the isolation level in exercise4cT1.sql\n";
    }

    print "  Transaction 2:";
    $result = read_file_no_comments("$REPO/$TASK/exercise4cT2.sql");
    if (($result =~ /read_uncommitted *= *1/i) or ($result =~ /read uncommitted/i)) {
      print " Ok.\n";
      $points++;
    }
    elsif (($result =~ /read committed/i) or ($result =~ /serializable/i) or ($result =~ /repeatable read/) or ($result =~ /snapshot/i)) {
      print "  Not ok.\n";
      print "  Tip: Restrict Transaction 2 minimally.\n";
    }
    else {
      print "  Not ok.\n";
      print "  Explicitly set the isolation level in exercise4cT2.sql\n";
    }

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
     s/= ' /= '/;  # error when copying from exercises...
     s/\n/ /;
     s/  +/ /g;
     # this should be removed:
     #s/SELECT titel FROM Boek WHERE isbn = '0321228383'/read1(y)/i;
     #s/UPDATE Boek SET titel = titel \|\| ' deel 1' WHERE isbn = '0136067018/write1(x)/i;
     #s/UPDATE Boek SET titel = titel \|\| ' deel 1' WHERE isbn = '0321228383/write1(y)/i;
     #s/UPDATE Boek SET titel = titel \|\| ' deel 2' WHERE isbn = '0136067018/write2(x)/i;
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
     s/\-\-.*//g;
     $result .= $_;
   }
   close I;
   return $result;
}
