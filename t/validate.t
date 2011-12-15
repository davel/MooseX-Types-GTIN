#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Try::Tiny;

use MooseX::Types::GTIN::Validate;

my $clean;
my $error;

try { $clean = MooseX::Types::GTIN::Validate::assert_gtin('829410333658'); }
catch {$error = $_};
is($error, undef, "barcode fine");
is($clean, '829410333658', "clean barcode matches");
$error = $clean = undef;


done_testing;
