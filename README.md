# Kafka on CoreOS

## Deploy

* `cp terraform.tfvars.example terraform.tfvars`
* edit `terraform.tfvars` to include your credentials
* scale the cluster with the variable `kafka_nodes`, `kafka_size` and
  `zookeeper_size`
* `terraform get`
* `for i in $(ls .terraform/modules/*/Makefile); do i=$(dirname $i); make -C $i; done`
* `terraform plan`
* `terraform apply`
