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

variable "kafka_partitions" {
    description = "Number of Kafka partitions per topic"
    default = 3
}

variable "kafka_replication" {
    description = "Replication factor for Kafka"
    default = 3
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

variable "amis-hvm" {
    description = "AMIs by region (HVM)"
    default = {
        ap-northeast-1 = "ami-e624fbe6"
        ap-southeast-1 = "ami-ac360cfe"
        ap-southeast-2 = "ami-bbc5bd81"
        eu-central-1   = "ami-02b78e1f"
        eu-west-1      = "ami-e31a6594"
        sa-east-1      = "ami-0972f214"
        us-east-1      = "ami-116d857a"
        us-west-1      = "ami-05cf2541"
        us-west-2      = "ami-818eb7b1"
        cn-north-1     = "ami-888815b1"
        us-gov-west-1  = "ami-35b5d516"
    }
}

variable "amis-pv" {
    description = "AMIs by region (Paravirtual)"
    default = {
        ap-northeast-1 = "ami-0822fd08"
        ap-southeast-1 = "ami-4e370d1c"
        ap-southeast-2 = "ami-e7c5bddd"
        eu-central-1   = "ami-5cb78e41"
        eu-west-1      = "ami-971a65e0"
        sa-east-1      = "ami-5972f244"
        us-east-1      = "ami-896d85e2"
        us-west-1      = "ami-21cf2565"
        us-west-2      = "ami-ed8eb7dd"
        us-gov-west-1  = "ami-3fb5d51c"
    }
}
