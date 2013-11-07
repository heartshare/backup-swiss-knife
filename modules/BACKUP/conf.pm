#! /usr/bin/perl

package BACKUP::conf_parser;

use strict;
use JSON;
use Exporter;
use File::Slurp;
use utf8::all;
use Encode;
our @ISA = qw(Exporter);
our @EXPORT = qw ( backconf );

sub backconf {
        my $option = shift;
	my $file = '/etc/perl/BACKUP/backconf.json';
        my $value;
        my $config=decode_json(encode("utf8",read_file($file))) || die;
        $value=$$config{$option};
        return $value;
}
1;
