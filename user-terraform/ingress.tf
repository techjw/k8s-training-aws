data "template_file" "icfg" {
  template = "${file("${path.module}/init.yaml.tpl")}"
  vars {
    hostname = "${var.project}-ingress-1"
  }
}

resource "aws_instance" "k8singress" {
  ami             = "${var.ami_id}"
  ebs_optimized   = "${var.ingress_ebs_optimized}"
  instance_type   = "${var.ingress_type}"
  subnet_id       = "${aws_subnet.subnet_pub1.id}"
  key_name        = "${aws_key_pair.kubernetes.key_name}"
  user_data       = "${data.template_file.icfg.rendered}"
  vpc_security_group_ids      = ["${aws_security_group.kubernetes.id}", "${aws_security_group.kubeingress.id}"]
  associate_public_ip_address = true
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-ingress-1"
    project = "${var.project}"
    kube_component = "ingress"
  }
}
