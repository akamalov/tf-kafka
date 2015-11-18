module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_coreos_ami"
  region = "${var.aws_region}"
  channel = "stable"
  virttype = "hvm"
}

resource "aws_instance" "zookeeper" {
    ami = "${module.ami.ami_id}"
    instance_type = "t2.small"
    user_data = "${file("data/coreos-no-restart.yaml")}"

    key_name = "${var.aws_key_name}"

    vpc_security_group_ids = ["${aws_security_group.zookeeper.id}",
                              "${aws_security_group.common.id}"]

    tags {
        Name = "zookeeper-node-001"
        Index = "1"
    }

    provisioner "remote-exec" {
        connection {
            user = "core"
        }
        inline = [
            "docker run -d --restart always \\",
            "--name zk_${count.index + 1} \\",
            "--hostname zk_${count.index + 1} \\",
            "-p 2181:2181 -p 2888:2888 -p 3888:3888 \\",
            "advancedtelematic/alpine-zookeeper ${count.index + 1}"
        ]
    }
}

resource "aws_instance" "kafka" {
    count = "${var.kafka_nodes}"

    ami = "${module.ami.ami_id}"
    instance_type = "t2.medium"
    user_data = "${file("data/coreos.yaml")}"

    key_name = "${var.aws_key_name}"

    vpc_security_group_ids = ["${aws_security_group.kafka.id}",
                              "${aws_security_group.common.id}"]

    tags {
        Name = "${format("kafka-node-%03d", count.index + 1)}"
        Index = "${count.index + 1}"
    }

    provisioner "remote-exec" {
        connection {
            user = "core"
        }
        inline = [
            "sudo mkdir /home/core/kafka_{data,logs}",
            "sudo chown 1000:1000 /home/core/kafka_{data,logs}",
            "docker run -d --restart always \\",
            "--name kafka_${count.index + 1} \\",
            "--publish 9092:9092 \\",
            "--volume /home/core/kafka_data:/data \\",
            "--volume /home/core/kafka_logs:/logs \\",
            "--env ZOOKEEPER_IP=${aws_instance.zookeeper.private_ip} \\",
            "ches/kafka"
        ]
    }
}
