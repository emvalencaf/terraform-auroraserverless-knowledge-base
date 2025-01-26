# AWS Bedrock Knowledge Base com Aurora Serverless como Infraestrutura como Código
[![Versão em inglês](https://img.shields.io/badge/lang-en-red.svg)](/README.md)
&nbsp;&nbsp;
[![Versão em português](https://img.shields.io/badge/lang-pt--br-green.svg)](/README.pt-br.md)

## Documentação do Projeto Terraform Bedrock Knowledge Base
![Diagrama do Fluxo do Terraform](/docs/terraform_flow.png)

Este projeto Terraform automatiza a criação da infraestrutura para uma Base de Conhecimento AWS Bedrock. Facilitando a sua implementação como um módulo a projetos mais complexos para a aceleração. Ele inclui:
- **Base de Conhecimento**: Configurada com RDS para armazenamento e S3 para fontes de dados.
- **Funções e Políticas IAM**: Garantem acesso seguro aos serviços da AWS.
- **Funções Lambda**: Automatizam a inicialização do banco de dados.
- **RDS Aurora Serverless**: Hospeda dados estruturados para a configuração da base de conhecimento vetorial.
- **Bucket S3**: Armazena dados para ingestão na base de conhecimento.

![Diagrama da Arquitetura AWS da Knowledge Base com o Aurora Serverless](/docs/aws_architecture.png)

## Função Lambda para Executar Comandos SQL no Aurora Serverless
![Diagrama do Fluxo da Função Lambda de Inicialização do Banco de Dados](/docs/lambda_database_init.png)

Esta função Lambda é responsável por executar comandos SQL em um banco de dados Amazon Aurora Serverless usando a API de Dados do AWS RDS. A função utiliza a biblioteca ``boto3`` para interagir com o Aurora Serverless e realizar diversas operações no banco de dados.

## Sumário

- [README Inicial](/README.md)
- [README do Terraform](/terraform/README.md)
- [README da Função Lambda de Inicialização do Banco de Dados](/app/database_init_lambda/README.md)

## Estrutura do Projeto
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
## Deploy da Base de Conhecimento

1. Abra o terminal na raiz do projeto e execute `cd ./terraform`.
2. Inicialize o projeto Terraform:
```bash
terraform init
```
3. Crie um diretório para armazenar os documentos que serão enviados para o S3 e preencha a variável ``data_source_dir``.
4. Comprima o código de ``app/database_init_lambda`` em um arquivo zip e crie um diretório na raiz do projeto Terraform (``/terraform/artifacts``) para mover o arquivo zip para o diretório ``terraform/artifacts/``.
5. Planeje a implantação da infraestrutura:
```bash
terraform plan
```
6. Aplique a configuração:
```bash
terraform apply
```

## Como deletar a infraestrutura

Não esqueça de deletar limpar seu ambiente da nuvem após o uso para evitar cobranças surpresas:

Abra o seu terminal em `terraform/` e digite o comando `terraform destroy`.

## Notas

- Certifique-se de que todas as variáveis de entrada estão devidamente definidas em um arquivo ``terraform/.tfvars`` ou passadas durante a execução.
- As credenciais do banco de dados RDS são armazenadas com segurança no AWS Secrets Manager.
- O bucket S3 deve conter arquivos de dados que serão ingeridos na base de conhecimento.

## Fontes
As seguintes fontes foram consultadas para a criação desse projeto:
- Documentação de Projeto similar da AWS:
    - Como criar uma Base de Conhecimento no Aurora Serverless: [clique aqui](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html)
    - Como criar uma Base de Conhecimento no Aurora Serverless no console: [clique aqui](https://aws.amazon.com/pt/blogs/database/accelerate-your-generative-ai-application-development-with-amazon-bedrock-knowledge-bases-quick-create-and-amazon-aurora-serverless/)
    - Como criar uma Base de Conhecimento pelo Terraform: [clique aqui](https://aws.amazon.com/pt/blogs/infrastructure-and-automation/build-an-automated-deployment-of-generative-ai-with-agent-lifecycle-changes-using-terraform/)
- Documentação do Terraform para o recurso `aws_bedrockagent_knowledge_base`: [clique aqui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base)
- Documentação do Terraform para o recurso `aws_bedrockagent_data_source`: [clique aqui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source)
- Documentação do Terraform para o recurso `aws_rds_cluster`: [clique aqui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)
- Documentação do Terraform para o recurso `aws_rds_cluster_instance`: [clique aqui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance)