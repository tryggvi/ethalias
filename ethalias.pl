#!/usr/bin/perl -w
### Easy way to create eth alias for Centos/RHEL
# Author: Tryggvi Farestveit <tryggvi@ok.is>
# License: GPLv2

use strict;
use Getopt::Long;

## Settings
my $base = "/etc/sysconfig/network-scripts";


## Global variables
my ($o_verb, $o_help, $o_eth, $o_ip, $o_mask);

## Funtions
sub check_options {
	Getopt::Long::Configure ("bundling");
	GetOptions(
		'v'     => \$o_verb,            'verbose'	=> \$o_verb,
		'h'     => \$o_help,            'help'	=> \$o_help,
		'e:s'     => \$o_eth,            'eth:s'	=> \$o_eth,
		'i:s'     => \$o_ip,            'ip:s'	=> \$o_ip,
		'm:s'     => \$o_mask,            'mask:s'	=> \$o_mask,
	);

	if(defined ($o_help)){
		help();
		exit 1;
	}

	if(!defined($o_ip) || !defined($o_mask) || !defined($o_eth)){
		help();
		exit 1;
	}
}

sub CreateAlias($$$){
	my ($eth, $ip, $mask) = @_;

	my @IpSplit = split("[\.]", $ip);
	my $IpLastPart = $IpSplit[3];

	my $NewEth = $eth.":".$IpLastPart;
	my $filename = $base."/"."ifcfg-".$NewEth;

	if(-e $filename){
		print "$filename already exists\n";
		exit 1;
	} else {
		print "Writing to $filename\n";
		open(C, ">$filename");
		print C <<EOF;
DEVICE=$NewEth
BOOTPROTO=none
NM_CONTROLLED=yes
ONBOOT=yes
TYPE=Ethernet
IPADDR=$ip
NETMASK=$mask
USERCTL=no

EOF
		close(C);

	}
}

sub help() {
	print "$0\n";
        print <<EOT;
-e ETH, --eth ETH
	Base nic name ex. eth0
-i IP, --ip IP
	IP address
-m MASK, --netmask MASK
	Netmask
-v, --verbose
        print extra debugging information
-h, --help
	print this help message
EOT
}

sub print_usage() {
	print "Usage: $0 [-v] ]\n";
}

## Main
check_options();


if(!-e $base){
	print "Directory $base does not exists\n";
	exit 1;
}

CreateAlias($o_eth, $o_ip, $o_mask);

