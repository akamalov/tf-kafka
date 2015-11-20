resource "aws_security_group" "common" {
    name = "kafka-cluster-admin"
    description = "Kafka cluster administrative SG"
    vpc_id = "${aws_vpc.default.id}"
}

resource "aws_security_group_rule" "admin-ssh" {
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["${var.admin_ip}"]
    security_group_id = "${aws_security_group.common.id}"
}

resource "aws_security_group_rule" "admin-icmp" {
    type = "ingress"
    protocol = "icmp"
    from_port = 0
    to_port = 0
    cidr_blocks = ["${var.admin_ip}"]
    security_group_id = "${aws_security_group.common.id}"
}

resource "aws_security_group_rule" "admin-prometheus" {
    type = "ingress"
    protocol = "tcp"
    from_port = 9090
    to_port = 9090
    cidr_blocks = ["${var.admin_ip}"]
    security_group_id = "${aws_security_group.common.id}"
}

resource "aws_security_group_rule" "allow-out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.common.id}"
}


resource "aws_security_group" "kafka" {
    name = "kafka-cluster"
    description = "Kafka cluster SG"
    vpc_id = "${aws_vpc.default.id}"
}

resource "aws_security_group_rule" "kafka-self-allow-in" {
    type = "ingress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
    security_group_id = "${aws_security_group.kafka.id}"
}

resource "aws_security_group_rule" "kafka-self-allow-out" {
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
    security_group_id = "${aws_security_group.kafka.id}"
}

resource "aws_security_group_rule" "kafka-allow-out-zookeeper" {
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    source_security_group_id = "${aws_security_group.zookeeper.id}"
    security_group_id = "${aws_security_group.kafka.id}"
}


resource "aws_security_group" "zookeeper" {
    name = "kafka-cluster-zookeeper"
    description = "Kafka cluster Zookeeper SG"
    vpc_id = "${aws_vpc.default.id}"
}

resource "aws_security_group_rule" "zookeeper-self-allow-in" {
    type = "ingress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
    security_group_id = "${aws_security_group.zookeeper.id}"
}

resource "aws_security_group_rule" "zookeeper-allow-in-kafka" {
    type = "ingress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    source_security_group_id = "${aws_security_group.kafka.id}"
    security_group_id = "${aws_security_group.zookeeper.id}"
}

resource "aws_security_group_rule" "zookeeper-self-allow-out" {
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
    security_group_id = "${aws_security_group.zookeeper.id}"
}
