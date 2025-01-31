#!/usr/bin/env bash

#===============================================================================
# SCRIPT NAME: 
#   06_plot_TE_density_circlize.sh
#
# DESCRIPTION:
#   This script runs an R script (`06_plot_TE_density_circlize.R`) to generate a Circos plot
#   visualizing the density of transposable elements (TEs) across the top 20 
#   longest scaffolds in a genome assembly. The Circos plot highlights TE 
#   densities by superfamilies and uses the 'circlize' R package.
#
# USAGE:
#   sbatch 06_plot_TE_density_circlize.sh
#
# REQUIREMENTS:
#   - A `.fai` index file for the genome assembly must be generated beforehand
#     using the `05_generate_fai_index.sh` script. This script uses `samtools faidx` 
#     to create the `.fai` index file, which provides scaffold lengths for creating 
#     the ideogram data needed by the Circos plot.
#       Command: sbatch 05_generate_fai_index.sh
#
#   - The following R libraries must be installed in the R environment loaded 
#     by the script (`R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2`):
#     - `circlize`
#     - `RColorBrewer`
#     - `tidyverse`
#
# INPUTS:
#   - Genome assembly `.fai` file (e.g., `assembly.fasta.fai`) created by running 
#     `05_generate_fai_index.sh`.
#   - TE annotation GFF3 file (e.g., `assembly.fasta.mod.EDTA.TEanno.gff3`) containing 
#     TE superfamily information for density plotting.
#
# OUTPUTS:
#   - A Circos plot in PDF format, saved to `$OUTDIR`, visualizing TE densities 
#     across scaffolds by superfamily.
#
# NOTE:
#   - Modify the `$WORKDIR` variable in this script to match your working directory structure.
#   - Ensure the R script `06_plot_TE_density_circlize.R` is located in the `$WORKDIR/scripts/` directory.
#   - In the R script `06_plot_TE_density_circlize.R`, update the file paths for:
#       1. The GFF3 annotation file (`gff_file`) to point to the correct path for 
#          the TE annotation file (e.g., `<WORKDIR>/outputs/01_edta_TE/assembly.fasta.mod.EDTA.TEanno.gff3`).
#       2. The FAI index file (`custom_ideogram`) to point to the correct path for 
#          the assembly `.fai` index file (e.g., `<WORKDIR>/outputs/05_assembly.fasta.fai`).
#===============================================================================

#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=te_density_plot
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/06_te_density_plot_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/06_te_density_plot_error_%j.e
#SBATCH --partition=pibu_el8

# Load R module
module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2

# Set the working and output directory
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"
OUTDIR="$WORKDIR/outputs"

# Create the output directory if it doesn't already exists
mkdir -p $OUTDIR

# Run the R script
Rscript "$WORKDIR/scripts/06_plot_TE_density_circlize.R"
