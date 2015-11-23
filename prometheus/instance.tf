resource "aws_instance" "prometheus" {
    ami = "${lookup(var.amis_hvm, var.aws_region)}"
    instance_type = "${var.size}"

    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.prometheus.id}"]

    subnet_id = "${var.subnet_id}"
    private_ip = "${var.private_ip}"

    tags {
        Name = "${format("prometheus-%s", var.name)}"
    }

    connection {
        type = "ssh"
        user = "admin"
    }

    provisioner "remote-exec" {
        script = "${path.module}/sh/install.sh"
    }

    provisioner "file" {
        source = "${path.module}/data/prometheus.yml"
        destination = "/home/admin/prometheus.yml"
    }

    provisioner "file" {
        source = "${path.module}/data/prometheus.service"
        destination = "/home/admin/prometheus.service"
    }

    provisioner "file" {
        source = "${path.module}/data/collectd_exporter.service"
        destination = "/home/admin/collectd_exporter.service"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mv /home/admin/prometheus.yml /opt/prometheus",
            "sudo chown prometheus:prometheus /opt/prometheus/prometheus.yml",

            "sudo mv /home/admin/prometheus.service /etc/systemd/system",
            "sudo chown root:root /etc/systemd/system/prometheus.service",

            "sudo mv /home/admin/collectd_exporter.service /etc/systemd/system",
            "sudo chown root:root /etc/systemd/system/collectd_exporter.service",

            "sudo systemctl enable prometheus collectd_exporter",
            "sudo systemctl restart prometheus collectd_exporter"
        ]
    }
}

output "public_ip" {
    value = "${aws_instance.prometheus.public_ip}"
}

output "private_ip" {
    value = "${aws_instance.prometheus.private_ip}"
}
