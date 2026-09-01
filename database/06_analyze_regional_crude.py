import pandas as pd


# Chargement des données nettoyées
data = pd.read_csv(
    "data/processed/regional_crude_daily_clean.csv"
)

# Mise en format pivot
prices = data.pivot(
    index="observation_date",
    columns="benchmark",
    values="price"
)

# On conserve uniquement les journées où les deux marchés
# possèdent une cotation
prices = prices.dropna(
    subset=["Dubai Crude", "Murban Crude"]
)

# Calcul du spread
prices["spread"] = (
    prices["Murban Crude"]
    - prices["Dubai Crude"]
)

print("Nombre de journées communes :", len(prices))
print()

print("Statistiques du spread Murban - Dubai")
print("--------------------------------------")
print("Moyenne :", round(prices["spread"].mean(), 4))
print("Minimum :", round(prices["spread"].min(), 4))
print("Maximum :", round(prices["spread"].max(), 4))
print("Volatilité :", round(prices["spread"].std(), 4))
print()

print("Plus grand spread positif :")
print(prices["spread"].idxmax())
print(round(prices["spread"].max(), 4))
print()

print("Plus petit spread :")
print(prices["spread"].idxmin())
print(round(prices["spread"].min(), 4))