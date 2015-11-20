#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

PROMETHEUS_VERSION="0.16.1"
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

COLLECTDEX_VERSION="0.2.0"
COLLECTDEX_URL="https://github.com/prometheus/collectd_exporter/releases/download/${COLLECTDEX_VERSION}/collectd_exporter-${COLLECTDEX_VERSION}.linux-amd64.tar.gz "

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y curl

cd /tmp

curl -Ls "$PROMETHEUS_URL" > /tmp/prometheus.tar.gz
tar xzf prometheus.tar.gz
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64 /opt/prometheus

curl -Ls "$COLLECTDEX_URL" > /tmp/collectd_exporter.tar.gz
tar xzf collectd_exporter.tar.gz
sudo mv collectd_exporter /opt/prometheus

sudo useradd \
  --home-dir /opt/prometheus \
  --create-home \
  --user-group \
  --shell /usr/sbin/nologin \
  prometheus

sudo chown -R prometheus:prometheus /opt/prometheus
