#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   11-2_create_raw_reads_meryl.sh
#
# DESCRIPTION: 
#   This script creates a Meryl database for the raw reads.
#
# USAGE:
#   sbatch 11-2_create_raw_reads_meryl.sh
#
# NOTES:
#   - Ensure that the raw read data file is available.
#   - The script processes raw reads generated from PacBio HiFi reads.
#================================================================

#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=raw_reads_meryl
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/11-2_raw_reads_meryl_output_%A.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/11-2_raw_reads_meryl_error_%A.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
RAW_READS=$WORKDIR/raw_data/Qar-8a/*.fastq.gz
ORIGINAL_DATA_DIR=/data/courses/assembly-annotation-course/raw_data  # Original data location

CONTAINER=/containers/apptainer/merqury_1.3.sif # Container path

# Define output directory
OUTPUT_DIR=$WORKDIR/outputs/11_merqury
mkdir -p $OUTPUT_DIR

# Create Meryl database for raw reads
echo "Creating Meryl database for raw reads..."
apptainer exec --bind $WORKDIR,$ORIGINAL_DATA_DIR $CONTAINER meryl count k=18 output "$OUTPUT_DIR/raw_reads.meryl" $RAW_READS

# Check if Meryl succeeded
if [ $? -ne 0 ]; then
    echo "Meryl failed for raw reads. Check logs for details."
    exit 1
fi
echo "Meryl database for raw reads completed successfully."
