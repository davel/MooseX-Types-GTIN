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
    where { try { MooseX::Types::GTIN::Validate::assert_gtin($_); 1; } },
    message { local $@; eval { MooseX::Types::GTIN::Validate::assert_gtin($_); }; my $error = $@; $error =~ / at.+/; $error };

coerce Barcode, from subtype(Str => where { /\s*(?:\d{8}|\d{12,14})\s*$/ }),
               via  { # Just trim all whitespace
                    s!\s+!!g;

                    # Magic workaround for spreadsheets eating the first digit
                    # of a UPC.
                    if (length($_)==11) {
                        return "0$_";
                    }
                    else {
                        return $_;
                    }
               };

subtype ISBN10, as Int,
    where { length($_)==10 },
    message { "Wrong length to be a ISBN10" };

coerce ISBN10, from subtype(Str => where { warn $_; /\s*\d{9}(?:\d|X|x)\s*$/ }),
               via  { # Just trim all whitespace
                    s!\s+!!g; $_;
               };

coerce Barcode, from ISBN10, via {
    $_ = '978'.substr($_, 0, -1); # Prepend 978, Throw away last digit
    $_ .= MooseX::TYpes::GTIN::Validate::calc_mod10_check_digit($_); # Add checksum
    return $_;
};

1;

