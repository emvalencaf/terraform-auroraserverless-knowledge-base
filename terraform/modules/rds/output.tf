output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret holding the database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "aurora_cluster_endpoint" {
  description = "The endpoint of the Aurora Serverless cluster"
  value       = aws_rds_cluster.aurora_serverless.endpoint
}

output "aurora_cluster_arn" {
  description = "The ARN of the cluster of Aurora Serverless cluster"
  value = aws_rds_cluster.aurora_serverless.arn
}

output "aurora_cluster_id" {
  description = "The ID of the Aurora Serverless cluster"
  value       = aws_rds_cluster.aurora_serverless.id
}


output "aurora_database_name" {
  description = "The name of Aurora Serverless database"
  value = aws_rds_cluster.aurora_serverless.database_name
}