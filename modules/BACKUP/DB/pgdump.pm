#!/usr/bin/perl

package BACKUP::DB::pgdump;

use strict;

our @ISA = qw(Exporter);
our @EXPORT = qw ( pg_dump );

sub pg_dump {
        my $ref = shift;
        my %options = %{$ref};
        my $pid=`echo $$`;
        my $report_log="/tmp/pgdump".$pid;
	my @exit_codes;
	my $exit;
        my $exclude_arg=exclude_parameters($options{'ex_tables'});
        chomp $report_log;
	my @databases=get_databases($options{'dbname'});
	if (scalar @databases > 0) {
		foreach(@databases){
			my $dbname=$_;
			chomp $dbname;
			my $sql_file=`date +%d%m%y`;
			chomp $sql_file;
			$sql_file=$sql_file."-".$dbname.".sql";
        		$ENV{PGPASSWORD}="$options{'pass'}";
        		$exit = system("nice -n19 ionice -n2 pg_dump -h $options{'host'} -U $options{'user'} $exclude_arg $dbname >  $options{'dir'}/$sql_file 2>> $report_log");
			push(@exit_codes,$exit);
        		if($exit==0){
                		system("gzip $options{'dir'}/$sql_file");
        		}
		}
		if(grep { $_ != 0} @exit_codes){
                        $exit=1;
                }
	}
	else{
		$exit=1;
	}
        #Returns the exit code from pg_dump process and the path to the report log file
        return $exit,$report_log;
}

sub exclude_parameters{
        my $extables = shift;
        my @extables = split(' ',$extables);
        my $string_argument="";
        if(scalar @extables > 0){
                foreach(@extables){
                        $string_argument=$string_argument."-T ".$_." ";
                }
        }
        return $string_argument;
}

sub get_databases{
	my $databases=shift;
	my @databases = split(' ',$databases);
	return @databases;
}
1;

