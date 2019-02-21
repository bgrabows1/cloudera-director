resource "aws_key_pair" "director" {
  key_name    = "cloudera-${var.env_name}"
  public_key  = "${file("${var.key_name}.pub")}"
}