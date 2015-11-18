variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_key_path" {}
variable "aws_key_name" {}

variable "kafka_nodes" {
    description = "Amount of Kafka nodes to be deployed."
    default = 3
}

variable "kafka_size" {
    description = "Size of the Kafka instances"
    default = "t2.medium"
}

variable "zookeeper_size" {
    description = "Size of the Zookeeper instance"
    default = "t2.small"
}

variable "admin_ip" {
    description = "IP from which administrative tasks can be run"
    default = "87.138.108.187/32"
}

variable "aws_region" {
    description = "EC2 Region for the VPC and Instance"
    default = "eu-central-1"
}

variable "aws_zone" {
    description = "EC2 Availability Zone for the VPC and Instance"
    default = "eu-central-1a"
}
