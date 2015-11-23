#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

sudo mkfs -t ext4 /dev/xvdh
sudo mkdir -p /var/lib/kafka
sudo mount /dev/xvdh /var/lib/kafka
sudo mkdir /var/lib/kafka/data
