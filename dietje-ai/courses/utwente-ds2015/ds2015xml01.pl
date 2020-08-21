#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
$ASSIGN = 'xml01';
$REPO = 'datascience';
$TASK = 'xml';

if ($#ARGV < 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 13;

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
    if (assert_file_exists("  Error", "$REPO/$TASK/")) {
      $points++;
    }
  }
}


print "Exercise 1c: (the sequence 'cie')\n";
regex_check("$REPO/$TASK", "assignment1c.txt", "cie");  

print "Exercise 1d: (yes or no)\n";
regex_check("$REPO/$TASK", "assignment1d.txt", "yes|no");  

print "Exercise 1e: (begin and end with same vowel)\n";
regex_check("$REPO/$TASK", "assignment1e.txt", "^([aeiou]).*\\1\$");  

print "Exercise 1f: (begin and end with same 3 letters)\n";
regex_check("$REPO/$TASK", "assignment1f.txt", "^(.{3}).*\\1\$");  

print "Exercise 1g: (4 vowels in a row)\n";
regex_check("$REPO/$TASK", "assignment1g.txt", "[aeiou]{4}");  

print "Exercise 1h: (no vowels)\n";
regex_check("$REPO/$TASK", "assignment1h.txt", "^[^aeiou]+\$");  

print "Exercise 1i: (four 'o')\n";
regex_check("$REPO/$TASK", "assignment1i.txt", "(o.*){4}");  

print "Exercise 1j: (3 times 2)\n";
regex_check("$REPO/$TASK", "assignment1j.txt", "(.{2})(.*\\1){2}");  

print "Exercise 1k: (long words with vowel at begin and end but not in between)\n";
regex_check("$REPO/$TASK", "assignment1k.txt", "^[aeiou][^aeiou]{4,}[aeiou]\$");  

print "Exercise 1l: (3 consecutive double-letter pairs)\n";
regex_check("$REPO/$TASK", "assignment1l.txt", "(.)\\1(.)\\2(.)\\3");

print "Exercise 1m: (in and out)\n";
regex_check("$REPO/$TASK", "assignment1m.txt", "in.*out|out.*in"); 





fullyDone:  #  spaghetti ends here


give_feedback($points, $TOTAL);

  
sub regex_check {
  $path = shift;
  $file = shift;
  $correct = shift;
  if (assert_file_exists("  Error", "$path/$file")) { 
    system("egrep \"$correct\" </usr/share/dict/words > $file.ok");
    system("cat $file.ok | wc -l > $file.ok.wc");
    open (I, "$path/$file") or die "Woops, contact the sysadmin!\n";
    $regex = <I>;
    close I;
    chop($regex);
    if ($regex =~ /^\/(.*)\/[gmi]*$/) {
      $regex =~ s/^\/(.*)\/[gmi]*$/$1/;  # we accept Perl notation
      print "  I change your regex in Perl notation\n";
    }
    if ($regex =~ /[^\\]\"/) {
      $regex =~ s/([^\\])\"/$1\\"/g;  # properly escape quotes
      print "  I escaped your quotes (quotes are part of the regular expression)\n";
    }
    if ($regex =~ /\\\\/) {
      $regex =~ s/\\\\/\\/g;  # double escapeing for Java fans?
      print "  I removed your escaped '\\' (for Java or C++?)\n";
    }
    if ($regex =~ /\$[0-9]/) {
      $regex =~ s/\$([0-9])/\\$1/g;  # $ notation Perl
      print "  I replaced '\$'$1 for \\$1\n";
    }

    if (!python_alternative($regex, $file)) {
      $command = "egrep \"$regex\" </usr/share/dict/words";
      #print "  I test with the following command: $command\n";
      system("$command > $file.try 2>$file.err");
    } else {
      #print "Tested as Python regex.\n";
      system("cp $file-py.try $file.try");
      system("cp $file-py.err $file.err");
    }
    
    system("cat $file.try | wc -l > $file.try.wc");
    system("diff $file.ok $file.try >$file.diff");
 
    if (-s "$file.err") {
      print "  Error: ";
      system("cat $file.err");
    }
    elsif (-s "$file.diff") { 
      print "  Not ok.\n";
      $ok  = file_content("$file.ok.wc");
      $try =  file_content("$file.try.wc");
      $ok =~ s/[^0-9]//g;
      $try =~ s/[^0-9]//g;
      if ($try != $ok) {
        if ($ok > 10 or $try > 10 or $try == 0) {
          print "  Your regular expression matches $try words, but it should match $ok words.\n";
        }
        else {
          print "  Your regular expression matches:\n";
          system ("cat $file.try");
          print "  but it should match the following words:\n";
          system ("cat $file.ok");
        }
      }
      else {
        print "  The found matches differ as follows:\n";
        system("cat $file.diff | head -20");   
      } 
      if ($regex =~ /[AEIOU]/) {
        print "  Do not match capital vowels 'A', 'E', 'I', etc.\n";
      }
    }
    else {
      print "  Ok.\n";
      $points++;
    }
  }
}
 
sub python_alternative {
  $regex = shift;
  $file = shift;
  system("python /home/hiemstra/Tools/dietje-ai/courses/utwente-ds2015/test_python.py '$regex' >$file-py.try 2>$file-py.err");
  system("diff $file.ok $file-py.try >$file-py.diff");
  if (-s "$file-py.err" or -s "$file-py.diff") { return 0; }
  else { return 1; }
} 
