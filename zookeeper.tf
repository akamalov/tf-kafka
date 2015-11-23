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

    provisioner "file" {
        source = "sh/setup_zookeeper.sh"
        destination = "/home/admin/setup_zookeeper.sh"
    }

    provisioner "file" {
        source = "data/zookeeper.service"
        destination = "/home/admin/zookeeper.service"
    }

    provisioner "file" {
        source = "sh/setup_collectd.sh"
        destination = "/home/admin/setup_collectd.sh"
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
            "sudo apt-get update",
            "sudo apt-get upgrade -y",

            "chmod +x setup_zookeeper.sh",
            "sudo /home/admin/setup_zookeeper.sh \\",
            "  ${count.index + 1} \\",
            "  ${var.zookeeper_nodes}",

            "chmod +x setup_collectd.sh",
            "./setup_collectd.sh \\",
            "  ${format("zookeeper-node-%03d", count.index + 1)} \\",
            "  ${module.prometheus.private_ip}",
        ]
    }
}

output "zookeeper.nodes_private" {
  value = "${join(",", aws_instance.zookeeper.*.private_ip)}"
}

output "zookeeper.nodes_public" {
  value = "${join(",", aws_instance.zookeeper.*.public_ip)}"
}
