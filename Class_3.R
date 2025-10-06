# =====================================================================
#        Module II: Microarray Data Preprocessing Assignment
# =====================================================================
#

# Dataset: GSE79973 (Gastric Cancer vs. Normal Mucosa)
#
# This script performs the full preprocessing workflow for the
# Affymetrix microarray dataset GSE79973. The steps include
# data acquisition, quality control (QC), RMA normalization,
# filtering of low-intensity probes, and preparation of
# phenotype data for downstream analysis.
#
# =====================================================================


#######################################################################
#### 0. Setup: Install and Load Required Packages ####
#######################################################################

# Ensure BiocManager is installed, which is the standard way to install Bioconductor packages.
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# Install essential Bioconductor packages for microarray analysis.
# - GEOquery: To download data from NCBI's Gene Expression Omnibus (GEO).
# - affy: The core package for reading and normalizing Affymetrix CEL files.
# - arrayQualityMetrics: For generating comprehensive QC reports.
BiocManager::install(c("GEOquery", "affy", "arrayQualityMetrics"))

# Install CRAN packages for data manipulation.
install.packages("dplyr")

# Load the libraries into the R session.
library(GEOquery)
library(affy)
library(arrayQualityMetrics)
library(dplyr)
library(matrixStats) # For rowMedians function

# Set up directories for organization
dir.create("Raw_Data", showWarnings = FALSE)
dir.create("Results", showWarnings = FALSE)


#######################################################################
#### 1. Data Acquisition: Downloading Raw and Phenotype Data ####
#######################################################################

# Define the GEO accession ID for the study.
accession_id <- "GSE79973"
print(paste("Assignment Answer: The accession ID of the dataset is", accession_id))

# --- Step 1a: Download Phenotype Data using Series Matrix ---
# The series matrix file is a quick way to get sample metadata (phenotype data).
gse_data <- getGEO(accession_id, GSEMatrix = TRUE)
phenotype_data <- pData(gse_data[[1]])

# Let's inspect the phenotype data to understand our sample groups.
cat("\n--- Assignment Answer: Sample Composition ---\n")
print(table(phenotype_data$source_name_ch1))
# This shows 10 gastric adenocarcinoma samples (Disease) and 10 gastric mucosa samples (Normal).
# Total = 20, Disease = 10, Normal = 10.

# --- Step 1b: Download and Read Raw CEL Files ---
# Raw CEL files are needed for proper QC and normalization.
# This command was run once to download the compressed file.
# getGEOSuppFiles(accession_id, baseDir = "Raw_Data")

# Uncompress the .tar archive to a dedicated CEL_Files directory.
# This was also run once.
# untar("Raw_Data/GSE79973_RAW.tar", exdir = "Raw_Data/CEL_Files")

# Read all .CEL files into an AffyBatch object. This object is the starting point for our analysis.
raw_affy_data <- ReadAffy(celfile.path = "Raw_Data/CEL_Files")
print(raw_affy_data)


#######################################################################
#### 2. Quality Control (QC) on Raw Data ####
#######################################################################

# Before normalization, it's crucial to check the raw data for technical issues.
# arrayQualityMetrics generates an interactive HTML report with various plots
# (boxplots, heatmaps, PCA) to help identify potential outlier arrays.
arrayQualityMetrics(expressionset = raw_affy_data,
                    outdir = "Results/QC_Report_Raw",
                    force = TRUE,
                    do.logtransform = TRUE)

# Observation: The QC report on the raw data flagged 5 potential outliers.
# This is common before normalization, as technical variations can make some arrays
# appear very different from others.


#######################################################################
#### 3. RMA Normalization ####
#######################################################################

# We use Robust Multi-array Average (RMA) to preprocess the data.
# RMA performs three key steps:
# 1. Background Correction: Removes noise.
# 2. Quantile Normalization: Aligns distributions across all arrays.
# 3. Summarization: Calculates a single expression value per gene from its probes.
cat("\nNormalizing data using RMA... This may take a moment.\n")
normalized_eset <- rma(raw_affy_data)
cat("Normalization complete.\n")


#######################################################################
#### 4. Quality Control (QC) on Normalized Data ####
#######################################################################

# After normalization, we run QC again to see if the previous issues were resolved.
# We expect the arrays to look much more consistent now.
arrayQualityMetrics(expressionset = normalized_eset,
                    outdir = "Results/QC_Report_Normalized",
                    force = TRUE)

# --- Assignment Answer: Outlier Detection ---
# The report showed that after normalization, only one sample (GSM2108428) was
# flagged as a potential outlier by a single method (distances between arrays).
# Since it was not flagged by multiple QC methods and could represent true
# biological variability, we will keep it for the analysis as per the tutorial's recommendation.
cat("\n--- Assignment Answer: Outliers after Normalization ---\n")
print("Yes, outlier arrays were detected after normalization.")
print("Number of outliers flagged: 1")


#######################################################################
#### 5. Filtering Low-Intensity Probes ####
#######################################################################

# Extract the normalized expression values into a matrix.
processed_data <- exprs(normalized_eset)

# Check the number of probes before filtering.
cat("\n--- Assignment Answer: Probes Before Filtering ---\n")
print(paste("Number of probes before filtering:", nrow(processed_data)))

# Filter out probes that have low expression across all samples. These are
# often uninformative and can add noise to downstream analysis.
# We will filter based on the median intensity of each probe.

# Calculate the median intensity for each probe across all samples.
row_medians <- rowMedians(as.matrix(processed_data))

# Visualize the distribution to choose a threshold.
hist(row_medians, 100, col = "cornflowerblue",
     main = "Distribution of Median Probe Intensities",
     xlab = "Median Intensity",
     ylab = "Frequency")

# A threshold of 3.5 seems appropriate to remove the left tail of the distribution.
threshold <- 3.5
abline(v = threshold, col = "red", lwd = 2, lty = 2)
legend("topright", "Filtering Threshold", col = "red", lwd = 2, lty = 2)

# Apply the filter: keep only probes with a median intensity greater than the threshold.
keep_indices <- row_medians > threshold
filtered_data <- processed_data[keep_indices, ]

# --- Assignment Answer: Probes After Filtering ---
cat("\n--- Assignment Answer: Transcripts After Filtering ---\n")
print(paste("Number of transcripts remaining after filtering:", nrow(filtered_data)))


#######################################################################
#### 6. Final Data Preparation ####
#######################################################################

# The column names are currently the long .CEL file names.
# Let's replace them with the sample names from the phenotype data for clarity.
colnames(filtered_data) <- rownames(phenotype_data)
cat("\nCleaned up column names:\n")
print(head(colnames(filtered_data)))

# --- Assignment Answer: Relabeling Target Groups ---
# To make the data intuitive for statistical analysis (e.g., differential expression),
# we will create a 'groups' factor with clear labels.
groups <- factor(phenotype_data$source_name_ch1,
                 levels = c("gastric mucosa", "gastric adenocarcinoma"),
                 labels = c("normal", "cancer"))

cat("\n--- Assignment Answer: Relabeling Target Groups ---\n")
print("Yes, the target groups were relabeled.")
print("The new labels are:")
print(table(groups))

# =====================================================================
#                        Preprocessing Complete
# =====================================================================
# The 'filtered_data' matrix and 'groups' factor are now ready for
# downstream analysis, such as differential gene expression.
# =====================================================================
