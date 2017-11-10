FROM alpine
MAINTAINER joshuajleigh
RUN apk --update --no-cache add ca-certificates openjdk7-jre tar wget offlineimap mutt feh lynx msmtp vim openldap-clients python py-pip py-dateutil && \
pip install icalendar && \
update-ca-certificates && \
mkdir /usr/local/davmail && \
wget -qO - https://downloads.sourceforge.net/project/davmail/davmail/4.8.0/davmail-linux-x86_64-4.8.0-2479.tgz | tar -C /usr/local/davmail --strip-components=1 -xz && \
mkdir /var/log/davmail && \
apk add --no-cache java-cacerts && \
rm /usr/lib/jvm/java-1.7-openjdk/jre/lib/security/cacerts && \
ln -s /etc/ssl/certs/java/cacerts /usr/lib/jvm/java-1.7-openjdk/jre/lib/security/cacerts && \
apk del tar
COPY wrapper.sh /
