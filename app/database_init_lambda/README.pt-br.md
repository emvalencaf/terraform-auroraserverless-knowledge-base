# Função Lambda para Executar Comandos SQL no Aurora Serverless
![Diagrama do Fluxo da Função Lambda de Inicialização do Banco de Dados](/docs/lambda_database_init.png)

Esta função Lambda é responsável por executar comandos SQL em um banco de dados Amazon Aurora Serverless usando a API de Dados do AWS RDS. A função utiliza a biblioteca ``boto3`` para interagir com o Aurora Serverless e realizar diversas operações no banco de dados.

## Sumário

- [README Inicial](/README.md)
- [README do Terraform](/terraform/README.md)
- [README da Função Lambda de Inicialização do Banco de Dados](/app/database_init_lambda/README.md)

## Estrutura do Projeto
```
|__ aws/
|    |__ rds/
|         |__ client.py
|__ sql/
|    |__ queries.py
|__ config.py
|__ lambda_function.py
```

- `aws`: Diretório que contém todas as funções que interagem com as APIs da AWS.
  - `rds`: Subdiretório dedicado a funções que interagem com o AWS RDS (Data API).
    - `client.py`: Implementa funções para comunicação com o AWS RDS.
- `sql`: Diretório que contém as consultas SQL utilizadas no projeto.
  - `queries`: Contém as consultas necessárias para inicializar o banco de dados.
- `config.py`: Arquivo que centraliza todas as variáveis de ambiente para a função Lambda.
- `lambda_function.py`: Arquivo principal que implementa o manipulador da função Lambda.

## Visão Geral da Função
A função Lambda executa os seguintes passos:

1. **Obtém um cliente do RDS DataService**: Este cliente é usado para interagir com o RDS Data API, permitindo a execução de comandos SQL em um cluster Amazon Aurora Serverless.
2. **Executa comandos SQL**: A função recebe comandos SQL como entrada, executa-os no banco de dados Aurora Serverless especificado e retorna o resultado da execução.

## Requisitos

- **AWS Lambda**: A função deve ser implantada no AWS Lambda para execução.
- **Permissões IAM**: A função Lambda precisa de permissões suficientes para interagir com o AWS Secrets Manager, o Amazon RDS (para Aurora Serverless) e executar comandos SQL.
    - A função IAM da Lambda deve ter permissões para:
        - Ler credenciais do AWS Secrets Manager.
        - Acessar o cluster Aurora Serverless via o RDS Data API.
        - Executar comandos SQL no banco de dados Aurora Serverless.

## Descrição da Função Lambda

### Função: ``get_sql_commands``
Esta função gera uma lista de comandos SQL necessários para configurar o esquema e a tabela do banco de dados no Aurora Serverless.

```python
def get_sql_commands(schema_name: str,
                     table_name: str,
                     table_schema: Dict,
                     dimensional_embedding: int = 1024):
    """
    Generates a list of SQL commands to set up a database schema and table.

    The generated SQL commands perform the following actions:
    1. Ensure the 'vector' extension is available, which supports vector data types in the database.
    2. Create the specified schema (`schema_name`) if it does not already exist.
    3. Create a table (`schema_name.table_name`) within the schema, if it does not already exist, with the following structure:
       - **Primary Key Field (`primary_key_field`)**: A UUID column that serves as the primary key.
       - **Vector Field (`vector_field`)**: A vector column with a configurable dimensionality (default: 1024).
       - **Text Field (`text_field`)**: A text column to store chunks of data.
       - **Metadata Field (`metadata_field`)**: A JSON column to store additional metadata for each record.

    Parameters:
        schema_name (str): The name of the schema to create or verify.
        table_name (str): The name of the table to create or verify within the schema.
        table_schema (dict): A dictionary defining the schema fields. Keys should include:
            - `primary_key_field` (str): Name of the primary key column.
            - `vector_field` (str): Name of the vector column.
            - `text_field` (str): Name of the text column.
            - `metadata_field` (str): Name of the JSON metadata column.
        dimensional_embedding (int, optional): The dimensionality of the vector field. Defaults to 1024.

    Returns:
        list: A list of SQL query strings to configure the schema and table.
    """

    # Extract field names from the schema dictionary
    primary_key_field = table_schema.get('primary_key_field')
    vector_field = table_schema.get('vector_field')
    metadata_field = table_schema.get('metadata_field')
    text_field = table_schema.get('text_field')
    
    queries = [
        "CREATE EXTENSION IF NOT EXISTS vector;",
        f"CREATE SCHEMA IF NOT EXISTS {schema_name};", 
        f"""
        CREATE TABLE IF NOT EXISTS {schema_name}.{table_name} (
            {primary_key_field} uuid PRIMARY KEY,  -- Unique identifier for each record
            {vector_field} vector({dimensional_embedding}),  -- Vector field for storing embeddings
            {text_field} text,  -- Column for related text data
            {metadata_field} json  -- Column for additional metadata in JSON format
        );
        """,
        f"""
        CREATE INDEX ON {schema_name}.{table_name} USING hnsw (embedding vector_cosine_ops) WITH (ef_construction=256);
        """
    ]
    
    return queries
```

