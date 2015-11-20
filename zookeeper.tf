resource "aws_instance" "zookeeper" {
    count = "${var.zookeeper_nodes}"

    ami = "${lookup(var.amis-hvm, var.aws_region)}"
    instance_type = "${var.zookeeper_size}"

    key_name = "${var.aws_key_name}"

    vpc_security_group_ids = ["${aws_security_group.zookeeper.id}",
                              "${aws_security_group.common.id}"]

    subnet_id = "${aws_subnet.default.id}"
    private_ip = "10.0.1.${count.index + 1}"

    tags {
        Name = "${format("zookeeper-node-%03d", count.index + 1)}"
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
            "sudo useradd --home-dir /var/lib/zookeeper --create-home --user-group --shell /usr/sbin/nologin zookeeper",
            "sudo chown -R zookeeper:zookeeper /var/lib/zookeeper",
            "sudo chown -R zookeeper:zookeeper /var/log/kafka",
            "sudo sh -c 'echo tickTime=2000 >> /etc/kafka/zookeeper.properties'",
            "sudo sh -c 'echo initLimit=10 >> /etc/kafka/zookeeper.properties'",
            "sudo sh -c 'echo syncLimit=5 >> /etc/kafka/zookeeper.properties'",
            "sudo sh -c 'echo ${count.index + 1} > /var/lib/zookeeper/myid'",
            "sudo apt-get build-dep -y collectd collectd-utils",
            "curl -Ls http://collectd.org/files/collectd-5.5.0.tar.gz > /tmp/collectd.tar.gz",
            "cd /tmp && tar xzf collectd.tar.gz",
            "cd /tmp/collectd-5.5.0 && ./configure && make && sudo make install",
        ]
    }

    provisioner "file" {
        source = "data/zookeeper.service"
        destination = "/home/admin/zookeeper.service"
    }

    provisioner "file" {
        source = "data/add_server.sh"
        destination = "/home/admin/add_server.sh"
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
            "chmod +x /home/admin/add_server.sh",
            "sudo /home/admin/add_server.sh ${var.zookeeper_nodes}",
            "sudo mv /home/admin/zookeeper.service /etc/systemd/system",
            "sudo systemctl enable zookeeper",
            "sudo systemctl start zookeeper",
            "sudo mv /home/admin/collectd.conf /opt/collectd/etc/collectd.conf && sudo chown root:root /opt/collectd/etc/collectd.conf",
            "sudo sh -c 'echo Hostname \"${format("zookeeper-node-%03d", count.index + 1)}\" >> /opt/collectd/etc/collectd.conf'",
            "sudo mv /home/admin/collectd.conf /opt/collectd/etc/collectd.conf",
            "sudo mv /home/admin/collectd.service /etc/systemd/system",
            "sudo chown root:root /etc/systemd/system/collectd.service",
            "sudo sed -i s/PROMETHEUS/${module.prometheus.private_ip}/ /opt/collectd/etc/collectd.conf",
            "sudo systemctl restart collectd",
            "sudo systemctl enable collectd"
        ]
    }
}

output "zookeeper.nodes_private" {
  value = "${join(",", aws_instance.zookeeper.*.private_ip)}"
}

output "zookeeper.nodes_public" {
  value = "${join(",", aws_instance.zookeeper.*.public_ip)}"
}
