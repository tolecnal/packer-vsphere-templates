#!/bin/bash
set -euo pipefail

echo "Setting up Ansible service account..."

if [ -z "${ANSIBLE_USER:-}" ] || [ -z "${ANSIBLE_USER_PASSWORD:-}" ] || [ -z "${ANSIBLE_PUBLIC_KEY:-}" ]; then
    echo "Error: ANSIBLE_USER, ANSIBLE_USER_PASSWORD, and ANSIBLE_PUBLIC_KEY environment variables are required"
    exit 1
fi

useradd -m -s /bin/bash "${ANSIBLE_USER}"
echo "${ANSIBLE_USER}:${ANSIBLE_USER_PASSWORD}" | chpasswd

usermod -aG sudo "${ANSIBLE_USER}"

echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${ANSIBLE_USER}"
chmod 0440 "/etc/sudoers.d/${ANSIBLE_USER}"

mkdir -p "/home/${ANSIBLE_USER}/.ssh"
echo "${ANSIBLE_PUBLIC_KEY}" > "/home/${ANSIBLE_USER}/.ssh/authorized_keys"
chmod 700 "/home/${ANSIBLE_USER}/.ssh"
chmod 600 "/home/${ANSIBLE_USER}/.ssh/authorized_keys"
chown -R "${ANSIBLE_USER}:${ANSIBLE_USER}" "/home/${ANSIBLE_USER}/.ssh"

echo "Ansible service account setup completed"