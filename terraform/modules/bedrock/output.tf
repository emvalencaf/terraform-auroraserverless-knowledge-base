output "knowledge_base_id" {
  description = "The ID of the created knowledge base."
  value       = aws_bedrockagent_knowledge_base.knowledge_base.id
}

output "data_source_id" {
  description = "The ID of the created data source for the knowledge base."
  value       = aws_bedrockagent_data_source.knowledge_base_data_source.id
}
