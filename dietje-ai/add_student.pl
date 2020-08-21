#!/usr/bin/perl -w

use strict;
use DBI;
#use Try::Tiny;

die "Usage: add_student.pl <student_nr> <account_name> <realname>\n" unless ($#ARGV == 1 or $#ARGV == 2);

my $ASSIGN  = "ds2017xml01";
my $student_nr = shift;
my $account_name = shift;
my $real_name = undef;

if ($#ARGV >= 0) {
    $real_name = shift;
}

print STDERR "Add $real_name ($account_name / $student_nr) to $ASSIGN \n";

my $dbh = DBI->connect(
   "DBI:Pg:dbname=dietje", "dietje", "", {'RaiseError' => 1}
);
 
my $sth1 = $dbh->prepare(
  "insert into student(sid, studentnr, realname) values (?, ?, ?)"
);
#$sth1->execute($account_name, $student_nr, $real_name);

my $sth2 = $dbh->prepare(
  "insert into submits (aid, sid, pid, request_date) values ('$ASSIGN', ?, 'dietje', NOW())"
);
$sth2->execute($account_name);
 
$dbh->disconnect();



