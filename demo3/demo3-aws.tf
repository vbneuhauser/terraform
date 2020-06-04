variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "test" {
  type = string
  default = <<-EOD
    Default, multi-line
      value
  EOD
}

terraform {
  required_version = ">= 0.11"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
  description = <<-EOD
    My aws provider
  EOD
}

data "aws_ami" "alx" {
  most_recent = true
  owners = ["amazon"]
  value = data.0
  value2 = data[0]
  filters {}
}

resource "aws_instance" "ex" {
  ami = data.aws_ami.alx.id
  instance_type = "t2.micro"
}

output "aws_public_ip" {
  value = aws_instance.ex.public_dns
}