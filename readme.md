# Commodity Arbitrage Analysis

## État d'avancement du projet

> **Statut :** 🟡 En cours
> **Phase actuelle :** Analyse quantitative des benchmarks pétroliers régionaux
> **Dernière mise à jour :** Août 2026

Ce projet est développé comme un projet de recherche quantitative à long terme autour des **marchés des matières premières, des relations cross-market, de la formation des prix fournisseurs et de la détection d'opportunités d'arbitrage potentielles**.

Le projet est volontairement développé progressivement. L'objectif n'est pas simplement d'obtenir un résultat final, mais de remplacer progressivement les hypothèses initiales par des **données de marché réelles et publiquement accessibles**, tout en documentant les limites liées à l'accès aux données.

| Phase                              | Objectif                                                             | Statut        | Travail réalisé
| ---------------------------------- | -------------------------------------------------------------------  | ------------  | --------------------------------------------------------------------------- |
| 1. Architecture du projet          | Définir la structure de la base et le workflow analytique            | ✅ Terminé   | Schéma PostgreSQL, tables commodities et market prices                      |
| 2. Collecte des données de marché  | Obtenir des historiques auprès de sources publiques fiables          | ✅ Terminé    | Données Brent, WTI et Natural Gas collectées et nettoyées                   |
| 3. Exploration SQL                 | Explorer les prix et valider la base de données                      | ✅ Terminé    | Requêtes SQL d'exploration, statistiques descriptives et calculs de spreads |
| 4. Analyse des relations de marché | Identifier les relations et mouvements inhabituels entre commodities | 🟢 Avancé     | Analyse du spread Brent/WTI et de sa volatilité                             |
| 5. Marchés pétroliers régionaux    | Étendre l'analyse au-delà du Brent et du WTI                         | 🟡 En cours   | Données quotidiennes Dubai Crude et Murban intégrées pour mars–juin 2026    |
| 6. Prix fournisseurs               | Intégrer les mécanismes réels de pricing des producteurs             | 🟡 Recherche  | Recherche sur les OSP et différentiels des principaux producteurs           |
| 7. Détection d'arbitrage           | Identifier les dislocations statistiquement significatives           | ⏳ À venir    | Normalisation des spreads, z-scores, mean reversion et signaux              |
| 8. Coûts et gestion du risque      | Vérifier si les opportunités restent rentables après les coûts       | ⏳ À venir    | Slippage, financement, coûts d'exécution et rendement ajusté au risque      |
| 9. Modèle quantitatif              | Construire un cadre de décision plus avancé                          | ⏳ À venir    | Modélisation statistique et approche bayésienne                             |

---

## Pourquoi le projet prend-il du temps ?

La principale difficulté du projet n'est pas l'implémentation en SQL ou en Python.

Elle concerne surtout **l'accès à des données qui représentent réellement le marché que nous cherchons à analyser**.

Au début du projet, l'idée était de construire une table `supplier_quotes` contenant quelque chose de similaire à :

```text
supplier
    ↓
bid_price / ask_price
```

Cela aurait permis de comparer directement les prix proposés par différents fournisseurs.

Cependant, les recherches ont montré qu'un fournisseur réel ne publie pas nécessairement chaque jour une nouvelle cotation publique sous la forme d'un bid/ask comparable à celui d'un carnet d'ordres.

Les plateformes professionnelles telles que **S&P Global Commodity Insights / Platts** disposent de données beaucoup plus détaillées : assessments, prix spot et forward, transactions, bids, offers, spreads, etc.

Cependant, une grande partie de ces données est commerciale et nécessite un accès payant.

Le même problème se pose avec les données de marché détaillées disponibles auprès d'**ICE** : les données historiques et les données de marché plus granulaires existent, mais leur accès complet est soumis à des conditions de licence et de diffusion.

Il n'est donc pas pertinent de construire artificiellement le projet autour d'une hypothèse du type :

```text
Entreprise A
Bid : 79.42 $

Entreprise B
Ask : 78.91 $

→ Arbitrage
```

sans disposer d'une source permettant réellement d'observer ces cotations.

---

## Évolution vers les OSP des producteurs

Une alternative particulièrement intéressante identifiée au cours des recherches est l'utilisation des **Official Selling Prices (OSP)** et des différentiels commerciaux publiés par les producteurs.

