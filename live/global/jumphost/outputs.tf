output "jumphost_public_dns" {
  value = "${aws_instance.jumphost.public_dns}"
}

output "jumphost_base64-encoded_ec2-key-encrypted_password" {
  value = "${aws_instance.jumphost.password_data}"
}
