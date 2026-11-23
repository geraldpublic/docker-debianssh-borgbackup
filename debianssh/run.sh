#!/bin/bash

set -e

# SSH host keys: keep them in /etc/ssh/hostkeys (mount a volume there),
# create missing ones on first start
HOSTKEY_DIR=/etc/ssh/hostkeys
mkdir -p "$HOSTKEY_DIR"
chmod 700 "$HOSTKEY_DIR"
for t in ed25519 ecdsa rsa; do
	if [ ! -s "$HOSTKEY_DIR/ssh_host_${t}_key" ]; then
		echo "=> Creating SSH host key ($t) in $HOSTKEY_DIR"
		rm -f "$HOSTKEY_DIR/ssh_host_${t}_key" "$HOSTKEY_DIR/ssh_host_${t}_key.pub"
		ssh-keygen -q -t "$t" -N "" -C "root@debian-ssh-borgbackup" -f "$HOSTKEY_DIR/ssh_host_${t}_key"
	fi
done

/set_root_pw.sh
exec /usr/sbin/sshd -D
