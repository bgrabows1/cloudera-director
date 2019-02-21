variable "env_name" {
  default = "dev"
}

variable "region" {
  default = "eu-west-2"
}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "user" {
  default = "centos"
}

variable "key_name" {
  default = "~/.ssh/id_rsa.cloudera.aws"
}

variable "subnet_prefix" {
  default = "10.0.0.0/16"
}

variable "ami" {
  default = {
    eu-central-1   = "ami-dd3c0f36"
    eu-west-1      = "ami-3548444c"
    eu-west-2      = "ami-00846a67"
    eu-west-3      = "ami-262e9f5b"
    us-east-1      = "ami-9887c6e7"
    us-east-2      = "ami-9c0638f9"
    us-west-1      = "ami-4826c22b"
    us-west-2      = "ami-3ecc8f46"
  }
}

variable "director_instance_type" {
  default = "t2.large"
}

variable "director_volume_size" {
  default = "50"
}

variable "director_volume_type" {
  default = "io1"
}

variable "director_iops" {
  default = "1000"
}
