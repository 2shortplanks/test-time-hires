package Test::Time::HiRes;

use strict;
# use warnings;

use 5.010;


use Carp qw(croak);

# stop this loading in its tracks if someone has already loaded Time::HiRes
BEGIN {
  if ($INC{"Time/HiRes.pm"} && $INC{"Time/HiRes.pm"} ne __FILE__)
    { croak "Too late to load Test::Time::HiRes, Time::HiRes already loaded" }
}

use vars qw($AUTOLOAD $VERSION @ISA @EXPORT);
require Exporter;
push @ISA, qw(Exporter);

use Math::BigFloat;

########################################################################
# constants
########################################################################

my $MILLISECONDS_IN_A_SECOND = Math::BigFloat->new( 1000 );
my $MICROSECONDS_IN_A_SECOND = $MILLISECONDS_IN_A_SECOND * 1000;
my $NANOSECONDS_IN_A_SECOND  = $MICROSECONDS_IN_A_SECOND * 1000;

# time contains the currnent simulated time in nanoseconds
my $time = $NANOSECONDS_IN_A_SECOND * "1_000_000_000";

########################################################################
# Fake Time::HiRes package
########################################################################

# alter %INC to indicate that Time::HiRes was loaded from this
# module, thereby preventing the real Time::HiRes being loaded whenever
# we're used.
$INC{"Time/HiRes.pm"} = __FILE__;

# make the fake Time::HiRes use Exporter
@Time::HiRes::ISA = qw(Exporter);

####
# constants
####

# these are normally system dependant, so just make up any old unique number

sub Time::HiRes::CLOCK_HIGHRES { return 4077 }
push @Time::HiRes::EXPORT_OK, "CLOCK_HIGHRES";

sub Time::HiRes::CLOCK_MONOTONIC { return 1701 }
push @Time::HiRes::EXPORT_OK, "CLOCK_MONOTONIC";

sub Time::HiRes::CLOCK_PROCESS_CPUTIME_ID { return 42 }
push @Time::HiRes::EXPORT_OK, "CLOCK_PROCESS_CPUTIME_ID";

sub Time::HiRes::CLOCK_REALTIME { return 69 }
push @Time::HiRes::EXPORT_OK, "CLOCK_REALTIME";

sub Time::HiRes::CLOCK_SOFTTIME { return 1918 }
push @Time::HiRes::EXPORT_OK, "CLOCK_SOFTTIME";

sub Time::HiRes::CLOCK_THREAD_CPUTIME_ID { return 1066 }
push @Time::HiRes::EXPORT_OK, "CLOCK_THREAD_CPUTIME_ID";

sub Time::HiRes::CLOCK_TIMEOFDAY { return 404 }
push @Time::HiRes::EXPORT_OK, "CLOCK_TIMEOFDAY";

sub Time::HiRes::CLOCKS_PER_SEC { return 500 }
push @Time::HiRes::EXPORT_OK, "CLOCKS_PER_SEC";

sub Time::HiRes::TIMER_ABSTIME { return 302 }
push @Time::HiRes::EXPORT_OK, "TIMER_ABSTIME";

sub Time::HiRes::ITIMER_PROF { return 911 }
push @Time::HiRes::EXPORT_OK, "ITIMER_PROF";

sub Time::HiRes::ITIMER_REAL { return 999 }
push @Time::HiRes::EXPORT_OK, "ITIMER_REAL";

sub Time::HiRes::ITIMER_REALPROF { return 112 }
push @Time::HiRes::EXPORT_OK, "ITIMER_REALPROF";

sub Time::HiRes::ITIMER_VIRTUAL { return 118118 }
push @Time::HiRes::EXPORT_OK, "ITIMER_VIRTUAL";

###
# functions we have implemented
###

sub Time::HiRes::gettimeofday() {

  say STDERR "Time is $time";
  say STDERR "nanoseconds in a second is $NANOSECONDS_IN_A_SECOND";
  my $seconds      = int($time / $NANOSECONDS_IN_A_SECOND);
  say STDERR "Seconds is $seconds";;

  my $remainder    = $time - ($seconds * $NANOSECONDS_IN_A_SECOND);
  my $microseconds = int($remainder) / 1000;
  return ($seconds->numify,int($microseconds)->numify);
}
push @Time::HiRes::EXPORT_OK, "gettimeofday";

