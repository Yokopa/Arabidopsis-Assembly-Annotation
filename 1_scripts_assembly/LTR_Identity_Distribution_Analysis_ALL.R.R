# Load necessary libraries
library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)

# Read each file for all three accessions
ishikawa <- read_tsv("/home/anna/Master/corsi/third_sem/annotation/practicals/Ishikawa/02_ishikawa_ltr_extracted_data.tsv")
abd_0 <- read_tsv("/home/anna/Master/corsi/third_sem/annotation/practicals/Abd-0/abd_ltr_extracted_data.tsv")
qar_8a <- read_tsv("/home/anna/Master/corsi/third_sem/annotation/practicals/Qar-8a/Qar81_ltr_extracted_data.tsv")

# Combine all data into one dataset and add a column for accession
combined_data <- bind_rows(
  ishikawa %>% mutate(Accession = "Ishikawa"),
  abd_0 %>% mutate(Accession = "Abd-0"),
  qar_8a %>% mutate(Accession = "Qar-8a")
)

# ------------------------------------------------------------------------------
# Plot the distribution of Percent_Identity for each Clade (combined for all accessions)
# ------------------------------------------------------------------------------
# Define a vector of clades that belong to COPIA
copia_clades <- c("Ale", "Alesia", "Angela", "Bianca", "Ikeros", "Ivana", "SIRE", "TAR", "Tork", "Mixture")

# Create a new column 'Superfamily' that assigns each clade to 'Copia' or 'Gypsy'
ishikawa$Superfamily <- ifelse(ishikawa$Clade %in% copia_clades, "Copia", "Gypsy")
abd_0$Superfamily <- ifelse(abd_0$Clade %in% copia_clades, "Copia", "Gypsy")
qar_8a$Superfamily <- ifelse(qar_8a$Clade %in% copia_clades, "Copia", "Gypsy")

# Now, you can map colors based on the 'Superfamily' column
# For ABD-0
dist_plot_abd_0 <- ggplot(abd_0, aes(x = Percent_Identity, fill = Superfamily)) +
  geom_histogram(binwidth = 0.01, alpha = 0.6, position = "identity", color = "black") +
  facet_wrap(~ Clade, scales = "fixed") + 
  scale_fill_manual(values = c("Copia" = "lightblue", "Gypsy" = "lightcoral")) +  # Change colors
  theme_minimal() +
  labs(title = "Distribution of Percent Identity by Clade - Abd-0",
       x = "Percent Identity",
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        legend.position = "none")
print(dist_plot_abd_0)

# For Ishikawa
dist_plot_ishikawa <- ggplot(ishikawa, aes(x = Percent_Identity, fill = Superfamily)) +
  geom_histogram(binwidth = 0.01, alpha = 0.6, position = "identity", color = "black") +
  facet_wrap(~ Clade, scales = "fixed") + 
  scale_fill_manual(values = c("Copia" = "lightblue", "Gypsy" = "lightcoral")) +  # Change colors
  theme_minimal() +
  labs(title = "Distribution of Percent Identity by Clade - Ishikawa",
       x = "Percent Identity",
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        legend.position = "none")
print(dist_plot_ishikawa)

# For Qar-8a
dist_plot_qar_8a <- ggplot(qar_8a, aes(x = Percent_Identity, fill = Superfamily)) +
  geom_histogram(binwidth = 0.01, alpha = 0.6, position = "identity", color = "black") +
  facet_wrap(~ Clade, scales = "fixed") + 
  scale_fill_manual(values = c("Copia" = "lightblue", "Gypsy" = "lightcoral")) +  # Change colors
  theme_minimal() +
  labs(title = "Distribution of Percent Identity by Clade - Qar-8a",
       x = "Percent Identity",
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        legend.position = "none")
print(dist_plot_qar_8a)

# Save all plots to a PDF
pdf("percent_identities_distribution_ALL.pdf", width = 12, height = 8)
print(dist_plot_ishikawa)
print(dist_plot_abd_0)
print(dist_plot_qar_8a)
dev.off()

