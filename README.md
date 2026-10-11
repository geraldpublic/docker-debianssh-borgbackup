# debian-ssh-borgbackup

A minimal Debian 13 (trixie) container with OpenSSH and [BorgBackup](https://www.borgbackup.org/), made to serve as a **remote Borg repository host**. Clients back up to it over SSH with key-only authentication.

- **Image:** `gerald77/debian-ssh-borgbackup`
- **Tags:** `latest`
- **Source:** https://github.com/geraldpublic/docker-debianssh-borgbackup
- **Port:** `22` (SSH)
- **Repository volume:** `/home/borgbackupmaster/repos`
- **Login user:** `borgbackupmaster` (limited account). Root login and password login are disabled.

## How it works

On start the container reads your **public SSH key** from the environment variable `SSH_KEY`, writes it to `/home/borgbackupmaster/.ssh/authorized_keys` and starts `sshd`. If `SSH_KEY` is not set, the container exits with an error message.

## Quick start

```shell
docker run -d \
    --name debian-ssh-borgbackup \
    -p 222:22 \
    -e SSH_KEY="ssh-ed25519 AAAA... you@host" \
    -v /your/borg-repos:/home/borgbackupmaster/repos \
    gerald77/debian-ssh-borgbackup:latest
```

## Docker Compose

Put the key into an env file (`rsa_secret_pub.env`):

```
SSH_KEY=ssh-ed25519 AAAA... you@host
```

```yaml
services:
  debiansshborgbackup:
    image: gerald77/debian-ssh-borgbackup:latest
    container_name: debian-ssh-borgbackup
    ports:
      - "222:22"
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /your/borg-repos:/home/borgbackupmaster/repos
    environment:
      - TZ=Europe/Vienna
    env_file:
      - ./rsa_secret_pub.env
    restart: unless-stopped
```

## Using it from a client

Initialise a repository and run a backup:

```shell
borg init --encryption=repokey-blake2 ssh://borgbackupmaster@your-host:222/./repos/myrepo
borg create ssh://borgbackupmaster@your-host:222/./repos/myrepo::{hostname}-{now} /path/to/backup
```

Paths are relative to the home directory of `borgbackupmaster`, so `./repos/...` is the mounted volume.

## Environment variables

| Variable | Description |
| :-- | :-- |
| `SSH_KEY` | **Required.** Public SSH key allowed to log in as `borgbackupmaster` |
| `TZ` | Optional time zone, e.g. `Europe/Vienna` |

## Using a different user name

The user `borgbackupmaster` is fixed in the image (`Dockerfile` and `set_root_pw.sh`). To use another name, fork the repository, replace the user in both files and build your own image.

## Notes

- Only expose the SSH port to networks you trust (VPN, LAN, firewall rules).
- Use encrypted Borg repositories (`--encryption=repokey-blake2` or `keyfile`) and keep your keys and passphrases safe; the server operator can read the files of unencrypted repositories.
- The image is rebuilt automatically on every push to the source repository, so pull regularly to get security updates.

## License

The scripts and Dockerfile in this project are licensed under the **GNU General Public License v3.0** (GPL-3.0). The full license text is in the [LICENSE](https://github.com/geraldpublic/docker-debianssh-borgbackup/blob/main/LICENSE) file of the source repository.

The image contains third-party software (Debian, OpenSSH, BorgBackup and others), each under its own license. See `/usr/share/doc/*/copyright` inside the container.

## Disclaimer

THIS IMAGE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR MAINTAINERS BE LIABLE FOR ANY CLAIM, DAMAGES, DATA LOSS OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE IMAGE OR ITS USE.

Use at your own risk. A backup you have not restored is not a backup: you are responsible for testing restores, securing your deployment (keys, network access, updates) and keeping additional copies of your data.
