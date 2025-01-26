variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "aurora_serverless_cluster_name" {
  description = "The name of the Aurora Serverless cluster."
  type        = string
}

variable "secret_manager_name" {
  description = "The name of the secret stored in AWS Secrets Manager for Aurora database credentials."
  type        = string
}

variable "vector_table_name" {
  description = "The name of the vector table in the database."
  type        = string
}

variable "vector_schema_name" {
  description = "The schema name in the database where the vector table is located."
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket where data will be stored."
  type        = string
}

variable "file_name_lambda" {
  description = "The filename (.zip) of lambda code for database init lambda function"
  type = string
  default = "database_init_lambda_code.zip"
}

variable "data_source_dir" {
  description = "The local directory containing the data source files to be uploaded to the S3 bucket."
  type        = string
}

variable "embedding_model_arn" {
  description = "The ARN of the embedding model to be used for vector knowledge base configuration."
  type        = string
  default = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
}

variable "vector_dimensionality_support" {
  description = "The output of dimensionality support by the embedding model to embed chunks of texts."
  type = number
  default = 1024
}

variable "kb_data_source_name" {
  description = "The name of the knowledge base data source."
  type        = string
}

variable "schema_name" {
  description = "The schema name in the database."
  type        = string
}

variable "table_name" {
  description = "The name of the table in the database."
  type        = string
}

variable "primary_key" {
  description = "The primary key field in the table."
  type        = string
  default = "id"
}

variable "text_field" {
  description = "The text field in the table for indexing."
  type        = string
  default = "chunks"
}

variable "metadata_field" {
  description = "The metadata field in the table for additional information."
  type        = string
  default = "metadata"
}

variable "vector_field" {
  description = "The vector field in the table for storing vector data."
  type        = string
  default = "embedding"
}

variable "knowledge_base_role" {
  description = "The name of the IAM role for the knowledge base integration with Bedrock."
  type        = string
}

variable "breakpoint_threshold" {
  description = "The threshold percentile for the semantic chunking strategy."
  type        = number
  default = 95
}

variable "buffer_size" {
  description = "The buffer size to be used for chunking configuration."
  type        = number
  default = 0
}

variable "max_token" {
  description = "The maximum token limit for the chunking configuration."
  type        = number
  default = 150
}

variable "knowledge_name" {
  description = "The name of the knowledge base."
  type        = string
  nullable = false
}