provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_vpc" "toolbox" {
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

resource "aws_internet_gateway" "toolbox" {
  vpc_id = "${aws_vpc.toolbox.id}"
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-igw"
    project = "${var.project}"
  }
}

resource "aws_subnet" "toolbox" {
  availability_zone = "${var.subnet_az}"
  cidr_block        = "${var.subnet_cidr}"
  vpc_id            = "${aws_vpc.toolbox.id}"
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-subnet-pub1"
    project = "${var.project}"
  }
}

resource "aws_route_table" "toolbox" {
  vpc_id = "${aws_vpc.toolbox.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.toolbox.id}"
  }
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-subnet-pub1-rt"
    project = "${var.project}"
  }
}

resource "aws_route_table_association" "toolbox" {
  subnet_id      = "${aws_subnet.toolbox.id}"
  route_table_id = "${aws_route_table.toolbox.id}"
}

resource "aws_security_group" "toolbox" {
  name        = "${var.project}-${var.environment}-sg"
  description = "Allow standard access to Kubernetes cluster nodes"
  vpc_id      = "${aws_vpc.toolbox.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.local_cidr}"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.local_cidr}"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
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

resource "aws_key_pair" "toolbox" {
  key_name = "${var.project}-${var.environment}-key"
  public_key = "${file("${path.module}/${var.ssh_key}")}"
}
