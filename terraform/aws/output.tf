output "director_private_ip" {
  value = "${aws_instance.director.private_ip}"
}

output "director_private_dns" {
  value = "${aws_instance.director.private_dns}"
}

output "director_public_ip" {
  value = "${aws_instance.director.public_ip}"
}

output "director_public_dns" {
  value = "${aws_instance.director.public_dns}"
}

output "director_sg_id" {
  value = "${aws_security_group.public.id}"
}

output "director_subnet_id" {
  value = "${aws_subnet.public.id}"
}

output "director_ami" {
  value = "${aws_instance.director.ami}"
}

output "director_db_subnet_group_name" {
  value = "${aws_db_subnet_group.private.name}"
}