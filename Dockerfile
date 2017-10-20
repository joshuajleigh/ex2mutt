FROM alpine
MAINTAINER joshua.j.leigh@gmail.com
RUN apk --update --no-cache add ca-certificates openjdk7-jre tar wget offlineimap mutt && \
adduser davmail -D && \
update-ca-certificates && \
mkdir /usr/local/davmail && \
wget -qO - https://downloads.sourceforge.net/project/davmail/davmail/4.8.0/davmail-linux-x86_64-4.8.0-2479.tgz | tar -C /usr/local/davmail --strip-components=1 -xz && \
mkdir /var/log/davmail && \
chown davmail:davmail /var/log/davmail -R && \
apk del tar
RUN apk add --no-cache java-cacerts && \
rm /usr/lib/jvm/java-1.7-openjdk/jre/lib/security/cacerts && \
ln -s /etc/ssl/certs/java/cacerts /usr/lib/jvm/java-1.7-openjdk/jre/lib/security/cacerts
#ENTRYPOINT /wrapper.bash
