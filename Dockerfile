FROM debian:bullseye

LABEL version="2024-01-14"
LABEL description="Debian latest for SSH with BorgBackup"

#Install packages 
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server sudo apt-utils mc borgbackup
RUN apt-get -y upgrade
ADD ./debianssh/set_root_pw.sh /set_root_pw.sh
ADD ./debianssh/run.sh /run.sh
RUN chmod +x /*.sh

RUN mkdir -p /var/run/sshd && sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation yes/g" /etc/ssh/sshd_config \
  && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
  && touch /root/.Xauthority \
  && true

## Set a default user. Available via runtime flag `--user docker` ## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library ## User should also have & own a home directory, but also be able to sudo 
## Replace "borgbackupmaster" with a username of your choice
RUN useradd borgbackupmaster \
        && passwd -d borgbackupmaster \
        && mkdir /home/borgbackupmaster \
	&& mkdir /home/borgbackupmaster/repos \
        && chown borgbackupmaster:borgbackupmaster /home/borgbackupmaster \
        && chown borgbackupmaster:borgbackupmaster /home/borgbackupmaster/repos \
        && addgroup borgbackupmaster staff \
        && addgroup borgbackupmaster sudo \
        && true

# Use SSH Default Port and change it outside
EXPOSE 22 

VOLUME ["/home/borgbackupmaster/repos"]

#Starting daemon
CMD ["/run.sh"]
