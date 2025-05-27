data "aws_ami" "test" {
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["973714476881"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.test.id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.sg.id]
  availability_zone = "us-east-1a"
  tags = {
    Name = var.name
  }
}

resource "null_resource" "ansible" {
 
 depends_on = [aws_instance.web, aws_route53_record.www]
   provisioner "remote-exec" {

    connection {
        type        = "ssh"
        user        = "centos"
        password    = "DevOps321"
        host        = aws_instance.web.public_ip
    }
    inline = [ 
        "sudo labauto ansible",
        "ansible-pull -i localhost, -U https://github.com/SantoshKrishh/roboshop-ansible.git roboshop.yml -e env=dev -e role_name=${var.name}"
    ]
  }
}

resource "aws_route53_record" "www" {
  zone_id = "Z0453228J48T2VKP1YKM"
  name    = "${var.name}.roboshopsk.shop"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web.private_ip]
}

resource "aws_security_group" "sg" {
  name        = var.name
  description = "Allow TLS inbound traffic"


  ingress {
    from_port   = 0
    to_port     = 0        
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}

variable "name" {  
}


