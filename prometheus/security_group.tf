resource "aws_security_group" "prometheus" {
    name = "prometheus"
    description = "Prometheus SG"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.admin_ip}"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["${var.admin_ip}"]
    }

    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        cidr_blocks = ["${var.admin_ip}"]
    }

    ingress {
        from_port = 25826
        to_port = 25826
        protocol = "udp"
        security_groups = ["${var.allowed_group}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
