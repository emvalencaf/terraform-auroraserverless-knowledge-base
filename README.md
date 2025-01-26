# AWS Bedrock Knowledge Base with Aurora Serverless as Infrastructure as a Code
[![English version](https://img.shields.io/badge/lang-en-red.svg)](/README.md)
&nbsp;&nbsp;
[![Portuguese version](https://img.shields.io/badge/lang-pt--br-green.svg)](/README.pt-br.md)

## Terraform Bedrock Knowledge Base Project Documentation
![Diagram Terraform Flow](/docs/terraform_flow.png)

This Terraform project automates the creation of infrastructure for an AWS Bedrock Knowledge Base, simplifying its implementation as a module in more complex projects to accelerate deployment. It includes:
- **Knowledge Base**: Configured with RDS for storage and S3 for data sources.
- **IAM Roles and Policies**: Ensures secure access to AWS services.
- **Lambda Functions**: Automates database initialization.
- **RDS Aurora Serverless**: Hosts structured data for vector knowledge base configuration.
- **S3 Bucket**: Stores data for ingestion into the knowledge base.

![Diagram AWS Knowledge Base with the Aurora Serverless Architecture](/docs/aws_architecture.png)

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
## How to Delete the Infrastructure

Do not forget to clean up your cloud environment after use to avoid unexpected charges:

Open your terminal in the `terraform/` directory and run the command `terraform destroy`.

## Notes

- Ensure all input variables are properly defined in a ``terraform/.tfvars`` file or passed during execution.
- The RDS database credentials are securely stored in AWS Secrets Manager.
- The S3 bucket must contain data files to be ingested into the knowledge base.

## References
The following sources were consulted for the creation of this project:
- AWS Documentation for similar projects:
    - How to create a Knowledge Base in Aurora Serverless: [click here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html)
    - How to create a Knowledge Base in Aurora Serverless using the console: [click here](https://aws.amazon.com/blogs/database/accelerate-your-generative-ai-application-development-with-amazon-bedrock-knowledge-bases-quick-create-and-amazon-aurora-serverless/)
    - How to create a Knowledge Base using Terraform: [click here](https://aws.amazon.com/blogs/infrastructure-and-automation/build-an-automated-deployment-of-generative-ai-with-agent-lifecycle-changes-using-terraform/)
- Terraform Documentation for the `aws_bedrockagent_knowledge_base` resource: [click here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base)
- Terraform Documentation for the `aws_bedrockagent_data_source` resource: [click here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source)
- Terraform Documentation for the `aws_rds_cluster` resource: [click here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)
- Terraform Documentation for the `aws_rds_cluster_instance` resource: [click here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance)