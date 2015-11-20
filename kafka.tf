resource "aws_instance" "kafka" {
    count = "${var.kafka_nodes}"

    ami = "${lookup(var.amis-hvm, var.aws_region)}"
    instance_type = "${var.kafka_size}"

    key_name = "${var.aws_key_name}"

    vpc_security_group_ids = ["${aws_security_group.kafka.id}",
                              "${aws_security_group.common.id}"]

    subnet_id = "${aws_subnet.default.id}"
    private_ip = "10.0.2.${count.index + 1}"

    tags {
        Name = "${format("kafka-node-%03d", count.index + 1)}"
        Index = "${count.index + 1}"
    }

    connection {
        type = "ssh"
        user = "admin"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y",
            "sudo apt-get install -y curl default-jdk software-properties-common",
            "curl -s http://packages.confluent.io/deb/1.0/archive.key | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=all] http://packages.confluent.io/deb/1.0 stable main'",
            "sudo apt-get update && sudo apt-get install -y confluent-platform-2.10.4",
            "sudo sed -i s/zookeeper.connect=localhost:2181/zookeeper.connect=${join(",",formatlist("%s:%s", aws_instance.zookeeper.*.private_ip, "2181"))}/ /etc/kafka/server.properties",
            "sudo sed -i s/broker.id=0/broker.id=${count.index + 1}/ /etc/kafka/server.properties",
            "sudo sed -i s/num.partitions=1/num.partitions=${var.kafka_partitions}/ /etc/kafka/server.properties",
            "sudo sed -i s/default.replication.factor=1/default.replication.factor=${var.kafka_replication}/ /etc/kafka/server.properties",
            "sudo useradd --home-dir /var/lib/kafka --create-home --user-group --shell /usr/sbin/nologin kafka",
            "sudo chown -R kafka:kafka /var/lib/kafka",
            "sudo chown -R kafka:kafka /var/log/kafka",
            "sudo apt-get build-dep -y collectd collectd-utils",
            "curl -Ls http://collectd.org/files/collectd-5.5.0.tar.gz > /tmp/collectd.tar.gz",
            "cd /tmp && tar xzf collectd.tar.gz",
            "cd /tmp/collectd-5.5.0 && ./configure && make && sudo make install",
        ]
    }

    provisioner "file" {
        source = "data/kafka.service"
        destination = "/home/admin/kafka.service"
    }

    provisioner "file" {
        source = "data/set_kafka_host.sh"
        destination = "/home/admin/set_kafka_host.sh"
    }

    provisioner "file" {
        source = "data/collectd.conf"
        destination = "/home/admin/collectd.conf"
    }

    provisioner "file" {
        source = "data/collectd.service"
        destination = "/home/admin/collectd.service"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/admin/set_kafka_host.sh",
            "sudo /home/admin/set_kafka_host.sh",
            "sudo mv /home/admin/kafka.service /etc/systemd/system",
            "sudo systemctl enable kafka",
            "sudo systemctl start kafka",
            "sudo mv /home/admin/collectd.conf /opt/collectd/etc/collectd.conf && sudo chown root:root /opt/collectd/etc/collectd.conf",
            "sudo sh -c 'echo Hostname \"${format("kafka-node-%03d", count.index + 1)}\" >> /opt/collectd/etc/collectd.conf'",
            "sudo mv /home/admin/collectd.conf /opt/collectd/etc/collectd.conf",
            "sudo mv /home/admin/collectd.service /etc/systemd/system",
            "sudo chown root:root /etc/systemd/system/collectd.service",
            "sudo sed -i s/PROMETHEUS/${module.prometheus.private_ip}/ /opt/collectd/etc/collectd.conf",
            "sudo systemctl restart collectd",
            "sudo systemctl enable collectd"
        ]
    }
}

output "kafka.brokers_private" {
    value = "${join(",", aws_instance.kafka.*.private_ip)}"
}

output "kafka.brokers_public" {
    value = "${join(",", aws_instance.kafka.*.public_ip)}"
}
