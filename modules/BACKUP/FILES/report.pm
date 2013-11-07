#!/usr/bin/perl

package BACKUP::FILES::report;

use strict;
use Data::Dumper;
use BACKUP::FILES::report;

our @ISA = qw(Exporter);
our @EXPORT = qw ( genreport );

sub genreport {
        my ($files_available,$files_rotate,$current_backups,$report_log)= @_;
        open(my $fh,'>>',$report_log);
        print $fh "\n######## Files rotated ########\n";
        print $fh Dumper @$files_rotate;
        print $fh "\n######## Current Backups ########\n";
        print $fh Dumper @$current_backups;
	print $fh "\n######## Old Backups ########\n";
	print $fh Dumper @$files_available;
        close $fh;
}
1;
