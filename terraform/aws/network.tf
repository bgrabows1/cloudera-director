resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 1)}"
  availability_zone = "${var.region}a"

  tags {
    Name = "cloudera-${var.env_name}-public"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "cloudera-${var.env_name}-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "cloudera-${var.env_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "private-db-1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 3)}"
  availability_zone = "${var.region}a"

  tags {
    Name = "cloudera-${var.env_name}-private-db-1"
  }
}

resource "aws_subnet" "private-db-2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 4)}"
  availability_zone = "${var.region}b"

  tags {
    Name = "cloudera-${var.env_name}-private-db-2"
  }
}

resource "aws_db_subnet_group" "private" {
  name = "cloudera-${var.env_name}"
  description = "RDS subnet for cloudera-${var.env_name}"
  subnet_ids = ["${aws_subnet.private-db-1.id}", "${aws_subnet.private-db-2.id}"]
}
