#!/bin/bash
set -euo pipefail

echo "Starting system cleanup..."

if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    
    echo "Cleaning package cache..."
    apt-get clean
    apt-get autoclean
    apt-get autoremove -y
    
    rm -rf /var/lib/apt/lists/*
    
elif command -v yum >/dev/null 2>&1; then
    echo "Cleaning package cache..."
    yum clean all
    rm -rf /var/cache/yum/*
    
elif command -v dnf >/dev/null 2>&1; then
    echo "Cleaning package cache..."
    dnf clean all
    rm -rf /var/cache/dnf/*
fi

echo "Clearing log files..."
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
find /var/log -type f -name "*.log.*" -delete
truncate -s 0 /var/log/wtmp /var/log/lastlog /var/log/btmp || true

echo "Clearing temporary files..."
rm -rf /tmp/*
rm -rf /var/tmp/*

echo "Clearing bash history..."
history -c
cat /dev/null > ~/.bash_history
unset HISTFILE

echo "Clearing SSH host keys..."
rm -f /etc/ssh/ssh_host_*

echo "Clearing machine ID..."
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id

echo "Clearing network configuration..."
if [ -d /etc/netplan ]; then
    find /etc/netplan -name "*.yaml" -exec sed -i '/dhcp-identifier:/d' {} \; || true
fi

echo "Clearing cloud-init data..."
rm -rf /var/lib/cloud/instances/*
rm -rf /var/lib/cloud/data/*
rm -rf /var/log/cloud-init*.log

echo "Clearing user data..."
rm -f /root/.bash_history
rm -f /root/.ssh/known_hosts

echo "Synchronizing filesystem..."
sync

echo "System cleanup completed"