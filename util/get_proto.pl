#!/usr/bin/perl

use strict;
use warnings;

use 5.010;

use Time::HiRes ();

foreach my $name (sort { lc($a) cmp lc($b) } @Time::HiRes::EXPORT_OK) {
  my $prototype = prototype \&{"Time::HiRes::$name"};
  $prototype = defined $prototype ? "($prototype)" : "";
  say <<"PERL"
sub Time::HiRes::$name$prototype {
  croak "Function '$name' imported from Time::HiRes called.  This function is not implemented by  Test::Time::HiRes";
}
push \@Time::HiRes::EXPORT, "$name";

PERL
}