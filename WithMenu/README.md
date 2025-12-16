# docker-installer-mode.sh

Install Docker on Ubuntu using Docker’s **official** repository.

This script asks for an **install mode at the start** and installs Docker based on that choice.

---

## Features

- Official Docker repository (stable source)
- Installs missing tools if needed (curl, gpg, lsb-release, etc.)
- Optional Docker Compose plugin (`docker compose`)
- Optional non-root mode (run docker without sudo)
- Optional demo container (hello-world or nginx)
- Clear terminal logs

---

## Requirements

- Ubuntu
- Internet access
- `sudo` access (or run as root)

---

## Quick Start

```bash
chmod +x docker-installer-mode.sh
./docker-installer-mode.sh
```

---

## Install Modes (shown at the start)

- **Simple**: Docker only, safest, sudo only, no demo
- **Dev (default)**: Docker + Compose + non-root + nginx demo
- **Server**: Docker + Compose, sudo only, no demo
- **Custom**: choose options manually

---

## About non-root mode (no sudo)

Non-root mode adds your user to the `docker` group.

This is convenient, but it gives strong power to your user.
Use it only on a personal laptop or a dev machine.

You may need to log out and log in again.

---

## Demo

- **hello-world**: fast test
- **nginx**: runs a web server on port 8080

Stop nginx demo:
```bash
sudo docker rm -f demo-nginx
```

---

## License

MIT (or choose your own)
