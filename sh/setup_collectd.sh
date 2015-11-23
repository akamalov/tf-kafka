#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

LOCAL_NAME=${1:-""}
PROMETHEUS=${2:-""}

die() {
  echo "Usage: $0 HOSTNAME PROMETHEUS_IP"
  exit 1
}

test -z "$LOCAL_NAME" && die
test -z "$PROMETHEUS" && die

echo 'deb http://http.debian.net/debian jessie-backports main' >> /etc/apt/sources.list
apt-get update
# installation fails because of invalid configuration file
apt-get -t jessie-backports install -y collectd collectd-utils || true

COLLECTD_CONF="/etc/collectd/collectd.conf"

mv /home/admin/collectd.conf "$COLLECTD_CONF"
chown root:root "$COLLECTD_CONF"
sh -c "echo Hostname \"${LOCAL_NAME}\" >> $COLLECTD_CONF"
sed -i s/PROMETHEUS/"$PROMETHEUS"/ "$COLLECTD_CONF"

systemctl enable collectd
systemctl restart collectd
