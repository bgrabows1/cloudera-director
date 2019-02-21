resource "aws_instance" "director" {
  ami                         = "${lookup(var.ami, var.region)}"
  instance_type               = "${var.director_instance_type}"
  key_name                    = "cloudera-${var.env_name}"
  subnet_id                   = "${aws_subnet.public.id}"
  vpc_security_group_ids      = ["${aws_security_group.public.id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "${var.director_volume_type}"
    volume_size           = "${var.director_volume_size}"
    iops                  = "${var.director_iops}"
    delete_on_termination = true
  }

  tags {
    Name = "cloudera-${var.env_name}-director"
  }

  volume_tags {
    Name = "cloudera-${var.env_name}-director"
  }

  connection {
    user        = "${var.user}"
    private_key = "${file("${var.key_name}")}"
  }
}