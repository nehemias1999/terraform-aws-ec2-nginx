#!/bin/bash
# Runs ONLY ONCE, as root, on the instance's first boot
set -euxo pipefail

dnf install -y nginx
systemctl enable --now nginx
