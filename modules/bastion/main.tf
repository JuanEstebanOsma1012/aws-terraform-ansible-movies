# ---------------------------
# SG (Bastion)
# ---------------------------
resource "aws_security_group" "bastion_sg" {
  name = "bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from Everywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "bastion-sg" }

}

# ------------------------------
# EC2 (bastion) en subred publica
# ------------------------------

resource "aws_instance" "bastion" {
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  subnet_id     = var.public_id_1
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  # user_data = data.template_file.bastion_userdata.rendered
  user_data = templatefile("bastion_userdata.tftpl", { private_key = file("llaves/bastion_key") })

  tags = {
    Name = "bastion-instance"
  }
}
