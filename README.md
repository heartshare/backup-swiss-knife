DESCRIPTION
==================

Perl modules and scripts to make tar backups and dumps from MySQL and PostgreSQL from remote host. The tar backups is supported to make full backups and incremental one, for each full backup will rotate the current one and rotate to other directory. All the backups from tar, mysqldump and pg_dump are stored in filesystem with a maximum days configured on the script, so after this days will be deleted from the system. Each time that the backup finishes, will send a mail report with the time that take the backup, the current backups available on the system and if there are any backup rotated.
For more information or any suggestions, please contacte me on: ivan@opentodo.net

INSTALLATION
==================

Change the value on install.sh script of NEW_INSTALL to 1 if is a new installation and execute ./install.sh script, by default just update the perl modules and scripts.

CONFIGURATION
==================

- Edit main backup configuration file:

	/etc/perl/BACKUP/backconf.json

	Parameters:
	
	- mailto: mail address to send backup reports.
	- retention: number of days the backup will keep stored,
	after this days the backup will be deleted.
	

- Edit the configuration file: 
	/etc/perl/SRV/srvconf.json 

	The scripts dump all the databases for mysql by default and exclude the databases from the mysql_exclude_db parameter. For the postgresql dump only backups the databases entered on the pgsql_databases parameter. For the backups for websites, we need to generate one full backup first and then incremental backups for every day, so each time that a full backup it's executed will create a tar file named weekn-ddmmyy.tar.gz with the current full backup with all the incrementals and will me moved to the old/ directory where will be stored until the retention day configured. to restore a backup we've to restore the full backup first and then all the incrementals next.
The options for this configuration file are:

	- host : ip address of the server.
	- ssh_user : user used to connect to the server. It's needed to copy the public key to authorized_keys file to connect without password prompt and allow to run tar with sudo without password.
	- mysql_user : user to connect to mysql. Privileges needed for all the databases are (SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER).
	- mysql_pass : password to connect to mysql.
	- mysql_dir : directory when will be stored the mysql backups.
	- mysql_exclude_db : by default will be dumped all the databases, this parameter is used to exclude which databases will not be dumped.
	- pgsql_user : user to connect to postgresql. This user has to be a superuser.
	- pgsql_pass : password to connect to postgresql.
	- pgsql_databases : databases that will be dumped, separated by a space.
	- pg_extables : tables to exclude from the dump, separated by a space.
	- pgsql_dir : directory when will be stored the postgresql backups.
	- www_backdir : directory when the websites backup will be stored.
	- www_rotatedir : directory when the rotated backup webistes will be stored.
	- www_excludedir : directories excluded from the websites backup.
	- www_dir : directory in host4 where are stored the websites.

- Add cron tasks for the backup scripts, located in:

	$BACKPATH/srv/scripts/srvbackdb.pl
	$BACKPATH/srv/scripts/srvback-www-full.pl (one time per week).
	$BACKPATH/srv/scripts/srvback-www-incremental.pl (every day except the full backup day).

And declare the USER variable for each cron (used to send mails from the user).

Example default cron:

#Cron tasks running as root
USER=root
# m h  dom mon dow user  command
# PGSQL & MySQL Backup
30 1 * * * root /mnt/backups/srv/scripts/srvbackdb.pl
# Incremental backup (from monday to saturday).
30 2 * * 1-6 root /mnt/backups/srv/scripts/srvback-www-incremental.pl
# New Full backup (each sunday) and rotate the old full backup with all the incrementals.
30 2 * * 0 root /mnt/backups/srv/scripts/srvback-www-full.pl

Add new server to backup
==================

- Create a new directory with the name of the project under /etc/perl/ directory and copy the json file srvconf.json and conf.pm, from the SRV template. For example in this case we'll use the name SRV2:
	/etc/perl/SRV2/srv2conf.json
	/etc/perl/SRV2/conf.pm
	
Change the parameters from the json file and from the conf.pm is needed to change the $file variable to parse the new configuration file, the package name and the name of the function.

- Create a new directory for the scripts, in this example we use the directory base /mnt/backups:
	- /mnt/backups/srv2/scripts/

- Change the script to use the new module of Backup created.

- Add the crontasks and create the directories needed to store the backups.

	
