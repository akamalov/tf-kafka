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

    ebs_block_device {
        device_name = "/dev/xvdh"
        volume_type = "io1"
        volume_size = 100
        iops = 3000
    }

    connection {
        type = "ssh"
        user = "admin"
    }

    provisioner "file" {
        source = "sh/setup_kafka.sh"
        destination = "/home/admin/setup_kafka.sh"
    }

    provisioner "file" {
        source = "data/kafka.service"
        destination = "/home/admin/kafka.service"
    }

    provisioner "file" {
        source = "sh/setup_collectd.sh"
        destination = "/home/admin/setup_collectd.sh"
    }

    provisioner "file" {
        source = "data/collectd.conf"
        destination = "/home/admin/collectd.conf"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y",

            "chmod +x /home/admin/setup_kafka.sh",
            "sudo /home/admin/setup_kafka.sh \\",
            "  ${join(",",formatlist("%s:%s", aws_instance.zookeeper.*.private_ip, "2181"))} \\",
            "  ${count.index + 1} \\",
            "  ${var.kafka_partitions} \\",
            "  ${var.kafka_replication}",

            "chmod +x setup_collectd.sh",
            "sudo /home/admin/setup_collectd.sh \\",
            "  ${format("kafka-node-%03d", count.index + 1)} \\",
            "  ${module.prometheus.private_ip}"
        ]
    }
}

output "kafka.brokers_private" {
    value = "${join(",", aws_instance.kafka.*.private_ip)}"
}

output "kafka.brokers_public" {
    value = "${join(",", aws_instance.kafka.*.public_ip)}"
}
