from os import getenv

settings = {
    "SECRETS_MANAGER_ARN" : getenv("SECRETS_MANAGER_ARN"),
    "AURORA_SERVERLESS_CLUSTER_ARN" : getenv("AURORA_SERVERLESS_CLUSTER_ARN"),
    "DATABASE_NAME" : getenv("DATABASE_NAME"),
    "TABLE_NAME" : getenv("TABLE_NAME"),
    "SCHEMA_NAME" : getenv("SCHEMA_NAME")
}