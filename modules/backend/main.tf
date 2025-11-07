# ------------------------------
# Security Groups
# ------------------------------
resource "aws_security_group" "backend_sg" {
  name = "backend-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    security_groups = [aws_security_group.elb_back_sg.id]
    description = "Allow HTTP from Load Balancer"
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

  tags = { Name = "backend-sg" }

}

# ------------------------------
# SG (ELB Backend)
# ------------------------------
resource "aws_security_group" "elb_back_sg" {
  name   = "elb-back-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [var.instance_sg_id]
    description = "Allow HTTP from Frontend"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "elb-back-sg" }
}

# ------------------------------
# EC2 (backend) en subred privada
# ------------------------------

resource "aws_instance" "back_end" {
  count         = 2
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  subnet_id     = var.private_id[count.index]
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  associate_public_ip_address = false
  user_data = templatefile("start_back.tftpl", { host = var.db_address, public_key = file("llaves/bastion_key.pub") })

  tags = {
    Name = "backend-instance-${count.index}"
  }
}

# ------------------------------
# ELB (Clásico) para balancer la carga en el backend en subred privada
# ------------------------------
resource "aws_elb" "back_elb" {
  name            = "back-elb"
  subnets         = var.private_id
  security_groups = [aws_security_group.elb_back_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/"
    interval            = 30
  }

  instances = aws_instance.back_end[*].id

  tags = { Name = "web-elb" }
}
