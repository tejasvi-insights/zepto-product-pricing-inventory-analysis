from sqlalchemy import create_engine

def get_engine():
    username = "" 
    password = ""
    host = "localhost"
    port = "5432"
    database = ""
    return create_engine(f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}")