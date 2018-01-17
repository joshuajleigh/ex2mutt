#!/bin/sh

echo
ldapsearch -LLL -x \
  -h --ADSERVER-- \
  -D "--ADUSER--" \
  -w "--ADPASSWORD--" \
  -b "dc=--ADFLATDOMAIN--,dc=--ADTLD--" \
  -s sub "(cn=*$1*)" cn mail |\
  awk '{ \
    if ($1=="cn:") \
      {$1=""; CN=$0} \
    if ($1=="mail:") \
      {$1=""; MAIL=$0; print MAIL " " CN; CN=""; MAIL=""}}'
