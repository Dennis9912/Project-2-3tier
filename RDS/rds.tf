#Configure DB Subnet Group for RDS
resource "aws_db_subnet_group" "dsa_rds_subnet_group" {
  name       = "db-subnet-group"
  description = "Subnet group for RDS in private subnets"
  subnet_ids  = [var.backend_subnet_az_1a, var.backend_subnet_az_1b]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-group"
  })
}

#Reference the already created Secret from AWS Secrets Mangers
data "aws_secretsmanager_secret" "dsa_db_credentials" {
  name = "dsa_rds_mysql"
}

data "aws_secretsmanager_secret_version" "dsa_db_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.dsa_db_credentials.id
}

#Configure Security group for RDS
resource "aws_security_group" "dsa_rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access to RDS from trusted sources"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow MySQL from trusted sources"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.private_server_sg_id]  # SGs of private servers
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-rds-sg"
  })
}

#Configure RDS MySQL Instance
resource "aws_db_instance" "dsa_mysql" {
  identifier              = "atech-mysql"
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = "gp2"
  parameter_group_name    = var.parameter_group_name
   db_name                 = "atechdb"

  username = jsondecode(data.aws_secretsmanager_secret_version.dsa_db_credentials_version.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.dsa_db_credentials_version.secret_string)["password"]

  vpc_security_group_ids  = [aws_security_group.dsa_rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.dsa_rds_subnet_group.name
  multi_az                = false                         # Set to true for production environments
  publicly_accessible     = false

  skip_final_snapshot     = true                          # set this to false in production to avoid data loss
  deletion_protection     = false

 # backup_retention_period = 0
 # backup_window = "00:00-00:10" # window for frequent backups set to every 10 minutes

    #  # Specify an S3 bucket for backups
  #   s3_import {
  #     bucket_name = "mysql-automated-backup"
  #     source_engine = "mysql"
  #     source_engine_version = "8.0"
  #     ingestion_role = aws_iam_role.s3RDS_backup.arn
  #   }

  #   iam_database_authentication_enabled = true

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-mysql"
  })
}
