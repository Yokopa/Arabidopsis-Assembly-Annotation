#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   09_analyze_te_divergence_age.sh
#
# DESCRIPTION:
#   This script submits a SLURM job to run the R script `09_analyze_te_divergence_age.R`,
#   which processes RepeatMasker results, calculates the divergence and insertion times
#   of transposable elements (TEs), and generates visualizations.
#   
# USAGE:
#   sbatch 09_analyze_te_divergence_age.sh
#
# DEPENDENCIES:
#   - R (R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2): For running the R script to analyze the data.
#   - The R script `09_analyze_te_divergence_age.R`: Analyzes and visualizes the TE data.
#
# OUTPUT:
#   - The R script generates visualizations, which are saved as PDF files in the output directory.
#
# NOTE:
#   - Ensure the R script `09_analyze_te_divergence_age.R` is available in the `$WORKDIR/scripts/` directory.
#   - Modify the `$WORKDIR` variable to point to the correct working directory where the data and R script are located.
#================================================================

#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=plot_div
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/09_plot_div_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/09_plot_div_error_%j.e
#SBATCH --partition=pibu_el8

# Load R module
module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2

# Set the working and output directory
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"
OUTDIR="$WORKDIR/outputs"

# Create the output directory if it doesn't exist
mkdir -p $OUTDIR
# Move to the working directory
cd $WORKDIR

# Run the R script
Rscript "$WORKDIR/scripts/09_analyze_te_divergence_age.R"
