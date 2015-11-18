#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

COUNT="${1:-1}"

for ((i=1; i<=COUNT; i++)); do
  echo "server.$i=10.0.1.$i:2888:3888" >> /etc/kafka/zookeeper.properties
done
