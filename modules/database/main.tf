# -------------------------------------
# SG (RDS database)
# -------------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Permitir MySQL desde backends"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [var.backend_sg_id]
  }

  egress {
    description = "Permitir salida a Internet si es necesario"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# -------------------------------
# RDS en servicio gestionado
# -------------------------------

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "movie_db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}

# ------------------------------
# Subnet Group para RDS
# ------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_id

  tags = {
    Name = "rds-subnet-group"
  }
}
