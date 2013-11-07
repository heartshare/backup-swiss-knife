#!/usr/bin/perl

package BACKUP::DB::mysqldump;

use strict;

our @ISA = qw(Exporter);
our @EXPORT = qw ( mysqldump );

sub mysqldump {
        my $ref = shift;
        my %options = %{$ref};
	my $exit;
        my $pid=`echo $$`;
	my @exit_codes;
        my $report_log="/tmp/mysqldump".$pid;
	chomp $report_log;
	my @databases=get_databases($options{'user'},$options{'pass'},$options{'host'},$options{'ex_db'},$report_log);
	if (scalar @databases > 0) {
		foreach (@databases){
        		my $sql_file=`date +%d%m%y`;
        		chomp $sql_file;
        		$sql_file=$sql_file."-".$_.".sql";
        		$exit = system("nice -n19 ionice -n2 mysqldump --databases $_ -u $options{'user'} -h $options{'host'} --password=$options{'pass'} > $options{'dir'}/$sql_file 2>> $report_log");
			if($exit==0){
                		system("gzip $options{'dir'}/$sql_file");
        		}
			push(@exit_codes,$exit);
		}
		if(grep { $_ != 0} @exit_codes){
			$exit=1;
		}
	}
	else{
		$exit=1;
	}
	print $exit;
        #Returns the exit code from pg_dump process and the path to the report log file
        return $exit,$report_log;
}

sub get_databases{
	my $user=shift;
	my $password=shift;
	my $host=shift;
	my $exclude=shift;
	my $report_log=shift;
	$exclude =~ tr / /\|/;
	my $databases=`mysql -u $user -h $host --password=$password -e 'show databases' -s --skip-column-names 2>> $report_log | egrep -v \"^($exclude)\$\"`;
	my @databases= split(/\n/,$databases);
	
	return @databases;
}
1;
