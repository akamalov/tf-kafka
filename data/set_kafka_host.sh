#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

MY_IP="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"
echo "advertised.host.name=$MY_IP" >> /etc/kafka/server.properties
