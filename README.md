# olp-server

A minimal, OPL-compatible Samba server in Docker, for streaming PS2 game
backups to a PS2 console over the network via [Open PS2 Loader](https://www.ps2homebrew.org/Open-PS2-Loader-User-Guide/) (OPL).

OPL's SMB client predates SMB2/3 and modern Samba's default security
settings. Samba 4.11+ disables SMB1 by default, which breaks OPL silently
with no useful error on the PS2 side. This image forces Samba back down to
the old `NT1` (SMB1) dialect with signing and encryption disabled, which is
what OPL actually speaks.

## Running it

### From source (build locally)

```sh
git clone https://github.com/athegreat90/olp-server.git
cd olp-server
mkdir -p games
docker compose up -d --build
```

### From the published image

```yaml
services:
  olp-server:
    image: ghcr.io/athegreat90/olp-server:latest
    container_name: olp-server
    restart: unless-stopped
    ports:
      - "445:445"
    volumes:
      - ./games:/games
    environment:
      - PUID=1000
      - PGID=1000
```

Drop your PS2 game ISOs into the mounted `games/` folder (or copy them in
over the SMB share once connected — the share is writable).

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `PUID` | `1000` | UID the Samba guest user writes files as, inside `/games` |
| `PGID` | `1000` | GID the Samba guest user writes files as, inside `/games` |

Set these to match your host user so files written from the PS2 (or dropped
in from the host) have sane ownership.

## PS2-side configuration (OPL)

On the PS2, open OPL, press Start on the Games/Apps list, then
**Network Config**, and set:

| Setting | Value |
|---|---|
| Address Type | `NetBIOS` (or `IP` if NetBIOS discovery doesn't work on your network) |
| Computer Name / IP | Your server's hostname in **capital letters**, or its IP address |
| Port | `445` |
| Share | `PS2SMB` |
| Username / Password | Leave blank (guest access) |

These settings are saved to `conf_network.cfg` in the `mc#:/OPL` folder on
your memory card. You'll need either a router connecting both the PS2 and
the Docker host, or a direct Ethernet/crossover connection.

## Verifying the share

From the Docker host (or any machine on the LAN):

```sh
smbclient -L //<server-ip> -N
smbclient //<server-ip>/PS2SMB -N
```

Both should connect without a password prompt and show your game files.

## Building and publishing

A GitHub Actions workflow (`.github/workflows/docker-publish.yml`) builds and
pushes the image to `ghcr.io/athegreat90/olp-server` on every push to `main`
and on version tags (`v*`). Tags produced: `latest` (default branch),
the branch name, semver tags, and the commit SHA.
