# ===================================================================
#                  TRY IT YOURSELF SOLUTIONS
# ===================================================================

# -----------------------------------------------------------
# 1. Cholesterol Level (Using if)
# -----------------------------------------------------------

cholesterol <- 230   # Store cholesterol value

# Check if cholesterol level is greater than 240
if (cholesterol > 240) {
  print("High Cholesterol")
}

# If cholesterol = 230, nothing is printed because condition is FALSE


# -----------------------------------------------------------
# 2. Blood Pressure Status (Using if...else)
# -----------------------------------------------------------

Systolic_bp <- 130   # Store systolic blood pressure

# Check if blood pressure is normal (<120)
if (Systolic_bp < 120) {
  print("Blood Pressure is normal")
} else {
  print("Blood Pressure is high")
}

# Since Systolic_bp = 130, it prints "Blood Pressure is high"


# -----------------------------------------------------------
# 3. Automating Data Type Conversion with for loop
# -----------------------------------------------------------

# Load dataset (patient_info.csv) into R
patient_data <- read.csv(file.choose())   # choose patient_info.csv
metadata <- read.csv(file.choose())       # choose metadata.csv

# Create copies to preserve originals
patient_clean <- patient_data
metadata_clean <- metadata

# Identify character columns in patient_info
str(patient_clean)
factor_cols_patient <- c("gender", "diagnosis", "smoker")   

# Loop through and convert character columns to factors in patient_data
for (col in factor_cols_patient) {
  patient_clean[[col]] <- as.factor(patient_clean[[col]])
}

str(patient_clean)

# Identify character columns in metadata
str(metadata_clean)
factor_cols_meta <- c("height", "gender")   

# Loop through and convert character columns to factors in metadata
for (col in factor_cols_meta) {
  metadata_clean[[col]] <- as.factor(metadata_clean[[col]])
}

str(metadata_clean)
# Check structure after conversion
str(patient_clean)
str(metadata_clean)


# -----------------------------------------------------------
# 4. Converting Factors to Numeric Codes
# -----------------------------------------------------------

# Example: Convert "smoking_status" factor to binary (Yes = 1, No = 0)

# Store column(s) to convert in a vector
binary_cols <- c("smoker")

# Loop through binary columns and recode
for (col in binary_cols) {
  patient_clean[[col]] <- ifelse(patient_clean[[col]] == "Yes", 1, 0)
}

# Verify changes
str(patient_clean)
str(patient_data)

# The original "Yes"/"No" becomes numeric binary (1/0).
