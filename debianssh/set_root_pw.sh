#!/bin/bash

if [ -z "${SSH_KEY}" ]; then
	echo "=> Please pass your public key in the SSH_KEY environment variable e.g. docker-compose --> env_file: ./rsa_public.env"
	exit 1
fi

for MYHOME in /home/borgbackupmaster; do
	echo "=> Adding SSH key to ${MYHOME}"
	mkdir -p ${MYHOME}/.ssh
	chmod go-rwx ${MYHOME}/.ssh
	echo "${SSH_KEY}" > ${MYHOME}/.ssh/authorized_keys
	chmod go-rw ${MYHOME}/.ssh/authorized_keys
	echo "=> Done!"
done
chown -R borgbackupmaster:borgbackupmaster /home/borgbackupmaster/.ssh

echo "========================================================================"
echo "You can now connect to this container via SSH using:"
echo ""
echo "    ssh -p <port> <user>@<host>"
echo ""
echo "Use borgbackupmaster (limited user account) as <user>."
echo "========================================================================"
