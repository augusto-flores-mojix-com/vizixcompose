#!/bin/bash
timestamp() {
  date "+%H:%M:%S.%3N"
}
info() {
  local msg=$1
  echo -e "\e[1;32m[info] $(timestamp) ${msg}\e[0m"
}
fail() {
  local msg=$1
  echo -e "\e[1;31m[err] $(timestamp) ERROR: ${msg}\e[0m"
  exit 1
}
is_ubuntu_xenial() {
  grep -qF "Ubuntu 16.04" /etc/os-release &>/dev/null
}
main() {
  if ! is_ubuntu_xenial; then
    fail "this script is only compatible with Ubuntu 16.04"
  fi
  info "Update and install 4.10 Kernel"
  info "Current Version: $(uname -r)"
  apt update
  apt install linux-image-4.10.0-40-generic
  FIRST=$(grep submenu /boot/grub/grub.cfg)
  FIRST=$(echo "$FIRST" | grep -o -P "(?<=\'gnulinux).*?(?=\')")
  FIRST="gnulinux$FIRST"
  info "from $FIRST"
  SECOND=$(grep gnulinux /boot/grub/grub.cfg | grep 4.10 | grep advanced)
  SECOND=$(echo "$SECOND" | grep -o -P "(?<=\'gnulinux).*?(?=\')" | head -n 1)
  SECOND="gnulinux$SECOND"
  info "to $SECOND"
  LINK="$FIRST>$SECOND"
  sed -i -e "s/GRUB_DEFAULT=0/GRUB_DEFAULT=\"$LINK\"/" /etc/default/grub
  info "Grub File updated to:\n"
  cat /etc/default/grub
  update-grub
  info "------------- Please Reboot Now -------------"
  info "After reboot, verify that kernel is on 4.10"
  #reboot
}
main
exit 0
