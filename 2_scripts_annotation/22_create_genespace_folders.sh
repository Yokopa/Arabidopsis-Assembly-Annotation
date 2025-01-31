#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   22_create_genespace_folders.sh
#
# DESCRIPTION:
#   This script prepares files and directories for running the 
#   GeneSpace pipeline by processing genome annotations and 
#   protein sequences. It performs the following tasks:
#   1. Filters gene annotations to include only the top 20 largest scaffolds
#   2. Creates BED files for the filtered annotations
#   3. Prepares a peptide FASTA file by filtering proteins for the top scaffolds
#   4. Copies required reference files to the output directory
#
# USAGE:
#   sbatch 22_create_genespace_folders.sh
#
# REQUIREMENTS:
#   - R and the following R libraries: `data.table`, `tidyverse`
#   - Input files (see below)
#
# INPUT:
#   - Gene annotation file in GFF3 format
#   - Fasta index file (FASTA.fai) for scaffolds
#   - Protein FASTA file containing longest isoforms
#
# OUTPUT:
#   - Filtered BED file for GeneSpace input
#   - Filtered peptide FASTA file for GeneSpace input
#
# NOTES:
#   - Update all file paths (e.g., WORKDIR, ANNO_FILE, FASTA_FAI, LONGEST_PROTEINS) 
#     to match your specific file system and input data locations.
#   - Replace the ACCESSION_NAME variable with the appropriate name for your data.
#================================================================

#SBATCH --time=05:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=genespace_folders
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/22_genespace_folders_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/22_genespace_folders_error_%j.e
#SBATCH --partition=pibu_el8

# Load R module
module load R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2
module load MariaDB/10.6.4-GCC-10.3.0
module load UCSC-Utils/448-foss-2021a

# Set working directory and file paths
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs"
R_SCRIPT="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/scripts/22_create_genespace_folders.R"
OUTDIR="$WORKDIR/22_genespace"

#############################################################################################
# FIRST ACCESSION Qar-8a - Uncomment the following block if you want to process the first accession. 
#############################################################################################
# ANNO_FILE="$WORKDIR/16_final_GENE/filtered.genes.renamed.final.gff3"
# FASTA_FAI="$WORKDIR/05_assembly.fasta.fai"
# LONGEST_PROTEINS="$WORKDIR/17_longest_isoforms/assembly_longest_protein_isoforms.fasta"

# # Replace this with the desired accession name. 
# # Use only alphanumeric characters, underscores (_), or dots (.), and avoid spaces, hyphens (-), or other special characters.
# ACCESSION_NAME="Qar_8a" 

# -------------------------------------------------------------------------------------------

###############################################################################################
# SECOND ACCESSION Abd-0 - Uncomment the following block if you want to process the second accession. 
###############################################################################################
# # Be sure to comment out the first accession block.
# # Set working directory and file paths for the second accession. 
# ANNO_FILE="/data/users/ascarpellini/assembly_annotation_course24/gene_annotation/final/filtered.genes.renamed.final.gff3"
# FASTA_FAI="/data/users/ascarpellini/assembly_annotation_course24/assemblies/flye/assembly.fasta.fai"
# LONGEST_PROTEINS="/data/users/ascarpellini/assembly_annotation_course24/gene_annotation/final/longest_proteins/assembly_longest_protein_isoforms.fasta"

# # Replace this with the desired accession name. 
# # Use only alphanumeric characters, underscores (_), or dots (.), and avoid spaces, hyphens (-), or other special characters.
# ACCESSION_NAME="Abd_0" 

# ---------------------------------------------------------------------------------------------

###############################################################################################
# THIRD ACCESSION Ishikawa - Uncomment the following block if you want to process the third accession. 
###############################################################################################
# Be sure to comment out the previous accession blocks.
# Set working directory and file paths for the third accession. 
ANNO_FILE="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/other_accessions/outputs/14_ishikawa_final_GENE/filtered.genes.renamed.final.gff3"
FASTA_FAI="/data/users/mjopiti/assembly-course/assemblies/flye-assembly/Flye.fai"
LONGEST_PROTEINS="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/other_accessions/outputs/15_ishikawa_longest_isoforms/assembly_longest_protein_isoforms.fasta"

# Replace this with the desired accession name. 
# Use only alphanumeric characters, underscores (_), or dots (.), and avoid spaces, hyphens (-), or other special characters.
ACCESSION_NAME="Ishikawa" 

# ---------------------------------------------------------------------------------------------

###############################################################################################
# TRY altai-5 - Uncomment the following block if you want to process the second accession. 
###############################################################################################
# # Be sure to comment out the previous accession blocks.
# # Set working directory and file paths for the second accession. 
# ANNO_FILE="/data/users/harribas/assembly_course/annotation/output/final/filtered.genes.renamed.final.gff3"
# FASTA_FAI="/data/users/harribas/assembly_course/assembly/results_fly/assembly.fasta.fai"
# LONGEST_PROTEINS="/data/users/harribas/assembly_course/annotation/output/final/assembly.all.maker.proteins.fasta.renamed.longest.fasta"

# # Replace this with the desired accession name. 
# # Use only alphanumeric characters, underscores (_), or dots (.), and avoid spaces, hyphens (-), or other special characters.
# ACCESSION_NAME="altai5" 

# ---------------------------------------------------------------------------------------------

# Prepare directories
mkdir -p "$OUTDIR"
mkdir -p "$OUTDIR/bed"
mkdir -p "$OUTDIR/peptide"
cd $OUTDIR

# Export variables to be used in R script
export WORKDIR="$WORKDIR"
export OUTDIR="$OUTDIR"
export ANNO_FILE="$ANNO_FILE"
export FASTA_FAI="$FASTA_FAI"
export LONGEST_PROTEINS="$LONGEST_PROTEINS"
export ACCESSION_NAME="$ACCESSION_NAME"

# Run the R script
Rscript $R_SCRIPT

# Confirmation
echo "GeneSpace preparation completed successfully. Outputs are saved in $OUTDIR."
