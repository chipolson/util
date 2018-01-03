
package Util;

use strict;
use Exporter qw(import);
use Cwd;
use File::Basename;

our $dev = "$ENV{HOME}/dev";
our @EXPORT_OK = qw(runCmd getProject getRepo genFile $dev);


sub runCmd {
    my ($cmd, $desc, $nodie) = @_;

    if(!defined($nodie)) {
	$nodie = 0;
    }
    print("$desc\n");
    my $ret = system($cmd);
    if((($ret >> 8) != 0) && !$nodie) {
	die("$desc failed; exiting\n");
    }
}

sub getProject {
    my ($dir) = @_;
    
    if(!defined($dir) || ($dir eq "")) {
    $dir = getcwd();
    print("dir: $dir\n");
    }

    if(!($dir =~ m|($dev/([^/]*))|)) {
	die("$dir: Not in development tree\n");
    }
    return { "path" => $1, "name" => "$2" };
}

sub getRepo {
    my ($dir) = @_;
    
    if(!defined($dir) || ($dir eq "")) {
	$dir = getcwd();
	print("dir: $dir\n");
    }

    if(!($dir =~ m|($dev/[^/]*/([^/]*))|)) {
	die("$dir: Not in repository working directory\n");
    }
    return { "path" => $1, "name" => $2 };
}

sub genFile {
    my ($template, $target, $project, $repo) = @_;

    my $template_fn = "$dev/util/$template";
    local $/ = undef;
    open(my $template_fd, "<", $template_fn) || die("Can't open $template: $!");
    my $text = <$template_fd>;
    close($template_fd);

    $text =~ s/PROJECT/$project/g;
    $text =~ s/REPO/$repo/g;

    open(my $target_fd, ">", $target)  || die("Can't open $target file: $!");
    print $target_fd $text;
    close($target_fd);
}



