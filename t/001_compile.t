use strict;
use warnings;

use Test::More;
use File::Find;
use Class::MOP;

use FindBin;
use File::Spec;

# http://www.simplicidade.org/notes/archives/2009/11/perl_testing_an.html
# Test::Compile might also be useful

my $lib = File::Spec->catdir($FindBin::Bin, "..", "lib");

my $failed = 0;
find({
  bydepth => 1,
  no_chdir => 1,
  wanted => sub {
    my $m = $_;
    return unless $m =~ s/[.]pm$//;

    my ($volume, $directories, $file) = File::Spec->splitpath($m);
    my @dirs = File::Spec->splitdir($directories);
    pop @dirs; # last entry's blank

    while (@dirs && shift(@dirs) ne 'lib') { };

    $m = join("::", @dirs, $file);

    ok( eval { Class::MOP::load_class($m); 1 }, "$m compiled " . $@||'') or do { $failed = 1 };
  },
}, $lib);

BAIL_OUT("COMPILE FAILED") if $failed;

done_testing();
