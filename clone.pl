#!/usr/bin/perl -w
use strict;

use lib "$ENV{HOME}/dev/util";
use Util qw(runCmd getProject genFile $dev);

my $repo = shift;
my $project = getProject();
my $name = $project->{name};
my $path = $project->{path};

my $cmd = "cd $project->{path}; git clone git\@github.com:ProjectDecibel/${repo}";
print("$cmd\n");
runCmd($cmd, "Cloning $repo");

genFile("project_template", ".project", $project->{name}, $repo);
genFile("cproject_template", ".cproject", $project->{name}, $repo);

