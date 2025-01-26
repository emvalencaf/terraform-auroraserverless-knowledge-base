resource "aws_bedrockagent_knowledge_base" "knowledge_base" {
  name     = var.knowledge_name
  role_arn = var.role_arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn
    }
      type = "VECTOR"
  }

  storage_configuration {
    type = "RDS"

    rds_configuration {
      database_name           = var.database_name
      table_name              = var.table_name
      credentials_secret_arn  = var.manager_secret_arn
      resource_arn            = var.rds_cluster_arn

      field_mapping {
        primary_key_field = var.primary_key
        text_field        = var.text_field
        metadata_field    = var.metadata_field
        vector_field =  var.vector_field
      }
    }
  }
}

resource "aws_bedrockagent_data_source" "knowledge_base_data_source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.knowledge_base.id
  name              = var.kb_data_source_name

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = var.bucket_s3_arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "SEMANTIC"

      semantic_chunking_configuration {
        breakpoint_percentile_threshold = var.breakpoint_threshold
        buffer_size                   = var.buffer_size
        max_token                     = var.max_token
      }
    }
  }

  data_deletion_policy = "RETAIN"

}
