#!/usr/bin/perl

package BACKUP::FILES::rotate;

use strict;
use BACKUP::conf;
use File::stat;
use Time::Seconds;
use Time::Piece;
use POSIX qw(strftime);
use Number::Bytes::Human qw(format_bytes);
our @ISA = qw(Exporter);
our @EXPORT = qw ( rotate );

sub rotate{
	my $dir= shift;
	chdir $dir;
	my @files_deleted;
	my @files_available;
	my $current_time=time();
	my @year_dirs=`ls`;
	my $retention=backconf('retention');
	$retention=ONE_DAY*$retention;
	foreach(@year_dirs){
		chomp $_;
		my $year=$_;
		chdir $dir."/".$year;
		my @month_dirs=`ls`;
		foreach(@month_dirs){
			chomp $_;
			my $month=$_;
			chdir $dir."/".$year."/".$month;
			my @files=`ls`;
			foreach(@files){
				chomp $_;
				if($_ =~ /^.*\.gz$/){
					my $sb=stat($_);
					my $mtime= $sb->mtime;
					my $dtime=$current_time-$mtime;
					my $human_date=strftime '%Y/%m/%d %H:%M:%S',localtime $mtime;
		       	                my $human_size=format_bytes($sb->size);
	
					if($dtime>$retention){
						push (@files_deleted,[mtime=>$human_date,name=>$_,size=>$human_size]);
						system("rm $_");
					}
					else{
						push(@files_available,[mtime=>$human_date,name=>$_,size=>$human_size]);
					}
				}
			}
		}
	}
	return (\@files_available,\@files_deleted);
}
1;
