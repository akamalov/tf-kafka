variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_key_path" {}
variable "aws_key_name" {}

variable "allowed_group" {
    description = "Security Group ID that should be allowed to access Prometheus"
}

variable "name" {
    description = "Name of the appliance, that this prometheus instance will handle"
}

variable "size" {
    description = "Size of the instance to be running prometheus"
}

variable "vpc_id" {
    description = "ID of the VPC to launch in"
}

variable "subnet_id" {
    description = "ID of the Subnet to launch in"
}

variable "private_ip" {
    description = "Private IP to assign to the prometheus instance"
}

variable "admin_ip" {
    description = "IP from which administrative tasks can be run"
    default = "87.138.108.187/32"
}

variable "aws_region" {
    description = "EC2 Region for the VPC and Instance"
    default = "eu-central-1"
}

variable "amis_hvm" {
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

variable "amis_pv" {
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
