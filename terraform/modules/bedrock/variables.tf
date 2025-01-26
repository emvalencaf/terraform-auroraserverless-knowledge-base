variable "knowledge_name" {
  description = "The name of the knowledge base."
  type        = string
  nullable = false
}

variable "role_arn" {
  description = "The ARN of the role that the knowledge base will assume."
  type        = string
}

variable "embedding_model_arn" {
  description = "The ARN of the embedding model to be used for vector knowledge base configuration."
  type        = string
  default = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
}

variable "database_name" {
  description = "The name of the database to be used in the RDS configuration."
  type        = string
}

variable "table_name" {
  description = "The name of the table within the database for storing knowledge base data."
  type        = string
}

variable "manager_secret_arn" {
  description = "The ARN of the secret in AWS Secrets Manager that contains the database credentials."
  type        = string
}

variable "rds_cluster_arn" {
  description = "The ARN of the RDS cluster to be used for storing knowledge base data."
  type        = string
}

variable "primary_key" {
  description = "The field in the RDS table that acts as the primary key for the vector knowledge base."
  type        = string
}

variable "text_field" {
  description = "The field in the RDS table that contains the text data for the vector knowledge base."
  type        = string
}

variable "vector_field" {
  description = "The field in the RDS table that contains vector data for the knowledge base."
  type        = string
}


variable "metadata_field" {
  description = "The field in the RDS table that contains metadata for the vector knowledge base."
  type        = string
}

variable "kb_data_source_name" {
  description = "The name of the data source associated with the knowledge base."
  type        = string
}

variable "bucket_s3_arn" {
  description = "The ARN of the S3 bucket for the data source configuration."
  type        = string
}

variable "breakpoint_threshold" {
  description = "The threshold percentile for the semantic chunking strategy."
  type        = number
}

variable "buffer_size" {
  description = "The buffer size to be used for chunking configuration."
  type        = number
}

variable "max_token" {
  description = "The maximum token limit for the chunking configuration."
  type        = number
}
