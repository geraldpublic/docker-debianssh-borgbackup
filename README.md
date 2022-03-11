### docker-debianssh-borgbackup
Docker Image debian latest with ssh to serve borgbackup (2022-03-11)

Your own user needs to be inserted instead of my user "borgbackupmaster" in the "Dockerfile" and the "set_root_pw.sh" file

###Usage docker-compose.yml:

```bash
version: '3.0'
services:
  debiansshborgbackup:
    image: gerald77/debian-ssh-borgbackup
    container_name: debian-ssh-borgbackup
    ports:
    - "222:22"
    volumes:
    - /etc/localtime:/etc/localtime:ro
    environment:
    - TZ=Europe/Vienna
    env_file:
    - ./rsa_secret_pub.env
    restart: unless-stopped
```