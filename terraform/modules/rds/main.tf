resource "aws_secretsmanager_secret" "db_credentials" {
  name        = var.secret_manager_name
  description = "Aurora Serverless Database Credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = "db_master_user"
    password = random_password.db_password.result
  })
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%#"
}


resource "aws_rds_cluster" "aurora_serverless" {
  cluster_identifier = var.cluster_name
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version = "16.3"
  master_username    = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string).username
  master_password    = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string).password
  database_name      = var.database_name
  storage_encrypted  = true
  skip_final_snapshot = true
  final_snapshot_identifier = "${var.cluster_name}-snapshot"
  enable_http_endpoint    = true
  apply_immediately   = true


  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity             = var.max_capacity
  }

  depends_on = [ aws_secretsmanager_secret.db_credentials, 
  aws_secretsmanager_secret_version.db_credentials ]
}

resource "aws_rds_cluster_instance" "aurora_serverless" {
  cluster_identifier = aws_rds_cluster.aurora_serverless.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora_serverless.engine
  engine_version     = aws_rds_cluster.aurora_serverless.engine_version
}
