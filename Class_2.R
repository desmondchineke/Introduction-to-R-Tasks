# ===================================================================
# Assignment 2 Solution
# ===================================================================
# Topic: Classification of Differentially Expressed Genes (DEGs)
# ===================================================================

# --------------------------
# Step 1: Define classify_gene() function
# --------------------------

# Function takes:
#   - logFC  (log2 fold change)
#   - padj   (adjusted p-value)
# Returns:
#   - "Upregulated" if logFC > 1 and padj < 0.05
#   - "Downregulated" if logFC < -1 and padj < 0.05
#   - "Not_Significant" otherwise

classify_gene <- function(logFC, padj) {
  if (logFC > 1 & padj < 0.05) {
    return("Upregulated")
  } else if (logFC < -1 & padj < 0.05) {
    return("Downregulated")
  } else {
    return("Not_Significant")
  }
}

# --------------------------
# Step 2: Setup input and output directories
# --------------------------

input_dir <- "Raw_data"
output_dir <- "Results"

# Create Results folder if it does not exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# --------------------------
# Step 3: Specify DEG datasets
# --------------------------

files_to_process <- c("DEGs_Data_1.csv", "DEGs_Data_2.csv")

# Prepare empty list to store results
deg_results <- list()

# --------------------------
# Step 4: Process files in loop
# --------------------------

for (file_name in files_to_process) {
  cat("\nProcessing:", file_name, "\n")
  
  # Import dataset
  input_file_path <- file.path(input_dir, file_name)
  data <- read.csv(input_file_path, header = TRUE)
  cat("File imported successfully.\n")
  
  # Handle missing padj values (replace with 1)
  data$padj[is.na(data$padj)] <- 1
  
  # Apply classify_gene() function to each row
  data$status <- mapply(classify_gene, data$logFC, data$padj)
  
  # Save processed dataset in R list
  deg_results[[file_name]] <- data
  
  # Save processed dataset as CSV in Results folder
  output_file_path <- file.path(output_dir, paste0("Processed_", file_name))
  write.csv(data, output_file_path, row.names = FALSE)
  cat("Processed results saved to:", output_file_path, "\n")
  
  # Print summary using table()
  cat("Summary of gene classification:\n")
  print(table(data$status))
}

# --------------------------
# Step 5: Access results for each dataset
# --------------------------

results_1 <- deg_results[["DEGs_Data_1.csv"]]
results_2 <- deg_results[["DEGs_Data_2.csv"]]

results_1
results_2

save.image(file = "full_workspace.RData")
# ===================================================================
# End of Assignment
# ===================================================================
