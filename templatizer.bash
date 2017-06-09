#!/usr/bin/env/bash

eval $(cat master.conf | sed 's/^/export /')

################## davmail section #######################

#creating the davmail conf file
cat << SOMETHINGUNLIKELY > ~/.davmail.properties
#DavMail settings
davmail.allowRemote=false
davmail.bindAddress=
davmail.caldavAlarmSound=
davmail.caldavEditNotifications=false
davmail.caldavPastDelay=90
davmail.caldavPort=1080
davmail.clientSoTimeout=
davmail.defaultDomain=
davmail.disableGuiNotifications=false
davmail.disableUpdateCheck=false
davmail.enableEws=true
davmail.enableKeepAlive=false
davmail.enableKerberos=false
davmail.enableProxy=false
davmail.folderSizeLimit=0
davmail.forceActiveSyncUpdate=false
davmail.imapAutoExpunge=true
davmail.imapIdleDelay=
davmail.imapPort=1143
davmail.keepDelay=30
davmail.ldapPort=1389
davmail.logFilePath=/home/$ADUSER/davmail.log
davmail.logFileSize=1MB
davmail.noProxyFor=
davmail.popMarkReadOnRetr=false
davmail.popPort=1110
davmail.proxyHost=
davmail.proxyPassword=
davmail.proxyPort=
davmail.proxyUser=
davmail.sentKeepDelay=90
davmail.server=true
davmail.showStartupBanner=true
davmail.smtpPort=1025
davmail.smtpSaveInSent=true
davmail.ssl.clientKeystoreFile=
davmail.ssl.clientKeystorePass=
davmail.ssl.clientKeystoreType=
davmail.ssl.keyPass=
davmail.ssl.keystoreFile=
davmail.ssl.keystorePass=
davmail.ssl.keystoreType=
davmail.ssl.nosecurecaldav=false
davmail.ssl.nosecureimap=false
davmail.ssl.nosecureldap=false
davmail.ssl.nosecurepop=false
davmail.ssl.nosecuresmtp=false
davmail.ssl.pkcs11Config=
davmail.ssl.pkcs11Library=
davmail.url=https\://$OWAADDRESS
davmail.useSystemProxies=false
log4j.logger.davmail=WARN
log4j.logger.httpclient.wire=WARN
log4j.logger.org.apache.commons.httpclient=WARN
log4j.rootLogger=WARN

SOMETHINGUNLIKELY

#creating service to start davmail at boot
sudo cat << SOMETHINGUNLIKELY > /usr/lib/systemd/system/davmail.service
[Unit]
Description=run offlineimap sync

[Service]
User=$ADUSER
Environment=CONFIG_FILE_PATH=/home/$ADUSER/.davmail.properties
ExecStart=/usr/bin/davmail
SOMETHINGUNLIKELY

#enabling and starting davmail service
sudo systemctl enable davmail.service
sudo systemctl start davmail.service

################## offlineimap section #####################

#creating the offlineimap conf file
cat << SOMETHINGUNLIKELY > ~/.offlineimaprc
[general]
accounts = $ACCOUNTNAME

[Account $ACCOUNTNAME]
localrepository = Work-Local
remoterepository = Work-Remote

[Repository Work-Local]
type = Maildir
localfolders = $MAILDIR

[Repository Work-Remote]
type = IMAP
SSL = no
remotehost = localhost
remoteport = 1143
#cert_fingerprint =
maxconnections = 3
remoteuser = $ADUSER@$ADDOMAIN.$ADTLD
remotepass = $ADPASSWORD
holdconnectionopen = true
keepalive = 120
realdelete = yes

# Folders to skip during sync. (You can set up which ones your self, this is just an example)
#folderfilter = lambda folder: folder in ['INBOX', 'Sent']

SOMETHINGUNLIKELY

#creating offlineimap sync systemd service
sudo cat << SOMETHINGUNLIKELY > /usr/lib/systemd/system/offlineimap.service
[Unit]
Description=run offlineimap sync

[Service]
User=$ADUSER
ExecStart=/usr/bin/offlineimap
SOMETHINGUNLIKELY

#copying the offlineimap timer file
sudo cp offlineimap/offlineimap.timer /usr/lib/systemd/system/offlineimap.timer
#enabling the timer to run (not starting until end of script)
sudo systemctl enable offlineimap.timer

################## mutt section #########################

#creating the mutt config file
cat << SOMETHINGUNLIKELY > ~/.muttrc

set spoolfile=~/$MAILDIR/INBOX

