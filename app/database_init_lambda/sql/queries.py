from typing import Dict
from config import settings

DATABASE_NAME = settings.get("DATABASE_NAME")

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

    Read Aurora Postgres PgVector: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html
    
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
            {primary_key_field} uuid PRIMARY KEY,
            {vector_field} vector({dimensional_embedding}),
            {text_field} text,
            {metadata_field} json
        );
        """,
        f"""
        CREATE INDEX ON {schema_name}.{table_name} USING hnsw (embedding vector_cosine_ops) WITH (ef_construction=256);
        """
    ]
    
    return queries
