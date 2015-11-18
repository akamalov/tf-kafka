resource "aws_instance" "zookeeper" {
    count = "${var.zookeeper_nodes}"

    ami = "${lookup(var.amis-hvm, var.aws_region)}"
    instance_type = "t2.small"

    key_name = "${var.aws_key_name}"

    vpc_security_group_ids = ["${aws_security_group.zookeeper.id}",
                              "${aws_security_group.common.id}"]

    subnet_id = "${aws_subnet.default.id}"
    private_ip = "10.0.1.${count.index + 1}"

    tags {
        Name = "${format("zookeeper-node-%03d", count.index + 1)}"
        Index = "${count.index + 1}"
    }

    provisioner "remote-exec" {
        connection {
            user = "admin"
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y",
            "sudo apt-get install -y curl default-jdk software-properties-common",
            "curl -s http://packages.confluent.io/deb/1.0/archive.key | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=all] http://packages.confluent.io/deb/1.0 stable main'",
            "sudo apt-get update && sudo apt-get install -y confluent-platform-2.10.4",
            "sudo useradd --home-dir /var/lib/zookeeper --create-home --user-group --shell /usr/sbin/nologin zookeeper",
            "sudo chown -R zookeeper:zookeeper /var/lib/zookeeper",
            "sudo chown -R zookeeper:zookeeper /var/log/kafka",
            "sudo sh -c 'echo tickTime=2000 >> /etc/kafka/zookeeper.properties'",
            "sudo sh -c 'echo initLimit=10 >> /etc/kafka/zookeeper.properties'",
            "sudo sh -c 'echo syncLimit=5 >> /etc/kafka/zookeeper.properties'",
            "sudo sh -c 'echo ${count.index + 1} > /var/lib/zookeeper/myid'"
        ]
    }

    provisioner "file" {
        connection {
            user = "admin"
        }
        source = "data/zookeeper.service"
        destination = "/home/admin/zookeeper.service"
    }

    provisioner "file" {
        connection {
            user = "admin"
        }
        source = "data/add_server.sh"
        destination = "/home/admin/add_server.sh"
    }

    provisioner "remote-exec" {
        connection {
            user = "admin"
        }
        inline = [
            "chmod +x /home/admin/add_server.sh",
            "sudo /home/admin/add_server.sh ${var.zookeeper_nodes}",
            "sudo mv /home/admin/zookeeper.service /etc/systemd/system",
            "sudo systemctl enable zookeeper",
            "sudo systemctl start zookeeper"
        ]
    }
}
