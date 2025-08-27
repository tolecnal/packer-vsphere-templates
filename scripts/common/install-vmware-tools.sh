#!/bin/bash
set -euo pipefail

echo "Installing VMware Tools..."

if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y open-vm-tools
    
    if systemctl list-unit-files | grep -q open-vm-tools; then
        systemctl enable open-vm-tools
        systemctl start open-vm-tools
    fi
    
elif command -v yum >/dev/null 2>&1; then
    yum update -y
    yum install -y open-vm-tools
    
    if systemctl list-unit-files | grep -q vmtoolsd; then
        systemctl enable vmtoolsd
        systemctl start vmtoolsd
    fi
    
elif command -v dnf >/dev/null 2>&1; then
    dnf update -y
    dnf install -y open-vm-tools
    
    if systemctl list-unit-files | grep -q vmtoolsd; then
        systemctl enable vmtoolsd
        systemctl start vmtoolsd
    fi
else
    echo "Unsupported package manager. Please install VMware Tools manually."
    exit 1
fi

echo "VMware Tools installation completed"