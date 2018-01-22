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
	$dir = "$ENV{HOME}/dev${arg}";
    }
}

my $br = "$ENV{HOME}/dev/buildroot/crown-buildroot";

print("Building: $dir\n");
    
my $repo = getRepo($dir);
my $comp = $repo->{name};
my $path = $repo->{project}->{path};
my $projdef = ${path} . "/.projdef";

my $target = "";
open(my $pfd, "<", $projdef) || die("Failed to open ${projdef}: $!");
open(my $lfd, ">", "$br/local.mk") || die("Failed to open local.mk: $!");
while(<$pfd>) {
    if(!/([^:]*): (.*)/) {
	die("Invalid .projdef file!\n");
    }
    print "$comp : $1 : $2\n";
    my $name = $1;
    my $pkg = $2;
    if($name eq $comp) {    
	$target = $pkg;
    }
    $pkg = uc($pkg);
    $pkg =~ s/-/_/g;
    my $line = "${pkg}_OVERRIDE_SRCDIR = ${path}/${name}\n";
    print $lfd $line;
}

close $lfd;
close $pfd;
if($target eq "") {
    die("Can't find buildroot comp for ${comp}\n");
}

if($opt ne "") {
    $target .= "-${opt}";
} else {
    $target .= "-reconfigure";
}

my $cmd = "cd $br; make " . $target;
# my $cmd = "cd $br; cat local.mk";
runCmd($cmd, "Building $target in Buildroot");
