#!/usr/bin/perl

use strict;
use warnings;

# jump, jump, jump around, JUMP AROUND!

use Test::More tests => 22;
use Test::Time::HiRes;
use Time::HiRes qw(usleep nanosleep gettimeofday tv_interval sleep time);

########################################################################
# usleep
########################################################################

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,1_000_000_000, "default seconds okay");
  is($microseconds,0, "default microseconds okay");
}

# sleep for half a second
usleep(500_000);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,1_000_000_000, "seconds okay");
  is($microseconds,500_000, "microseconds okay");
}

usleep(501_000);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,1_000_000_001, "seconds okay");
  is($microseconds,1_000, "microseconds okay");
}

usleep(0.5);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,1_000_000_001, "seconds okay");
  is($microseconds,1_000, "microseconds okay");
}

usleep(0.5);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,1_000_000_001, "seconds okay");
  is($microseconds,1_001, "microseconds okay");
}

########################################################################
# time travel to
########################################################################

# quick, let's go back and assinate me as a baby!
time_travel_to(500_000,400_000);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,500_000, "travel_to seconds okay");
  is($microseconds,400_000, "travel_to microseconds okay");
}

# wait, that's a silly idea.  I built the time machine.  We'll create
# a paradox that'll make space time go kablooey.
# Back to 2001-09-09T01:46:40 sharpish
time_travel_to(1_000_000_000);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,1_000_000_000, " seconds okay");
  is($microseconds,0, " microseconds okay");  # check microseconds got reset
}

########################################################################
# time travel by
########################################################################

# tivo 30 second buffer?
time_travel_by(-30,0);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,999_999_970, "travel_by seconds okay");
  is($microseconds,0, "travel_by microseconds okay");
}


########################################################################
# nanosleep
########################################################################

nanosleep(500);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,999_999_970, "nanosleep seconds okay");
  is($microseconds,0, "nanosleep microseconds okay");
}

nanosleep(500);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,999_999_970, "nanosleep seconds okay");
  is($microseconds,1, "nanosleep microseconds okay");
}


########################################################################
# sleep
########################################################################

sleep(0.5);

{
  my ($seconds, $microseconds) = gettimeofday;
  is($seconds,999_999_970, "sleep seconds okay");
  is($microseconds,500_001, "sleep microseconds okay");
}

__END__


########################################################################
# time
########################################################################

is(time(),999_999_970.500_001);

########################################################################
# tvinterval
########################################################################