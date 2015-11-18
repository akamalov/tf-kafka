resource "aws_instance" "zookeeper" {
    ami = "${lookup(var.amis-hvm, var.aws_region)}"
    instance_type = "t2.small"

    key_name = "${var.aws_key_name}"

    vpc_security_group_ids = ["${aws_security_group.zookeeper.id}",
                              "${aws_security_group.common.id}"]

    tags {
        Name = "zookeeper-node-001"
        Index = "1"
    }

    provisioner "remote-exec" {
        connection {
            user = "admin"
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y",
            "sudo apt-get install -y wget default-jdk software-properties-common",
            "wget -qO - http://packages.confluent.io/deb/1.0/archive.key | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=all] http://packages.confluent.io/deb/1.0 stable main'",
            "sudo apt-get update && sudo apt-get install -y confluent-platform-2.10.4",
            "sudo useradd --home-dir /var/lib/zookeeper --create-home --user-group --shell /usr/sbin/nologin zookeeper",
            "sudo chown -R zookeeper:zookeeper /var/lib/zookeeper",
            "sudo chown -R zookeeper:zookeeper /var/log/kafka"
        ]
    }

    provisioner "file" {
        connection {
            user = "admin"
        }
        source = "data/zookeeper.service"
        destination = "/home/admin/zookeeper.service"
    }

    provisioner "remote-exec" {
        connection {
            user = "admin"
        }
        inline = [
            "sudo mv /home/admin/zookeeper.service /etc/systemd/system",
            "sudo systemctl enable zookeeper",
            "sudo systemctl start zookeeper"
        ]
    }
}

resource "aws_instance" "kafka" {
    count = "${var.kafka_nodes}"

    ami = "${lookup(var.amis-hvm, var.aws_region)}"
    instance_type = "t2.medium"

    key_name = "${var.aws_key_name}"

    vpc_security_group_ids = ["${aws_security_group.kafka.id}",
                              "${aws_security_group.common.id}"]

    tags {
        Name = "${format("kafka-node-%03d", count.index + 1)}"
        Index = "${count.index + 1}"
    }

    provisioner "remote-exec" {
        connection {
            user = "admin"
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y",
            "sudo apt-get install -y wget default-jdk software-properties-common",
            "wget -qO - http://packages.confluent.io/deb/1.0/archive.key | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=all] http://packages.confluent.io/deb/1.0 stable main'",
            "sudo apt-get update && sudo apt-get install -y confluent-platform-2.10.4",
            "sudo sed -i s/zookeeper.connect=localhost:2181/zookeeper.connect=${aws_instance.zookeeper.private_ip}:2181/ /etc/kafka/server.properties",
            "sudo sed -i s/broker.id=0/broker.id=${count.index + 1}/ /etc/kafka/server.properties",
            "sudo sed -i s/num.partitions=1/num.partitions=${var.kafka_partitions}/ /etc/kafka/server.properties",
            "sudo useradd --home-dir /var/lib/kafka --create-home --user-group --shell /usr/sbin/nologin kafka",
            "sudo chown -R kafka:kafka /var/lib/kafka",
            "sudo chown -R kafka:kafka /var/log/kafka"
        ]
    }

    provisioner "file" {
        connection {
            user = "admin"
        }
        source = "data/kafka.service"
        destination = "/home/admin/kafka.service"
    }

    provisioner "remote-exec" {
        connection {
            user = "admin"
        }
        inline = [
            "sudo mv /home/admin/kafka.service /etc/systemd/system",
            "sudo systemctl enable kafka",
            "sudo systemctl start kafka"
        ]
    }
}
