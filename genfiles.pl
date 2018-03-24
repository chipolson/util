#!/usr/bin/perl -w
use strict;

use lib "$ENV{HOME}/dev/util";
use Util qw(runCmd getProject getRepo genFile readFile writeFile $dev $br);

my $project = getProject();
my $projectname = $project->{name};
my $path = $project->{path};

genFile("project_template", "$path/.project", "PROJECTNAME", $projectname);
genFile("cproject_template", "$path/.cproject", "PROJECTNAME", $projectname);
genFile("pyproject_template", "$path/.pydevproject", "PROJECTNAME", $projectname);

