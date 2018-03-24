#!/usr/bin/perl -w
use strict;

use lib "$ENV{HOME}/dev/util";
use Util qw(runCmd getProject getRepo genFile readFile writeFile getBR $dev);

my $name = shift;
my $branch = shift;
my $project = getProject();
my $projectname = $project->{name};
my $path = $project->{path};

if(!-e "$path/.project" || !-e "$path/.cproject") {
  genFile("project_template", "$path/.project", "PROJECTNAME", $projectname);
  genFile("cproject_template", "$path/.cproject", "PROJECTNAME", $projectname);
  genFile("pyproject_template", "$path/.pydevproject", "PROJECTNAME", $projectname);
  genFile("notes_template", "$ENV{HOME}/dev/notes/${project}",  "PROJECTNAME", $projectname);
}

if(!defined($name)) {
  die("No Git repository specified.");
}

runCmd("git clone git\@github.com:ProjectDecibel/${name}", "Cloning $name");
my $repo = getRepo("$project->{path}/${name}");
if(defined($branch)) {
    runCmd("cd $repo->{path} && git checkout origin/${branch}", "Switching to branch ${branch}");
}

my $mybranch = "colson/${projectname}";
runCmd("cd $repo->{path} && git submodule update --init --recursive", "Updating submodules");
runCmd("cd $repo->{path} && git checkout -b $mybranch", "Creating branch ${mybranch}");

my $projdef = "${path}/.projdef";
my $platform = "";
my $text = "";
if(-e $projdef)  {
    $text = readFile($projdef);
    $test =~ /PLATFORM: (.*)/;
    $platform = $1;
} else {
    while($platform eq "") {
	print("Platform? ");
	my $answer = <SRDIN>;
	if(($answer eq "tcastle") || ($answer eq "shield")) {
	    $platform = $answer;
	}
    }
}

if(!($text =~ /${name}.*/)) {
    print("Looking for ${name}\n");
    my $br = getBR($platform);
    my $pkgdir = "${br}/feeds/crown-buildroot-packages/packages";
    my $pkg = $name;
    if(!-e "${pkgdir}/${pkg}") {
	my $mk = `find ${pkgdir} -maxdepth 2 -name \*.mk -exec grep -l ProjectDecibel/${name}.git {} \\;`;
	if(($mk =~ m|/([^/\.]*)\.mk|g)) {
	    $pkg = $1;
	}
    }
    $text .= "${name}: ${pkg}\n";
    writeFile($projdef, $text);
}



