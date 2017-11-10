#!/bin/sh

#used later for getting the user info
questions() {
  echo "What is the name of your AD server sans the domain name. ex DC01, NOT DC01.blah.com"
  read ADSERVER
  echo "What is your domain name sans the top level? ex blah, NOT blah.net"
  read ADDOMAIN
  echo "What is the top level domain, ex com or net or org"
  read ADTLD
  echo "what is your username sans the domain? ex jdoe NOT jdoe@blah.com"
  read ADUSER
  echo "What is your AD password?"
  read ADPASSWORD
  echo "What is the name of the base DN where the users are kept? (you may need to ask your friendly Admin)"
  read ADBASEDN
  echo "What name do you want to give the mail account?"
  read ACCOUNTNAME
  echo "What is the web endpoint of the exchange server? ex owa.domain.com/ews/exchange.asmx"
  read OWAADDRESS

  answers
}
#used later for creating a master configuration file
answers () {
  echo "AD SERVER=$ADSERVER"
  echo "AD DOMAIN=$ADDOMAIN"
  echo "AD Top Level Domain=$ADTLD"
  echo "AD User=$ADUSER"
  echo "AD Password=$ADPASSWORD"
  echo "Base org DN=$ADBASEDN"
  echo "Account Name=$ACCOUNTNAME"
  echo "Exchange Endpoint=$OWAADDRESS"
  echo "echo does this look correct?"
  read ANSWER
  case $ANSWER in
    [Yy]*)
      cat << SOMETHINGUNLIKELY > /home/$ENDUSER/master.conf
ADSERVER="$ADSERVER"
ADDOMAIN="$ADDOMAIN"
ADTLD="$ADTLD"
ADUSER="$ADUSER"
ADPASSWORD="$ADPASSWORD"
ADBASEDN="$ADBASEDN"
ACCOUNTNAME="$ACCOUNTNAME"
OWAADDRESS="$OWAADDRESS"
SOMETHINGUNLIKELY
      ;;
#      exit;;
    [Nn]*)
      questions
  esac
}
make_templates () {
#creating the davmail conf file
  cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.davmail.properties
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
davmail.logFilePath=/home/$ENDUSER/davmail.log
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
#creating the offlineimap conf file
  cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.offlineimaprc
[general]
accounts = $ACCOUNTNAME
maxsyncaccounts = 1

[Account $ACCOUNTNAME]
localrepository = Work-Local
remoterepository = Work-Remote
autorefresh = 0.5
quick = 10

[Repository Work-Local]
type = Maildir
localfolders = ~/Maildir/$ACCOUNTNAME

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
keepalive = 60
realdelete = yes

# Folders to skip during sync. (You can set up which ones your self, this is just an example)
#folderfilter = lambda folder: folder in ['INBOX', 'Sent']

SOMETHINGUNLIKELY
#creating the mutt config file
  cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.muttrc

# $ACCOUNTNAME account
source ~/.mutt/$ACCOUNTNAME

# needed for maildir format
set mbox_type=Maildir
set sendmail="/usr/bin/msmtp"
my_hdr From: "$ADUSER@$ADDOMAIN.$ADTLD"

# setting theme
source ~/.mutt/comidia

# set mailcap file for handling different filetypes
# text vs html vs image, etc
set mailcap_path        = ~/.mutt/mailcap                     # enabling html read
set query_command="/bin/sh ~/.mutt/ldapsearch.sh '%s'"      # ldapsearch script
# view some some items inline
auto_view text/html                                       # view html automatically
auto_view text/calendar                                   # view ics files via mutt_ics python application

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
#creating the mutt account file
  cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.mutt/$ACCOUNTNAME

set spoolfile=~/Maildir/$ACCOUNTNAME/INBOX
set folder=~/Maildir/$ACCOUNTNAME
set sendmail="/usr/bin/msmtp"
set postponed = "~/Maildir/$ACCOUNTNAME/Drafts"
my_hdr From: "$ADUSER@$ADDOMAIN.$ADTLD"

SOMETHINGUNLIKELY
#comida theme info
	cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.mutt/comidia
## This theme is from H. D. Lee
#
# This colors file was originally taken from Rosenfeld's
# Modified slightly.
# Running aterm with:
# aterm +sb -geometry 80x60 -bg papayawhip -fg darkgreen -e mutt
#
# color terminals:
# (default, white, black, green, magenta, blue, cyan, yellow, red)
# (bright...)
# (color1,color2,...,colorN-1)
#
# object foreground background
#
color normal default default # normal text
color indicator brightcyan black # actual message
color tree brightmagenta default # thread arrows
color status cyan black # status line
color error brightcyan default # errors
color message cyan default # info messages
color signature red default # signature
color attachment green default # MIME attachments
color search brightyellow red # search matches
color tilde brightmagenta default # ~ at bottom of msg
color markers red default # + at beginning of wrapped lines
color hdrdefault blue default # default header lines
color bold red default # hiliting bold patterns in body
color underline green default # hiliting underlined patterns in body
color quoted cyan default # quoted text
color quoted1 green default
color quoted2 red default
color quoted3 magenta default
color quoted4 blue default
color quoted5 blue default
#
# object foreground backg. RegExp
#
color header red default "^(from|subject):"
color body yellow default "((ftp|http|https)://|(file|news):|www\\.)[-a-z0-9_.:]*[a-z0-9](/[^][{} \t\n\r\"<>()]*[^][{} \t\n\r\"<>().,:!])?/?"
color body cyan default "[-a-z_0-9.+]+@[-a-z_0-9.]+"
color body red default "(^| )\\\\*[-a-z0-9*]+\\\\*[,.?]?[ \n]"
color body green default "(^| )_[-a-z0-9_]+_[,.?]?[ \n]"

uncolor index * # unset all color index entries
color index green default ~F # Flagged
color index red default ~N # New
color index magenta default ~T # Tagged
color index yellow default ~D # Deleted
color index blue default '\[(CHRPM|Contrib-Rpm)\]'
color index brightblack default "~h ^X.Mailer..Microsoft.Outlook"
# color index brightblack default "~n 10-20"
SOMETHINGUNLIKELY
# ldap search file
  cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.mutt/ldapsearch.sh
#!/bin/sh

echo
ldapsearch -LLL -x -h $ADSERVER.$ADDOMAIN.$ADTLD -D "$ADUSER@$ADDOMAIN.$ADTLD" -w "$ADPASSWORD" -b "ou=$ADBASEDN,dc=$ADDOMAIN,dc=$ADTLD" -s sub "(cn=*\$1*)" cn mail |\\
	awk '{\\
		if (\$1=="cn:")\\
			{\$1="";CN=\$0};\\
		if (\$1=="mail:")\\
			{\$1="";MAIL=\$0};\\
		if (\$0=="")\\
			{print MAIL "	" CN}\\
	}'

