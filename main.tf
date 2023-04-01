resource "aws_security_group" "allow_tls" {
  name        = "${var.env}-db_segrp"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main_vpc

  ingress {
    description      = "MONGODB"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags       = merge(
    local.common_tags,
    { Name = "${var.env}-db_segrp" }
  )
}

resource "aws_docdb_subnet_group" "default" {
  name       = "${var.env}-db_subnetgrp"
  subnet_ids = var.subnet_ids

  tags       = merge(
    local.common_tags,
    { name = "${var.env}-db_subnetgrp" }
  )
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.env}-db-cluster"
  engine                  = "docdb"
  engine_version          = var.engine_version
  master_username         = "dimpul"
  master_password         = "dimpul123"
  storage_encrypted       = true
  skip_final_snapshot     = true
  db_subnet_group_name   = aws_docdb_subnet_group.default.name
  vpc_security_group_ids = aws_security_group.allow_tls.id

  tags       = merge(
    local.common_tags,
    { name = "${var.env}-db_cluster" }
  )
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "docdb-cluster-demo-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class
}