#!/bin/bash
NEW_INSTALL=0
echo -e "Enter the root directory used to store the backups\n"
read BACKPATH

if [[ ! -d $BACKPATH || -z $BACKPATH ]] ; then
	echo "directory not entered or directory doesn't exist"
else
	if [ $NEW_INSTALL -eq 1 ] ; then
		sudo aptitude update && sudo aptitude -y install postgresql-client-9.1 make gcc mysql-client-5.5
		sudo cpan -i Net::SMTP
		sudo cpan -i Email::Sender
		sudo cpan -i Email::Simple
		sudo cpan -i JSON
		sudo cpan -i Exporter
		sudo cpan -i File::Slurp
		sudo cpan -i Encode	
		sudo cpan -i utf8:all
		sudo cpan -i Number::Bytes::Human
		echo -e "Copying necessary modules to make backups:\n"
		cp -r modules/* /etc/perl/
		cp -r projects/* $BACKPATH/
		echo -e "Creating directory to store server database dumps:\n"
                mkdir $BACKPATH/srv/db
		mkdir $BACKPATH/srv/db/mysql
		mkdir $BACKPATH/srv/db/pgsql
		mkdir $BACKPATH/srv/www
		mkdir $BACKPATH/srv/www/current
		mkdir $BACKPATH/srv/www/old
		echo -e "[INSTALLATION DONE]: Please don't forget edit the configuration files:\n"
		echo -e "/etc/perl/BACKUP/backconf.json\n"
		echo -e "/etc/perl/SRV/srvconf.json\n"

	else
		echo -e "Updating modules\n"
		cp projects/srv/scripts/*  $BACKPATH/srv/scripts/
		rm -rf /etc/perl/BACKUP/DB/
		rm -rf /etc/perl/BACKUP/SMTP/
		rm -rf /etc/perl/BACKUP/FILES/
		cp -r modules/BACKUP/DB /etc/perl/BACKUP/
		cp -r modules/BACKUP/SMTP /etc/perl/BACKUP/
		cp -r modules/BACKUP/FILES /etc/perl/BACKUP/
		cp modules/BACKUP/conf.pm /etc/perl/BACKUP/conf.pm
		cp modules/SRV/conf.pm /etc/perl/SRV/conf.pm
	fi
fi
