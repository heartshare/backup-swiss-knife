#! /usr/bin/perl

package BACKUP::SMTP::sendreport;

use strict;
use Net::SMTP;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();
use Email::Simple ();
use Email::Simple::Creator ();

our @ISA = qw(Exporter);
our @EXPORT = qw (sendreport );

my $smtpserver = 'localhost';
my $smtpport = 25;
my $from = $ENV{USER}.'@backup-server.local';

sub sendreport {
	my $ref = shift;
        my %mail_prop = %{$ref};
	my $subject = $mail_prop{subject};
	my $body = $mail_prop{body};
	my $to = $mail_prop{mailto};
	my $transport = Email::Sender::Transport::SMTP->new({
  		host => $smtpserver,
		port => $smtpport,
		from => $from,
	});

	my $email = Email::Simple->create(
		header  => [
    			To      => $to,
    			From    => $from,
    			Subject => $subject,
  		],
  		body => $body,
	);

	sendmail($email, { transport => $transport });
}
1;

