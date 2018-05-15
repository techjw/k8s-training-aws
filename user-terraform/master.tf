data "template_file" "mcfg" {
  template = "${file("${path.module}/init.yaml.tpl")}"
  vars {
    hostname = "${var.project}-master-1"
  }
}

resource "aws_instance" "k8smaster" {
  ami             = "${var.ami_id}"
  ebs_optimized   = "${var.master_ebs_optimized}"
  instance_type   = "${var.master_type}"
  subnet_id       = "${aws_subnet.subnet_pub1.id}"
  key_name        = "${aws_key_pair.kubernetes.key_name}"
  user_data       = "${data.template_file.mcfg.rendered}"
  vpc_security_group_ids      = ["${aws_security_group.kubernetes.id}", "${aws_security_group.kubeapi.id}"]
  associate_public_ip_address = true
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-master-1"
    project = "${var.project}"
    kube_component = "master"
  }
}
