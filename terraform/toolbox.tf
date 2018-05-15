data "template_file" "tcfg" {
  template = "${file("${path.module}/user-data/init.yaml.tpl")}"
  vars {
    hostname = "${var.project}-toolbox"
  }
}

resource "aws_instance" "toolbox" {
  ami             = "${var.ami_id}"
  ebs_optimized   = "${var.ebs_optimized}"
  instance_type   = "${var.instance_type}"
  subnet_id       = "${aws_subnet.toolbox.id}"
  key_name        = "${aws_key_pair.toolbox.key_name}"
  user_data       = "${data.template_file.tcfg.rendered}"
  vpc_security_group_ids      = ["${aws_security_group.toolbox.id}"]
  associate_public_ip_address = true
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-toolbox"
    project = "${var.project}"
  }

  connection {
    type        = "ssh"
    private_key = "${file("${path.module}/../ssh/cluster.pem")}"
    user        = "ubuntu"
    host        = "${aws_instance.toolbox.public_ip}"
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "${path.module}/../ssh/cluster.pem"
    destination = "/home/ubuntu/kismatic.pem"
  }

  provisioner "file" {
    source = "${path.module}/user-data/kismatic-ansible.yaml"
    destination = "/home/ubuntu/kismatic-ansible.yaml"
  }

  provisioner "file" {
    source = "${path.module}/user-data/kismatic-cluster.yaml.j2"
    destination = "/home/ubuntu/kismatic-cluster.yaml.j2"
  }

  provisioner "file" {
    source = "${path.module}/user-data/prep-users.sh"
    destination = "/home/ubuntu/prep-users.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y -q",
      "sudo apt-get install -y -q ansible"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 kismatic.pem kismatic-ansible.yaml kismatic-cluster.yaml.j2",
      "chown ubuntu:ubuntu kismatic.pem kismatic-ansible.yaml kismatic-cluster.yaml.j2 prep-users.sh",
      "chmod 700 prep-users.sh"
    ]
  }
}

resource "aws_eip" "toolbox" {
  instance    = "${aws_instance.toolbox.id}"
  vpc         = true
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-toolbox-eip"
    project = "${var.project}"
  }
}
