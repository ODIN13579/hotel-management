import pyodbc

def get_connection():
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=hotel_management;"
        "UID=sa;"
        "PWD=123;"
    )
    return conn

