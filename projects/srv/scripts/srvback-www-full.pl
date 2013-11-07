#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurp;
use utf8::all;
use Encode;

use SRV::conf;
use BACKUP::conf;
use BACKUP::SMTP::sendreport;
use BACKUP::FILES::rotate;
use BACKUP::FILES::report;
use BACKUP::FILES::remotetar;
use Number::Bytes::Human qw(format_bytes);
use POSIX qw(strftime);
use File::stat;


&dump_www;

sub dump_www{
	my %remotetar_prop = (www_dir=>srvconf("www_dir"),backdir=>srvconf("www_backdir"),www_rotatedir=>srvconf("www_rotatedir"),ssh_user=>srvconf("ssh_user"),host=>srvconf("host"),www_excludedir=>srvconf("www_excludedir"));
	my $time_start= scalar localtime ();
	my ($return,$report_log) = remote_tar(\%remotetar_prop);
	my $time_end= scalar localtime ();
	my $subject;
	if ($return == 0) {
                my ($files_available,$files_rotate) = rotate(srvconf('www_rotatedir'));
		my $current_backups=get_current_backups(srvconf("www_backdir"));
                genreport($files_available,$files_rotate,$current_backups,$report_log);
                $subject="Full Backup Report SRV WWW [Success]";
        } else{
                $subject="Full Backup Report SRV WWW [Errors]";
        }

        my $report_output=encode("utf8",read_file($report_log));
        my %mail_prop = (mailto=>backconf('mailto'),body=>"Full Backup for SRV WWW begin at $time_start and finishes at $time_end.\n\n See the report messages for more details: \n $report_output",subject=>$subject);
        sendreport(\%mail_prop);
}

sub get_current_backups{
        my $dir=shift;
        chdir $dir;
        my @files=`ls`;
        my @current_backups;
        foreach(@files){
                chomp $_;
                if($_ =~ /^.*\.gz$/){
                        my $sb=stat($_);
                        my $mtime= $sb->mtime;
                        my $human_date=strftime '%Y/%m/%d %H:%M:%S',localtime $mtime;
                        my $human_size=format_bytes($sb->size);
                        push (@current_backups,[mtime=>$human_date,name=>$_,size=>$human_size]);
                }
        }
        return \@current_backups;
}