# needed for maildir format
set mbox_type=Maildir
set folder=$MAILDIR
set sendmail="/usr/bin/msmtp"
my_hdr From: "$ADUSER@$ADDOMAIN.$ADTLD"

# setting theme
source ~/.mutt/themes/comidia

# set mailcap file for handling different filetypes
# text vs html vs image, etc
set mailcap_path        = ~/.mutt/mailcap                # enabling html read
# set LDAP query command
set query_command="~/.mutt/mutt-ldap.pl '%s'"
# view some some items inline
auto_view text/html                                      # view html automatically
auto_view text/calendar                                  # view ics files via mutt_ics python application

# configuration for display format
set index_format="%3C %Z %[!%H:%M %m.%d] %-17.17F (%5c) %s"

# Generally making mutt more vimlike
# vim style keymappings
bind index j next-entry
bind index k previous-entry
bind index J next-thread
bind index K previous-thread

bind index / search
#bind index ? search-reverse
bind index n search-next
bind index N search-opposite

bind index gg first-entry
bind index G last-entry

bind index r reply
bind index g imap-fetch-mail
bind index R group-reply

# Pager
# vim style keymappings
bind pager j next-line
bind pager k previous-line
bind pager / search
bind pager ? search-reverse
bind pager n search-next
bind pager N search-opposite
unset markers

SOMETHINGUNLIKELY

#creating the mutt LDAP querying script
cat << SOMETHINGUNLIKELY > ~/.mutt/mutt-ldap.pl
#! /usr/bin/perl -Tw

# 2005-02-24: Fixed for AD/Exchange 2003 & Unicode characters,
# anders@bsdconsulting.no If you find this script useful, let me know. :-)
#
# 2000/2001: Original version obtained from Andreas Plesner Jacobsen at
# World Online Denmark. Worked for me with Exchange versions prior to Exchange
# 2000.
#
# Use it with mutt by putting in your .muttrc:
# set query_command = "/home/user/bin/mutt-ldap.pl '%s'"
#
# Then you can search for your users by name directly from mutt. Press ^t
# after having typed parts of the name. Remember to edit configuration
# variables below.

use strict;
use Encode qw/encode decode/;
use vars qw { \$ldapserver \$domain \$username \$password \$basedn };

# --- configuration ---
\$ldapserver = "$ADSERVER.$ADDOMAIN.$ADTLD";
\$domain = "$ADDOMAIN";
\$username = "$ADUSER";
\$password = "$ADPASSWORD";
\$basedn = "ou=$ADBASEDN,dc=$ADDOMAIN,dc=$ADTLD";
# --- end configuration ---

#my \$search=shift;
my \$search=encode("UTF-8", join(" ", @ARGV));

if (!\$search=~/[\.\*\w\s]+/) {
	print("Invalid search parameters\n");
	exit 1;
}

use Net::LDAP;

my \$ldap = Net::LDAP->new(\$ldapserver) or die "$@";

\$ldap->bind("$ADDOMAIN\\\\$ADUSER", password=>\$password);

my \$mesg = \$ldap->search (base => \$basedn,
                          filter => "(|(cn=*\$search*) (rdn=*\$search*) (uid=*\$search*) (mail=*\$search*))",
			  attrs => ['mail','cn']);

\$mesg->code && die \$mesg->error;

print(scalar(\$mesg->all_entries), " entries found\n");

foreach my \$entry (\$mesg->all_entries) {
	if (\$entry->get_value('mail')) {
		print(\$entry->get_value('mail'),"\t",
		      decode("UTF-8", \$entry->get_value('cn')),"\tFrom Exchange LDAP database\n");
		}
	}
\$ldap->unbind;

SOMETHINGUNLIKELY

#copying the mutt theme file
cp mutt/comida ~/.mutt/comida
#copying the mutt mailcap file (tells mutt how to open files)
cp mutt/mailcap ~/.mutt/mailcap
#copying the mutt xdg-open script
cp mutt/mutt-open.bash ~/.mutt/mutt-open

############### msmtp section ###################

#creating the msmtp conf file
cat << SOMETHINGUNLIKELY > ~/.msmtprc
# Set default values for all following accounts.
defaults
auth              on
tls               off
logfile           ~/.msmtp.log

# LFO
account           LFO
host              localhost
port              1025
protocol          smtp
from              $ADDOMAIN\\$ADUSER
auth              login
user              $ADDOMAIN\\$ADUSER
password          $ADPASSWORD

account default : LFO

SOMETHINGUNLIKELY

#first offlineimap sync should be run in one thread mode as below
offlineimap -d 1
sudo systemctl start offlineimap.timer