#### Parâmetros:
- **schema_name**: Nome do esquema a ser criado ou verificado.
- **table_name**: Nome da tabela a ser criada ou verificada dentro do esquema.
- **table_schema**: Um dicionário que define os campos do esquema. As chaves devem incluir:
  - `primary_key_field` (str): Nome da coluna da chave primária.
  - `vector_field` (str): Nome da coluna de vetores.
  - `text_field` (str): Nome da coluna de texto.
  - `metadata_field` (str): Nome da coluna JSON de metadados.
- **dimensional_embedding**: A dimensionalidade da coluna de vetores. Padrão: 1024.
  - Deve verificar o limite de dimensionalidade suportado pelo modelo de embeddings escolhido.

### Função: ``execute_sql_commands``
Esta função Lambda executa comandos SQL em um banco de dados Aurora Serverless usando o RDS Data API.

```python
def execute_sql_commands(sql_command: str):
    """
    This function executes a given SQL command on an Amazon Aurora Serverless database 
    using the RDS Data API. It leverages the `execute_statement` method of the RDS DataService client 
    to run the SQL command on the specified database.
    
    The function uses the following parameters:
    - `secretArn`: The ARN of the AWS Secrets Manager secret that stores the database credentials.
    - `resourceArn`: The ARN of the Aurora Serverless cluster to run the SQL command on.
    - `database`: The name of the database where the SQL command will be executed.
    - `sql`: The SQL command to execute.

    Args:
        sql_command (str): The SQL command to be executed in the Aurora Serverless database.

    Returns:
        dict: The response from the RDS Data API, typically containing information about the executed statement.
    """
    client = get_rds_client()
    
    return client.execute_statement(secretArn=SECRETS_MANAGER_ARN,
                                    resourceArn=AURORA_SERVERLESS_CLUSTER_ARN,
                                    database=DATABASE_NAME,
                                    sql=sql_command)

```

#### Parâmetros:
- **sql_command**: A consulta SQL a ser executada no banco de dados Aurora Serverless.

## Variáveis de Ambiente

A função requer as seguintes variáveis de ambiente configuradas:

- **SECRETS_MANAGER_ARN**: O ARN do segredo no AWS Secrets Manager que contém as credenciais do banco de dados.
- **AURORA_SERVERLESS_CLUSTER_ARN**: O ARN do cluster Aurora Serverless para executar comandos SQL.
- **DATABASE_NAME**: O nome do banco de dados dentro do cluster Aurora Serverless onde o comando SQL será executado.

## Dependências

