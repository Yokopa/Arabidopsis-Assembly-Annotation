#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   04_plot_ltr_clade_data.sh
#
# DESCRIPTION: 
#   This script executes an R script to analyze and plot LTR clade data, including histograms 
#   and bar plots of transposable element (TE) identity data. It runs on a computational cluster 
#   using a Slurm workload manager.
#
# USAGE:
#   sbatch 04_plot_ltr_clade_data.sh
#
# REQUIREMENTS:
#   - The R script `04_plot_ltr_te_clade_data.R` should be located in the `$WORKDIR/scripts/` directory.
#   - The `R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2` module must be available on the cluster.
#   - Required R libraries (`ggplot2`, `dplyr`, `tidyr`) should be installed.
#
# INPUTS AND OUTPUT DIRECTORY:
#   - Input File: The R script expects a properly formatted tab-delimited input file 
#     (e.g., "03_ltr_extracted_data.tsv") for analysis. Ensure that this file is located in 
#     the designated output directory (`$OUTDIR`) before running the script. 
#     Alternatively, if the file is in another directory, execute the script from that directory 
#     or adjust the script to reference the correct file path.
#
#   - Output Directory: The script creates the `$OUTDIR` directory (if it does not exist) 
#     and sets it as the working directory (`cd $OUTDIR`) to save all outputs, such as generated plots 
#     and analysis results. By default, the input file should also reside in `$OUTDIR` for the script 
#     to function as intended.
#================================================================

#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=ltr_clade_histogram
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/04_ltr_clade_histogram_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/04_ltr_clade_histogram_error_%j.e
#SBATCH --partition=pibu_el8

# Load R module
module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2

# Set the working and output directory
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"
OUTDIR="$WORKDIR/outputs"

# Create the output directory if it doesn't exist and move to it
mkdir -p $OUTDIR
# Navigate to the directory where the input file resides
cd $OUTDIR

# Run the R script
Rscript "$WORKDIR/scripts/04_plot_ltr_te_clade_data.R"