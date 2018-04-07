output "private_ip" {
  value = "${aws_instance.domain_controller.private_ip}"
}

output "password" {
  value = "${rsadecrypt("${aws_instance.domain_controller.password_data}", file("${module.global_variables.key_path}"))}"
}

output "domain_name" {
  value = "${var.domain_name}"
}

output "domain_netbios_name" {
  value = "${var.domain_netbios_name}"
}

output "safe_mode_administrator_password" {
  value = "${random_string.safe_mode_administrator_password.result}"
}
