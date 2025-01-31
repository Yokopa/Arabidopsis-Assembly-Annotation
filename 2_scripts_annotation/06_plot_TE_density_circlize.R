# ------------------------------------------------------------------------------
# Script to Plot Transposable Element (TE) Density for Selected Superfamilies
# 
# This script generates a Circos plot showing the density of various transposable 
# element (TE) superfamilies across the top 20 longest scaffolds in a genome. 
# It uses the 'circlize' and 'RColorBrewer' packages to generate the circular plot, 
# and the plot is saved as a PDF.
#
# Dependencies:
# - circlize: For generating circular plots of genomic data.
# - RColorBrewer: For defining color palettes.
# - tidyverse: For data manipulation.
#
# Outputs:
# - A PDF file containing a circular plot of TE densities for each superfamily.
# ------------------------------------------------------------------------------

# Load the circlize package
library(circlize)
library(RColorBrewer)
library(tidyverse)

# Load the TE annotation GFF3 file
gff_file <- "/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/01_edta_TE/assembly.fasta.mod.EDTA.TEanno.gff3"
gff_data <- read.table(gff_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# Check the superfamilies present in the GFF3 file, and their counts
gff_data$V3 %>% table()

# Remove unwanted terms: repeat_region, target_site_duplication, long_terminal_repeat
gff_data_filtered <- gff_data %>%
  filter(!V3 %in% c("repeat_region", "target_site_duplication", "long_terminal_repeat"))

# Set the filtered and ordered superfamilies
superfamilies <- c("Gypsy_LTR_retrotransposon", "Copia_LTR_retrotransposon", "CACTA_TIR_transposon", "Mutator_TIR_transposon", "PIF_Harbinger_TIR_transposon", "Tc1_Mariner_TIR_transposon", "hAT_TIR_transposon", "helitron")
cat("Superfamilies filtered and ordered:", superfamilies, "\n")

# custom ideogram data
## To make the ideogram data, you need to know the lengths of the scaffolds.
## There is an index file that has the lengths of the scaffolds, the `.fai` file.
## To generate this file you need to run the following command in bash:
## samtools faidx assembly.fasta
## This will generate a file named assembly.fasta.fai
## You can then read this file in R and prepare the custom ideogram data

custom_ideogram <- read.table("/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/05_assembly.fasta.fai", header = FALSE, stringsAsFactors = FALSE)
custom_ideogram$chr <- custom_ideogram$V1
custom_ideogram$start <- 1
custom_ideogram$end <- custom_ideogram$V2
custom_ideogram <- custom_ideogram[, c("chr", "start", "end")]
custom_ideogram <- custom_ideogram[order(custom_ideogram$end, decreasing = T), ]
sum(custom_ideogram$end[1:20])

# Select only the first 20 longest scaffolds, You can reduce this number if you have longer chromosome scale scaffolds
custom_ideogram <- custom_ideogram[1:20, ]

# Function to filter GFF3 data based on Superfamily (You need one track per Superfamily)
filter_superfamily <- function(gff_data, superfamily, custom_ideogram) {
    filtered_data <- gff_data[gff_data$V3 == superfamily, ] %>%
        as.data.frame() %>%
        mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
        select(chrom, start, end, strand) %>%
        filter(chrom %in% custom_ideogram$chr)
    return(filtered_data)
}

pdf("/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/06_TE_density.pdf", width = 15, height = 13)

# Define a color palette for the superfamilies
colors <- brewer.pal(length(superfamilies), "Paired")

# Set plot parameters
gaps <- c(rep(1, length(custom_ideogram$chr) - 1), 5)  # Add a gap between scaffolds
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)

# Adjust Circlize parameters to give more room
circos.par(
  start.degree = 90, 
  gap.after = 1, 
  track.margin = c(0, 0),  # Adjust margin between tracks
  gap.degree = 0  # Increase the gap between sectors (scaffolds)
)

# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(custom_ideogram)

# Loop over all superfamilies and plot their density
for (i in seq_along(superfamilies)) {
  circos.genomicDensity(
    filter_superfamily(gff_data_filtered, superfamilies[i], custom_ideogram), 
    count_by = "number", 
    col = colors[i],  # Dynamically use colors for each superfamily
    track.height = 0.07, 
    window.size = 1e5
  )
}

# Draw the legend in the plot using base R's `legend()` function
legend("topright",  # Position of the legend (adjust as needed)
       legend = superfamilies,  # Superfamily names
       fill = colors,  # Corresponding colors
       title = "Superfamily",  # Title of the legend
       cex = 1,  # Size of the legend text
       bty = "n")  # No box around the legend

circos.clear()

# Close the graphics device
dev.off()
