#!/usr/bin/perl -w
use strict;

use lib "$ENV{HOME}/dev/util";
use Util qw(runCmd getRepo isMac readFile writeFile getBR $dev);

my $opt = "";
my $dir = "";

while(my $arg = shift) {
    if($arg eq "-o") {
	$opt = shift;
    } else {
	$dir = $arg;
    }
}

print "Building in $dir\n";
    
my $repo = getRepo($dir);
my $name = $repo->{name};
my $project = $repo->{project};

my $target = "";
my $localmk = "";
my $platform = "";
my $rpath = "/home/colson/dev/$project->{name}";
my $projdef = "$project->{path}/.projdef";
open(my $fd, "<", $projdef) || die("Can't open ${projdef}: $!");
foreach (<$fd>) {
    /([^:]*): (.*)/;
    my $comp = $1;
    my $pkg = $2;
    if($comp eq "PLATFORM") {
	$platform = $pkg;
	next;
    }
    if($comp eq $name) {
	$target = $pkg;
    }
    $pkg = uc($pkg);
    $pkg =~ s/-/_/g;
    $localmk .= "${pkg}_OVERRIDE_SRCDIR = ${rpath}/$comp\n";    
}
if(!$target) {
    die("Can't find ${name} in $projdef");
}

my $br = getBR($platform);
writeFile("${br}/local.mk", $localmk);

if($opt ne "") {
    $target .= "-${opt}";
} else {
    $target .= "-reconfigure";
}

if(isMac()) {
    my $rbr = getBR($platform, 0);
    runCmd("ssh dev mkdir $rpath", "creating remote directory", 1);
    runCmd("rsync -avz $repo->{path} dev:${rpath}/", "copying files");
    runCmd("scp ${br}/local.mk dev:${rbr}", "copying local.mk");
    runCmd("ssh dev \"cd ${rbr} && make ${target}\"", "Building $target");
    # copy packages to board
} else {
    runCmd("cd ${br} && make ${target}", "Building $target");
}
