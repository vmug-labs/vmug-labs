output "domain_controller_private_ip" {
  value = "${aws_instance.domain_controller.private_ip}"
}

output "domain_controller_base64-encoded_ec2-key-encrypted_password" {
  value = "${aws_instance.domain_controller.password_data}"
}
