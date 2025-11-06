# 🧩 Anonymization Project – AIDS Dataset (R & Python)

## 🎯 Objectif du projet
Ce projet vise à **évaluer et réduire les risques de ré-identification** dans un jeu de données sensibles (AIDS dataset), en appliquant des **techniques d’anonymisation conformes au RGPD**.

L’analyse combine :
- 🧮 **R (sdcMicro)** pour la mesure du risque de divulgation,
- 🐍 **Python (Pandas, NumPy, Matplotlib)** pour l’expérimentation et l’analyse du compromis **Risque ↔ Utilité**.

---

## 🧠 Contexte
Avec la multiplication des bases de données personnelles, la **protection de la vie privée** est devenue une priorité.  
Ce projet explore comment anonymiser efficacement un jeu de données médicales tout en conservant sa valeur analytique.

Le dataset original : `aids_original_data.csv` (2 139 lignes × 27 colonnes).  
Variables sensibles : `age`, `gender`, `race`, `treat`, `arms`.

---

## 🧩 Méthodologie

### Étape 1 – Exploration des données
- Identification des variables continues, catégorielles et sensibles.  
- Visualisation : histogrammes, boxplots, bar charts, heatmaps, pairplots.  
- Détection des relations déterministes (`arms → treat`).

### Étape 2 – Évaluation du risque (R avec `sdcMicro`)
**Quasi-identifiants utilisés :** `age`, `gender`, `race`

| Indicateur | Résultat initial |
|-------------|------------------|
| Risque global | **8.51 %** |
| Attendus ré-identifiés | **182 / 2139** |
| % unique (k = 1) | **1.36 %** |
| % avec k ≤ 5 | **10.52 %** |

📊 Conclusion : le risque de ré-identification est élevé sans anonymisation, notamment à cause de la variable **âge**.

### Étape 3 – Anonymisation (Python)
Deux méthodes principales testées :
1. **Age Banding** – regroupement par tranches d’âge (5, 10, 15 ans)  
2. **PRAM (Post Randomization Method)** – permutation aléatoire des catégories (genre, race)

#### Résultats clés

| Méthode | Paramètre | Expected Re-ID | k ≤ 5 (%) | IL1 | Eigen Sim (%) |
|----------|------------|----------------|-----------|-----|----------------|
| Baseline | — | 182 | 10.52 | — | — |
| Banding (5 ans) | width = 5 | 44 | 1.40 | 0.021 | 99.94 |
| Banding (10 ans) | width = 10 | 25 | 0.61 | 0.044 | 99.75 |
| Banding (15 ans) | width = 15 | 18 | 0.37 | 0.067 | 99.39 |
| PRAM (race) | p = 10 % | 174 | 9.80 | 0.10 | 99.80 |

✅ **Meilleur compromis :** Age Banding (10 ans)  
→ Risque réduit × 7, avec une perte d’information minimale.

---

## 📈 Principales visualisations
Les graphiques générés illustrent l’évolution du risque et de la perte d’utilité :
- `step3/outputs/plots/` → Distribution du risque individuel, histogrammes, équivalence k  
- `step4/` → Graphiques du risque par méthode, IL1 global, trade-off Risk vs Utility

Exemples :
- 📊 **Figure 1** – Distribution du risque individuel (R)  
- 📉 **Figure 2** – Trade-off entre anonymisation et utilité (Python)

---

## 💡 Conclusion
- L’anonymisation par **tranches d’âge de 10 ans** garantit une **baisse majeure du risque de ré-identification (8.5% → 1.2%)**.  
- Les relations déterministes (`arms` et `treat`) doivent être **supprimées ou agrégées** pour éviter la divulgation indirecte.  
- Le compromis **confidentialité / utilité** est excellent (structure préservée à 99.7 %).

> 🔐 Ce projet illustre l’importance d’une approche scientifique pour concilier **protection des données** et **valeur analytique**.

---

## ⚙️ Stack Technique
| Langage / Outil | Usage |
|------------------|--------|
| 🧮 **R (sdcMicro)** | Calcul du risque de divulgation |
| 🐍 **Python (Pandas, NumPy, Matplotlib)** | Simulation et évaluation du trade-off |
| 🧠 **Jupyter & RStudio** | Environnements d’expérimentation |
| 📈 **Seaborn** | Visualisation et corrélation |
| 💾 **CSV / PNG outputs** | Sauvegarde automatisée des résultats |

---

## 🧾 Extrait de code

### 🔹 R – Calcul du risque
```r
library(sdcMicro)
data <- read.delim("aids_original_data.csv", sep=";")
sdc <- createSdcObj(dat=data, keyVars=c("age","gender","race"))
report(sdc, filename="Risk_Report.html")
