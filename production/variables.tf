variable "region" {
  default = "eu-west-1"
}

variable "env" {
  default = "production"
}

variable "aws_access_key" {
    default = "ACCESS"
}
variable "aws_secret_key" {
    default = "SECRET"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}