sub Time::HiRes::nanosleep($) {
  my $nanoseconds = shift;

  # add the nanoseconds
  $time += $nanoseconds;
  $time->ffround(0);  # no fractions of nanoseconds
  
  return
}
push @Time::HiRes::EXPORT_OK, "nanosleep";

sub Time::HiRes::sleep(;@) {
  my $seconds = shift;
  
  # add the seconds
  $time += $NANOSECONDS_IN_A_SECOND * $seconds;
  $time->ffround(0);  # no fractions of nanoseconds

  return
}
push @Time::HiRes::EXPORT_OK, "sleep";

sub Time::HiRes::time() {
  # we add 0 here as ->numify returns a string that numifies into the number
  # not a number.  This means if you try and do a string comparison between
  # this an a perl number, the strings won't match (e.g. with Test::More::is)
  # - more importantly, it doesn't matche the expected behavior of what we're
  # simulating.  So we turn it into a number before returning it.
  return ($time / $NANOSECONDS_IN_A_SECOND)->numify + 0;
}
push @Time::HiRes::EXPORT_OK, "time";

sub Time::HiRes::usleep($) {
  my $microseconds = shift;
  my $seconds = $microseconds / $MICROSECONDS_IN_A_SECOND;
  $time += $seconds * $NANOSECONDS_IN_A_SECOND;
  $time->ffround(0);  # no fractions of nanoseconds
  return
}
push @Time::HiRes::EXPORT_OK, "usleep";

###
# functions that we haven't (yet) implemented
###

