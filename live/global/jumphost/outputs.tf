output "public_dns" {
  value = "${aws_instance.jumphost.public_dns}"
}

output "base64-encoded_ec2-key-encrypted_password" {
  value = "${aws_instance.jumphost.password_data}"
}
