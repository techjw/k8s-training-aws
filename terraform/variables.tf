variable "ami_id" { default = "ami-9c56efe3" }

variable "instance_type" { default = "t2.micro" }
variable "ebs_optimized" { default = false }

variable "aws_region"  { default = "us-east-1" }
variable "vpc_cidr"    { default = "10.1.0.0/28" }
variable "subnet_az"   { default = "us-east-1c" }
variable "subnet_cidr" { default = "10.1.0.0/28" }

variable "local_cidr" { default = "127.0.0.1/32" }
variable "ssh_key"    { default = "../ssh/cluster.pem.pub" }

variable "environment" { default = "training" }
variable "project"     { default = "k8s" }

variable "aws_access_key" {}
variable "aws_secret_key" {}
