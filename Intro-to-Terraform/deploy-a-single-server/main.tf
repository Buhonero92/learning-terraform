provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type  = number
  default = 8080  
}

output "public_ip" {
  value = aws_instance.ec2-instance-test.public_ip
  description = "The public IP address of the web server"
}

resource "aws_instance" "ec2-instance-test" {
  ami = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.sg-ec2-instance-test.id ]
  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohub busybox httpd -f -p ${var.server_port} &
                EOF
  user_data_replace_on_change = true
  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "sg-ec2-instance-test" {
  name = "terraform-example-instance-sg"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}