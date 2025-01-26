# AWS Bedrock Knowledge Base with Aurora Serverless as Infrastructure as a Code
[![English version](https://img.shields.io/badge/lang-en-red.svg)](/README.md)
&nbsp;&nbsp;
[![Portuguese version](https://img.shields.io/badge/lang-pt--br-green.svg)](/README.pt-br.md)

## Terraform Bedrock Knowledge Base Project Documentation
![Diagram Terraform Flow](/docs/terraform_flow.png)

This Terraform project automates the creation of an AWS Bedrock Knowledge Base infrastructure. It includes:
- **Knowledge Base**: Configured with RDS for storage and S3 for data sources.
- **IAM Roles and Policies**: Ensures secure access to AWS services.
- **Lambda Functions**: Automates database initialization.
- **RDS Aurora Serverless**: Hosts structured data for vector knowledge base configuration.
- **S3 Bucket**: Stores data for ingestion into the knowledge base.

## Lambda Function for Executing SQL Commands on Aurora Serverless
![Diagram Database Init Lambda Function Flow](/docs/lambda_database_init.png)

This Lambda function is responsible for executing SQL commands on an Amazon Aurora Serverless database using the AWS RDS Data API. The function leverages the ``boto3`` library to interact with Aurora Serverless and perform various database operations.

## Summary

- [Initial README](/README.md)
- [Terraform README](/terraform/README.md)
- [Database Init Lambda README](/app/database_init_lambda/README.md)

## Structure
```
|__ app/database_init_lambda
|       |__ aws/
|       |    |__ rds/
|       |         |__ client.py
|       |__ sql/
|       |    |__ queries.py
|       |__ config.py
|       |__ lambda_function.py
|       |__ README.md
|       |__ README.pt-br.md
|__ docs/
|__ terraform/
|       |__ artifacts/
|       |__ modules/
|       |    |__ bedrock/
|       |    |     |__ main.py
|       |    |     |__ output.py
|       |    |     |__ variables.py
|       |    |__ iam/
|       |    |     |__ main.py
|       |    |     |__ output.py
|       |    |     |__ variables.py
|       |    |__ lambda/
|       |    |    |__ main.py
|       |    |    |__ output.py
|       |    |    |__ variables.py
|       |    |__ rds/
|       |         |__ main.py
|       |         |__ output.py
|       |         |__ variables.py     
|       |__ main.tf
|       |__ variables.tf
|       |__ README.md
|       |__ README.pt-br.md
|__ README.md
|__ README.pt-br.md
```

## Usage
1. Open terminal at root and execute `cd ./terraform`
2. Initialize the Terraform project:
```bash
terraform init
```
3. Create dictory for store the documents that will be upload into `s3` to fill the variable `data_source_dir`
4. Compress `app/database_init_lambda` code into a `zip` file and create a directory at the root the terraform project (`/terraform/artifacts`) and move the `zip` file to `terraform/artifacts/` directory.
5. Plan the infrastructure deployment:
```bash
terraform plan
```
6. Apply the configuration:
```bash
terraform apply
```

## Notes
- Ensure all input variables are properly defined in a ``terraform/.tfvars`` file or passed during execution.
- The RDS database credentials are securely stored in AWS Secrets Manager.
- The S3 bucket must contain data files to be ingested into the knowledge base.