package DietjeAI;

use strict;
use warnings;
use Exporter;

our @ISA= qw( Exporter );

# these CAN be exported.
our @EXPORT_OK = qw( 
  git_fetch
  git_check_email
  assert_equals 
  assert_at_least
  file_content
  assert_file_exists
  give_feedback
);

# these are exported by default.
our @EXPORT = @EXPORT_OK;


sub git_fetch {
  my $priv = shift @_;
  my $repo = shift @_;
  my $points = 0;
  my $url = $priv;
  $url =~ s/ChangeThis/Dietje4President/;
  #$priv =~ s/dietje:ChangeThis\@//;

  print STDERR "git repository: $priv\n";
  if (-d $repo) {
    print STDERR "git pull ($repo)\n";
    if (system("cd $repo; git pull >/dev/null 2>git-err.log; cd ..") == 0) {
      $points++;
    }
    else {
      print  "  Error: Cannot fetch $priv\n";
    }
  }
  else {
    print STDERR "git clone '$priv'\n";
    if (system("git clone $priv >/dev/null 2>/dev/null") == 0) {
      print "  Error: Please make your repo private.\n";
      $points = 0;
    }
    else {
      if (system("git clone $url >/dev/null 2>git-err.log") == 0) {
        $points++;
      }
      else {
        print  "  Error: Cannot clone $priv\n";
      }
    }
  }
  return $points;
}

sub git_check_email {
  my $priv = shift @_;
  my $repo = shift @_;
  my $author = "";
  my $max = 0;
  my %count = ();
  my $key;
  if (-d $repo) {
    print STDERR "git log ($repo)\n";
    if (system("cd $repo; git log >git-log.txt 2>git-err.log; cd ..") == 0) {
       open(I, "$repo/git-log.txt");
       while (<I>) {
         if (/^Author:[^<]+<([^>]+)>/) {
           $author = $1;
           if (!defined($count{$author})) { $count{$author} = 0; }
           else { $count{$author}++; }
         } 
       }
       $max = 0;
       foreach $key (keys %count) {
         if ($count{$key} > $max) {
           $author = $key;
           $max = $count{$author};
         }
       }
       return $author;
    }
    else {
       print "  Error: Cannot access git $priv\n";
    }
  }
}

sub assert_equals {
  my $assertion = shift @_;
  my $file      = shift @_;
  my $expected  = shift @_;
  my $result    = file_content($file);
  my $points    = 0;
  if ($result =~ $expected ) {
    $points++;
  } else {
    print "$assertion. Got $result; expected $expected.\n";
  }
  return ($points);
}

sub assert_at_least {
  my $assertion = shift @_;
  my $file      = shift @_;
  my $expected  = shift @_;
  my $points    = 0;
  my $result    = file_content($file);
  if ($result >= $expected ) {
    $points++;
  } else {
    print "$assertion. Got $result; expected at least $expected.\n";
  }
  return ($points);
}

sub file_content {
  my $file_name = shift @_;
  open (I, $file_name) or die "Wooops: $file_name!";
  my @result = <I>;
  close I;
  my $result = join " ", @result;
  $result =~ s/\n//;
  return $result;
}


sub assert_file_exists {
  my $message   = shift @_;
  my $file_name = shift @_;
  my $response  = shift @_;
  my $points    = 0;
  if (-e $file_name) {
    if (-s $file_name) {
      if ($response) { print "  Ok.\n"; }
      open(I, $file_name);
      my @lines = <I>;
      close I;
#      if (!-d $file_name and $lines[0] =~ /\xEF\xBB\xBF/) {
#         print "  Sqlite does not accept UTF-8 files. Please save your SQL files as plain ASCII.\n";
#      }
#      else {
        $points++;
#      }
    }
    else {
      print "$message: $file_name is empty.\n";
    }
  } else {
    print "$message: $file_name does not exist.\n";
  }
  return $points;
}

sub give_feedback {
  my $points = shift @_;
  my $TOTAL  = shift @_;
  print "\n";
  if ($points < 0) { $points = 0; }
  printf "Points: %d\n", $points + 0.4;  # afronding, dus + 0.5?
  if ($points > $TOTAL) { $points = $TOTAL; }
  printf "Grade: %1.1f\n", 9 * $points / $TOTAL + 1;
}

1;
