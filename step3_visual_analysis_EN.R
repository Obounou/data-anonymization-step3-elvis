# Test de lecture du fichier
library(readr)
df <- read_csv("data/aids_original_data.csv", show_col_types = FALSE)

# Affiche les 5 premières lignes
head(df)

df <- read_csv("data/aids_original_data.csv", show_col_types = FALSE)

# relire le fichier avec le bon séparateur (;)
df <- read_delim("data/aids_original_data.csv",
                 delim = ";",
                 show_col_types = FALSE)

# afficher les 5 premières lignes
head(df)

# Voir les noms de colonnes et leurs types
names(df)
str(df)
summary(df[, 1:10])  # aperçu rapide des 10 premières variables




# ================================================================
# Step 3 — Re-identification Risk Analysis (Display-only Version)
# This script runs directly without saving any files.
# It displays:
#   - Dataset overview
#   - Risk metrics (global and individual)
#   - Graphs (boxplot, histogram, k-anonymity)
# ================================================================

# ---------------------------------------------------------------
# 0) Load required package
# ---------------------------------------------------------------
if (!requireNamespace("sdcMicro", quietly = TRUE)) {
  install.packages("sdcMicro", repos = "https://cloud.r-project.org")
}
library(sdcMicro)

# ---------------------------------------------------------------
# 1) Load the dataset
# ---------------------------------------------------------------
cat("🔹 Loading dataset...\n")

csv_path <- "data/aids_original_data.csv"
if (!file.exists(csv_path)) {
  url_csv <- "https://raw.githubusercontent.com/octopize/avatar-paper/main/datasets/AIDS/aids_original_data.csv"
  download.file(url_csv, destfile = csv_path, mode = "wb")
}

df <- read.delim(csv_path, sep = ";", dec = ".", stringsAsFactors = FALSE)

cat("✅ Data loaded:", nrow(df), "rows and", ncol(df), "columns.\n")
cat("Preview of first rows:\n")
print(head(df, 5))

# ---------------------------------------------------------------
# 2) Quick data overview
# ---------------------------------------------------------------
cat("\n📊 Dataset structure:\n")
str(df)

cat("\nStatistical summary of the first 10 variables:\n")
print(summary(df[, seq_len(min(10, ncol(df)))]))

# ---------------------------------------------------------------
# 3) Variable selection
# ---------------------------------------------------------------
key_vars       <- c("age", "gender", "race")                 # Quasi-identifiers
num_vars       <- c("wtkg", "karnof", "preanti", "days")     # Numerical variables
sensitive_vars <- "treat"                                    # Sensitive variable

cat("\nSelected variables:\n")
cat("🔸 Quasi-identifiers:", paste(key_vars, collapse = ", "), "\n")
cat("🔸 Numerical:", paste(num_vars, collapse = ", "), "\n")
cat("🔸 Sensitive:", sensitive_vars, "\n")

# ---------------------------------------------------------------
# 4) Create the SDC object
# ---------------------------------------------------------------
cat("\n🔹 Creating SDC object for risk analysis...\n")

sdc <- createSdcObj(
  dat         = df,
  keyVars     = key_vars,
  numVars     = num_vars,
  sensibleVar = sensitive_vars
)

cat("✅ SDC object successfully created.\n")

# ---------------------------------------------------------------
# 5) Compute risk measures
# ---------------------------------------------------------------
cat("\n📈 Computing risk measures...\n")

rk            <- get.sdcMicroObj(sdc, type = "risk")
global_risk   <- rk$global$risk
expected_reid <- rk$global$risk_ER
indiv_risk    <- as.data.frame(rk$individual)

cat(sprintf("\n🌐 Global risk: %.2f%%", 100 * global_risk))
cat(sprintf("\n👥 Expected re-identifications: %.0f out of %d records\n",
            expected_reid, nrow(df)))

# ---------------------------------------------------------------
# 6) Compute k-anonymity
# ---------------------------------------------------------------
cat("\n🔹 Computing k-anonymity...\n")
fk <- freqCalc(as.data.frame(df), keyVars = key_vars)$fk
k_df <- cbind(df[key_vars], k = fk)

cat("✅ k-anonymity computed.\n")
cat("Average class size (k):", round(mean(k_df$k, na.rm = TRUE), 2), "\n")

# ---------------------------------------------------------------
# 7) Visualization
# ---------------------------------------------------------------
cat("\n📊 Displaying plots...\n")

# Boxplot of individual risk
boxplot(indiv_risk[,1],
        main = "Distribution of Individual Re-identification Risk",
        ylab = "Individual risk",
        col  = "lightblue")

# Histogram of individual risk
hist(indiv_risk[,1],
     breaks = 30,
     col    = "skyblue",
     main   = "Histogram of Individual Re-identification Risk",
     xlab   = "Individual risk")

# Histogram of k-anonymity
hist(k_df$k,
     breaks = seq(0.5, max(k_df$k, na.rm = TRUE) + 0.5, by = 1),
     main   = "Distribution of Equivalence Class Sizes (k)",
     xlab   = "Class size (k)",
     col    = "orange")

cat("\n✅ Plots displayed. Analysis completed.\n")

# ---------------------------------------------------------------
# 8) Summary interpretation
# ---------------------------------------------------------------
cat("\n🧭 Interpretation:\n")
cat(sprintf("• Global risk is %.2f%%: ", 100 * global_risk))
if (global_risk < 0.01) {
  cat("Excellent anonymization level.\n")
} else if (global_risk < 0.05) {
  cat("Moderate and acceptable risk.\n")
} else {
  cat("High risk — anonymization required.\n")
}

cat(sprintf("• About %.0f individuals (out of %d) have a significant re-identification risk.\n",
            expected_reid, nrow(df)))

cat("• The k-anonymity plot shows that many equivalence classes have small k,\n  meaning some profiles are nearly unique.\n")

cat("\n🔍 End of script — results are only displayed on screen, not saved.\n")
