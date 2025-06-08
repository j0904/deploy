#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# Disable prompts for apt-get.
export DEBIAN_FRONTEND="noninteractive"

# System info.
PLATFORM="$(uname --hardware-platform || true)"
DISTRIB_CODENAME="$(lsb_release --codename --short || true)"
DISTRIB_ID="$(lsb_release --id --short | tr '[:upper:]' '[:lower:]' || true)"

# 
# The Docker compose file.
COMPOSE_URL="https://raw.githubusercontent.com/j0904/deploy/main/bluesky/prod/compose.yml"
 
# System dependencies.
REQUIRED_SYSTEM_PACKAGES="
  ca-certificates
  curl
  gnupg
  jq
  lsb-release
  openssl
  sqlite3
  xxd
"
# Docker packages.
REQUIRED_DOCKER_PACKAGES="
  containerd.io
  docker-ce
  docker-ce-cli
  docker-compose-plugin
"
 
function usage {
  local error="${1}"
  cat <<USAGE >&2
ERROR: ${error}
Usage:
sudo bash $0

Please try again.
USAGE
  exit 1
}

function main {
  # Check that user is root.
  if [[ "${EUID}" -ne 0 ]]; then
    usage "This script must be run as root. (e.g. sudo $0)"
  fi

  # Check for a supported architecture.
  # If the platform is unknown (not uncommon) then we assume x86_64
  if [[ "${PLATFORM}" == "unknown" ]]; then
    PLATFORM="x86_64"
  fi
  if [[ "${PLATFORM}" != "x86_64" ]] && [[ "${PLATFORM}" != "aarch64" ]] && [[ "${PLATFORM}" != "arm64" ]]; then
    usage "Sorry, only x86_64 and aarch64/arm64 are supported. Exiting..."
  fi

  # Check for a supported distribution.
  SUPPORTED_OS="false"
  if [[ "${DISTRIB_ID}" == "ubuntu" ]]; then
    if [[ "${DISTRIB_CODENAME}" == "focal" ]]; then
      SUPPORTED_OS="true"
      echo "* Detected supported distribution Ubuntu 20.04 LTS"
    elif [[ "${DISTRIB_CODENAME}" == "jammy" ]]; then
      SUPPORTED_OS="true"
      echo "* Detected supported distribution Ubuntu 22.04 LTS"
    elif [[ "${DISTRIB_CODENAME}" == "mantic" ]]; then
      SUPPORTED_OS="true"
      echo "* Detected supported distribution Ubuntu 23.10 LTS"
    elif [[ "${DISTRIB_CODENAME}" == "noble" ]]; then
      SUPPORTED_OS="true"
    fi
  elif [[ "${DISTRIB_ID}" == "debian" ]]; then
    if [[ "${DISTRIB_CODENAME}" == "bullseye" ]]; then
      SUPPORTED_OS="true"
      echo "* Detected supported distribution Debian 11"
    elif [[ "${DISTRIB_CODENAME}" == "bookworm" ]]; then
      SUPPORTED_OS="true"
      echo "* Detected supported distribution Debian 12"
    fi
  fi

  if [[ "${SUPPORTED_OS}" != "true" ]]; then
    echo "Sorry, only Ubuntu 20.04, 22.04, Debian 11 and Debian 12 are supported by this installer. Exiting..."
    exit 1
  fi

   
 
  #
  # Prompt user for required variables.
  #
 
 
 
  #
  # Install system packages.
  #
  if lsof -v >/dev/null 2>&1; then
    while true; do
      apt_process_count="$(lsof -n -t /var/cache/apt/archives/lock /var/lib/apt/lists/lock /var/lib/dpkg/lock | wc --lines || true)"
      if (( apt_process_count == 0 )); then
        break
      fi
      echo "* Waiting for other apt process to complete..."
      sleep 2
    done
  fi

  apt-get update
  apt-get install --yes ${REQUIRED_SYSTEM_PACKAGES}

  #
  # Install Docker
  #
  if ! docker version >/dev/null 2>&1; then
    echo "* Installing Docker"
    mkdir --parents /etc/apt/keyrings

    # Remove the existing file, if it exists,
    # so there's no prompt on a second run.
    rm --force /etc/apt/keyrings/docker.gpg
    curl --fail --silent --show-error --location "https://download.docker.com/linux/${DISTRIB_ID}/gpg" | \
      gpg --dearmor --output /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRIB_ID} ${DISTRIB_CODENAME} stable" >/etc/apt/sources.list.d/docker.list

    apt-get update
    apt-get install --yes ${REQUIRED_DOCKER_PACKAGES}
  fi

  #
  # Configure the Docker daemon so that logs don't fill up the disk.
  #
  if ! [[ -e /etc/docker/daemon.json ]]; then
    echo "* Configuring Docker daemon"
    cat <<'DOCKERD_CONFIG' >/etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "500m",
    "max-file": "4"
  }
}
DOCKERD_CONFIG
    systemctl restart docker
  else
    echo "* Docker daemon already configured! Ensure log rotation is enabled."
  fi
