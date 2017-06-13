#!/usr/bin/env bash

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
  echo "What directory should your mail be kept? ~/Maildir/work isn't terrible"
  read MAILDIR
  echo "What name do you want to give the mail account?"
  read ACCOUNTNAME
  echo "What is the web endpoint of the exchange server? ex owa.domain.com/ews/exchange.asmx"
  read OWAADDRESS

  answers
}

answers () {
  echo "AD SERVER=$ADSERVER"
  echo "AD DOMAIN=$ADDOMAIN"
  echo "AD Top Level Domain=$ADTLD"
  echo "AD User=$ADUSER"
  echo "AD Password=$ADPASSWORD"
  echo "Base org DN=$ADBASEDN"
  echo "Mail Directory=$MAILDIR"
  echo "Account Name=$ACCOUNTNAME"
  echo "Exchange Endpoint=$OWAADDRESS"
  echo "echo does this look correct?"
  read ANSWER
  case $ANSWER in
      [Yy]*)
cat << SOMETHINGUNLIKELY > master.conf
ADSERVER="$ADSERVER"
ADDOMAIN="$ADDOMAIN"
ADTLD="$ADTLD"
ADUSER="$ADUSER"
ADPASSWORD="$ADPASSWORD"
ADBASEDN="$ADBASEDN"
MAILDIR="$MAILDIR"
ACCOUNTNAME="$ACCOUNTNAME"
OWAADDRESS="$OWAADDRESS"
SOMETHINGUNLIKELY
        exit;;
      [Nn]*)
        questions
  esac
}

questions
