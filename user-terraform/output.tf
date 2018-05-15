output "master_ip" {
    value = "${aws_instance.k8smaster.private_ip}"
}
output "master_pubip" {
    value = "${aws_instance.k8smaster.public_ip}"
}
output "master_pubdns" {
    value = "${aws_instance.k8smaster.public_dns}"
}

output "worker1_ip" {
  value = "${aws_instance.k8sworker.*.private_ip[0]}"
}
output "worker1_pubip" {
  value = "${aws_instance.k8sworker.*.public_ip[0]}"
}
output "worker2_ip" {
  value = "${aws_instance.k8sworker.*.private_ip[1]}"
}
output "worker2_pubip" {
  value = "${aws_instance.k8sworker.*.public_ip[1]}"
}

output "ingress_ip" {
    value = "${aws_instance.k8singress.private_ip}"
}
output "ingress_pubip" {
    value = "${aws_instance.k8singress.public_ip}"
}