SOMETHINGUNLIKELY
#creating the mailcap file
  cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.mutt/mailcap
# to display html content inline
text/html; lynx -assume_charset=%{charset} -display_charset=utf-8 -dump %s; nametemplate=%s.html; copiousoutput
# to disply exchange invatation inline
text/calendar; python ~/.mutt/mutt_ics.py; copiousoutput
#an attempt at catch all for application in mail
#display pictures (usually through attachments)
image/*; feh %s
SOMETHINGUNLIKELY
#creating the calendar invite view file
	cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.mutt/mutt_ics.py
#!/usr/bin/env python
import io
import os
import re
import sys
from functools import partial, reduce
from operator import add
from dateutil import tz

import icalendar


datefmt = '%A, %d %B %Y, %H:%M %Z'


def compose(*functions):
    """
    Returns a function which acts as a composition of several 'functions'. If
    one function is given it is returned if no function is given a
    :exc: 'TypeError' is raised.
    >>> compose(lambda x: x + 1, lambda x: x * 2)(1)
    3
    .. note:: Each function (except the last one) has to take the result of the
              last function as argument.
    [ Shamelessly stolen from Brownie: https://github.com/DasIch/brownie ]
    """
    if not functions:
        raise TypeError('expected at least 1 argument, got 0')
    elif len(functions) == 1:
        return functions[0]
    return reduce(lambda f, g: lambda *a, **kws: f(g(*a, **kws)), functions)


def get_ics_text(f):
    """
    Loads the content from the stream and applies a workaround for Microsoft
    Exchange Server.
    """
    content = f.read()
    # Ugly workaround: Python datetime doesn't support dates earlier than 1900,
    # whilst Microsoft corp. has created it's Exchange Sever 2007 somewhere in
    # the beginning of XVII century. Yeah, right.
    hacks = {"STANDARD\\nDTSTART:16010101": "STANDARD\\nDTSTART:20071104",
             "DAYLIGHT\\nDTSTART:16010101": "DAYLIGHT\\nDTSTART:20070311"}
    for search, replace in hacks.items():
        ics_text = content.replace(search, replace)
    return ics_text


def get_interesting_stuff(cal):
    components = []
    for component in cal.subcomponents:
        c = get_component(component)
        if c is not None:
            components.append(c)
    return u'\\n'.join(components)


def get_component(component):
    name = component.name
    if name == 'VCALENDAR':
        pass
    elif name == 'VTIMEZONE':
        pass
    elif name == 'VEVENT':
        return get_event(component)
    else:
        return None


def identity(x):
    return x


def format_date(x):
    return x.dt.astimezone(tz.tzlocal()).strftime(datefmt)


def get_event(e):
    unmailto = lambda x: re.compile('mailto:', re.IGNORECASE).sub('', x)
    def get_header(e):
        name_map = {'SUMMARY': 'Subject',
                    'ORGANIZER': 'Organizer',
                    'DTSTART': 'Start',
                    'DTEND': 'End',
                    'LOCATION': 'Location'}
        vals = []
        res = []

        def get_val(name, f):
            if name in e:
                vals.append((name_map[name], f(e[name])))

        get_val('SUMMARY', identity)
        get_val('ORGANIZER', unmailto)
        get_val('DTSTART', format_date)
        get_val('DTEND', format_date)
        get_val('LOCATION', identity)

        max_width = max(len(k) for k, v in vals)
        for k, v in vals:
            pad = u' ' * (max_width + 1 - len(k))
            line = u'%s:%s%s' % (k, pad, v)
            res.append(line)
        return u'\\n'.join(res)


    def get_participants(e):
        participants = e.get('ATTENDEE', [])
        if not isinstance(participants, list):
            participants = [participants]
        if len(participants):
            people = map(compose(partial(add, u' ' * 4), unmailto),
                         participants)
            return u'Participants:\\n%s' % "\\n".join(people)
        else:
            return None


    def get_description(e):
        description = e.get('DESCRIPTION', '').strip()
        if len(description):
            return u'Description:\\n\\n%s' % description
        else:
            return None

    result = filter(bool, [get_header(e),
                           get_participants(e),
                           get_description(e)])
    return u'\\n'.join(result)


def main(args):
    if len(args) > 1 and os.path.isfile(args[1]):
        with io.open(args[1], 'r', encoding='utf-8') as f:
            ics_text = get_ics_text(f)
    else:
        stream = io.open(sys.stdin.fileno(), 'r', encoding='utf-8')
        ics_text = get_ics_text(stream)

    cal = icalendar.Calendar.from_ical(ics_text)
    output = get_interesting_stuff(cal)
    out_stream = io.open(sys.stdout.fileno(), 'w', encoding='utf-8')
    out_stream.write(output + '\\n')


def entry_point():
    return main(sys.argv)


if __name__ == '__main__':
    entry_point()

# vi:set ts=4 sw=4 et sta:
SOMETHINGUNLIKELY
#creating the msmtp conf file
  cat << SOMETHINGUNLIKELY > /home/$ENDUSER/.msmtprc
# Set default values for all following accounts.
defaults
auth              on
tls               off
logfile           ~/.msmtp.log

# $ACCOUNTNAME
account           $ACCOUNTNAME
host              localhost
port              1025
protocol          smtp
from              $ADDOMAIN\\$ADUSER
auth              login
user              $ADDOMAIN\\$ADUSER
password          $ADPASSWORD

account default : $ACCOUNTNAME
SOMETHINGUNLIKELY
}

#prompting for info
#writing the info into configs
if [ ! -e /home/$ENDUSER/master.conf ]; then
  questions
fi
if [ ! -e /home/$ENDUSER/.mutt ]; then
  mkdir -p /home/$ENDUSER/.mutt
  eval $(cat /home/$ENDUSER/master.conf | sed 's/^/export /')
  make_templates
  chown -R $ENDUSER:$ENDUSER /home/$ENDUSER
fi
# Start the first process
su -c "/usr/local/davmail/davmail.sh &" -s /bin/sh $ENDUSER
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start davmail: $status"
  exit $status
fi

sleep 2
#first run, slow to prevent failures
if [ ! -e /home/$ENDUSER/Maildir/firstrun ]; then
  echo "First run started, syncing all mailboxes."
  echo "Mutt will open once this is finished."
  echo "Hit enter to continue."
  read whatever
  su -c "/usr/bin/offlineimap -o -d 1 && touch ~/Maildir/firstrun" -s /bin/sh $ENDUSER
fi
# Start the second process
su -c "/usr/bin/offlineimap 2>/dev/null &" -s /bin/sh $ENDUSER
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start offlineimap: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container will exit with an error
# if it detects that either of the processes has exited.
# Otherwise it will loop forever, waking up every 60 seconds

daemonize () {
  while /bin/true; do
    ps | awk '{ if($4~"java"){err=0; exit err} else {err=1}} END {exit err}'
    PROCESS_1_STATUS=$?
    ps | awk '{ if($4~"offlineimap"){err=0; exit err} else {err=1}} END {exit err}'
    PROCESS_2_STATUS=$?
    # If the greps above find anything, they will exit with 0 status
    # If they are not both 0, then something is wrong
    if [ "$PROCESS_1_STATUS" -ne 0 -o "$PROCESS_2_STATUS" -ne 0 ]; then
      echo "One of the processes has already exited."
      exit -1
    fi
    sleep 60
  done
}

export EDITOR=vim
daemonize &
su -c "mutt" -s /bin/sh $ENDUSER
