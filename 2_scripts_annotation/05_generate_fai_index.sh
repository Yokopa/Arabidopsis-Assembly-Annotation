#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   05_generate_fai_index.sh
#
# DESCRIPTION: 
#   This script generates a FASTA index (FAI) file for a genome assembly using 
#   SAMtools. The FAI file is required for downstream analyses, such as creating 
#   ideograms or visualizing transposable element (TE) annotations using tools 
#   like Circos or the R package `circlize`. The FAI file contains scaffold names, 
#   their lengths, and positional metadataThe output index file will be moved to 
#   the specified output directory.
#
# USAGE:
#   sbatch 05_generate_fai_index.sh
#
#   Modify the `ASSEMBLY` variable in the script to specify the input genome 
#   assembly file. No additional command-line arguments are required. Ensure 
#   the SAMtools module is loaded and available.
#
# OUTPUTS:
#   - The FAI index file (e.g., `assembly.fasta.fai`) will be generated in the 
#     same directory as the input FASTA file and then moved to:
#       /data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/05_assembly.fasta.fai
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --job-name=fai_index
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/05_fai_index_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/05_fai_index_error_%j.e
#SBATCH --partition=pibu_el8

# Set working directory and input file
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"
ASSEMBLY="/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/outputs/05_flye/assembly.fasta"
OUTDIR="$WORKDIR/outputs"

# Load the SAMtools module
module load SAMtools/1.13-GCC-10.3.0

# Generate the FAI index file
samtools faidx $ASSEMBLY

# Move the output FAI file to the specified output directory
FAI_FILE="${ASSEMBLY}.fai"
OUTFILE="$OUTDIR/05_$(basename $FAI_FILE)"
mkdir -p $OUTDIR
mv $FAI_FILE $OUTFILE

# Print confirmation message
echo "FAI index file has been moved to: $OUTFILE"