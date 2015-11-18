# Kafka on CoreOS

## Deploy

* `cp terraform.tfvars.example terraform.tfvars`
* edit `terraform.tfvars` to include your credentials
* scale the cluster with the variable `kafka_nodes`, `kafka_size` and
  `zookeeper_size`
* `terraform plan`
* `terraform apply`
