output "vpc_id" {
  value = "${aws_default_vpc.default.id}"
}

output "cidr_block" {
  value = "${aws_default_vpc.default.cidr_block}"
}
