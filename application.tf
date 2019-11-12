resource "aws_key_pair" "ssh" {
  key_name   = "default"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "web" {
  name        = "webserver"
  description = "Public HTTP + SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-00dc79254d0461090"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.ssh.id}"
  vpc_security_group_ids = [ "${aws_security_group.web.id}" ]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
      }
     inline = [
       "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-late",
       "sudo yum install -y epel-release",
       "sudo yum update -y",
       "sudo amazon-linux-extras install nginx1.12",
       "sudo yum install nginx -y"
    ]
  }
}

output "web_public_dns" {
  value = "${aws_instance.web.public_dns}"
}
