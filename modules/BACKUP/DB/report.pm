#!/usr/bin/perl

package BACKUP::DB::report;

use strict;
use Data::Dumper;
use BACKUP::DB::report;

our @ISA = qw(Exporter);
our @EXPORT = qw ( genreport );

sub genreport {
        my ($files_available,$files_rotate,$report_log)= @_;
        open(my $fh,'>>',$report_log);
        print $fh "\n######## Files rotated ########\n";
        print $fh Dumper @$files_rotate;
        print $fh "\n######## Files Available ########\n";
        print $fh Dumper @$files_available;
        close $fh;
}
1;
