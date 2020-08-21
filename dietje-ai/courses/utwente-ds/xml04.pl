#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
#$ASSIGN = 'xml03';
$REPO = 'datascience';
$TASK = 'xml';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 7;

system ("rm -rf $REPO"); # we're going to do a fresh install
system ("rm -rf *.tmp");
 
if (!git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
  print "  Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}


print "Exercise 3a: (voyages' boatnames)\n";
if (!xq_check("$REPO/$TASK", "assignment3a.xq", 'distinct-values(doc("voc.xml")//boatname)', 1)) { 
  print "  Not ok.\n";
  print "  Do not give the distinct boatname values: Give all boatname elements in document order.\n";
}
elsif (!xq_check("$REPO/$TASK", "assignment3a.xq", 'for $n in distinct-values(doc("voc.xml")//boatname) return <boatname>{$n}</boatname>', 1)) {
  print "  Not ok.\n";
  print "  Do not give the distinct boatname element: Give all boatname elements in document order.\n";
}
elsif (!xq_check("$REPO/$TASK", "assignment3a.xq", 'doc("voc.xml")//voyage//boatname')) {
  print "  Ok.\n";
} else {
  print "  Not ok.\n";
  print "  Give all boatname elements in document order.\n";
} 


print "Exercise 3b: (hired boatnames)\n";
print "To be graded.\n";



fullyDone:  #  spaghetti ends here


give_feedback($points, $TOTAL);

  
sub xq_check {
  $path = shift;
  $file = shift;
  $correct = shift;
  $sorted =  shift;
  if (defined($sorted)) {
    $sortcommand = "| sort";
  }
  else {
    $sortcommand = "";
  }
  if (assert_file_exists("  Error", "$path/$file")) { 
    system("basex $path/$file $sortcommand >$file.try 2>$file.err");
    system("echo '$correct' $sortcommand > $file.correct");
    system("basex $file.correct $sortcommand >$file.ok");
    system("diff $file.ok $file.try >$file.diff");

    if (-s "$file.err") {
      print "  Error: ";
      system("cat $file.err");
      return 1;
    }
    elsif (-s "$file.diff") {
      return 1;
    }
    else {
      return 0; 
    }
  }
}
  
