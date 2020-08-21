#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
#$ASSIGN = 'xml03';
$REPO = 'datascience';
$TASK = 'xml';
$BASEX = 'java -cp /home/hiemstra/Tools/BaseX/BaseX803.jar org.basex.BaseX';

if ($#ARGV < 0) { 
  die "Failed grading: Student id and email not provided.\n";
}
else {
  $STUDENT = $ARGV[0];
}

if ($#ARGV >= 1) {
  $EMAIL = $ARGV[1];
}

$points = 0;
$TOTAL = 15;

system ("rm -rf $REPO"); # we're going to do a fresh install
system ("rm -rf *.tmp");
 
if (!git_fetch("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO)) {
  print "  Error: Git access https://bitbucket.org/$STUDENT/$REPO.git\n"; 
  goto fullyDone;
}

$git_mail = git_check_email("https://$USER:$PASS\@bitbucket.org/$STUDENT/$REPO.git", $REPO);
if ($#ARGV >= 1) {
  $EMAIL = $ARGV[1];
  $EMAIL =~ s/\@.*$//;
  $git_mail =~ s/\@.*$//;
  print "  Expecting results from <$EMAIL\@email>\n";
  $exp_mail = $EMAIL;
  $exp_mail =~ tr/A-Z/a-z/;
  $git_mail =~ tr/A-Z/a-z/;
  print "  Most commits by <$git_mail\@email>\n";
  if ($exp_mail ne $git_mail) {
    print "  ERROR: Most commits were not by <$EMAIL\@email>\n";
    goto fullyDone;
  }
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
  $points++;
} else {
  print "  Not ok.\n";
  print "  Give all boatname elements in document order.\n";
} 


print "Exercise 3b: (hired boatnames)\n";
if (!xq_check("$REPO/$TASK", "assignment3b.xq", 'doc("voc.xml")//voyage[.//hired]//boatname')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
}


print "Exercise 3c: (destination harbours of the BATAVIA)\n";
if (!xq_check("$REPO/$TASK", "assignment3c.xq", 'doc("voc.xml")//leftpage[boatname="BATAVIA"]/harbour')) {
  print "  Not ok.\n";
  print "  It determines not the destination harbours but the departure harbours.\n";
}
elsif (!xq_check("$REPO/$TASK", "assignment3c.xq", 'doc("voc.xml")//leftpage[boatname="BATAVIA"]//harbour')) {
  print "  Not ok.\n";
  print "  It determines the destination harbours but also the departure harbours.\n";
}
elsif (!xq_check("$REPO/$TASK", "assignment3c.xq", 'doc("voc.xml")//leftpage[boatname="BATAVIA"]/destination/harbour')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
}


print "Exercise 3d: (voyages of the BATAVIA sailing from or to the harbour Batavia)\n";
if (!xq_check("$REPO/$TASK", "assignment3d.xq", 'doc("voc.xml")//voyage[.//boatname="BATAVIA"][.//harbour="Batavia"]')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
}


print "Exercise 3e: (voyages with master Willem IJsbrandsz. Bontekoe)\n";
if (!xq_check("$REPO/$TASK", "assignment3e.xq", 'doc("voc.xml")//voyage[.//master="Willem IJsbrandsz. Bontekoe"]')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
}


print "Exercise 3f: (voyages mentioning Cape of Good Hope in the particulars)\n";
if (!xq_check("$REPO/$TASK", "assignment3f.xq", 'doc("voc.xml")//voyage[.//particulars[contains(.,"Cape of Good Hope")]]')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
  print "  Tip: use contains()\n";
}


print "Exercise 3g: (first voyage with no boatname)\n";
if (!xq_check("$REPO/$TASK", "assignment3g.xq", 'doc("voc.xml")//voyage[not(.//boatname)][1]')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
}


print "Exercise 3h: (explicit axis steps)\n";
if (assert_file_exists("  Error", "$REPO/$TASK/assignment3h.xq")) {
  print "  Ok.\n";
  print "  I did not check this assignment, note that:\n";
  print "  '/*' stands for '/child::*', so the first one selects the fourth child of\n";
  print "  each voyage with number 4144; '//*' stands for '/descendant-or-self::*/child::*',\n";
  print "  so '//*[4]' selects the fourth child of the voyage element itself and the fourth\n";
  print "  child of all of its descendants. This is indeed difference from '/descendant::*[4]'\n";
  print "  which selects in the sequence of descendants the fourth element (boatname)\n";
  $points++;
}
else {
  print "  Not ok.\n";
}


print "Exercise 3i: (oldest voyage of Jakob de Vries)\n";
if (!xq_check("$REPO/$TASK", "assignment3i.xq", '(for $v in doc("voc.xml")//voyage[.//master="Jakob de Vries"] order by zero-or-one($v/leftpage/departure) ascending return $v)[1]')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
  print "  Tip: Use a flwor query now. You need to either use zero-or-one(), exactly-one(),\n";
  print "  or string() to make sure that the order-by clause does not refer to a sequence type.\n";
}



print "Exercise 3j: (number of voyages, boats and masters)\n";
if (!xq_check("$REPO/$TASK", "assignment3j.xq", 'let $doc := doc("voc.xml") return <totals> <voyages> { count($doc//voyage) } </voyages> <boats> { count(distinct-values($doc//boatname)) } </boats> <masters> { count(distinct-values($doc//master)) } </masters> </totals>')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
  print "  Tip: use distinct-values()\n";
}



print "Exercise 3k: (total number of soldiers)\n";
if (!xq_check("$REPO/$TASK", "assignment3k.xq", 'sum(doc("voc.xml")//onboard/soldiers/*)')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok. The answer should be 467244.\n";
}



print "Exercise 3l: (master with number of voyages)\n";
# Alternative with group by gives error:  1/203: [XPTY0004] Item expected, sequence found: (1, 1, 1, 1, 1).
# for $voyage in doc("voc.xml")//voyage[.//master] let $master := $voyage//master let $cnt := count($voyage) group by $master order by $cnt descending return <master name="{$master}" nrofvoyages="{$cnt}"/>
if (!xq_check("$REPO/$TASK", "assignment3l.xq", 'let $doc := doc("voc.xml") for $master in distinct-values($doc//master) let $voyages := $doc//voyage[.//master = $master] return <master name="{$master}" nrofvoyages="{count($voyages)}"/>')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
  print "  Tip: Use 'group by' or distinct-values() to determine the groups.\n";
}



print "Exercise 3m: (masters with most voyages)\n";
if (!xq_check("$REPO/$TASK", "assignment3m.xq", 'let $doc := doc("voc.xml") let $result := for $master in distinct-values($doc//master) let $nrofvoyages := count($doc//voyage[.//master = $master]) order by $nrofvoyages descending return <master name="{ $master }" nrofvoyages="{ $nrofvoyages }"/> let $maxnrofvoyages := $result[1]/@nrofvoyages for $master in $result where $master/@nrofvoyages = $maxnrofvoyages return $master')) {
  print "  Ok.\n";
  $points++;
}
else {
  print "  Not ok.\n";
} 


print "Exercise 3o: (DTD)\n";
if (assert_file_exists("  Error", "$REPO/$TASK/assignment3o.dtd")) {
  system("xmllint --noout -dtdvalid $REPO/$TASK/assignment3o.dtd $PATH/voc.xml 2>$file-0.err");
  if (-s "$file-0.err") {
    print "  Not ok. Errors:";
    system("cat $file-0.err | sed -e 's/\\/home\\/hiemstra\\/Tools\\/dietje-ai\\/courses\\/utwente-ds\\///g' | head -30");
  }
  else {
    system("xmllint --noout -dtdvalid $REPO/$TASK/assignment3o.dtd $PATH/test1.xml 2>$file-1.err");
    if (!-s "$file-1.err") {
      print "  Not ok. Your DTD should be more strict. Please model voyage, etc.\n";
    }
    else {
      print "  Ok.\n";
      $points++;
      $bonus = 0;
      system("xmllint --noout -dtdvalid $REPO/$TASK/assignment3o.dtd $PATH/test2.xml 2>$file-2.err");
      if (!-s "$file-2.err") {
        print "  Your answer can be improved by modeling the fact that trip_sup, num_support, and\n";
        print "  number_sup never occur inside one leftpage.\n";
      }
      else {
        $bonus += 0.5;
      }
      system("xmllint --noout -dtdvalid $REPO/$TASK/assignment3o.dtd $PATH/test3.xml 2>$file-3.err");
      if (!-s "$file-3.err") {
        print "  Your answer can be improved by modeling the fact that bought, hired, and\n"; 
        print "  built never occur inside one leftpage.\n";
      }
      else {
        $bonus += 0.5;
      }
      if ($bonus == 1) {
        print "  Well done.\n";
      }
      $points += $bonus;
    }
  }
}



print "Exercise 3p: (harbours according to DTD)\n";
if (assert_file_exists("  Error", "$REPO/$TASK/assignment3p.xq")) {
  print "  Ok.\n";
  print "  I now see that my DTD was not complete: I didn't specify the root element.\n";
}


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
    $query = file_content("$path/$file");
    if ($query !~ /doc\([^\)]+\)/) {
      print "  Error: Include the function doc() in your query to refer to voc.xml\n";
      return 1;
    }
    else {
      # This was used originally, replacing ' with ". Not sure why...
      # system("cat $path/$file | sed -e 's/doc([^)]\\+)/doc(\"\\/home\\/hiemstra\\/Tools\\/dietje-ai\\/courses\\/utwente-ds\\/voc.xml\")/g' | tr \"'\" '\"' > $file");
      system("cat $path/$file | sed -e 's/doc([^)]\\+)/doc(\"\\/home\\/hiemstra\\/Tools\\/dietje-ai\\/courses\\/utwente-ds\\/voc.xml\")/g' > $file");
      system("$BASEX $file $sortcommand >$file.try 2>$file.err");
      system("echo '$correct' $sortcommand | sed -e 's/doc([^)]\\+)/doc(\"\\/home\\/hiemstra\\/Tools\\/dietje-ai\\/courses\\/utwente-ds\\/voc.xml\")/g' > $file.correct");
      system("$BASEX $file.correct $sortcommand >$file.ok");
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
  return 1;
}
  
