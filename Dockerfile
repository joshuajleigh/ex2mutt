FROM alpine
MAINTAINER joshuajleigh
RUN apk --update --no-cache add ca-certificates openjdk7-jre tar wget offlineimap mutt feh lynx msmtp vim openldap-clients python py-pip py-dateutil bash bind-tools && \
pip install icalendar && \
update-ca-certificates && \
mkdir /usr/local/davmail && \
wget -qO - https://downloads.sourceforge.net/project/davmail/davmail/4.8.0/davmail-linux-x86_64-4.8.0-2479.tgz | tar -C /usr/local/davmail --strip-components=1 -xz && \
mkdir /var/log/davmail && \
apk add --no-cache java-cacerts && \
rm /usr/lib/jvm/java-1.7-openjdk/jre/lib/security/cacerts && \
ln -s /etc/ssl/certs/java/cacerts /usr/lib/jvm/java-1.7-openjdk/jre/lib/security/cacerts && \
apk del tar && mkdir -p /home/user/.mutt
COPY conf_files/.msmtprc /home/user/
COPY conf_files/.davmail.properties /home/user/
COPY conf_files/.muttrc /home/user/
COPY conf_files/.offlineimaprc /home/user/
COPY conf_files/account.mutt /home/user/.mutt/
COPY conf_files/ldapsearch.sh /home/user/.mutt/
COPY conf_files/mailcap /home/user/.mutt/
COPY conf_files/mutt_ics.py /home/user/.mutt/
COPY conf_files/comida /home/user/.mutt/
COPY runner.sh /home/user/
ENTRYPOINT /bin/bash /home/user/runner.sh
