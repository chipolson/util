
package Util;

use strict;
use Exporter qw(import);
use Cwd;
use File::Basename;

our $dev = "$ENV{HOME}/dev";
our $br = "$ENV{HOME}/dev/buildroot";

our @EXPORT_OK = qw(runCmd getProject getRepo isMac genFile startDev readFile writeFile $dev getBR);

sub startDev {
  if(!`VBoxManage list runningvms` =~ /"Dev"/g) { 
    runCmd("VBoxManage startvm Dev", "Starting Dev VM, please wait...");
  }
}

sub isMac {
  return ($ENV{HOME} =~ m|/Users/.*|);
}

sub readFile {
  my ($fn) = @_;
  
  open(my $fd, "<", $fn) || die("Can't open ${fn} for reading: $!");
  local $/ = "";
  my $text = <$fd>;
  close $fd;
  return $text;
}

sub writeFile {
  my ($fn, $text) = @_;

  open(my $fd, ">", $fn) || die("Can't open ${fn} for writing: $!");
  print $fd $text;
  close $fd;
}

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

    my $project = getProject($dir);
    if(!($dir =~ m|($dev/[^/]*/([^/]*))|)) {
	die("$dir: Not in repository working directory\n");
    }
    return { "path" => $1, "name" => $2, "project" => $project };
}

sub genFile {
    my ($template, $target, $key, $repl) = @_;

    my $template_fn = "$dev/util/$template";
    local $/ = undef;
    open(my $template_fd, "<", $template_fn) || die("Can't open $template: $!");
    my $text = <$template_fd>;
    close($template_fd);

    $text =~ s/$key/$repl/g;

    open(my $target_fd, ">", $target)  || die("Can't open $target file: $!");
    print $target_fd $text;
    close($target_fd);
}

sub getBR {
    my ($platform, $mac) = @_;

    if(!defined($mac)) {
	$mac = isMac()? 1 : 0;
    }
       
    my %br_table = (
	"tcastle" => [ "$ENV{HOME}/dev/buildroot", "$ENV{HOME}/dev/buildroot" ],
	"shield" => [ "/opt/buildroot_shield", "$ENV{HOME}/dev/buildroot" ]
    );
    return $br_table{$platform}[$mac];
}

