#!/bin/bash
set -euo pipefail

echo "Starting Debian-specific setup..."

export DEBIAN_FRONTEND=noninteractive

echo "Updating package repositories..."
apt-get update

echo "Installing essential packages..."
apt-get install -y \
    curl \
    wget \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    sudo \
    vim \
    htop \
    tree \
    unzip \
    git \
    rsync \
    lvm2 \
    parted \
    cloud-init \
    python3 \
    python3-pip

echo "Configuring SSH..."
systemctl enable ssh
systemctl start ssh

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

echo "Configuring timezone..."
timedatectl set-timezone UTC

echo "Setting up systemd services..."
systemctl enable systemd-networkd
systemctl enable systemd-resolved

echo "Configuring cloud-init..."
if [ ! -d /etc/cloud ]; then
    mkdir -p /etc/cloud
fi

cat > /etc/cloud/cloud.cfg << 'EOF'
users:
 - default

disable_root: 0
ssh_pwauth:   1

locale_configfile: /etc/default/locale
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
ssh_deletekeys:   1
ssh_genkeytypes:  ~
syslog_fix_perms: ~

cloud_init_modules:
 - migrator
 - seed_random
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - disk_setup
 - mounts
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - users-groups
 - ssh

cloud_config_modules:
 - emit_upstart
 - ssh-import-id
 - locale
 - set-passwords
 - grub-dpkg
 - apt-pipelining
 - apt-configure
 - ubuntu-advantage
 - ntp
 - timezone
 - disable-ec2-metadata
 - runcmd
 - byobu

cloud_final_modules:
 - package-update-upgrade-install
 - fan
 - landscape
 - lxd
 - ubuntu-drivers
 - puppet
 - chef
 - mcollective
 - salt-minion
 - rightscale_userdata
 - scripts-vendor
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message
 - power-state-change

system_info:
  default_user:
    name: debian
    lock_passwd: True
    gecos: Debian
    groups: [adm, audio, cdrom, dialout, dip, floppy, lxd, netdev, plugdev, sudo, video]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: debian
  paths:
    cloud_dir: /var/lib/cloud/
    run_dir: /run/cloud-init/
  ssh_svcname: ssh
EOF

echo "Debian-specific setup completed"