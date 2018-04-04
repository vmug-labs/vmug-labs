output "password" {
  value = "${var.random_password ? random_string.password.result : var.default_password}"
}
