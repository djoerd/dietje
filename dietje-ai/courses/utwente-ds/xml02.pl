#!/usr/bin/perl -w

use DietjeAI;
use DBI;
use Cwd 'abs_path';
use File::Basename;

#$PATH = dirname(abs_path($0));  # path of the script
$USER = 'dietje';
$PASS = 'ChangeThis'; 
#$ASSIGN = 'xml02';
$REPO = 'datascience';
$TASK = 'xml';

if ($#ARGV < 0) { 
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

print "Exercise 2a: (old school SQL)\n";
sql_check("$REPO/$TASK", "assignment2a.sql", "SELECT name, year, rating FROM movie;");  

print "Exercise 2b: (SQL/XML, 3 columns)\n";
sql_check("$REPO/$TASK", "assignment2b.sql", "SELECT XMLELEMENT(NAME name, name), XMLELEMENT(NAME year, year), XMLELEMENT(NAME rating, rating) FROM movie;");      

print "Exercise 2c: (SQL/XML single column)\n";
sql_check("$REPO/$TASK", "assignment2c.sql", "SELECT XMLFOREST(name, year, rating) FROM movie;");      

print "Exercise 2d: (SQL/XML with movie element)\n";
sql_check("$REPO/$TASK", "assignment2d.sql", "SELECT XMLELEMENT(NAME movie, XMLATTRIBUTES(mid AS \"id\"), XMLFOREST(name, year, rating)) FROM movie;", " m\\?id=\\\"[0-9]\\+\\\"");      

print "Exercise 2e: (SQL/XML with actor roles)\n";
print "  I only check the final commit.\n";
sql_check("$REPO/$TASK", "assignment2e.sql", 
  "SELECT XMLELEMENT(NAME movie, XMLELEMENT(NAME name, m.name), XMLELEMENT(NAME year, m.year), XMLELEMENT(NAME rating, m.rating), XMLAGG( XMLELEMENT(NAME role, a.role))) FROM movie m, acts a, person p WHERE m.mid = a.mid AND a.pid = p.pid GROUP BY m.name, m.year, m.rating;", undef, 
  "  SELECT m.name, m.year, m.rating, COUNT(*) as nr_of_roles\n  FROM movie m, acts a, person p\n  WHERE m.mid = a.mid\n  AND a.pid = p.pid\n  GROUP BY m.name, m.year, m.rating"
);


print "Exercise 2f: (SQL/XML with actor roles and directors)\n";
print "  I only check the final commit.\n";
print "  If you do not get this assignment, don't worry: Ask help from the student assistants.\n";
if(sql_check("$REPO/$TASK", "assignment2f.sql", "SELECT XMLELEMENT(NAME movie, XMLELEMENT(NAME name, r.name), XMLELEMENT(NAME year, r.year), XMLELEMENT(NAME rating, r.rating), r.roles, r.directors) FROM ( SELECT m.name, m.year, m.rating, (SELECT XMLAGG(XMLELEMENT(NAME role, a.role)) FROM acts a WHERE a.mid = m.mid) AS roles, (SELECT XMLAGG(XMLELEMENT(NAME director, p.name)) FROM directs d, person p WHERE d.mid = m.mid AND d.pid = p.pid) AS directors FROM movie m) AS r;", undef, "  SELECT * FROM (\n    SELECT m.name, m.year, m.rating,\n      (SELECT COUNT(a.role) FROM acts a WHERE a.mid = m.mid) AS nr_of_roles,\n      (SELECT COUNT(p.name) FROM directs d, person p\n        WHERE d.mid = m.mid AND d.pid = p.pid) AS nr_of_directors\n    FROM movie m\n  ) AS result;"
)) {
  print "  If your query selects 251 rows, then you miss movies without a director.\n";
}


fullyDone:  #  spaghetti ends here


give_feedback($points, $TOTAL);

  
sub sql_check {
  $path = shift;
  $file = shift;
  $correct = shift;
  $bonus = shift;
  $hint = shift;
  if (!defined($bonus)) { 
    $bonus = "AbSoLUtelyNothingDietje";
  }
  if (assert_file_exists("  Error", "$path/$file")) { 
    $correct =~ s/"/\\"/g;
    system("psql -t -c \"$correct\" | sed -e \"s/$bonus//g\" | sed -e 's/<[^>]\\+\\/>//g' | sort > $file.ok");
    system("cat $file.ok | wc -l > $file.ok.wc");
    system("psql -t -f $path/$file | sed -e 's/<[^>]\\+\\/>//g' | sort > $file.try1 2>$file.err");
    system("cat $file.try1 | sed -e \"s/$bonus//g\" | sed -e 's/<[^>]\\+\\/>//g' | sort > $file.try");
    system("cat $file.try | wc -l > $file.try.wc");
    system("diff $file.ok $file.try >$file.diff");
    system("diff $file.try1 $file.try >$file.bonus.diff");
    if (-s "$file.err") {
      print "  Error: ";
      system("cat $file.err");
    }
    elsif (-s "$file.diff") { 
      print "  Not ok.\n";
      if (defined($hint)) {
        print "  Tip: Start for instance with this SQL query:\n";
        print "$hint\n";
      } 
      $ok  = file_content("$file.ok.wc");
      $try =  file_content("$file.try.wc");
      $ok =~ s/[^0-9]//g;
      $try =~ s/[^0-9]//g;
      if ($try != $ok) {
        print "  Your query selects $try rows, but it should select $ok rows.\n";
      } else {
        print "  Your query should return for instance these rows:\n";
        system("cat $file.ok | head -3 | sed -e 's/ \\+/ /g'");
      }
      $result = file_content("$file.try");
      if ($result =~ /\<[A-Z]/) {
        print "  Note that XML is case-sensitive (You use capital letters in XML element names).\n";
      }
    } else {
      print "  Ok.\n";
      $points++;
      if (-s "$file.bonus.diff") {
        print "  Well done: bonus point added.\n";
        $points++; 
      }
      return 0;
    }
  } else {
    if (defined($hint)) {
      print "  Please, give it a try.\n";
      print "  If you enter a (wrong) solution, I promise I will give you a hint.\n";
    }
  }
  return 1;
}
  
