# ---------------------------------
# SG (frontend)
# ---------------------------------
resource "aws_security_group" "instance_sg" {
  name   = "instance-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3030
    to_port         = 3030
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id]
    description     = "Allow HTTP from ELB"
  }

  ingress {
    description      = "Permitir conexiones SSH desde el Bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [var.bastion_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "instance-sg" }
}

# ------------------------------
# SG (ELB Frontend)
# ------------------------------
resource "aws_security_group" "elb_sg" {
  name   = "elb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from Internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "elb-sg" }
}

# ------------------------------
# EC2 (frontend) en subred privada
# ------------------------------
resource "aws_instance" "front_end" {
  count         = 2
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  subnet_id     = var.private_id[count.index]
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = false
  user_data = templatefile("start_front.tftpl", { backend_host = var.elb_back_dns_name, backend_port = 80, public_key = file("llaves/bastion_key.pub") })

  tags = {
    Name = "frontend-instance-${count.index}"
  }
}

# ------------------------------
# ELB (Clásico) para balancer la carga en el frontend en subred pública
# ------------------------------
resource "aws_elb" "web_elb" {
  name            = "web-elb"
  subnets         = var.public_id
  security_groups = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 3030
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3030/"
    interval            = 30
  }

  instances = aws_instance.front_end[*].id

  tags = { Name = "web-elb" }
}
