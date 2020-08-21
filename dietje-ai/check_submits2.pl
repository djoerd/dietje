#!/usr/bin/perl -w

# curl --data "course=utwente-di&nickname=di00&assignment=level01" http://dietje.org/services/request.json
# psql -U di00 -h datainfo.ewi.utwente.nl -W 

use strict;
use DBI;

my $STUDENT_DIR = "students";
my $COURSE_DIR  = "courses";
my $datetime    = localtime();

print STDERR "Check ($datetime)\n";

my $dbh = DBI->connect(
   "DBI:Pg:dbname=dietje", "dietje", "", {'RaiseError' => 1}
);
 
my $sth = $dbh->prepare(
  "SELECT s.sid, s.aid, a.cid, p.email FROM submits s, assignment a, student p
   WHERE s.aid = a.aid
   AND s.sid = p.sid
   AND (s.pid = 'dietje' OR s.pid IS NULL)
   AND (s.feedback_date IS NULL OR s.feedback_date < s.request_date)" 
);
#$sth = $dbh->prepare(
#  "select a.sid, b.aid, b.cid from (SELECT DISTINCT s.sid FROM submits s, assignment a WHERE s.aid = a.aid and a.cid = 'utwente-di') A, 
#                 (select a.aid, a.cid from assignment a where a.cid = 'utwente-di') B order by a.sid, b.aid"
#);
$sth->execute();
#
#  Loop over all student/assignment pairs that need grading.
#
while (my @row = $sth->fetchrow_array()) {
  my $student    = $row[0];
  my $assignment = $row[1];
  my $course     = $row[2];
  my $email      = $row[3];
  #print STDERR "BOO: $student, $assignment, $course\n";
 
  if ($course eq 'utwente-ds2018' or ($course eq 'utwente-ds2017' and ($student eq 'semerekiros' or $student eq 'ShreyasiPathak'))) { # ONLY RUN DS 2016/2017 Q3
    my $feedback   = "Prof. Dietje says: Hi $student.\nHere is your feedback for $assignment.\n";
    my $script     = "$COURSE_DIR/$course/$assignment.pl"; 
    my $grade      = undef;
    if (!defined($email)) {  $email = ""; }
    print STDERR "$student $assignment $course\n";
    unless (-e "$STUDENT_DIR/$student") {
        system("mkdir $STUDENT_DIR/$student");
        $feedback .= "Welcome to my course, $student.\n";
    }
    if (-e $script) {
        #
        #   *.tmp files might be removed by $script!
        #
        system("cd $STUDENT_DIR/$student; ../../$script $student $email >$assignment-feedback.txt");
        $feedback .= file_content("$STUDENT_DIR/$student/$assignment-feedback.txt");
        ($grade) = ($feedback =~ m/Grade: ([0-9\.]+)/); 
    }
    else {
        $feedback .= "Automatic grading unavailable for this assignment.\n";
        $feedback .= "Please contact a professor of flesh and blood.\n";
    }
    my $update = $dbh->prepare(
      "UPDATE submits SET 
         feedback_date = NOW(), 
         grade = ?,
         feedback = ?
       WHERE sid = ? AND aid = ?"
    );
    if (length($feedback) > 60000) {
       $feedback = substr($feedback, 0, 60000);
    } 
    $update->execute($grade, $feedback, $student, $assignment);
  }
}
$sth->finish();

$dbh->disconnect();


sub file_content {
  my $file_name = shift @_;
  open (I, $file_name) or die "Wooops: $file_name!";
  my @result = <I>;
  my $result = join "", @result;
  return $result;
}

