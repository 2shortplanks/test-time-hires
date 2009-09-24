package Test::Time::HiRes;

use strict;
# use warnings;

use Carp qw(croak);

# stop this loading in its tracks if someone has already loaded Time::HiRes
BEGIN {
  if ($INC{"Time/HiRes.pm"} && $INC{"Time/HiRes.pm"} ne __FILE__)
    { croak "Too late to load Test::Time::HiRes, Time::HiRes already loaded" }
}

use vars qw($AUTOLOAD $VERSION @ISA @EXPORT);
require Exporter;
push @ISA, qw(Exporter);
$VERSION = 0.01;

########################################################################
# The time
########################################################################

# we keep two figures here, seconds and nanoseconds
# this is so we don't lose accuracy on 32bit systems

# this is the integer number of seconds since the epoch.
# It can go negative, but I have no-idea what that'll mean for the end
# user;  The real Time::HiRes obviously never does that!
# but I have no idea (tm)
my $time_s = 1_000_000_000;

# this is the number of nanoseconds on top of that.  It doesn't
# ever go negative (so it has a range of 0 to 999_999_999)
my $time_n = 0;

# internal routine to add a floating point number of seconds
sub _add_seconds($) {
  my $seconds = shift;

  # break into integer and non integer parts
  my $int_seconds  = int($seconds);
  my $sub_seconds  = $seconds - $int_seconds;

  $time_s += $int_seconds;
  _add_overflowing_nanoseconds( 1_000_000_000 * $sub_seconds );

  return;
}

# internal routine to add a floating point number of microseconds
sub _add_microseconds($) {
  my $microseconds = shift;

  # handle whole seconds
  my $seconds = int($microseconds / 1_000_000);
  $time_s += $seconds;
  $microseconds -= $seconds * 1_000_000;

  _add_overflowing_nanoseconds( $microseconds * 1_000 );
  return;
}

# internal routine to add a number of nanoseconds
sub _add_nanoseconds($) {
  my $nanoseconds = shift;

  # handle whole seconds
  my $seconds = int($nanoseconds / 1_000_000_000);
  $time_s += $seconds;
  $nanoseconds -= $seconds * 1_000_000_000;

  _add_overflowing_nanoseconds( $nanoseconds );
  return;
}

# note that _add_overflowing_nanoseconds expects nanonseconds
# that have an absolute value of *less* than 1_000_000_000
# (i.e. less than 1s)

# Note that 32bits can hold up to positive or negative
# 2_147_483_648, meaning we've got enough space for this to
# overflow cleanly as long as the inputs are as stated.

sub _add_overflowing_nanoseconds {
	my $n = int(shift);

	$time_n += $n;
	if($time_n >= 1_000_000_000) {
		$time_s++;
		$time_n -= 1_000_000_000;
	} elsif($time_n < 0) {
		$time_s--;
		$time_n += 1_000_000_000;
	}

	return;
}

########################################################################
# Fake Time::HiRes package
########################################################################

# alter %INC to indicate that Time::HiRes was loaded from this
# module, thereby preventing the real Time::HiRes being loaded whenever
# we're used.
{
  ## no critic (RequireLocalizedPunctuationVars)
  $INC{"Time/HiRes.pm"} = __FILE__;
}
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

sub Time::HiRes::ITIMER_VIRTUAL { return 118 }
push @Time::HiRes::EXPORT_OK, "ITIMER_VIRTUAL";

###
# functions we have implemented
###

sub Time::HiRes::gettimeofday() {
  return ($time_s,int($time_n/1000));
}
push @Time::HiRes::EXPORT_OK, "gettimeofday";

sub Time::HiRes::nanosleep($) {
  my $nanoseconds = shift;
  _add_nanoseconds($nanoseconds);
  return
}
push @Time::HiRes::EXPORT_OK, "nanosleep";

sub Time::HiRes::sleep(;@) {
  my $seconds = shift;
  _add_seconds($seconds);
  return
}
push @Time::HiRes::EXPORT_OK, "sleep";

sub Time::HiRes::time() {
  return $time_s + ($time_n / 1_000_000_000);
}
push @Time::HiRes::EXPORT_OK, "time";

sub Time::HiRes::usleep($) {
  my $microseconds = shift;
  _add_microseconds($microseconds);
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
  my $t0 = shift;
  my $t1 = @_ ? shift : [Time::HiRes::gettimeofday()];
  return $t1->[0] - $t0->[0] + (($t1->[1] - $t0->[1]) / 1_000_000);
}
push @Time::HiRes::EXPORT_OK, "tv_interval";

sub Time::HiRes::ualarm($;$) {
  croak "Function 'ualarm' imported from Time::HiRes called.  This function is not implemented by Test::Time::HiRes";
}
push @Time::HiRes::EXPORT_OK, "ualarm";

########################################################################
# time travel methods

sub time_travel_to(;$$$) {

  # move to the start of time
  $time_s = 0;
  $time_n = 0;

  # then just move forward by the number of seconds passed.
  # this copes nicely if we've been passed non-integer /
  # overflowing values
  time_travel_by(shift, shift, shift);
  return;
}
push @EXPORT, "time_travel_to";

sub time_travel_by(;$$$) {
  _add_seconds(shift || 0);
  _add_microseconds(shift || 0);
  _add_nanoseconds(shift || 0);
  return;
}
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

  ok(Bomb->has_expoded, "someone set us up the bomb");

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

All other functions implmented by Time::HiRes can be imported from the mocked
Time::HiRes, but should you attempt to call them then they will simply throw
an exception.

When you load this module the time is set to be initially set to exactly
2001-09-09T01:46:40 UTC, i.e. 1,000,000,000 seconds and zero microseconds
and zero nanoseconds after the unix epoch.

Please note that the simulated clock in this module, unlike the acutal
timing hardware in your computer, is completely accurate to the nanosecond
level.  Be careful to not rely on this behavior when your code is used with
the real Time::HiRes outside of testing.

=head2 Functions exported by Test::Time::HiRes

This module, as is a tradition for test modules, pollutes your namespace with
several functions when you use it.  These are:

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
system on your computer will allow.

=head1 AUTHOR

Written by Mark Fowler E<lt>mark@twoshortplanks.comE<gt> with lots of
help from Andrew Main (Zefram) E<lt>zefram@fysh.orgE<gt>.  All the bits
where I got the maths right are Zefram's fault;  All the bits where I
got it wrong are my fault.

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
