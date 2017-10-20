#!/bin/sh

# Start the first process
/usr/local/davmail/davmail.sh &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start davmail: $status"
  exit $status
fi

sleep 2
# Start the second process
if [ ! -e /root/Maildir/firstrun ]; then
  echo "First run started, syncing all mailboxes."
  echo "Mutt will open once this is finished."
  echo "Hit enter to continue."
  read whatever
  /usr/bin/offlineimap -o -d 1 && touch /root/Maildir/firstrun
fi
/usr/bin/offlineimap 2>/dev/null &
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
    ps | grep davmail | grep -v grep &> /dev/null
    PROCESS_1_STATUS=$?
    ps | grep offlineimap | grep -v grep &> /dev/null
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

daemonize & mutt
