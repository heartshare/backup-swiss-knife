#!/usr/bin/perl

package BACKUP::FILES::remotetar;

use strict;

our @ISA = qw(Exporter);
our @EXPORT = qw ( remote_tar );

sub remote_tar {
        my $ref = shift;
        my %options = %{$ref};
        my $pid=`echo $$`;
        my $report_log="/tmp/".$pid;
        my $tar_file=`date +%d%m%y`;
	my $exclude_args=exclude_dirs($options{'www_excludedir'});
	my $exit;
        chomp $tar_file;
        chomp $report_log;
        $tar_file="full-".$tar_file.".tar";
	my $rotate_return=rotate_full_tar($options{'backdir'},$options{'www_rotatedir'},$report_log);
	if($rotate_return==0){
        	$exit = system("ssh $options{'ssh_user'}\@$options{'host'} \'nice -n19 ionice -n2 sudo tar cfP - $exclude_args -g ~/backup.snar --level=0  $options{'www_dir'} \' 2>> $report_log | cat - > $options{'backdir'}/$tar_file 2>> $report_log");
		system("scp $options{'ssh_user'}\@$options{'host'}:~/backup.snar $options{'backdir'}/full-`date +%d%m%y`.snar");
	}
	else{
		$exit=1;
	}
	
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

sub rotate_full_tar{
	my $backdir=shift;
	my $rotatedir=shift;
	my $logfile=shift;
	my $year=`date +%Y`;
	my $month=`date +%m`;
	my $week_number=`date +%U`;
	my @files=`ls $backdir`;
	my $is_new=0;
	my $tar_return=0;
	chomp $year;
        chomp $month;
        chomp $week_number;
	
	foreach(@files){
		chomp $_;
		if($_=~ /^full.*\.gz$/){
			$is_new=1;
		}
	}
	
	if(! -d "$rotatedir/$year"){
                system("mkdir $rotatedir/$year");
        }
        if(! -d "$rotatedir/$year/$month"){
                system("mkdir $rotatedir/$year/$month");
        }
	if($is_new==1){
		my $tar_name="week-".$week_number.".tar.gz";
		$tar_return=system("tar czf $rotatedir/$year/$month/$tar_name -C $backdir . 2>> $logfile");
		if($tar_return==0){
			chdir($backdir);
			system("rm *");
			return 0;
		}
		else{
			return 1;
		}
	} else{
		return 0;
	}
}
1;
