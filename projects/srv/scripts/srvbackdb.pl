#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurp;
use utf8::all;
use Encode;

use SRV::conf;
use BACKUP::conf;
use BACKUP::SMTP::sendreport;
use BACKUP::DB::mysqldump;
use BACKUP::DB::pgdump;
use BACKUP::DB::rotate;
use BACKUP::DB::report;

&dump_mysql;
&dump_pgsql;

sub dump_mysql{
	my $date=`date +%d%m%y`;
	chomp $date;
	my $maindir=srvconf('mysql_dir');
	my $backdir=$maindir."/$date";
	system("mkdir $backdir");
	my %db_prop = (host=>srvconf('host'),user=>srvconf('mysql_user'),pass=>srvconf('mysql_pass'),dir=>$backdir,ex_db=>srvconf('mysql_exclude_db'));
	my $time_start= scalar localtime ();
	my ($return,$report_log) = mysqldump(\%db_prop);
	my $time_end= scalar localtime ();
	my $subject;

	my $tar_return=system("tar czvf $maindir/$date.tar.gz $backdir");

	if ($tar_return==0){
		system("rm -rf $backdir/");
	}
	if ($return == 0) {
        	my ($files_available,$files_rotate) = rotate(srvconf('mysql_dir'));
        	genreport($files_available,$files_rotate,$report_log);
        	$subject="Backup Report SRV MySQL DB [Success]";
	} else{
        	$subject="Backup Report SRV MySQL DB [Errors]";
	}

	my $report_output=encode("utf8",read_file($report_log));
	my %mail_prop = (mailto=>backconf('mailto'),body=>"Backup for SRV MySQL DB begin at $time_start and finishes at $time_end.\n\n See the report messages for more details: \n $report_output",subject=>$subject);
	sendreport(\%mail_prop);
}

sub dump_pgsql{
	my $date=`date +%d%m%y`;
        chomp $date;
        my $maindir=srvconf('pgsql_dir');
        my $backdir=$maindir."/$date";
        system("mkdir $backdir");
        my %db_prop = (host=>srvconf('host'),user=>srvconf('pgsql_user'),pass=>srvconf('pgsql_pass'),dir=>$backdir,dbname=>srvconf('pgsql_databases'),ex_tables=>srvconf('pgsql_extables'));
        my $time_start= scalar localtime ();
        my ($return,$report_log) = pg_dump(\%db_prop);
        my $time_end= scalar localtime ();
        my $subject;

        my $tar_return=system("tar czvf $maindir/$date.tar.gz -C $backdir .");

        if ($tar_return==0){
                system("rm -rf $backdir/");
        }
        if ($return == 0) {
                my ($files_available,$files_rotate) = rotate(srvconf('pgsql_dir'));
                genreport($files_available,$files_rotate,$report_log);
                $subject="Backup Report SRV PGSQL DB [Success]";
        } else{
                $subject="Backup Report SRV PGSQL DB [Errors]";
        }

        my $report_output=encode("utf8",read_file($report_log));
        my %mail_prop = (mailto=>backconf('mailto'),body=>"Backup for SRV PGSQL DB begin at $time_start and finishes at $time_end.\n\n See the report messages for more details: \n $report_output",subject=>$subject);
        sendreport(\%mail_prop);
}
