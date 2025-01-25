import boto3
from config import settings


SECRETS_MANAGER_ARN = settings.get("SECRETS_MANAGER_ARN")
AURORA_SERVERLESS_CLUSTER_ARN = settings.get("AURORA_SERVERLESS_CLUSTER_ARN")
DATABASE_NAME = settings.get("DATABASE_NAME")
 
def get_rds_client():
    """
    This function initializes and returns an RDS DataService client using the `boto3` library.
    
    The client allows interaction with Amazon Aurora Serverless and other RDS databases 
    using the RDS Data API, which provides a simple HTTP endpoint for executing SQL commands 
    and interacting with the database without needing to manage database connections.
    
    Returns:
        boto3.client: An RDS DataService client that can be used to execute SQL statements.
    """
    return boto3.client('rds-data')

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
