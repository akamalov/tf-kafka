#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

ZK_ID=${1:-""}
ZK_COUNT="${2:-1}"

die() {
  echo "Usage: $0 ZOOKEEPER_ID [ZOKEEPER_COUNT]"
  exit 1
}

test -z "$ZK_ID" && die

apt-get install -y curl default-jdk software-properties-common

curl -s 'http://packages.confluent.io/deb/1.0/archive.key' | apt-key add -
add-apt-repository 'deb [arch=all] http://packages.confluent.io/deb/1.0 stable main'

apt-get update
apt-get install -y confluent-platform-2.10.4

useradd \
  --home-dir /var/lib/zookeeper \
  --create-home \
  --user-group \
  --shell /usr/sbin/nologin \
  zookeeper

chown -R zookeeper:zookeeper /var/lib/zookeeper /var/log/kafka
sh -c "echo tickTime=2000 >> /etc/kafka/zookeeper.properties"
sh -c "echo initLimit=10 >> /etc/kafka/zookeeper.properties"
sh -c "echo syncLimit=5 >> /etc/kafka/zookeeper.properties"
sh -c "echo $ZK_ID > /var/lib/zookeeper/myid"

for ((i=1; i<=ZK_COUNT; i++)); do
  sh -c "echo server.$i=10.0.1.$i:2888:3888 >> /etc/kafka/zookeeper.properties"
done

mv /home/admin/zookeeper.service /etc/systemd/system
systemctl start zookeeper
systemctl enable zookeeper
