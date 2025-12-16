# docker-uninstall.sh

Remove Docker from Ubuntu (complete removal).

This script removes:
- Docker packages
- Docker data (containers, images, volumes, networks)
- Docker config folders
- Docker repo file and key

---

## WARNING

This is destructive.

It will delete:
- All containers
- All images
- All volumes (your data)

If you need volume data, back it up first.

---

## Usage

```bash
chmod +x docker-uninstall.sh
./docker-uninstall.sh
```

The script asks for confirmation before it removes anything.

---

## What it removes

- Packages (apt purge):
  - docker-ce, docker-ce-cli, containerd.io, plugins
- Data folders:
  - /var/lib/docker
  - /var/lib/containerd
- Config folders:
  - /etc/docker
- Repo/key:
  - /etc/apt/sources.list.d/docker.list
  - /etc/apt/keyrings/docker.gpg

---

## Notes

If Docker was installed by Snap or manual binaries, you may need extra cleanup.

---

## License

MIT (or choose your own)
