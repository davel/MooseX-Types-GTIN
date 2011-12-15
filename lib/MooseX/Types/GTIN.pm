package MooseX::Types::GTIN;
our $VERSION = '0.01';

use 5.10.0;
use MooseX::Types::Moose qw/Int Str/;
use MooseX::Types::Structured qw(Dict);
use MooseX::Types
    -declare => [qw(
        Barcode
        ISBN10
    )];

# import builtin types
use Moose::Util::TypeConstraints;
use MooseX::Types::GTIN::Validate;
use Try::Tiny;

subtype Barcode, as Int,
    where { try { MooseX::Types::GTIN::Validate::assert_barcode($_); 1; } },
    message { local $@; eval { MooseX::Types::GTIN::Validate::assert_barcode($_); }; my $error = $@; $error =~ / at.+/; $error };

coerce Barcode, from Int, via { "0$_" };

subtype ISBN10, as Int,
    where { length($_) == 10 };

foreach my $type (Barcode, ISBN10) {
    coerce $type, from Str, via { # Just trim all whitespace
        s!\s+!!g; $_;
    };
}

coerce Barcode, from ISBN10, via {
    $_ = '978'.substr($_, 0, -1); # Prepend 978, Throw away last digit
    $_ .= state51::Validate::calc_mod10_check_digit($_); # Add checksum
    return $_;
};

1;

