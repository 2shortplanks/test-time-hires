#!/usr/bin/perl

use strict;
use Test::More tests => 25;

########################################################################
# importing from Test::Time::HiRes
########################################################################

use Test::Time::HiRes;

# import okay?

ok(defined &time_travel_to, "time_travel_to");
is(prototype \&time_travel_to, ';$$$', "time_travel_to proto");
ok(defined &time_travel_to, "time_travel_by");
is(prototype \&time_travel_by, ';$$$', "time_travel_to proto");

########################################################################
# try importing from Time::HiRes
########################################################################

use Time::HiRes qw(
  
  CLOCK_HIGHRES
  CLOCK_MONOTONIC
  CLOCK_PROCESS_CPUTIME_ID
  CLOCK_REALTIME
  CLOCK_SOFTTIME
  CLOCK_THREAD_CPUTIME_ID
  CLOCK_TIMEOFDAY
  CLOCKS_PER_SEC
  TIMER_ABSTIME
  ITIMER_PROF
  ITIMER_REAL
  ITIMER_REALPROF
  ITIMER_VIRTUAL
  
  alarm
  clock
  clock_getres
  clock_gettime
  clock_nanosleep
  d_clock
  d_clock_getres
  d_clock_gettime
  d_clock_nanosleep
  d_getitimer
  d_gettimeofday
  d_nanosleep
  d_setitimer
  d_ualarm
  d_usleep
  getitimer
  setitimer
  stat
  tv_interval
  ualarm
  
);

# check that those are unique constants

my %thingy = map { $_ => 1 } (
CLOCK_HIGHRES,
CLOCK_MONOTONIC,
CLOCK_PROCESS_CPUTIME_ID,
CLOCK_REALTIME,
CLOCK_SOFTTIME,
CLOCK_THREAD_CPUTIME_ID,
CLOCK_TIMEOFDAY,
CLOCKS_PER_SEC,
TIMER_ABSTIME,
ITIMER_PROF,
ITIMER_REAL,
ITIMER_REALPROF,
ITIMER_VIRTUAL,
);

is(scalar(keys %thingy), 13, "constants exported and all unique");

#########################################################################
# check the no-can call functions work

my @tests = split /\n/, <<'ENDOFTESTS';
alarm "foo"
clock;
clock_getres "foo";
clock_gettime "foo";
clock_nanosleep;
d_clock();
d_clock_getres();
d_clock_gettime();
d_clock_nanosleep();
d_getitimer();
d_gettimeofday();
d_nanosleep();
d_setitimer();
d_ualarm();
d_usleep();
getitimer "foo"
setitimer "foo", "bar", "baz";
stat "foo";
tv_interval();
ualarm "foo", "bar";
ENDOFTESTS

foreach (@tests) {
  my ($funcname) = m/\A([a-z_]+)/;
  eval $_;
  like($@,
    "/Function '$funcname' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes/",
    "$funcname errors correctly");
}

