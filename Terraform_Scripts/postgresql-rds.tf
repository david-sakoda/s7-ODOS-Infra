resource "aws_security_group" "rds-postgres-dev-sg" {
  name   = "rds-postgres-dev-sg"
  vpc_id = aws_vpc.preprod.id  

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["10.0.64.0/19", "10.0.96.0/19"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["10.0.64.0/19", "10.0.96.0/19"]
  }
}

resource "random_password" "postgres-dev-password" {
  length = 10
}


module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "odosmoviedbdev"
 
  engine               = "postgres"
  engine_version       = "11.12"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"         # DB option group
  instance_class       = "db.t3.large"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name     = "odosmoviedbdev"
  username = "odos_user"

  #change to this when ready: random_password.postgres-dev-password.result
  password = "odos_password_123!"
  
  port     = 5432

  multi_az               = false
  subnet_ids = [        
        aws_subnet.private-us-east-1a.id,
        aws_subnet.private-us-east-1b.id
    ]
  vpc_security_group_ids = ["${aws_security_group.rds-postgres-dev-sg.id}"]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "odos-dev-monitoring-role"
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = {
      Environment = "dev"
      Name        = "odos-postgres-db-dev"
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}