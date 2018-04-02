output "public_dns" {
  value = "${aws_instance.jumphost.public_dns}"
}

output "password" {
  value = "${rsadecrypt("${aws_instance.jumphost.password_data}", file("${module.global_variables.key_path}"))}"
}
