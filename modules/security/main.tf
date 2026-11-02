resource "aws_security_group" "alb" {
  name = "${var.name}-alb-sg"
  description = "HTTP ingress to ALB"
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.allowed_http_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
}
resource "aws_security_group" "app" {
  name = "${var.name}-app-sg"
  description = "Only ALB can reach application"
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name}-app-sg" })
}
resource "aws_security_group" "db" {
  name = "${var.name}-db-sg"
  description = "Only application tier can reach MySQL"
  vpc_id = var.vpc_id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name}-db-sg" })
}
