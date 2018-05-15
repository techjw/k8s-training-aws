data "template_file" "wcfg" {
  count = "${var.worker_count}"
  template = "${file("${path.module}/init.yaml.tpl")}"
  vars {
    index = "${count.index}"
    hostname = "${var.project}-worker-${count.index + 1}"
  }
}

resource "aws_instance" "k8sworker" {
  count = "${var.worker_count}"
  ami             = "${var.ami_id}"
  ebs_optimized   = "${var.worker_ebs_optimized}"
  instance_type   = "${var.worker_type}"
  subnet_id       = "${aws_subnet.subnet_pub1.id}"
  key_name        = "${aws_key_pair.kubernetes.key_name}"
  user_data       = "${element(data.template_file.wcfg.*.rendered, count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.kubernetes.id}"]
  associate_public_ip_address = true
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-worker-${count.index + 1}"
    project = "${var.project}"
    kube_component = "worker"
  }
}
