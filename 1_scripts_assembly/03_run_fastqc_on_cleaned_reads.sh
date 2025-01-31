#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   03_run_fastqc_on_cleaned_reads.sh
#
# DESCRIPTION: 
#   This script runs FastQC on the cleaned RNA reads processed with fastp.
#
# USAGE:
#   sbatch 03_run_fastqc_on_cleaned_reads.sh
#
# NOTES:
#   - Ensure that the appropriate directories and files are set up in advance.
#   - The script expects the following directory structure:
#       - outputs/
#           - 02_fastp/ (contains cleaned RNA reads)
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=fastqc_cleaned_array
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/03_fastqc_cleaned_output_%A_%a.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/03_fastqc_cleaned_error_%A_%a.e
#SBATCH --partition=pibu_el8
#SBATCH --array=0-1

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
CLEANED_DATA=$WORKDIR/outputs/02_fastp # Input directory
OUTPUT_DIR=$WORKDIR/outputs/03_fastqc_cleaned # Output directory
CONTAINER=/containers/apptainer/fastqc-0.12.1.sif  # Container path

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Define file paths
RNA_FILES=($CLEANED_DATA/rna*_cleaned.fastq.gz)

# Check if there are any RNA files available
if [ ${#RNA_FILES[@]} -eq 0 ]; then
    echo "No cleaned RNA files found in $CLEANED_DATA."
    exit 1  # Exit if no files found
fi

# Run FastQC for RNA files (common for all accessions)
RNA_FILE=${RNA_FILES[$SLURM_ARRAY_TASK_ID]}
echo "Running FastQC on RNA file: $RNA_FILE"
apptainer exec --bind $WORKDIR $CONTAINER fastqc \
    $RNA_FILE \
    -o $OUTPUT_DIR
echo "FastQC processing completed for RNA file: $RNA_FILE"