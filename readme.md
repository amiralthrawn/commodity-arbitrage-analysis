Un fournisseur réel ne va pas forcément publier quotidiennement une nouvelle cotation exactement comme notre table quotes l'imaginait.

Donc on va distinguer :

Source de marché

Par exemple :

EIA
FRED

Fournisseur / acteur

On pourra ensuite intégrer des cotations de fournisseurs simulées à partir d'un benchmark réel.

Par exemple, conceptuellement :

                 Brent benchmark
                       ↓
          $80.00 / barrel
                       ↓
       ┌───────────────┴───────────────┐
       ↓                               ↓
Supplier A                         Supplier B
$80.35                              $79.80
       ↓                               ↓
    spread                           spread


Le problème : les vraies cotations commerciales sont rarement publiques

Les plateformes professionnelles comme S&P Global Commodity Insights / Platts disposent bien de données de marché très détaillées : prix spot/forward, spreads, transactions, bids/offers, etc. S&P indique publier plus de 12 000 assessments quotidiennement et couvre notamment Dated Brent, WTI Midland, gaz naturel et LNG.

Mais ces données détaillées sont commerciales. On ne peut donc pas raisonnablement construire notre projet autour de :

« Bid d'une entreprise X à 10h32 contre ask d'une entreprise Y à 10h34 »

sans abonnement.

Même problème avec ICE : les données historiques et même les données Level 1/Level 2 existent, mais l'accès complet passe par les services de données ICE.


J'ai trouvé une excellente alternative : les OSP des producteurs

On peut utiliser les Official Selling Prices (OSP) publiés par de grandes compagnies pétrolières nationales.

Et là, on a exactement ce qu'il nous faut pour créer une couche « supplier quotes » réaliste.

Exemple : Saudi Aramco

Saudi Aramco publie des prix de vente officiels pour ses différents grades de brut, avec des différentiels par rapport à des benchmarks.

Par exemple, pour l'Europe, l'Arab Light peut être coté comme :

ICE Brent + X $/baril

On trouve même des tableaux détaillés par grade et région.


ADNOC, la compagnie pétrolière nationale d'Abu Dhabi, publie également les OSP de son brut Murban.

Et j'ai trouvé une donnée particulièrement intéressante pour notre période :

Avril 2026

ADNOC a fixé le prix officiel du Murban pour avril à :

69,45 $/baril.

Puis pour mai 2026 :

110,75 $/baril.

Ça représente une variation énorme.

Et surtout, ce sont de vraies données provenant d'un producteur majeur, pas une simulation.



Mais il y a une nuance TRÈS importante

Je veux modifier légèrement notre conception initiale de supplier_quotes.

Au départ, on imaginait quelque chose comme :

supplier
     ↓
bid_price
ask_price

Mais les OSP ne sont pas des bid/ask quotes de carnet d'ordres.

Ce sont plutôt :

des prix de vente officiels / différentiels commerciaux publiés par le producteur pour une qualité de brut et une destination données.

Mon architecture devient donc :                   



  MARKET DATA
                         │
          ┌──────────────┼──────────────┐
          ↓              ↓              ↓
        Brent            WTI        Natural Gas
          │              │              │
          └───────┬──────┘              │
                  ↓                     │
            Market spreads              │
                  │                     │
                  └──────────┬──────────┘
                             ↓
                   QUANTITATIVE ANALYSIS
                             │
                             │
              ┌──────────────┴──────────────┐
              ↓                             ↓
       Market relationships          Supplier pricing
                                            │
                           ┌────────────────┼──────────────┐
                           ↓                ↓              ↓
                       Aramco             ADNOC           KPC/SOMO
                           │                │              │
                           └────────────────┼──────────────┘
                                            ↓
                                      OSP / Differential
                                            │
                                            ↓
                                    Supplier comparison
                                            │
                                            ↓
                                  Arbitrage opportunity
                                            │
                                            ↓
                                     Risk analysis
                                            │
                                            ↓
                                     Bayesian model