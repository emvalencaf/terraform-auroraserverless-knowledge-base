from aws.rds.client import execute_sql_commands
from sql.queries import get_sql_commands

def lambda_handler(event, 
                   context):
    try:
        # Input data
        schema_name, table_name = event.get('schema_name'), event.get('table_name')
        table_schema = event.get('table_Schema')
        
        # Check embedding model documentation for setting dimensional_embedding.
        # Check at: https://docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html
        # | embedding_model | dimensional embedding |
        # | - | - |
        # | amazon.titan-embed-text-v2:0 | 1024 |
        dimensional_embedding = event.get('dimensional_embedding')
        
        sql_commands = get_sql_commands(schema_name=schema_name,
                                        table_name=table_name,
                                        table_schema=table_schema,
                                        dimensional_embedding=dimensional_embedding)
        
        # Executar cada comando SQL
        for sql in sql_commands:
            response = execute_sql_commands(sql=sql)
            
            print("Executed SQL:", sql)
            print("Response:", response)

        return {
            "statusCode": 200,
            "body": "SQL commands executed successfully"
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Error executing SQL commands: {str(e)}"
        }