# Confirm saving
print("All plots saved as 'percent_identities_distribution_ALL.pdf'")

################################

# Add the 'Superfamily' column to the combined data
combined_data$Superfamily <- ifelse(combined_data$Clade %in% copia_clades, "Copia", "Gypsy")

# Filter combined data for Copia and Gypsy
combined_data_copia <- combined_data[combined_data$Superfamily == "Copia", ]
combined_data_gypsy <- combined_data[combined_data$Superfamily == "Gypsy", ]

# For Copia
dist_plot_combined_copia <- ggplot(combined_data_copia, aes(x = Percent_Identity, fill = Accession)) +
  geom_histogram(binwidth = 0.01, alpha = 0.6, position = "stack", color = "black") +  # Stack the bars
  facet_wrap(~ Clade, scales = "fixed") +  # Facet by Clade
  scale_fill_manual(values = c("Ishikawa" = "lightblue", "Abd-0" = "lightcoral", "Qar-8a" = "gold")) +  # Colors for each accession
  theme_minimal() +
  labs(title = "Stacked distribution of percent identity by clade - Copia",
       x = "Percent Identity",
       y = "Frequency") +
  theme(plot.background = element_rect(fill="white"),
        axis.text.x = element_text(angle = 0, hjust = 1, size = 14),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        legend.position = "top",
        strip.text = element_text(size = 14))

# For Gypsy
dist_plot_combined_gypsy <- ggplot(combined_data_gypsy, aes(x = Percent_Identity, fill = Accession)) +
  geom_histogram(binwidth = 0.01, alpha = 0.6, position = "stack", color = "black") +  # Stack the bars
  facet_wrap(~ Clade, scales = "fixed") +  # Facet by Clade
  scale_fill_manual(values = c("Ishikawa" = "lightblue", "Abd-0" = "lightcoral", "Qar-8a" = "gold")) +  # Colors for each accession
  theme_minimal() +
  labs(title = "Stacked distribution of percent identity by clade - Gypsy",
       x = "Percent Identity",
       y = "Frequency") +
  theme(plot.background = element_rect(fill="white"),
        axis.text.x = element_text(angle = 0, hjust = 1, size = 14),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        legend.position = "top",
        strip.text = element_text(size = 14))

# Save the Copia plot to a PDF
pdf("percent_identities_distribution_copia.pdf", width = 12, height = 8)
print(dist_plot_combined_copia)
dev.off()

# Save the Gypsy plot to a PDF
pdf("percent_identities_distribution_gypsy.pdf", width = 12, height = 8)
print(dist_plot_combined_gypsy)
dev.off()

# Confirm saving
print("Copia and Gypsy plots saved as separate PDFs.")

# ------------------------------------------------------------------------------
# Check and print the total number of LTR-RTs for each clade and accession
# ------------------------------------------------------------------------------
clade_totals <- df_grouped %>%
  group_by(Clade, Accession) %>%
  summarise(Total_LTR_RTs = sum(Frequency), .groups = "drop") %>%
  arrange(desc(Total_LTR_RTs))
cat("\nClades sorted by total number of LTR-RTs for each accession:\n")
print(clade_totals)
cat("#########################################\n")

# ------------------------------------------------------------------------------
# Create and Save a Bar Plot of LTR Identity Categories for Each Clade and Accession
# ------------------------------------------------------------------------------
# Create identity categories based on Percent_Identity
combined_data <- combined_data %>%
  mutate(Identity_Category = case_when(
    Percent_Identity >= 0.99 ~ "High",
    Percent_Identity < 0.90 & Percent_Identity >= 0.70 ~ "Low",
    TRUE ~ "Other"
  ))

# Group by Clade, Identity_Category, and Accession to count frequencies
df_grouped <- combined_data %>%
  group_by(Clade, Identity_Category, Accession) %>%
  summarise(Frequency = n(), .groups = "drop")

# Display the table using kable
library(knitr)
kable(df_grouped, caption = "Table 1: Frequency of Identity Categories by Clade and Accession")

