#!/bin/bash
set -euo pipefail

echo "Configuring LVM settings..."

if [ ! -f /etc/lvm/lvm.conf ]; then
    echo "LVM configuration file not found, skipping LVM configuration"
    exit 0
fi

cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak

sed -i 's/# use_devicesfile = 1/use_devicesfile = 0/' /etc/lvm/lvm.conf || true

if grep -q "scan = \[ \"\/dev\/\" \]" /etc/lvm/lvm.conf; then
    echo "LVM scan filter already configured"
else
    sed -i '/devices {/a\        scan = [ "/dev/" ]' /etc/lvm/lvm.conf || true
fi

if command -v vgdisplay >/dev/null 2>&1; then
    echo "Available volume groups:"
    vgdisplay --short || true
    
    echo "Available logical volumes:"
    lvdisplay --short || true
fi

echo "LVM configuration completed"