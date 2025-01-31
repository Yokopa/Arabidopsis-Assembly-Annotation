# ---------------------------------------------------------------
# R Script to Process Orthofinder Results and Generate Visualizations
#
# Description:
#   This script processes the output of Orthofinder comparative genomics 
#   analysis, specifically focusing on extracting and visualizing key 
#   statistics related to orthogroups across different species.
#
#   Specifically, the script:
#   1. Loads required libraries (`tidyverse`, `data.table`, `UpSetR`, 
#      and `ComplexUpset`) for data manipulation and visualization.
#   2. Reads in the file `Statistics_PerSpecies.tsv` containing 
#      comparative genomics statistics.
#   3. Transforms the data into a long format using `pivot_longer` 
#      to separate values by species.
#   4. Filters the data to create two subsets:
#      - `ortho_ratio`: contains count-based statistics (e.g., number of genes in orthogroups, unassigned genes).
#      - `ortho_percent`: contains percentage-based statistics (e.g., percentage of genes in orthogroups).
#   5. Creates bar plots (`ggplot2`) for both `ortho_ratio` and `ortho_percent`:
#      - A bar plot of gene count data for each species.
#      - A bar plot of percentage data for each species.
#   6. Saves the plots to PDF files in the `23_orthogroup_plots` directory.
#   7. Reads in the `Orthogroups.GeneCount.tsv` file to extract gene presence/absence data for orthogroups.
#   8. Converts gene counts to presence/absence (1 for present, 0 for absent).
#   9. Creates an upset plot to visualize orthogroup overlap and presence/absence data across species.
#   10. Saves the upset plot as a PDF in the `Plots` directory.
#
# Notes:
#   - Ensure all required libraries (`tidyverse`, `data.table`, `UpSetR`, 
#     `ComplexUpset`, and `ggplot2`) are installed in your R environment.
#   - This script expects input files:
#     - `Statistics_PerSpecies.tsv` from the Orthofinder comparative genomics analysis.
#     - `Orthogroups.GeneCount.tsv` containing gene counts for orthogroups.
#   - The script saves two types of plots to PDF:
#     - `orthogroup_plot.pdf`: Bar plot of orthogroup counts.
#     - `orthogroup_percent_plot.pdf`: Bar plot of orthogroup percentages.
#     - `one-to-one_orthogroups_plot.complexupset.pdf`: UpSet plot showing orthogroup presence/absence.
# ---------------------------------------------------------------

library(tidyverse)
library(data.table)

dat <- fread("/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/22_genespace/orthofinder/Results_Jan25/Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv", header = T, fill = TRUE)
genomes <- names(dat)[names(dat) != "V1"]

dat <- dat %>% pivot_longer(cols = -V1, names_to = "species", values_to = "perc")
ortho_ratio <- dat %>%
    filter(V1 %in% c(
        "Number of genes", "Number of genes in orthogroups", "Number of unassigned genes",
        "Number of orthogroups containing species", "Number of species-specific orthogroups", "Number of genes in species-specific orthogroups"
    ))

ortho_percent <- dat %>%
    filter(V1 %in% c(
        "Percentage of genes in orthogroups", "Percentage of unassigned genes", "Percentage of orthogroups containing species",
        "Percentage of genes in species-specific orthogroups"
    ))

p <- ggplot(ortho_ratio, aes(x = V1, y = perc, fill = species)) +
    geom_col(position = "dodge") +
    cowplot::theme_cowplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(y = "Count")
ggsave("23_orthogroup_plots/orthogroup_plot.pdf")


p <- ggplot(ortho_percent, aes(x = V1, y = as.numeric(perc), fill = species)) +
    geom_col(position = "dodge") +
    ylim(c(0, 100)) +
    cowplot::theme_cowplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(y = "Count")
ggsave(
  filename = "23_orthogroup_plots/orthogroup_percent_plot.pdf", 
  plot = p,
  width = 10,  # Custom width
  height = 8   # Default height
)


library(UpSetR)


orthogroups <- fread("/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/22_genespace/orthofinder/Results_Jan25/Orthogroups/Orthogroups.GeneCount.tsv")
orthogroups <- orthogroups %>%
    select(-Total)
ogroups_presence_absence <- orthogroups
rownames(ogroups_presence_absence) <- ogroups_presence_absence$Orthogroup

# convert the gene counts to presence/absence
ogroups_presence_absence[ogroups_presence_absence > 0] <- 1
ogroups_presence_absence$Orthogroup <- rownames(ogroups_presence_absence)

str(ogroups_presence_absence)

ogroups_presence_absence <- ogroups_presence_absence %>%
    rowwise() %>%
    mutate(SUM = sum(c_across(!ends_with("Orthogroup"))))

ogroups_presence_absence <- data.frame(ogroups_presence_absence)
ogroups_presence_absence[genomes] <- ogroups_presence_absence[genomes] == 1


# use ComplexUpset package to make an upset plot with a subset of the data
library(ComplexUpset)

pdf("23_orthogroup_plots/one-to-one_orthogroups_plot.complexupset.pdf", height = 5, width = 10, useDingbats = FALSE)

upset(ogroups_presence_absence, genomes, name = "genre", width_ratio = 0.1, wrap = TRUE, set_sizes = FALSE)
dev.off()
