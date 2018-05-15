provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
      environment = "${var.environment}"
      Name    = "${var.project}-${var.environment}"
      project = "${var.project}"
  }
}

resource "aws_internet_gateway" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-igw"
    project = "${var.project}"
  }
}

resource "aws_subnet" "subnet_pub1" {
  availability_zone = "${var.subnet_az}"
  cidr_block        = "${var.subnet_cidr}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-subnet-pub1"
    project = "${var.project}"
  }
}

resource "aws_route_table" "subnet_pub1" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc.id}"
  }
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-subnet-pub1-rt"
    project = "${var.project}"
  }
}

resource "aws_route_table_association" "subnet_pub1" {
  subnet_id      = "${aws_subnet.subnet_pub1.id}"
  route_table_id = "${aws_route_table.subnet_pub1.id}"
}

resource "aws_security_group" "kubernetes" {
  name        = "${var.project}-${var.environment}-sg"
  description = "Allow standard access to Kubernetes cluster nodes"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.local_cidr}", "${var.toolbox_cidr}"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.local_cidr}", "${var.toolbox_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-sg"
    project = "${var.project}"
  }
}

resource "aws_security_group" "kubeapi" {
  name        = "${var.project}api-${var.environment}-sg"
  description = "Allow access to Kubernetes API"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.local_cidr}", "${var.toolbox_cidr}"]
  }

  tags {
    environment = "${var.environment}"
    Name    = "${var.project}api-${var.environment}-sg"
    project = "${var.project}"
  }
}

resource "aws_security_group" "kubeingress" {
  name        = "${var.project}ingress-${var.environment}-sg"
  description = "Allow access to Kubernetes Ingress"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.local_cidr}", "${var.toolbox_cidr}"]
  }

  tags {
    environment = "${var.environment}"
    Name    = "${var.project}ingress-${var.environment}-sg"
    project = "${var.project}"
  }
}

resource "aws_key_pair" "kubernetes" {
  key_name = "${var.project}-${var.environment}-key"
  public_key = "${file("${path.module}/${var.ssh_key}")}"
}