# ------------------------------------------------------------------------------
# Check and print the total number of High Identity (99-100%) LTR-RTs for each clade and accession
# ------------------------------------------------------------------------------
high_identity_totals <- df_grouped %>%
  filter(Identity_Category == "High") %>%
  group_by(Clade, Accession) %>%
  summarise(High_Identity_LTR_RTs = sum(Frequency), .groups = "drop") %>%
  arrange(desc(High_Identity_LTR_RTs))
cat("\nClades sorted by number of High Identity (99-100%) LTR-RTs for each accession:\n")
print(high_identity_totals)
cat("#########################################\n")

# ------------------------------------------------------------------------------
# Create a bar plot for each Clade showing the frequency of Identity Categories 
# with different colors for each Accession
# ------------------------------------------------------------------------------
# Filter to include only "High" and "Low" categories
df_filtered <- df_grouped %>%
  filter(Identity_Category %in% c("High", "Low"))


# Create the bar plot for High and Low categories, grouped by Clade and Accession
bar_plot <- ggplot(df_filtered, aes(x = Identity_Category, y = Frequency, fill = Accession)) +
  geom_bar(stat = "identity", color="black", position = "dodge", alpha = 0.7) +  # Set transparency (alpha)
  facet_wrap(~ Clade, scales = "fixed") +  # Facet by Clade
  scale_fill_manual(values = c("Ishikawa" = "lightblue", "Abd-0" = "lightcoral", "Qar-8a" = "gold")) +  # Set colors for each accession
  theme_minimal() +
  labs(title = " ",
       x = "Identity Category", 
       y = "Frequency") +
  theme(plot.background = element_rect(fill = "white"),  # Set background to white
        axis.text.x = element_text(angle = 0, hjust = 1, size = 14),  # Increase size of x labels
        axis.text.y = element_text(size = 14),  # Increase size of y labels
        axis.title.x = element_text(size = 14, margin = margin(t = 10)),  # Increase and add space (top margin) for x axis title
        axis.title.y = element_text(size = 14, margin = margin(r = 10)),  # Increase and add space (right margin) for y axis title
        legend.title = element_blank(),  # Remove legend title
        legend.position = "top",      # Move legend to the bottom
        legend.text = element_text(size = 14),
        strip.text = element_text(size = 16, face = "bold"))  # Bold and increase font size of Clade labels

# Save the bar plot
bar_plot_file <- paste0("LTR_category_frequency_high_low_by_clade_with_legend_and_bold_clade_labels.png")
ggsave(bar_plot_file, bar_plot, width = 12, height = 8)

# Optional: Print the filenames to the console
print(paste("Bar plot saved as:", bar_plot_file))

# ------------------------------------------------------------------------------
# Plot the distribution of Athila and CRM clades (known centromeric TEs in Brassicaceae)
# ------------------------------------------------------------------------------
# Filter the dataset for Athila and CRM clades
centromeric_df <- combined_data %>%
  filter(Clade %in% c("Athila", "CRM"))

# Plot the distribution for Athila and CRM clades
centromeric_dist_plot <- ggplot(centromeric_df, aes(x = Percent_Identity, fill = Accession)) +
  geom_histogram(binwidth = 0.01, alpha = 0.6, position = "identity", color = "black") +
  facet_wrap(~ Clade + Accession, scales = "fixed") + 
  scale_fill_manual(values = c("Ishikawa" = "lightblue", "Abd-0" = "lightcoral", "Qar-8a" = "gold")) + 
  theme_minimal() +
  labs(title = "Distribution of Percent Identity for Centromeric TEs (Athila and CRM)",
       x = "Percent Identity",
       y = "Frequency") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        plot.background = element_rect(fill = "white"),
        legend.position = "none")  # Remove the legend

# Save the centromeric distribution plot
centromeric_plot_file <- paste0("Athila_CRM_percent_identity_distribution_all_accessions.png")
ggsave(centromeric_plot_file, centromeric_dist_plot, width = 12, height = 8)

# Optional: Print the filename to the console
print(paste("Centromeric distribution plot saved as:", centromeric_plot_file))

