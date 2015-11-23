#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

ZK_IPS=${1:-""}
INDEX=${2:-""}
PARTITIONS=${3:=""}
REPLICATION=${4:=""}

die() {
  echo "Usage: $0 ZOOKEEPER_IPS ID PARTITIONS REPLACTION"
  echo "This script needs root access"
  exit 1
}

test -z "$ZK_IPS" && die
test -z "$INDEX" && die
test -z "$PARTITIONS" && die
test -z "$REPLICATION" && die
test 0 -nq $EUID && die

apt-get install -y curl default-jdk software-properties-common

mkfs -t ext4 /dev/xvdh
mkdir -p /var/lib/kafka
mount /dev/xvdh /var/lib/kafka
mkdir /var/lib/kafka/data

curl -s "http://packages.confluent.io/deb/1.0/archive.key" | apt-key add -
add-apt-repository 'deb [arch=all] http://packages.confluent.io/deb/1.0 stable main'
apt-get update
apt-get install -y confluent-platform-2.10.4

sed -i 's,log.dirs=.*$,log.dirs=/var/lib/kafka/data,' /etc/kafka/server.properties
sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=${ZK_IPS}/" \
  /etc/kafka/server.properties
sed -i "s/broker.id=0/broker.id=${INDEX}/" /etc/kafka/server.properties
sed -i "s/num.partitions=1/num.partitions=${PARTITIONS}/" /etc/kafka/server.properties
sed -i "s/default.replication.factor=1/default.replication.factor=${REPLICATION}/" \
  /etc/kafka/server.properties

MY_IP="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"
echo "advertised.host.name=$MY_IP" >> /etc/kafka/server.properties

useradd \
  --home-dir /var/lib/kafka \
  --create-home \
  --user-group \
  --shell /usr/sbin/nologin \
  kafka

chown -R kafka:kafka /var/lib/kafka /var/log/kafka

mv /home/admin/kafka.service /etc/systemd/system
systemctl start kafka
systemctl enable kafka
