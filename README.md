# TRex Docker Images

Automated Docker image builds for [Cisco TRex](https://trex-tgn.cisco.com/) traffic generator, based on Rocky Linux 9.

Images are published to the GitHub Container Registry:

```
ghcr.io/tshelter/trex:<version>
```

## Available versions

| Version | Pull command |
|---------|-------------|
| v3.08 | `docker pull ghcr.io/tshelter/trex:v3.08` |
| v3.02 | `docker pull ghcr.io/tshelter/trex:v3.02` |
| v3.00 | `docker pull ghcr.io/tshelter/trex:v3.00` |

## Running TRex

TRex requires direct access to network interfaces and hugepages, so it must run with full privileges and host networking.

### Start the TRex server

```bash
docker run --rm -it \
  --privileged \
  --network host \
  --cap-add ALL \
  --ulimit memlock=-1:-1 \
  -v /dev/hugepages:/dev/hugepages \
  -v /etc/trex_cfg.yaml:/etc/trex_cfg.yaml \
  ghcr.io/tshelter/trex:v3.08 \
  t-rex-64 -i
```

### Connect with trex-console

Open a second terminal and run:

```bash
docker run --rm -it \
  --privileged \
  --network host \
  -v /etc/trex_cfg.yaml:/etc/trex_cfg.yaml \
  ghcr.io/tshelter/trex:v3.08 \
  trex-console
```

### Shell aliases

Add these to your `~/.bashrc` or `~/.zshrc` for convenient access:

```bash
TREX_IMAGE="ghcr.io/tshelter/trex:v3.08"
TREX_OPTS="--rm -it --privileged --network host --cap-add ALL --ulimit memlock=-1:-1
  -v /dev/hugepages:/dev/hugepages
  -v /etc/trex_cfg.yaml:/etc/trex_cfg.yaml"

alias t-rex-64="docker run $TREX_OPTS $TREX_IMAGE t-rex-64"
alias trex-console="docker run $TREX_OPTS $TREX_IMAGE trex-console"
```

Reload your shell (`source ~/.bashrc`) then use as if TRex were installed natively:

```bash
t-rex-64 -i                     # start server (interactive mode)
t-rex-64 --help                  # show all flags
trex-console                     # connect console to running server
trex-console -s 127.0.0.1       # connect to specific server
```

### Minimal config (`/etc/trex_cfg.yaml`)

```yaml
- port_limit: 2
  version: 2
  interfaces:
    - "0000:01:00.0"
    - "0000:01:00.1"
  port_info:
    - ip: 1.1.1.1
      default_gw: 2.2.2.2
    - ip: 2.2.2.2
      default_gw: 1.1.1.1
```

Find your interface PCI addresses with `lspci | grep -i eth` or `dpdk-devbind.py --status`.

## Image details

- **Base image**: `rockylinux:9.3.20231119`
- **TRex path**: `/root/trex`
- **Working directory**: `/root/trex`
- **PATH**: includes `/root/trex`
- **Packages added**: `procps-ng`, `pciutils`, `iproute`
- **Architecture**: `linux/amd64`

## Build pipeline

Builds are triggered automatically on push when `Dockerfile`, `versions.json`, or the workflow file changes. You can also trigger a build manually from the [Actions tab](../../actions/workflows/build.yml).

### Build a specific set of versions

Use **Run workflow** → enter space-separated versions:

```
v3.06 v3.07 v3.08
```

Leave the field empty to build all versions listed in `versions.json`.

### Add or remove versions

Edit [`versions.json`](versions.json):

```json
["v3.00", "v3.02", "v3.08"]
```

TRex tarballs are cached between runs — subsequent builds skip the download (~250 MB per version).

## Building locally

```bash
# Download the tarball first
curl -k -L -o trex.tar.gz https://trex-tgn.cisco.com/trex/release/v3.08.tar.gz

# Build
docker build --build-arg TREX_VERSION=v3.08 -t trex:v3.08 .
```