DATAPATH=/data/vm/
  #
  # Create data directory.
  #
  if ! [[ -d "${DATAPATH}" ]]; then
    echo "* Creating data directory ${DATAPATH}"
    mkdir --parents "${DATAPATH}"
  fi
  chmod 700 "${DATAPATH}"

  #
  # Configure Caddy
  #
  if ! [[ -d "${DATAPATH}/caddy/data" ]]; then
    echo "* Creating Caddy data directory"
    mkdir --parents "${DATAPATH}/caddy/data"
  fi
  if ! [[ -d "${DATAPATH}/caddy/etc/caddy" ]]; then
    echo "* Creating Caddy config directory"
    mkdir --parents "${DATAPATH}/caddy/etc/caddy"
  fi

  echo "* Creating Caddy config file"
  cat <<CADDYFILE >"${DATAPATH}/caddy/etc/caddy/Caddyfile"
# Caddyfile for Bluesky/atproto dev-env production

{
	email deploy@bigt.ai
}


# HTTP to HTTPS redirect
:80 {
  redir https://{host}{uri} permanent
}

# PLC service
plc.bigt.ai, plc {
  reverse_proxy plc:2582
}

# PDS service
pds.bigt.ai, pds {
  reverse_proxy pds:2583
}

# Bsky Appview
bsky.bigt.ai, bsky {
  reverse_proxy bsky:2584
}

# Ozone service
ozone.bigt.ai, ozone {
  reverse_proxy ozone:2587
}


# Sync service
sync.bigt.ai, sync {
  reverse_proxy sync:2592
}


# Feed Generator service
feed-gen.bigt.ai, feed-gen {
  reverse_proxy feed-gen:2585
}


# Default fallback (optional)
# :443 {
#   respond "Not found" 404
# }


CADDYFILE

 
  #
  # Download and install pds launcher.
  #
  echo "* Downloading   compose file"
  curl \
    --silent \
    --show-error \
    --fail \
    --output "${DATAPATH}/compose.yaml" \
    "${COMPOSE_URL}"

   
  #
  # Create the systemd service.
  #
  echo "* Starting the pds systemd service"
  cat <<SYSTEMD_UNIT_FILE >/etc/systemd/system/pds.service
[Unit]
Description=Bluesky PDS Service
Documentation=https://github.com/bluesky-social/pds
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${DATAPATH}
ExecStart=/usr/bin/docker compose --file ${DATAPATH}/compose.yaml up --detach
ExecStop=/usr/bin/docker compose --file ${DATAPATH}/compose.yaml down

[Install]
WantedBy=default.target
SYSTEMD_UNIT_FILE

  systemctl daemon-reload
  systemctl enable pds
  systemctl restart pds

  # Enable firewall access if ufw is in use.
  if ufw status >/dev/null 2>&1; then
    if ! ufw status | grep --quiet '^80[/ ]'; then
      echo "* Enabling access on TCP port 80 using ufw"
      ufw allow 80/tcp >/dev/null
    fi
    if ! ufw status | grep --quiet '^443[/ ]'; then
      echo "* Enabling access on TCP port 443 using ufw"
      ufw allow 443/tcp >/dev/null
    fi
  fi
}

# Run main function.
main

# End of script
