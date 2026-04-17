import mysql.connector

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'root1234',
    'database': 'supply_chain_db'
}


def get_connection():
    return mysql.connector.connect(**DB_CONFIG)
