output "toolbox_public_ip" {
    value = "${aws_eip.toolbox.public_ip}"
}
