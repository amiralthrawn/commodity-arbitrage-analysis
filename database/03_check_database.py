import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

connection = psycopg2.connect(
    host=os.getenv("POSTGRES_HOST"),
    port=os.getenv("POSTGRES_PORT"),
    database=os.getenv("POSTGRES_DATABASE"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD")
)

cursor = connection.cursor()

cursor.execute("""
    SELECT commodity_id, commodity_name, unit
    FROM commodities
    ORDER BY commodity_id;
""")

rows = cursor.fetchall()

for row in rows:
    print(row)

cursor.close()
connection.close()