Les grandes compagnies pétrolières nationales publient des mécanismes de pricing pour différents grades de brut et différentes destinations.

Conceptuellement :

```text
Benchmark de marché
        ↓
     Brent
        ↓
Prix du benchmark
        +
Différentiel producteur
        ↓
Official Selling Price
```

Cette approche permet de rapprocher les **prix de marché observables** des mécanismes de fixation des prix du pétrole physique.

Le projet distingue donc désormais clairement :

* **données de marché** : prix observés sur les marchés financiers ;
* **benchmarks** : Brent, WTI, Dubai, etc. ;
* **grades physiques** : par exemple Murban ;
* **pricing fournisseur** : OSP et différentiels ;
* **relations quantitatives** : spreads, volatilité et écarts statistiques ;
* **opportunités d'arbitrage** : uniquement après prise en compte des contraintes économiques et opérationnelles.

Cette distinction est essentielle : un OSP n'est **pas l'équivalent d'un bid/ask issu d'un carnet d'ordres**.

---

## Données actuellement intégrées

La base de données contient actuellement des historiques de prix pour :

* **Brent**
* **WTI**
* **Natural Gas**

L'analyse initiale s'est concentrée sur la relation **Brent/WTI**, notamment à travers l'évolution du spread, sa volatilité et ses variations mensuelles.

Le projet a ensuite été étendu aux marchés pétroliers régionaux.

Des données quotidiennes de :

* **Dubai Crude**
* **Murban Crude**

ont été intégrées pour la période :

```text
Mars 2026 → Juin 2026
```

Le dataset régional contient actuellement :

```text
Dubai Crude  : 85 observations
Murban Crude : 86 observations
Total        : 171 observations
```

Certaines journées ne possèdent pas de cotation simultanée sur les deux séries. L'analyse du spread utilisera donc uniquement les dates pour lesquelles les deux marchés disposent d'une observation valide.

La prochaine étape quantitative consiste à étudier :

```text
Murban − Dubai
```

et notamment :

* la moyenne du spread ;
* son minimum et son maximum ;
* sa volatilité ;
* sa distribution ;
* ses écarts par rapport à son comportement historique ;
* son éventuelle tendance à revenir vers une moyenne (*mean reversion*).

Un spread important ne sera **pas automatiquement considéré comme une opportunité d'arbitrage**.

---

## Architecture actuelle du projet

```text
                         DONNÉES DE MARCHÉ
                                  │
          ┌───────────────────────┼───────────────────────┐
          ↓                       ↓                       ↓
        Brent                    WTI                Natural Gas
          │                       │                       │
          └───────────────┬───────┘                       │
                          ↓                               │
                    Market Spreads                        │
                          │                               │
                          └───────────────┬───────────────┘
                                          ↓
                              ANALYSE QUANTITATIVE
                                          │
                         ┌────────────────┴────────────────┐
                         ↓                                 ↓
               Relations de marché                  Pricing fournisseurs
                                                           │
                                      ┌────────────────────┼────────────────┐
                                      ↓                    ↓                ↓
                                   Aramco                ADNOC           KPC / SOMO
                                      │                    │                │
                                      └────────────────────┼────────────────┘
                                                           ↓
                                                   OSP / Différentiels
                                                           │
                                                           ↓
                                                 Comparaison fournisseurs
                                                           │
                                                           ↓
                                              Opportunités potentielles
                                                           │
                                                           ↓
                                                    Analyse du risque
                                                           │
                                                           ↓
                                               Modèle statistique/bayésien
```

---

## Philosophie de recherche

L'objectif du projet n'est donc pas uniquement de produire un signal d'achat ou de vente.

Il consiste à documenter le passage progressif de :

```text
Données brutes
      ↓
Nettoyage
      ↓
Exploration SQL
      ↓
Relations entre marchés
      ↓
Analyse statistique
      ↓
Mécanismes de formation des prix
      ↓
Dislocations potentielles
      ↓
Coûts de transaction
      ↓
Gestion du risque
      ↓
Modèle quantitatif
```

Le projet évolue volontairement au fur et à mesure de l'identification de nouvelles sources de données fiables.

Certaines hypothèses et structures de données initiales sont donc susceptibles d'être modifiées au cours du développement. Ces modifications sont documentées car elles font partie intégrante de la démarche de recherche.