![Boto 3](https://img.shields.io/badge/boto3-1.35.9-blue.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCEtLSBVcGxvYWRlZCB0bzogU1ZHIFJlcG8sIHd3dy5zdmdyZXBvLmNvbSwgR2VuZXJhdG9yOiBTVkcgUmVwbyBNaXhlciBUb29scyAtLT4KPHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgLTUxLjUgMjU2IDI1NiIgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiBwcmVzZXJ2ZUFzcGVjdFJhdGlvPSJ4TWlkWU1pZCI+CgkJPGc+CgkJCQk8cGF0aCBkPSJNNzIuMzkyMDUzLDU1LjQzODQxMDYgQzcyLjM5MjA1Myw1OC41NzQ4MzQ0IDcyLjczMTEyNTgsNjEuMTE3ODgwOCA3My4zMjQ1MDMzLDYyLjk4Mjc4MTUgQzc0LjAwMjY0OSw2NC44NDc2ODIxIDc0Ljg1MDMzMTEsNjYuODgyMTE5MiA3Ni4wMzcwODYxLDY5LjA4NjA5MjcgQzc2LjQ2MDkyNzIsNjkuNzY0MjM4NCA3Ni42MzA0NjM2LDcwLjQ0MjM4NDEgNzYuNjMwNDYzNiw3MS4wMzU3NjE2IEM3Ni42MzA0NjM2LDcxLjg4MzQ0MzcgNzYuMTIxODU0Myw3Mi43MzExMjU4IDc1LjAxOTg2NzUsNzMuNTc4ODA3OSBMNjkuNjc5NDcwMiw3Ny4xMzkwNzI4IEM2OC45MTY1NTYzLDc3LjY0NzY4MjEgNjguMTUzNjQyNCw3Ny45MDE5ODY4IDY3LjQ3NTQ5NjcsNzcuOTAxOTg2OCBDNjYuNjI3ODE0Niw3Ny45MDE5ODY4IDY1Ljc4MDEzMjUsNzcuNDc4MTQ1NyA2NC45MzI0NTAzLDc2LjcxNTIzMTggQzYzLjc0NTY5NTQsNzUuNDQzNzA4NiA2Mi43Mjg0NzY4LDc0LjA4NzQxNzIgNjEuODgwNzk0Nyw3Mi43MzExMjU4IEM2MS4wMzMxMTI2LDcxLjI5MDA2NjIgNjAuMTg1NDMwNSw2OS42Nzk0NzAyIDU5LjI1Mjk4MDEsNjcuNzI5ODAxMyBDNTIuNjQxMDU5Niw3NS41Mjg0NzY4IDQ0LjMzMzc3NDgsNzkuNDI3ODE0NiAzNC4zMzExMjU4LDc5LjQyNzgxNDYgQzI3LjIxMDU5Niw3OS40Mjc4MTQ2IDIxLjUzMTEyNTgsNzcuMzkzMzc3NSAxNy4zNzc0ODM0LDczLjMyNDUwMzMgQzEzLjIyMzg0MTEsNjkuMjU1NjI5MSAxMS4xMDQ2MzU4LDYzLjgzMDQ2MzYgMTEuMTA0NjM1OCw1Ny4wNDkwMDY2IEMxMS4xMDQ2MzU4LDQ5Ljg0MzcwODYgMTMuNjQ3NjgyMSw0My45OTQ3MDIgMTguODE4NTQzLDM5LjU4Njc1NSBDMjMuOTg5NDA0LDM1LjE3ODgwNzkgMzAuODU1NjI5MSwzMi45NzQ4MzQ0IDM5LjU4Njc1NSwzMi45NzQ4MzQ0IEM0Mi40Njg4NzQyLDMyLjk3NDgzNDQgNDUuNDM1NzYxNiwzMy4yMjkxMzkxIDQ4LjU3MjE4NTQsMzMuNjUyOTgwMSBDNTEuNzA4NjA5MywzNC4wNzY4MjEyIDU0LjkyOTgwMTMsMzQuNzU0OTY2OSA1OC4zMjA1Mjk4LDM1LjUxNzg4MDggTDU4LjMyMDUyOTgsMjkuMzI5ODAxMyBDNTguMzIwNTI5OCwyMi44ODc0MTcyIDU2Ljk2NDIzODQsMTguMzk0NzAyIDU0LjMzNjQyMzgsMTUuNzY2ODg3NCBDNTEuNjIzODQxMSwxMy4xMzkwNzI4IDQ3LjA0NjM1NzYsMTEuODY3NTQ5NyA0MC41MTkyMDUzLDExLjg2NzU0OTcgQzM3LjU1MjMxNzksMTEuODY3NTQ5NyAzNC41MDA2NjIzLDEyLjIwNjYyMjUgMzEuMzY0MjM4NCwxMi45Njk1MzY0IEMyOC4yMjc4MTQ2LDEzLjczMjQ1MDMgMjUuMTc2MTU4OSwxNC42NjQ5MDA3IDIyLjIwOTI3MTUsMTUuODUxNjU1NiBDMjAuODUyOTgwMSwxNi40NDUwMzMxIDE5LjgzNTc2MTYsMTYuNzg0MTA2IDE5LjI0MjM4NDEsMTYuOTUzNjQyNCBDMTguNjQ5MDA2NiwxNy4xMjMxNzg4IDE4LjIyNTE2NTYsMTcuMjA3OTQ3IDE3Ljg4NjA5MjcsMTcuMjA3OTQ3IEMxNi42OTkzMzc3LDE3LjIwNzk0NyAxNi4xMDU5NjAzLDE2LjM2MDI2NDkgMTYuMTA1OTYwMywxNC41ODAxMzI1IEwxNi4xMDU5NjAzLDEwLjQyNjQ5MDEgQzE2LjEwNTk2MDMsOS4wNzAxOTg2OCAxNi4yNzU0OTY3LDguMDUyOTgwMTMgMTYuNjk5MzM3Nyw3LjQ1OTYwMjY1IEMxNy4xMjMxNzg4LDYuODY2MjI1MTcgMTcuODg2MDkyNyw2LjI3Mjg0NzY4IDE5LjA3Mjg0NzcsNS42Nzk0NzAyIEMyMi4wMzk3MzUxLDQuMTUzNjQyMzggMjUuNiwyLjg4MjExOTIxIDI5Ljc1MzY0MjQsMS44NjQ5MDA2NiBDMzMuOTA3Mjg0OCwwLjc2MjkxMzkwNyAzOC4zMTUyMzE4LDAuMjU0MzA0NjM2IDQyLjk3NzQ4MzQsMC4yNTQzMDQ2MzYgQzUzLjA2NDkwMDcsMC4yNTQzMDQ2MzYgNjAuNDM5NzM1MSwyLjU0MzA0NjM2IDY1LjE4Njc1NSw3LjEyMDUyOTggQzY5Ljg0OTAwNjYsMTEuNjk4MDEzMiA3Mi4yMjI1MTY2LDE4LjY0OTAwNjYgNzIuMjIyNTE2NiwyNy45NzM1MDk5IEw3Mi4yMjI1MTY2LDU1LjQzODQxMDYgTDcyLjM5MjA1Myw1NS40Mzg0MTA2IFogTTM3Ljk3NjE1ODksNjguMzIzMTc4OCBDNDAuNzczNTA5OSw2OC4zMjMxNzg4IDQzLjY1NTYyOTEsNjcuODE0NTY5NSA0Ni43MDcyODQ4LDY2Ljc5NzM1MSBDNDkuNzU4OTQwNCw2NS43ODAxMzI1IDUyLjQ3MTUyMzIsNjMuOTE1MjMxOCA1NC43NjAyNjQ5LDYxLjM3MjE4NTQgQzU2LjExNjU1NjMsNTkuNzYxNTg5NCA1Ny4xMzM3NzQ4LDU3Ljk4MTQ1NyA1Ny42NDIzODQxLDU1Ljk0NzAxOTkgQzU4LjE1MDk5MzQsNTMuOTEyNTgyOCA1OC40OTAwNjYyLDUxLjQ1NDMwNDYgNTguNDkwMDY2Miw0OC41NzIxODU0IEw1OC40OTAwNjYyLDQ1LjAxMTkyMDUgQzU2LjAzMTc4ODEsNDQuNDE4NTQzIDUzLjQwMzk3MzUsNDMuOTA5OTMzOCA1MC42OTEzOTA3LDQzLjU3MDg2MDkgQzQ3Ljk3ODgwNzksNDMuMjMxNzg4MSA0NS4zNTA5OTM0LDQzLjA2MjI1MTcgNDIuNzIzMTc4OCw0My4wNjIyNTE3IEMzNy4wNDM3MDg2LDQzLjA2MjI1MTcgMzIuODkwMDY2Miw0NC4xNjQyMzg0IDMwLjA5MjcxNTIsNDYuNDUyOTgwMSBDMjcuMjk1MzY0Miw0OC43NDE3MjE5IDI1LjkzOTA3MjgsNTEuOTYyOTEzOSAyNS45MzkwNzI4LDU2LjIwMTMyNDUgQzI1LjkzOTA3MjgsNjAuMTg1NDMwNSAyNi45NTYyOTE0LDYzLjE1MjMxNzkgMjkuMDc1NDk2Nyw2NS4xODY3NTUgQzMxLjEwOTkzMzgsNjcuMzA1OTYwMyAzNC4wNzY4MjEyLDY4LjMyMzE3ODggMzcuOTc2MTU4OSw2OC4zMjMxNzg4IFogTTEwNi4wNDUwMzMsNzcuNDc4MTQ1NyBDMTA0LjUxOTIwNSw3Ny40NzgxNDU3IDEwMy41MDE5ODcsNzcuMjIzODQxMSAxMDIuODIzODQxLDc2LjYzMDQ2MzYgQzEwMi4xNDU2OTUsNzYuMTIxODU0MyAxMDEuNTUyMzE4LDc0LjkzNTA5OTMgMTAxLjA0MzcwOSw3My4zMjQ1MDMzIEw4MS4xMjMxNzg4LDcuNzk4Njc1NSBDODAuNjE0NTY5NSw2LjEwMzMxMTI2IDgwLjM2MDI2NDksNS4wMDEzMjQ1IDgwLjM2MDI2NDksNC40MDc5NDcwMiBDODAuMzYwMjY0OSwzLjA1MTY1NTYzIDgxLjAzODQxMDYsMi4yODg3NDE3MiA4Mi4zOTQ3MDIsMi4yODg3NDE3MiBMOTAuNzAxOTg2OCwyLjI4ODc0MTcyIEM5Mi4zMTI1ODI4LDIuMjg4NzQxNzIgOTMuNDE0NTY5NSwyLjU0MzA0NjM2IDk0LjAwNzk0NywzLjEzNjQyMzg0IEM5NC42ODYwOTI3LDMuNjQ1MDMzMTEgOTUuMTk0NzAyLDQuODMxNzg4MDggOTUuNzAzMzExMyw2LjQ0MjM4NDExIEwxMDkuOTQ0MzcxLDYyLjU1ODk0MDQgTDEyMy4xNjgyMTIsNi40NDIzODQxMSBDMTIzLjU5MjA1Myw0Ljc0NzAxOTg3IDEyNC4xMDA2NjIsMy42NDUwMzMxMSAxMjQuNzc4ODA4LDMuMTM2NDIzODQgQzEyNS40NTY5NTQsMi42Mjc4MTQ1NyAxMjYuNjQzNzA5LDIuMjg4NzQxNzIgMTI4LjE2OTUzNiwyLjI4ODc0MTcyIEwxMzQuOTUwOTkzLDIuMjg4NzQxNzIgQzEzNi41NjE1ODksMi4yODg3NDE3MiAxMzcuNjYzNTc2LDIuNTQzMDQ2MzYgMTM4LjM0MTcyMiwzLjEzNjQyMzg0IEMxMzkuMDE5ODY4LDMuNjQ1MDMzMTEgMTM5LjYxMzI0NSw0LjgzMTc4ODA4IDEzOS45NTIzMTgsNi40NDIzODQxMSBMMTUzLjM0NTY5NSw2My4yMzcwODYxIEwxNjguMDEwNTk2LDYuNDQyMzg0MTEgQzE2OC41MTkyMDUsNC43NDcwMTk4NyAxNjkuMTEyNTgzLDMuNjQ1MDMzMTEgMTY5LjcwNTk2LDMuMTM2NDIzODQgQzE3MC4zODQxMDYsMi42Mjc4MTQ1NyAxNzEuNDg2MDkzLDIuMjg4NzQxNzIgMTczLjAxMTkyMSwyLjI4ODc0MTcyIEwxODAuODk1MzY0LDIuMjg4NzQxNzIgQzE4Mi4yNTE2NTYsMi4yODg3NDE3MiAxODMuMDE0NTcsMi45NjY4ODc0MiAxODMuMDE0NTcsNC40MDc5NDcwMiBDMTgzLjAxNDU3LDQuODMxNzg4MDggMTgyLjkyOTgwMSw1LjI1NTYyOTE0IDE4Mi44NDUwMzMsNS43NjQyMzg0MSBDMTgyLjc2MDI2NSw2LjI3Mjg0NzY4IDE4Mi41OTA3MjgsNi45NTA5OTMzOCAxODIuMjUxNjU2LDcuODgzNDQzNzEgTDE2MS44MjI1MTcsNzMuNDA5MjcxNSBDMTYxLjMxMzkwNyw3NS4xMDQ2MzU4IDE2MC43MjA1Myw3Ni4yMDY2MjI1IDE2MC4wNDIzODQsNzYuNzE1MjMxOCBDMTU5LjM2NDIzOCw3Ny4yMjM4NDExIDE1OC4yNjIyNTIsNzcuNTYyOTEzOSAxNTYuODIxMTkyLDc3LjU2MjkxMzkgTDE0OS41MzExMjYsNzcuNTYyOTEzOSBDMTQ3LjkyMDUzLDc3LjU2MjkxMzkgMTQ2LjgxODU0Myw3Ny4zMDg2MDkzIDE0Ni4xNDAzOTcsNzYuNzE1MjMxOCBDMTQ1LjQ2MjI1Miw3Ni4xMjE4NTQzIDE0NC44Njg4NzQsNzUuMDE5ODY3NSAxNDQuNTI5ODAxLDczLjMyNDUwMzMgTDEzMS4zOTA3MjgsMTguNjQ5MDA2NiBMMTE4LjMzNjQyNCw3My4yMzk3MzUxIEMxMTcuOTEyNTgzLDc0LjkzNTA5OTMgMTE3LjQwMzk3NCw3Ni4wMzcwODYxIDExNi43MjU4MjgsNzYuNjMwNDYzNiBDMTE2LjA0NzY4Miw3Ny4yMjM4NDExIDExNC44NjA5MjcsNzcuNDc4MTQ1NyAxMTMuMzM1MDk5LDc3LjQ3ODE0NTcgTDEwNi4wNDUwMzMsNzcuNDc4MTQ1NyBaIE0yMTQuOTcyMTg1LDc5Ljc2Njg4NzQgQzIxMC41NjQyMzgsNzkuNzY2ODg3NCAyMDYuMTU2MjkxLDc5LjI1ODI3ODEgMjAxLjkxNzg4MSw3OC4yNDEwNTk2IEMxOTcuNjc5NDcsNzcuMjIzODQxMSAxOTQuMzczNTEsNzYuMTIxODU0MyAxOTIuMTY5NTM2LDc0Ljg1MDMzMTEgQzE5MC44MTMyNDUsNzQuMDg3NDE3MiAxODkuODgwNzk1LDczLjIzOTczNTEgMTg5LjU0MTcyMiw3Mi40NzY4MjEyIEMxODkuMjAyNjQ5LDcxLjcxMzkwNzMgMTg5LjAzMzExMyw3MC44NjYyMjUyIDE4OS4wMzMxMTMsNzAuMTAzMzExMyBMMTg5LjAzMzExMyw2NS43ODAxMzI1IEMxODkuMDMzMTEzLDY0IDE4OS43MTEyNTgsNjMuMTUyMzE3OSAxOTAuOTgyNzgxLDYzLjE1MjMxNzkgQzE5MS40OTEzOTEsNjMuMTUyMzE3OSAxOTIsNjMuMjM3MDg2MSAxOTIuNTA4NjA5LDYzLjQwNjYyMjUgQzE5My4wMTcyMTksNjMuNTc2MTU4OSAxOTMuNzgwMTMyLDYzLjkxNTIzMTggMTk0LjYyNzgxNSw2NC4yNTQzMDQ2IEMxOTcuNTA5OTM0LDY1LjUyNTgyNzggMjAwLjY0NjM1OCw2Ni41NDMwNDY0IDIwMy45NTIzMTgsNjcuMjIxMTkyMSBDMjA3LjM0MzA0Niw2Ny44OTkzMzc3IDIxMC42NDkwMDcsNjguMjM4NDEwNiAyMTQuMDM5NzM1LDY4LjIzODQxMDYgQzIxOS4zODAxMzIsNjguMjM4NDEwNiAyMjMuNTMzNzc1LDY3LjMwNTk2MDMgMjI2LjQxNTg5NCw2NS40NDEwNTk2IEMyMjkuMjk4MDEzLDYzLjU3NjE1ODkgMjMwLjgyMzg0MSw2MC44NjM1NzYyIDIzMC44MjM4NDEsNTcuMzg4MDc5NSBDMjMwLjgyMzg0MSw1NS4wMTQ1Njk1IDIzMC4wNjA5MjcsNTMuMDY0OTAwNyAyMjguNTM1MDk5LDUxLjQ1NDMwNDYgQzIyNy4wMDkyNzIsNDkuODQzNzA4NiAyMjQuMTI3MTUyLDQ4LjQwMjY0OSAyMTkuOTczNTEsNDcuMDQ2MzU3NiBMMjA3LjY4MjExOSw0My4yMzE3ODgxIEMyMDEuNDk0MDQsNDEuMjgyMTE5MiAxOTYuOTE2NTU2LDM4LjQgMTk0LjExOTIwNSwzNC41ODU0MzA1IEMxOTEuMzIxODU0LDMwLjg1NTYyOTEgMTg5Ljg4MDc5NSwyNi43MDE5ODY4IDE4OS44ODA3OTUsMjIuMjk0MDM5NyBDMTg5Ljg4MDc5NSwxOC43MzM3NzQ4IDE5MC42NDM3MDksMTUuNTk3MzUxIDE5Mi4xNjk1MzYsMTIuODg0NzY4MiBDMTkzLjY5NTM2NCwxMC4xNzIxODU0IDE5NS43Mjk4MDEsNy43OTg2NzU1IDE5OC4yNzI4NDgsNS45MzM3NzQ4MyBDMjAwLjgxNTg5NCwzLjk4NDEwNTk2IDIwMy42OTgwMTMsMi41NDMwNDYzNiAyMDcuMDg4NzQyLDEuNTI1ODI3ODEgQzIxMC40Nzk0NywwLjUwODYwOTI3MiAyMTQuMDM5NzM1LDAuMDg0NzY4MjExOSAyMTcuNzY5NTM2LDAuMDg0NzY4MjExOSBDMjE5LjYzNDQzNywwLjA4NDc2ODIxMTkgMjIxLjU4NDEwNiwwLjE2OTUzNjQyNCAyMjMuNDQ5MDA3LDAuNDIzODQxMDYgQzIyNS4zOTg2NzUsMC42NzgxNDU2OTUgMjI3LjE3ODgwOCwxLjAxNzIxODU0IDIyOC45NTg5NCwxLjM1NjI5MTM5IEMyMzAuNjU0MzA1LDEuNzgwMTMyNDUgMjMyLjI2NDkwMSwyLjIwMzk3MzUxIDIzMy43OTA3MjgsMi43MTI1ODI3OCBDMjM1LjMxNjU1NiwzLjIyMTE5MjA1IDIzNi41MDMzMTEsMy43Mjk4MDEzMiAyMzcuMzUwOTkzLDQuMjM4NDEwNiBDMjM4LjUzNzc0OCw0LjkxNjU1NjI5IDIzOS4zODU0Myw1LjU5NDcwMTk5IDIzOS44OTQwNCw2LjM1NzYxNTg5IEMyNDAuNDAyNjQ5LDcuMDM1NzYxNTkgMjQwLjY1Njk1NCw3Ljk2ODIxMTkyIDI0MC42NTY5NTQsOS4xNTQ5NjY4OSBMMjQwLjY1Njk1NCwxMy4xMzkwNzI4IEMyNDAuNjU2OTU0LDE0LjkxOTIwNTMgMjM5Ljk3ODgwOCwxNS44NTE2NTU2IDIzOC43MDcyODUsMTUuODUxNjU1NiBDMjM4LjAyOTEzOSwxNS44NTE2NTU2IDIzNi45MjcxNTIsMTUuNTEyNTgyOCAyMzUuNDg2MDkzLDE0LjgzNDQzNzEgQzIzMC42NTQzMDUsMTIuNjMwNDYzNiAyMjUuMjI5MTM5LDExLjUyODQ3NjggMjE5LjIxMDU5NiwxMS41Mjg0NzY4IEMyMTQuMzc4ODA4LDExLjUyODQ3NjggMjEwLjU2NDIzOCwxMi4yOTEzOTA3IDIwNy45MzY0MjQsMTMuOTAxOTg2OCBDMjA1LjMwODYwOSwxNS41MTI1ODI4IDIwMy45NTIzMTgsMTcuOTcwODYwOSAyMDMuOTUyMzE4LDIxLjQ0NjM1NzYgQzIwMy45NTIzMTgsMjMuODE5ODY3NSAyMDQuOCwyNS44NTQzMDQ2IDIwNi40OTUzNjQsMjcuNDY0OTAwNyBDMjA4LjE5MDcyOCwyOS4wNzU0OTY3IDIxMS4zMjcxNTIsMzAuNjg2MDkyNyAyMTUuODE5ODY4LDMyLjEyNzE1MjMgTDIyNy44NTY5NTQsMzUuOTQxNzIxOSBDMjMzLjk2MDI2NSwzNy44OTEzOTA3IDIzOC4zNjgyMTIsNDAuNjAzOTczNSAyNDAuOTk2MDI2LDQ0LjA3OTQ3MDIgQzI0My42MjM4NDEsNDcuNTU0OTY2OSAyNDQuODk1MzY0LDUxLjUzOTA3MjggMjQ0Ljg5NTM2NCw1NS45NDcwMTk5IEMyNDQuODk1MzY0LDU5LjU5MjA1MyAyNDQuMTMyNDUsNjIuODk4MDEzMiAyNDIuNjkxMzkxLDY1Ljc4MDEzMjUgQzI0MS4xNjU1NjMsNjguNjYyMjUxNyAyMzkuMTMxMTI2LDcxLjIwNTI5OCAyMzYuNTAzMzExLDczLjIzOTczNTEgQzIzMy44NzU0OTcsNzUuMzU4OTQwNCAyMzAuNzM5MDczLDc2Ljg4NDc2ODIgMjI3LjA5NDA0LDc3Ljk4Njc1NSBDMjIzLjI3OTQ3LDc5LjE3MzUwOTkgMjE5LjI5NTM2NCw3OS43NjY4ODc0IDIxNC45NzIxODUsNzkuNzY2ODg3NCBaIiBmaWxsPSIjMjUyRjNFIiBmaWxsLXJ1bGU9Im5vbnplcm8iPgoNPC9wYXRoPgoJCQkJPHBhdGggZD0iTTIzMC45OTMzNzcsMTIwLjk2NDIzOCBDMjAzLjEwNDYzNiwxNDEuNTYyOTE0IDE2Mi41ODU0MywxNTIuNDk4MDEzIDEyNy43NDU2OTUsMTUyLjQ5ODAxMyBDNzguOTE5MjA1MywxNTIuNDk4MDEzIDM0LjkyNDUwMzMsMTM0LjQ0MjM4NCAxLjY5NTM2NDI0LDEwNC40MzQ0MzcgQy0wLjkzMjQ1MDMzMSwxMDIuMDYwOTI3IDEuNDQxMDU5Niw5OC44Mzk3MzUxIDQuNTc3NDgzNDQsMTAwLjcwNDYzNiBDNDAuNTE5MjA1MywxMjEuNTU3NjE2IDg0Ljg1Mjk4MDEsMTM0LjE4ODA3OSAxMzAuNzEyNTgzLDEzNC4xODgwNzkgQzE2MS42NTI5OCwxMzQuMTg4MDc5IDE5NS42NDUwMzMsMTI3Ljc0NTY5NSAyMjYuOTI0NTAzLDExNC41MjE4NTQgQzIzMS41ODY3NTUsMTEyLjQwMjY0OSAyMzUuNTcwODYxLDExNy41NzM1MSAyMzAuOTkzMzc3LDEyMC45NjQyMzggWiBNMjQyLjYwNjYyMywxMDcuNzQwMzk3IEMyMzkuMDQ2MzU4LDEwMy4xNjI5MTQgMjE5LjA0MTA2LDEwNS41MzY0MjQgMjA5Ljk3MDg2MSwxMDYuNjM4NDExIEMyMDcuMjU4Mjc4LDEwNi45Nzc0ODMgMjA2LjgzNDQzNywxMDQuNjAzOTc0IDIwOS4yOTI3MTUsMTAyLjgyMzg0MSBDMjI1LjIyOTEzOSw5MS42MzQ0MzcxIDI1MS40MjI1MTcsOTQuODU1NjI5MSAyNTQuNDc0MTcyLDk4LjU4NTQzMDUgQzI1Ny41MjU4MjgsMTAyLjQgMjUzLjYyNjQ5LDEyOC41OTMzNzcgMjM4LjcwNzI4NSwxNDEuMTM5MDczIEMyMzYuNDE4NTQzLDE0My4wODg3NDIgMjM0LjIxNDU3LDE0Mi4wNzE1MjMgMjM1LjIzMTc4OCwxMzkuNTI4NDc3IEMyMzguNjIyNTE3LDEzMS4xMzY0MjQgMjQ2LjE2Njg4NywxMTIuMjMzMTEzIDI0Mi42MDY2MjMsMTA3Ljc0MDM5NyBaIiBmaWxsPSIjRkY5OTAwIj4KDTwvcGF0aD4KCQk8L2c+Cjwvc3ZnPg==)

## Fluxo de Execução

1. **Obter o cliente do RDS DataService**: A função `get_rds_client` é chamada para inicializar o cliente boto3 para interagir com o RDS Data API.
2. **Executar Comando SQL**: A função `execute_sql_commands` executa a consulta SQL fornecida utilizando o método `execute_statement` do cliente RDS DataService. Os parâmetros necessários, como o ARN do segredo, ARN do cluster e nome do banco de dados, são passados.
3. **Retornar Resposta**: O resultado da execução do comando SQL é retornado, normalmente incluindo metadados sobre a execução ou erros encontrados.

## Execução da Lambda

Espera-se a seguinte entrada para invocação da Lambda:

```json
{
    "schema_name": "<schema_name>",
    "table_name": "<table_name>"
}
```
## Instruções de Implantação
- **Criar a Função Lambda**: Crie uma nova função Lambda no Console de Gerenciamento da AWS e faça o upload do código da função como um arquivo ZIP ou via bucket S3.
- **Configurar Variáveis de Ambiente**: Configure as variáveis de ambiente necessárias (``SECRETS_MANAGER_ARN``, ``AURORA_SERVERLESS_CLUSTER_ARN``, ``DATABASE_NAME``) na configuração da função Lambda.
- **Anexar Função IAM**: Certifique-se de que a função Lambda possui uma função IAM com as permissões necessárias para interagir com o AWS Secrets Manager, o RDS Data API e o cluster Aurora Serverless.
- **Implantar e Testar**: Implante a função e teste-a invocando a função Lambda com um comando SQL de exemplo.

## Notas
Certifique-se de que o banco de dados Aurora Serverless está configurado e que o esquema do banco de dados, tabelas e quaisquer extensões necessárias (como a extensão ``vector``) foram criados previamente.

## Exemplo de Configuração Terraform
Abaixo está um exemplo de como implantar esta função Lambda usando Terraform:

```hcl
resource "aws_lambda_function" "execute_sql" {
  function_name = "ExecuteSQLCommands"
  s3_bucket     = "my-lambda-bucket"
  s3_key        = "lambda/execute_sql.zip"
  handler       = "index.handler"
  runtime       = "python3.8"
  
  environment {
    variables = {
      SECRETS_MANAGER_ARN       = "<secret_arn>"
      AURORA_SERVERLESS_CLUSTER_ARN = "<aurora_cluster_arn>"
      DATABASE_NAME             = "<database_name>"
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = "<secret_arn>"
      },
      {
        Action   = "rds-data:ExecuteStatement"
        Effect   = "Allow"
        Resource = "<aurora_cluster_arn>"
      }
    ]
  })
}

```