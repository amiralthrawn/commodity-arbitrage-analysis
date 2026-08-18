import pandas as pd
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

brent = pd.read_csv("data/processed/brent_daily_clean.csv")
wti = pd.read_csv("data/processed/wti_daily_clean.csv")
gas = pd.read_csv("data/processed/natural_gas_daily_clean.csv")

connection = psycopg2.connect(
    host=os.getenv("POSTGRES_HOST"),
    port=os.getenv("POSTGRES_PORT"),
    database=os.getenv("POSTGRES_DATABASE"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD")
)

cursor = connection.cursor()

cursor.execute("""
    SELECT commodity_id, commodity_name
    FROM commodities
    ORDER BY commodity_id;
""")

commodities = cursor.fetchall()

print(commodities)
commodity_ids = {
    name: commodity_id
    for commodity_id, name in commodities
}

print(commodity_ids)

def import_prices(df, commodity_name, price_column):
    commodity_id = commodity_ids[commodity_name]

    cursor.execute("""
        DELETE FROM market_prices
        WHERE commodity_id = %s;
    """, (commodity_id,))

    for _, row in df.iterrows():
        cursor.execute("""
            INSERT INTO market_prices (
                commodity_id,
                observation_date,
                price
            )
            VALUES (%s, %s, %s);
        """, (
            commodity_id,
            row["observation_date"],
            row[price_column]
        ))

    print(f"{commodity_name} importé avec succès !")

import_prices(brent, "Brent", "brent_price")
import_prices(wti, "WTI", "wti_price")
import_prices(gas, "Natural Gas", "natural_gas_price")

connection.commit()

cursor.execute("""
    SELECT COUNT(*)
    FROM market_prices;
""")

count = cursor.fetchone()[0]

print("Nombre de lignes dans market_prices :", count)

cursor.execute("""
    SELECT commodity_id, COUNT(*)
    FROM market_prices
    GROUP BY commodity_id
    ORDER BY commodity_id;
""")

results = cursor.fetchall()

for result in results:
    print(result)



cursor.close()
connection.close()
