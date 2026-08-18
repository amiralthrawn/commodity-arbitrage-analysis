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

with open("database/02_insert_data.sql", "r", encoding="utf-8") as file:
    sql_script = file.read()

cursor.execute(sql_script)

connection.commit()

cursor.close()
connection.close()

print("Commodities insérées avec succès !")