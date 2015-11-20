module "prometheus" {
    source = "prometheus"

    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    aws_key_path = "${var.aws_key_path}"
    aws_key_name = "${var.aws_key_name}"

    allowed_group = "${aws_security_group.common.id}"
    name = "kafka-cluster"

    size = "${var.prometheus_size}"

    admin_ip = "${var.admin_ip}"

    aws_region = "${var.aws_region}"

    vpc_id = "${aws_vpc.default.id}"
    subnet_id = "${aws_subnet.default.id}"
    private_ip = "10.0.0.16"
}

output "prometheus.public_ip" {
    value = "${module.prometheus.public_ip}"
}

output "prometheus.private_ip" {
    value = "${module.prometheus.private_ip}"
}
