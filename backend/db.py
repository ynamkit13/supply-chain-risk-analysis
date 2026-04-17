import mysql.connector

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'supply_chain_db'
}


def get_connection():
    return mysql.connector.connect(**DB_CONFIG)
