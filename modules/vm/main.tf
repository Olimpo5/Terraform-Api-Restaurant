

resource "aws_key_pair" "restaurant_app_keys" {
  public_key = file("./keys/restaurant_app_key.pub")
  key_name   = var.aws_key_pair_name
}

resource "aws_security_group" "restaurant_sg" {
  name        = var.aws_restaurant_sg
  description = "Permitir Conexiones por SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "NodeApp"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_instance" "restaurant_app_server" {
  ami           = "ami-0cfde0ea8edd312d4"
  instance_type = var.aws_instance_type
  key_name      = aws_key_pair.restaurant_app_keys.key_name
  user_data     = filebase64("${path.module}/scripts/apps-install.sh")
  vpc_security_group_ids = [
    aws_security_group.restaurant_sg.id
  ]
  tags = {
    Name = "${var.aws_server_name} - ${var.aws_environment}"
  }

  //PROVISIONERS
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./keys/restaurant_app_key")
      host        = self.public_ip
    }
    inline = [
      "sudo mkdir /containers",
      "mkdir /home/ubuntu/.aws",
      "sudo touch /containers/.env",
      "sudo chmod 777 /containers",
      "sudo chmod 777 /containers/.env",
      "sudo echo \"SERVICE=${var.node_app_service}\" >> /containers/.env ",
      "sudo echo \"USER_EMAIL=${var.node_app_service}\" >> /containers/.env ",
      "sudo echo \"USER_PASSWORD=${var.node_app_service}\" >> /containers/.env ",
      "sudo echo \"[default]\naws_access_key_id=${var.aws_access_key}\naws_secret_access_key=${var.aws_secret_key}\" | sudo tee /home/ubuntu/.aws/credentials >/dev/null",
      "sudo echo \"[default]\nregion=${var.aws_region}\noutput=json\" | sudo tee /home/ubuntu/.aws/config >/dev/null",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/.aws",
      "sudo chmod 700 /home/ubuntu/.aws",
      "sudo chmod 600 /home/ubuntu/.aws/credentials /home/ubuntu/.aws/config",
    ]
  }

  # Copiando contenido del docker compose a EC2
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./keys/restaurant_app_key")
      host        = self.public_ip
    }
    source      = "./containers/docker-compose.yml"
    destination = "/containers/docker-compose.yml"
  }
}

resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"
  depends_on      = [aws_instance.restaurant_app_server]
}

resource "null_resource" "setup_app" {
  depends_on = [time_sleep.wait_120_seconds]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./keys/restaurant_app_key")
      host        = aws_instance.restaurant_app_server.public_ip
    }
    inline = [
      "cd /containers",
      "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 086143043522.dkr.ecr.us-east-2.amazonaws.com",
      "docker compose up -d"
    ]
  }
}
