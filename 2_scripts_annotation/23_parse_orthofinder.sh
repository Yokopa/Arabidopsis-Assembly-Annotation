#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   23_parse_orthofinder.sh
#
# DESCRIPTION:
#   This script runs the R script `23_parse_orthofinder.R` which processes
#   orthogroup statistics, generates plots, and creates an upset plot 
#   based on gene count data.
#
# USAGE:
#   sbatch 23_parse_orthofinder.sh
#
# REQUIREMENTS:
#   - R and the following R libraries: `tidyverse`, `data.table`, `ggplot2`, `cowplot`, `UpSetR`, `ComplexUpset`
#
# INPUT:
#   - `23_parse_orthofinder.R` (R script)
#   - `Statistics_PerSpecies.tsv` (Orthofinder comparative genomics statistics)
#   - `Orthogroups.GeneCount.tsv` (Orthogroups gene count data)
#
# OUTPUT:
#   - Plots in the directory `23_orthogroup_plots/`
#   - A PDF file of the upset plot in `23_orthogroup_plots/one-to-one_orthogroups_plot.complexupset.pdf`
#================================================================

#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=parse_orthofinder
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/23_parse_orthofinder_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/23_parse_orthofinder_error_%j.e
#SBATCH --partition=pibu_el8

# Load R module
module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2

# Set the working and output directory
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"
OUTDIR="$WORKDIR/outputs/23_orthogroup_plots"

# Create the output directory if it doesn't exist
mkdir -p $OUTDIR
cd $WORKDIR/outputs

# Run the R script with the appropriate arguments
Rscript $WORKDIR/scripts/23_parse_orthofinder.R