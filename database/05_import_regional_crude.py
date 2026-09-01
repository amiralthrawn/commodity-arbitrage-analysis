import pandas as pd


# Chargement des données brutes
dubai = pd.read_csv("data/raw/dubai_crude_daily.csv")
murban = pd.read_csv("data/raw/murban_crude_daily.csv")


# Sélection et normalisation de Dubai
dubai_clean = dubai[["Date", "Price"]].copy()

dubai_clean = dubai_clean.rename(columns={
    "Date": "observation_date",
    "Price": "price"
})

dubai_clean["benchmark"] = "Dubai Crude"
dubai_clean["currency"] = "USD"
dubai_clean["unit"] = "bbl"
dubai_clean["source"] = "Investing.com"


# Sélection et normalisation de Murban
murban_clean = murban[["Date", "Price"]].copy()

murban_clean = murban_clean.rename(columns={
    "Date": "observation_date",
    "Price": "price"
})

murban_clean["benchmark"] = "Murban Crude"
murban_clean["currency"] = "USD"
murban_clean["unit"] = "bbl"
murban_clean["source"] = "Investing.com"


# Conversion des dates
dubai_clean["observation_date"] = pd.to_datetime(
    dubai_clean["observation_date"]
)

murban_clean["observation_date"] = pd.to_datetime(
    murban_clean["observation_date"]
)


# Fusion des deux séries
regional_crude = pd.concat(
    [dubai_clean, murban_clean],
    ignore_index=True
)


# Tri chronologique
regional_crude = regional_crude.sort_values(
    ["observation_date", "benchmark"]
)


# Suppression des éventuels doublons
regional_crude = regional_crude.drop_duplicates(
    subset=["observation_date", "benchmark"]
)


# Export
regional_crude.to_csv(
    "data/processed/regional_crude_daily_clean.csv",
    index=False
)


print("Nettoyage terminé !")
print("Nombre total de lignes :", len(regional_crude))
print()
print(regional_crude.groupby("benchmark").size())
print()
print(regional_crude.head())