sub Time::HiRes::alarm($;$) {
  croak "Function 'alarm' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "alarm";

sub Time::HiRes::clock() {
  croak "Function 'clock' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "clock";

sub Time::HiRes::clock_getres(;$) {
  croak "Function 'clock_getres' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "clock_getres";

sub Time::HiRes::clock_gettime(;$) {
  croak "Function 'clock_gettime' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "clock_gettime";

sub Time::HiRes::clock_nanosleep() {
  croak "Function 'clock_nanosleep' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "clock_nanosleep";

sub Time::HiRes::d_clock {
  croak "Function 'd_clock' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_clock";

sub Time::HiRes::d_clock_getres {
  croak "Function 'd_clock_getres' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_clock_getres";

sub Time::HiRes::d_clock_gettime {
  croak "Function 'd_clock_gettime' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_clock_gettime";

sub Time::HiRes::d_clock_nanosleep {
  croak "Function 'd_clock_nanosleep' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_clock_nanosleep";

sub Time::HiRes::d_getitimer {
  croak "Function 'd_getitimer' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_getitimer";

sub Time::HiRes::d_gettimeofday {
  croak "Function 'd_gettimeofday' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_gettimeofday";

sub Time::HiRes::d_nanosleep {
  croak "Function 'd_nanosleep' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_nanosleep";

sub Time::HiRes::d_setitimer {
  croak "Function 'd_setitimer' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_setitimer";

sub Time::HiRes::d_ualarm {
  croak "Function 'd_ualarm' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_ualarm";

sub Time::HiRes::d_usleep {
  croak "Function 'd_usleep' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "d_usleep";

sub Time::HiRes::getitimer($) {
  croak "Function 'getitimer' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "getitimer";

sub Time::HiRes::setitimer($$;$) {
  croak "Function 'setitimer' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "setitimer";

sub Time::HiRes::stat(;$) {
  croak "Function 'stat' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "stat";

sub Time::HiRes::tv_interval {
  croak "Function 'tv_interval' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "tv_interval";

sub Time::HiRes::ualarm($;$) {
  croak "Function 'ualarm' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "ualarm";

########################################################################
# time travel methods

sub _time_travel {
  my $start            = shift;
  my $new_seconds      = Math::BigFloat->new(shift || "0");
  my $new_microseconds = Math::BigFloat->new(shift || "0");
  my $new_nanoseconds  = Math::BigFloat->new(shift || "0");

  $time = $start
        + $new_nanoseconds
        + $new_microseconds * ($NANOSECONDS_IN_A_SECOND / $MICROSECONDS_IN_A_SECOND)
        + $new_seconds      * $NANOSECONDS_IN_A_SECOND;
  $time->fround(0);  # no fractions of nanoseconds

  return;
}

sub time_travel_to(;$$$) { return _time_travel(Math::BigFloat->new("0"), @_); }
push @EXPORT, "time_travel_to";

sub time_travel_by(;$$$) { return _time_travel($time, @_); }
push @EXPORT, "time_travel_by";

########################################################################

1;

__END__

=head1 NAME

Test::Time::HiRes - help testing code by mocking Time::HiRes

=head1 SYNOPSIS

  use Test::More tests => 1;
  use Time::Time::HiRes;

  # module to test;
  use Bomb;
  my $b = Bomb->new( countdown => 30 );
  
  # jump thirty seconds into the future, i.e. get
  # gettimebyday to report time 30 seconds later
  time_travel_by(30,0);

  ok(Bomb->has_expoded, "someone set us up for the bomb");

=head1 DESCRIPTION

This module is designed to help test modules that use Time::HiRes.

This module, which should be loaded before any module attempts to load
Time::HiRes, contains an alternative implementation of Time::HiRes disconnected
from the real clock on your computer where time doesn't pass either you or
code you're testing asks it to.

=head2 Time::HiRes functions implemented

The following functions of Time::HiRes are implemneted:

=over

=item sleep

=item usleep

=item nanosleep

=item time

=item gettimeofday

=item tvinterval

=back

All other functions (infact, any function of any name) can be imported from
Time::HiRes, but should you attempt to call them then they will simply throw
an exception.

When you load this module the time is set to be initially set to exactly
2001-09-09T01:46:40 UTC, i.e. 1,000,000 seconds and zero microseconds
and zero nanoseconds after the unix epoch.

Please note that the simulated clock in this module, unlike the acutal
timing hardware in your computer, is completely accurate to the nanosecond
level.  Be careful to not rely on this behavior when your code is used with
the real Time::HiRes outside of testing.

=head2 Functions exported by Test::Time::HiRes

This module, as is a tradition for test modules, pollutes your namespace with
several functions when you use.  These are:

=over

=item time_travel_to($seconds, $microseconds, $nanoseconds)

Moves the internal simulated clock to this time exactly (i.e. this many
seconds, microseconds, and zero nanoseconds)

=item time_travel_by($delta_seconds, $delta_microseconds, $delta_nanoseconds)

Move the clock forwards (or backwards) by the passed number of seconds, 
microseconds and nanoseconds

=back

In both cases you may ommit any argument and it will be assumed to be zero.

You may use floating point arguments for any of these arguments and this module
will attempt to Do The Right Thing, so far as the floating point number
system on your computer will allow.   If you pass Math::BigFloat numbers as any
of the arguments then this module will certainly do the right thing (as that's
what we use under the hood to keep track of the total nanoseconds passed)

=head1 AUTHOR

Written by Mark Fowler E<lt>mark@twoshortplanks.comE<gt>

Copyright Mark Fowler 2009.  All Rights Reserved.

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 BUGS

Obviously the scope of this module is only limited to simulating Time::HiRes.
If any of your code uses other sources of time then these will disagree with
the simulated clock (for example, using core C<time()>, C<gmtime()>, C<localtime>,
using DateTime (which relies on core time functions), using filesystem
or network timestamps, etc, etc.)

Not all Time::HiRes functions are implemented.  In particular, many of the
C<clock_*> functions could probably be mocked also.  Maybe in the next version
of this code?  Patches welcome.

We're currently supporting every function, with the same prototypes, as
Time::HiRes 1.9719.  Future changes to that module will be reflected in
future releases of this module, but obviously for now, can't be.

Please see http://twoshortplanks.com/dev/testtimehires for
details of how to submit bugs, access the source control for
this project, and contact the author.

=head1 SEE ALSO

L<Time::HiRes>, L<Test::More>

=cut