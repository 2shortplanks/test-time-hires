#!/usr/bin/perl

use strict;
use Test::More tests => 2;

SKIP: {
  skip 2, "Time::HiRes is not installed"
    unless eval "use Time::HiRes; 1";

  ok(!eval "use Test::Time::HiRes", "Can't use after Time::HiRes");
  like($@,"/Too late to load Test::Time::HiRes, Time::HiRes already loaded/", "right error")
}
