output "knowledge_base_id" {
  description = "The ID of the created knowledge base."
  value       = module.knowledge_base.knowledge_base_id
}

output "data_source_id" {
  description = "The ID of the created data source for the knowledge base."
  value       = module.knowledge_base.data_source_id
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