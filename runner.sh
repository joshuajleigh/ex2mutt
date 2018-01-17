#used later for configuring config files
set_env () {
	! (: "${FULLNAME?}") 2>/dev/null  &&\
    echo "What is your full name? ex jane doe" &&\
    read FULLNAME
	! (: "${ADUSER?}") 2>/dev/null  &&\
    echo "what is your full email?  ex jdoe@whatever.net" &&\
    read ADUSER
	! (: "${ADPASSWORD?}") 2>/dev/null  &&\
    until [ $ADPASSWORD == $CONFIRMED ] && [[ $ADPASSWORD != "" ]]; do
      echo "What is your AD password?"
      read -s ADPASSWORD
      echo "confirm the password"
      read -s CONFIRMED
      if [ $ADPASSWORD != $CONFIRMED ]; then
        echo "Password mismatch, try again."
      fi
    done
	! (: "${OWAADDRESS?}") 2>/dev/null &&\
    echo "What is the web endpoint of the exchange server? ex owa.domain.com/ews/exchange.asmx" &&\
    read OWAADDRESS
  ADUSERSHORT=$(echo $ADUSER | sed "s/\(.*\)\(@.*\)/\1/g")
  ADDOMAIN=$(echo $ADUSER | sed "s/\(^.*@\)\(.*\)/\2/g")
  ADFLATDOMAIN=$(echo $ADDOMAIN | sed "s/\(^.*\)\(\..*\)/\1/g")
  ADTLD=$(echo $ADDOMAIN | sed "s/\(^.*\.\)\(.*\)/\2/g")
	! (: "${USERID?}") 2>/dev/null && \
	  echo "set enduser - output of 'id -u'" && \
	  read USERID
}

#used to verify answers
verify_answers () {
	clear
  echo "AD User=$ADUSER"
  echo "FULL AD DOMAIN=$ADDOMAIN"
  autodetect $ADDOMAIN
  echo "AD SERVER=$ADSERVER"
  echo "AD DOMAIN=$ADFLATDOMAIN"
  echo "AD Top Level Domain=$ADTLD"
  echo "Exchange Endpoint=$OWAADDRESS"
  echo "echo does this look correct? [y/n]"
  read ANSWER
  case $ANSWER in
    [Yy]*)
      ;;
    [Nn]*)
      questions
  esac
}

autodetect() {
  DC_LOOKUP=($(dig -t SRV _ldap._tcp.$1 +nocookie +short | awk '{print $NF}'))
  if [[ "${DC_LOOKUP[0]}" == "" ]] ; then
    echo "autodetect of DCs failed"
    echo "What is the name of your AD server? Ex DC01.whatever.net"
    read ADSERVER
  else
    ADSERVER="${DC_LOOKUP[0]}"
  fi
  USER_LOOKUP=$(ldapsearch -x -h "$1" -D "$ADUSER" -w "$ADPASSWORD" -b "dc=$ADFLATDOMAIN,dc=$ADTLD" -s sub "(cn=*$FULLNAME*)" cn mail | grep "dn:")
#  echo "$USER_LOOKUP"
#  DC_LIST=($(dig -t SRV _ldap._tcp.$1 +nocookie +short | awk '{print $NF}'))
#  echo ${DC_LIST[@]}
}

search_and_replace (){
  sed -e "s/--FULLNAME--/$FULLNAME/g" -i $1
  sed -e "s/--ADUSER--/$ADUSER/g" -i $1
  sed -e "s/--ADUSERSHORT--/$ADUSERSHORT/g" -i $1
  sed -e "s/--ADPASSWORD--/$ADPASSWORD/g" -i $1
  sed -e "s@--OWAADDRESS--@$OWAADDRESS@g" -i $1
  sed -e "s/--ADDOMAIN--/$ADDOMAIN/g" -i $1
  sed -e "s/--ADFLATDOMAIN--/$ADFLATDOMAIN/g" -i $1
  sed -e "s/--ADTLD--/$ADTLD/g" -i $1
  sed -e "s/--ADSERVER--/$ADSERVER/g" -i $1
}

rewrite_config () {
  template_files=(
  /home/user/.davmail.properties
	/home/user/.msmtprc
  /home/user/.offlineimaprc
  /home/user/.muttrc
  /home/user/.mutt/ldapsearch.sh
	/home/user/.mutt/comida
	/home/user/.mutt/mailcap
  )
#  echo "${template_files[@]}"
  for i in ${template_files[@]}; do
    search_and_replace $i
  done
}

run_stuff() {
  set_env
  verify_answers
  adduser user -D -u $USERID
  chown -R user /home/user
	rewrite_config
#	# Start the first process
	su -c "/usr/local/davmail/davmail.sh &" -s /bin/sh user
	status=$?
	if [ $status -ne 0 ]; then
	  echo "Failed to start davmail: $status"
	  exit $status
	fi

	sleep 2
	#first run, slow to prevent failures
	if [ ! -e /home/user/Maildir/firstrun ]; then
	  echo "First run started, syncing all mailboxes."
	  echo "Mutt will open once this is finished."
	  echo "Hit enter to continue."
	  read whatever
	  su -c "/usr/bin/offlineimap -o -d 1 && touch /home/user/Maildir/firstrun" -s /bin/sh user
	fi
	# Start the second process
	su -c "/usr/bin/offlineimap 2>/dev/null &" -s /bin/sh user
	status=$?
	if [ $status -ne 0 ]; then
	  echo "Failed to start offlineimap: $status"
	  exit $status
	fi
  su -c "mutt" -s /bin/sh user
}

run_stuff
