resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"

    tags {
        Name = "VPC for the Kafka cluster"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "Gateway for the Kafka cluster"
    }
}

resource "aws_subnet" "default" {
    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "${var.aws_zone}"
    cidr_block = "10.0.0.0/16"

    map_public_ip_on_launch = true

    tags {
        Name = "Subnet for the Kafka cluster"
    }
}

resource "aws_route_table" "default" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }
}

resource "aws_route_table_association" "default" {
    subnet_id = "${aws_subnet.default.id}"
    route_table_id = "${aws_route_table.default.id}"
}
