#!/usr/bin/perl -w
use strict;

use File::Basename;
use Cwd;

my $repo = $ARGV[1];
my $dev = "$ENV{HOME}/dev";

if($defined($repo)) {
    my $dir = getcwd();
    if ($dir =~ m|$dev|([^/]*)|) {
	$repo = $1;
    } else {
	die("Not in development tree.\n");
    }
}

print "Building $repo\n";


    
