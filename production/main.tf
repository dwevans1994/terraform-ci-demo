terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
  backend "s3" {
    bucket = "terraform-demo-backend"
    key    = "terraform/webapp/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDaD3y5lyQgeZIi2SL9bBLKV9D6YR6pHpiWYJZ9fItl/12y940e2Q/Xw/xeUA540/3qo0NOrb046OoO3YjGEd58W1wgccBlD3iQVi+m5DVDYKPu/8zNo0u3w5EsyPEpeUa0SjRuN1uL0vkS6W2jo3Zx8XakqW6RJU5HDCfaq48GlofcUF34ZEiev8yXFEe7hf2W/BM1J2UyY+Tdo4K+Jy/22atECwcqsB43fhghEH8+sqzZShUMe2Jwo6G93DdlBBTxs9u3uwNazyp6VUj3cPeCHjx9Nb8QEwRZDYwBhHXX55/3T3s5tXmtw3DE2hk3zv8Kxe+ZsPTpZ5A8NhmTxJ3VbBBv86XpqWtnYjfIT57Vn9xDAeRJ63lJxzZBThY2EfUb1I2Vj/pvkb6AcjJ15+7Kb4TdtQVz7IoeYG+9BuZMni/4lGRXSQ64sJZg5NRTjP4UnV5ZvOOHzUDwifWYK1s0kLyGWENnypSE9Q/islNiVYOL4UgmhezSfc0x0IXa6a0= dylanevans@dylans-MacBook-Pro.local"
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = {
        Name = "terraform-aws-vpc"
    }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}

resource "aws_eip" "wordpress" {
    instance = "${aws_instance.wordpress.id}"
    vpc = true
}

resource "aws_route_table" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.main_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.ig-main.id}"
    }

    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "eu-west-1a-public" {
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}

resource "aws_subnet" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.main_vpc.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "eu-west-1a"

    tags = {
        Name = "Public Subnet"
    }
}


resource "aws_internet_gateway" "ig-main" {
    vpc_id = "${aws_vpc.main_vpc.id}"
}

resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Can access both subnets"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.main_vpc.id}"

    tags = {
        Name = "BastionSG"
    }
}

resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.main_vpc.id}"

    tags = {
        Name = "WordpressSG"
    }
}

resource "aws_instance" "nat" {
    ami = "ami-0e3f630ea5003ecf3"
    availability_zone = "eu-west-1a"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
        Name = "Bastion"
    }
}

resource "aws_instance" "wordpress" {
    ami = "ami-0fc970315c2d38f01"
    availability_zone = "eu-west-1a"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
    vpc_security_group_ids = ["${aws_security_group.web.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false

    depends_on = [
      aws_internet_gateway.ig-main
    ]

    tags = {
        Name = "Wordpress"
    }
}
