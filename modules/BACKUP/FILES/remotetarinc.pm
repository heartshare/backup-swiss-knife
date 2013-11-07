#!/usr/bin/perl

package BACKUP::FILES::remotetarinc;

use strict;

our @ISA = qw(Exporter);
our @EXPORT = qw ( remote_tar_inc );

sub remote_tar_inc {
        my $ref = shift;
        my %options = %{$ref};
        my $pid=`echo $$`;
        my $report_log="/tmp/".$pid;
        my $tar_file=`date +%d%m%y`;
	my $exclude_args=exclude_dirs($options{'www_excludedir'});
        chomp $tar_file;
        chomp $report_log;
        $tar_file="incremental-".$tar_file.".tar";
        my $exit = system("ssh $options{'ssh_user'}\@$options{'host'} \'nice -n19 ionice -n2 sudo tar cfP - $exclude_args -g ~/backup.snar $options{'www_dir'} \' 2> $report_log | cat - > $options{'backdir'}/$tar_file 2>> $report_log");
	system("scp $options{'ssh_user'}\@$options{'host'}:~/backup.snar $options{'backdir'}/incremental-`date +%d%m%y`.snar");
	if($exit==0){
		system("gzip $options{'backdir'}/$tar_file");
	}
        #Returns the exit code from pg_dump process and the path to the report log file
        return $exit,$report_log;
}

sub exclude_dirs{
	my $exdirs = shift;
        my @exdirs = split(' ',$exdirs);
        my $string_argument="";
        if(scalar @exdirs > 0){
                foreach(@exdirs){
                        $string_argument=$string_argument."--exclude \"".$_."\" ";
                }
        }
        return $string_argument;
}
1;
