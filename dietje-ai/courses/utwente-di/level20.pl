#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
#$USER = 'djoerd';
#$PASS = 'password';
$ASSIGN = 'level20';

if ($#ARGV != 0) { 
  die "Failed grading: Student id not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

$points = 0;
$TOTAL = 6;
$REPO = $STUDENT;

git_fetch("https://github.com/utwente-di/$STUDENT.git", $REPO);

#
# Opgave 
#
print "Task 20: (Working application)\n";
if (assert_file_exists ("  Warning", "$REPO/README.md", "  Ok.")) {
  system("cat $REPO/README.md | grep \"datainfo.ewi.utwente.nl\" >$ASSIGN-readme.tmp");
  if (-s "$ASSIGN-readme.tmp") {
    $points++;
    $url = file_content("$ASSIGN-readme.tmp");
    if ($url =~ /(https?:\/\/datainfo\.ewi\.utwente\.nl\/[^\s\*\)]+)/) {
        $webapp = $1;
        print "  Found: $webapp\n";
    }
    if ($webapp =~ /datainfo\.ewi\.utwente\.nl\/$STUDENT/) {
        $points++;
    }
    else {
      print "  Warning: Prefix your webapp with '$STUDENT'\n";
    }
    system("wget $webapp -o $ASSIGN-wget.tmp -O $ASSIGN-html.tmp");
    system("grep -e \"HTTP request sent.* 200\" $ASSIGN-wget.tmp >$ASSIGN-ok.tmp");
    system("grep -e \"HTTP request sent.* 404\" $ASSIGN-wget.tmp >$ASSIGN-notfound.tmp");
    system("grep -e \"HTTP request sent\" $ASSIGN-wget.tmp");
    if (-s "$ASSIGN-ok.tmp") { 
       $points += 3;
       print "  Yes, found it.\n";
    }
    if (-s "$ASSIGN-notfound.tmp") {
       print "  The web app is not found.\n";
    }
    else {
       $points++;
    }
  }
  else {
    print "  Error: Add the url to your application to README.md";
  }
}

give_feedback($points, $TOTAL);
