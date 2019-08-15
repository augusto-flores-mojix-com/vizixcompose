#!/bin/bash
#
# Vizix Installer
# Steps:
#   - wget this file
#   - sudo chmod +x install.sh
#   - run this file: ./install.sh
#   - input the dockerhub credentials

usage() {
  cat <<USAGE >&2
usage: $0 [options]

Vizix Installer Script.

OPTIONS:
  -h,   --help                     Shows this message.

  -v,   --version VERSION          Install explicit VERSION (e.g. v5.1.4).

  -u,   --url URL                  Services URL, default icanhazip (e.g. 192.168.0.4).

  -s,   --source URL               Selects the download site of the config files.

  -am,  --add-mirror               Adds local registry mirror.

  --skip-provision                 Skips Provision of Docker, Docker-compose, ctop and other basic Linux Tools.

  --skip-launch                    Skips Launch of Vizix.
USAGE
}

main() {
  # Preliminar setup
  if ! is_root; then
    fail "this script must be executed as the root user"
  fi
  if ! is_ubuntu_xenial; then
    warn "this script is compatible with Ubuntu 16.04, test with another distros is unknown"
  fi
  check_installed "wget" "curl"

  #Variables
  local provision=true
  local launch=true
  local regmirror=false
  local source_url="${VIZIX_SOURCE_URL:-"https://s3.amazonaws.com/vizix-releases/compose/dev_6.x.x"}"
  local version="${VIZIX_VERSION:-"v6.21.1"}"
  local services_url="${SERVICES_URL-$(curl -4 -s icanhazip.com)}"

  while true; do
    case "$1" in
      -v | --version)
        if [[ -z "$2" ]]; then
          fail "--version requires an argument"
        fi
        version="$2"
        shift 2
        ;;
      -s | --source)
        if [[ -z "$2" ]]; then
          fail "--source requires an argument"
        fi
        source_url="$2"
        shift 2
        ;;
      -u | --url)
        if [[ -z "$2" ]]; then
          fail "--url requires an argument"
        fi
        services_url="$2"
        shift 2
        ;;
      -am | --add-mirror)
        regmirror=true
        shift
        ;;
      --skip-provision)
        provision=false
        shift
        ;;
      --skip-launch)
        launch=false
        shift
        ;;
      -h | --help)
        usage
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ $# -ne 0 ]]; then
    usage
    exit 1
  fi

  #Read input TODO
  if $launch; then
    info "Docker-Hub credentials: "
    read -p 'Username: ' dockeruservar
    read -sp 'Password: ' dockerpassvar
  fi


  if $provision; then
    info "Updating repos and installing Docker"
    bash < <(curl -fsSL "${source_url}/provision.sh")
    #Updating Docker
    wget -N "${source_url}/daemon.json" -P /etc/docker
    if $regmirror; then
      sed -i "s|\s\s}|  },\n  \"registry-mirrors\" : [\n    \"http://10.100.152.204:80\"\n  ],\n  \"dns\" : [\n    \"8.8.8.8\"\n  ]|" /etc/docker/daemon.json
    fi
    systemctl daemon-reload
    systemctl stop docker
    rm -rf /var/lib/docker
    systemctl start docker
  fi


  #Installing Vizix
  if $launch; then
    info "-----------------"
    info "Installing Vizix"
    info "-----------------"
    wget -N "${source_url}/docker-compose.yml" -P /opt/vizix
    wget -N "${source_url}/mongoinit.yml" -P /opt/vizix
    wget -N "${source_url}/envsample" -P /opt/vizix
    wget -N "${source_url}/Caddyfile" -P /opt/vizix
    wget -N "${source_url}/launch.sh" -P /opt/vizix
    wget -N "${source_url}/vizix-tools.yml" -P /opt/vizix
    chmod +x /opt/vizix/launch.sh
    #Setting Up Variables
    info "Setting up variables"
    export VIZIX_UI_VERSION=mojix/riot-core-ui:${version}
    export VIZIX_SERVICES_VERSION=mojix/riot-core-services:${version}
    export VIZIX_BRIDGES_VERSION=mojix/riot-core-bridges:${version}
    export VIZIX_TOOLS_VERSION=mojix/vizix-tools:${version}
    export SERVICES_URL=${services_url}
    export DOCKER_HUB_USERNAME="${dockeruservar}"
    export DOCKER_HUB_PASSWORD="${dockerpassvar}"
    export VIZIX_DATA_PATH=/data
    info "Starting..."
    bash /opt/vizix/launch.sh empty
    rm /opt/vizix/launch.sh
    info "Successfully Installed"
    warn "Please update SERVICES_URL variable on /opt/vizix/.env file"
  fi
}
# Helper Functions
is_root() {
  [[ $(id -u) -eq 0 ]]
}

timestamp() {
  date "+%H:%M:%S.%3N"
}

info() {
  local msg=$1
  echo -e "\e[1;32m[info] $(timestamp) ${msg}\e[0m"
}

warn() {
  local msg=$1
  echo -e "\e[1;33m[warn] $(timestamp) ${msg}\e[0m"
}

fail() {
  local msg=$1
  echo -e "\e[1;31m[err] $(timestamp) ERROR: ${msg}\e[0m"
  exit 1
}

check_installed() {
  local missing=()

  for bin in "$@"; do
    if ! which "${bin}" &>/dev/null; then
      missing+=("${bin}")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    fail "this script requires: ${missing[@]}"
  fi
}

is_ubuntu_xenial() {
  grep -qF "Ubuntu 16.04" /etc/os-release &>/dev/null
}

main "$@"
info "Setup Complete!"
exit 1
