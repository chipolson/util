#!/usr/bin/perl -w
use strict;

use lib "$ENV{HOME}/dev/util";
use Util qw(runCmd getRepo);

my $opt = "";
my $dir = "";

while(my $arg = shift) {
    if($arg eq "-o") {
	$opt = shift;
    } else {
	$dir = $arg;
    }
}

my $br = "$ENV{HOME}/dev/buildroot/crown-buildroot";
    
my $repo = getRepo($dir);
my $target = $repo->{name};
if($opt ne "") {
    $target .= "-${opt}";
}

my $localmk = "STARRY_COLLECTD_PLUGINS_OVERRIDE_SRCDIR = $repo->{path}";
my $local_fn = "${br}/local.mk";
open(my $local_fd, ">", $local_fn) || die("Can't open ${br}/local.mk: $!");
print $local_fd $localmk;
close $local_fd;

my $cmd = "cd $br; make " . $target;
runCmd($cmd, "Building $target in Buildroot");
