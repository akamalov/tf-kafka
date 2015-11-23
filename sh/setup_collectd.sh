#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

LOCAL_NAME=${1:-""}
PROMETHEUS=${1:-""}

COLLECTD_VERSION="5.5.0"

die() {
  echo "Usage: $0 HOSTNAME PROMETHEUS_IP"
  exit 1
}

test -z "$LOCAL_NAME" && die
test -z "$PROMETHEUS" && die

sudo apt-get build-dep -y collectd collectd-utils

cd /tmp
curl -Ls "http://collectd.org/files/collectd-${COLLECTD_VERSION}.tar.gz" > /tmp/collectd.tar.gz
tar xzf collectd.tar.gz

cd "/tmp/collectd-$COLLECTD_VERSION"
./configure
make
sudo make install

COLLECTD_CONF="/opt/collectd/etc/collectd.conf"

sudo mv /home/admin/collectd.conf "$COLLECTD_CONF"
sudo chown root:root "$COLLECTD_CONF"
sudo sh -c "'echo Hostname \"${LOCAL_NAME}\"' >> $COLLECTD_CONF"
sudo sed -i s/PROMETHEUS/"$PROMETHEUS"/ "$COLLECTD_CONF"

sudo mv /home/admin/collectd.service /etc/systemd/system
sudo chown root:root /etc/systemd/system/collectd.service

sudo systemctl enable collectd
sudo systemctl restart collectd
