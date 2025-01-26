terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.3"
    }
  }

}

provider "aws" {
  region = var.region
  profile = var.profile
}


# RDS
module "aurora_serverless" {
  source = "./modules/rds"
  database_name = "knowldege_database_name"
  cluster_name = var.aurora_serverless_cluster_name
  secret_manager_name = var.secret_manager_name
}

# Lambda Database Init
module "database_init_lambda_role" {
  source = "./modules/iam"
  role_name = "DatabaseInitLambdaRole_Terraform"
  assume_role_services = ["lambda.amazonaws.com"]
  policy_name = "DatabaseInitLambdaPolicies"
  policy_description = "Necessaries policies for lambda to access RDS and secrets from secret manager"
  depends_on = [ module.aurora_serverless ]
  policy_statements = <<POLICY
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : "${module.aurora_serverless.db_credentials_secret_arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "rds-data:*"
        ],
        "Resource" : "${module.aurora_serverless.aurora_cluster_arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  }
  POLICY
}

module "database_init_lambda" {
  source = "./modules/lambda"
  function_name = "database_init_terraform"
  file_name = "artifacts/${var.file_name_lambda}"
  role_arn = module.database_init_lambda_role.role_arn
  depends_on = [ module.aurora_serverless ]
  environment_vars = {
    SECRETS_MANAGER_ARN = module.aurora_serverless.db_credentials_secret_arn
    AURORA_SERVERLESS_CLUSTER_ARN = module.aurora_serverless.aurora_cluster_arn
    DATABASE_NAME = module.aurora_serverless.aurora_database_name
  }
}

resource "aws_lambda_invocation" "database_init_execution" {
  function_name = module.database_init_lambda.lambda_function_name

  input = jsonencode({
    table_name   = var.vector_table_name
    schema_name  = var.vector_schema_name
    table_schema = {
      primary_key_field = var.primary_key
      vector_field = var.vector_field
      text_field = var.text_field
      metadata_field = var.metadata_field
    }
    dimensional_embedding = var.vector_dimensionality_support
  })

  depends_on = [module.database_init_lambda]
}


# S3
resource "aws_s3_bucket" "bucket_data_source" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "s3_objects" {
  for_each = fileset(var.data_source_dir, "*")

  bucket = aws_s3_bucket.bucket_data_source.bucket
  key    = each.key
  source = "${var.data_source_dir}/${each.key}"
  acl    = "private"
}


# Knowledge Base
module "knowldge_base_role" {
  source = "./modules/iam"
  role_name = var.knowledge_base_role
  assume_role_services = ["bedrock.amazonaws.com"]
  policy_name = "KnowledgeBasePolicies_Terraform"
  policy_description = ""
  policy_statements = <<POLICY
  {
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect" : "Allow",
            "Action" : "s3:ListBucket",
            "Resource" : "${aws_s3_bucket.bucket_data_source.arn}"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "bedrock:InvokeModel",
            "bedrock:ListModels",
            "bedrock:ListFoundationModels",
            "bedrock:DeleteDataSource",
            "bedrock:DeleteVectorStore",
            "bedrock:UpdateDataSource",
            "rds:DescribeDBClusters",
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : ["${module.aurora_serverless.aurora_cluster_arn}","${module.aurora_serverless.db_credentials_secret_arn}"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "rds-data:ExecuteStatement",
            "rds-data:BatchExecuteStatement"
          ],
          "Resource" : "${module.aurora_serverless.aurora_cluster_arn}"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : ["${aws_s3_bucket.bucket_data_source.arn}", "${aws_s3_bucket.bucket_data_source.arn}/*"]
        }
    ]
  }
  POLICY
}

module "knowledge_base" {
  source = "./modules/bedrock"
  rds_cluster_arn = module.aurora_serverless.aurora_cluster_arn
  role_arn = module.knowldge_base_role.role_arn
  manager_secret_arn = module.aurora_serverless.db_credentials_secret_arn
  kb_data_source_name = var.kb_data_source_name
  database_name = module.aurora_serverless.aurora_database_name
  table_name = "${var.schema_name}.${var.table_name}"
  primary_key = var.primary_key
  text_field        = var.text_field
  metadata_field    = var.metadata_field
  vector_field =  var.vector_field
  buffer_size = var.buffer_size
  knowledge_name = var.knowledge_name
  breakpoint_threshold = var.breakpoint_threshold
  max_token = var.max_token
  bucket_s3_arn = aws_s3_bucket.bucket_data_source.arn

  depends_on = [module.aurora_serverless, module.database_init_lambda]

}

resource "null_resource" "aws_cli_execution" {
  provisioner "local-exec" {
    command = "aws bedrock-agent start-ingestion-job --knowledge-base-id ${module.knowledge_base.knowledge_base_id} --data-source-id ${module.knowledge_base.data_source_id} --region ${var.region} --profile ${var.profile}"
  }

  depends_on = [ module.knowledge_base ]
}