terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIARS7Q7ZGIVREKYS"
  secret_key = "0wY+S0DCHZ4dSWWgWgtNOY3R+SZt4BHee/2P"
}

#instance creation
resource "aws_instance" "demoinstance" {
  ami           = "ami-034a8236c75419857"
  instance_type = "t3.micro"
  tags = {
    Name = "myterraforminstance"
  }
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.publickey.id
}

#create security groups
resource "aws_security_group" "main" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allowed ssh port over internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
}
#create key-pair
resource "tls_private_key" "terraform_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#create key-pair
resource "aws_key_pair" "publickey" {
  key_name   = "aws_keys_pairs"
  public_key = tls_private_key.terraform_private_key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
echo '${tls_private_key.terraform_private_key.private_key_pem}' > aws_key_pairs.pem
chmod 400 aws_key_pairs.pem
EOT
  }
}

output "publicip" {
  value = aws_instance.demoinstance.public_ip
}
