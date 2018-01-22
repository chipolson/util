#!/usr/bin/perl -w
use strict;

use lib "$ENV{HOME}/dev/util";
use Util qw(runCmd getProject genFile $dev);

my $repo = shift;
my $project = getProject();
my $name = $project->{name};
my $path = $project->{path};

if(!-e ".cproject") {
    genFile("project_template", ".project", "PROJECT", $project->{name});
    genFile("cproject_template", ".cproject", "PROJECT", $project->{name});
}

my $cmd = "cd ${path}; git clone git\@github.com:ProjectDecibel/${repo}";
runCmd($cmd, "Cloning ${repo}");
my $branch = "colson/${name}";
runCmd("cd ${path}/${repo} && git checkout -b ${branch}", 
       "Creating branch ${branch}");
runCmd("cd ${path}/${repo} && git submodule update --init --recursive", 
       "Updating submodules");

my $buildroot_path = "$ENV{HOME}/dev/buildroot/crown-buildroot";
my $pkgs_path = "${buildroot_path}/feeds/crown-buildroot-packages/packages";
my $pkg = $repo;
if(!-e "$pkgs_path/${repo}") {
    my $cmd = "find ${buildroot_path}/feeds/crown-buildroot-packages/packages -maxdepth 2 -name \\*.mk -exec grep -l git\@github.com:ProjectDecibel/${repo}.git {} \\;";
    print "$cmd\n";
    my $pkg_path = `$cmd`;
    if($pkg_path eq "") { 
	die("Failed to locate Buildroot package for $repo.\n"); 
    }
    chomp $pkg_path;
    $pkg_path =~ m|/([^\./]*)\.mk|;
    $pkg = $1;
    
    print("Found Buildroot package $pkg for $repo.\n");   
}

my $fn = "$path/.projdef";
my $text = "";
if(open(my $rfd, "<", $fn)) {
    local $/ = undef;
    $text = <$rfd>;
    close $rfd;
}

if(!$text =~ /$repo: $pkg/) {
    $text .= "${repo}: ${pkg}\n";
    open(my $wfd, ">", $fn) || die("Can't open $fn for writing: $!");
    print $wfd $text;
    close $wfd;
}


