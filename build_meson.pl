#!/usr/bin/perl -w
use strict;

use lib "$ENV{HOME}/dev/util";
use Util qw(runCmd getRepo);

my $dir = shift;

my $repo = getRepo($dir);

print "Building $repo->{name} in $repo->{path}\n";

my $builddir = "$repo->{path}/builddir";
print("Checking for $builddir\n");
if(!-d $builddir) {
    mkdir $builddir;
    runCmd("meson builddir", "Creating Meson build directory");
}
runCmd("cd $builddir && ninja", "Building $repo->{name}");


