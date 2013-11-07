#!/usr/bin/perl

package BACKUP::DB::pgbasebackup;

use strict;

our @ISA = qw(Exporter);
our @EXPORT = qw ( pg_basebackup );

sub pg_basebackup {
        my $ref = shift;
	my %options = %{$ref};
	my $pid=`echo $$`;
	my $errlg="/tmp/".$pid;
	chomp $errlg;
	$ENV{PGPASSWORD}="$options{'pass'}";
	my $exit = system("nice -n19 ionice -n2 pg_basebackup  -h $options{'host'} -U $options{'user'} -l \"Full backup\" -z -Z 9 -F tar -D $options{'dir'}/ 2> $errlg");
	#Returns the exit code from pg_dump process and the path to the error log file
	return $exit,$errlg;
}
1;
