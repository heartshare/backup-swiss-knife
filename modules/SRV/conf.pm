#! /usr/bin/perl

package SRV::conf;

use strict;
use JSON;
use Exporter;
use File::Slurp;
use utf8::all;
use Encode;
our @ISA = qw(Exporter);
our @EXPORT = qw ( srvconf );

sub srvconf {
        my $option = shift;
	my $file = '/etc/perl/SRV/srvconf.json';
        my $value;
        my $config=decode_json(encode("utf8",read_file($file))) || die;
        $value=$$config{$option};
        return $value;
}
1;
