#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   02_run_fastp_preprocessing.sh
#
# DESCRIPTION: 
#   This script runs FastP on RNA and DNA reads for a specified accession.
#   The RNA reads are processed with quality and length filter,
#   while DNA reads are processed with filtering options disabled (-Q and -L).
#   It utilizes SLURM array jobs to handle multiple files in parallel.
#
# PARAMETERS:
#   ACCESSION: The unique identifier for the dataset to be processed. 
#              This corresponds to a folder in the raw_data directory that contains the 
#              symbolic link to the DNA reads for that specific accession. The RNA reads 
#              are shared across accessions and are located in the RNAseq_Sha folder.
#
# USAGE:
#   sbatch 02_run_fastp_preprocessing.sh <accession>
#
# EXAMPLE:
#   sbatch 02_run_fastp_preprocessing.sh Qar-8a
#
# NOTES:
#   - Ensure that the appropriate directories and files are set up in advance.
#   - The script expects the following directory structure:
#       - raw_data/
#           - <accession>/ (symbolic link to the DNA reads for the specified accession)
#           - RNAseq_Sha/  (symbolic link to shared RNA reads) 
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=04:00:00
#SBATCH --job-name=fastp_array
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/02_fastp_output_%A_%a.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/02_fastp_error_%A_%a.e
#SBATCH --partition=pibu_el8
#SBATCH --array=0-1  # Two array jobs: 0 for RNA, 1 for DNA

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
RAW_DATA_DIR=$WORKDIR/raw_data # Directory where raw data soft links are stored
ORIGINAL_DATA_DIR=/data/courses/assembly-annotation-course/raw_data  # Original data location
OUTPUT_DIR=$WORKDIR/outputs/02_fastp # Output directory
CONTAINER=/containers/apptainer/fastp_0.23.2--h5f740d0_3.sif # Container path

# Get the accession from the command line argument
ACCESSION=${1}

# Check if an accession was provided
if [ -z "$ACCESSION" ]; then
    echo "Error: No accession specified. Usage: sbatch 02_run_fastp_preprocessing.sh <accession>"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Get a list of RNA and DNA files
RNA_FILES=($RAW_DATA_DIR/RNAseq_Sha/*.fastq.gz)
ACCESSION_FILES=($RAW_DATA_DIR/$1/*.fastq.gz)  # Use the passed accession as an argument

# Check if there are RNA files and ensure there are three files total (two RNA and one DNA)
if [ ${#RNA_FILES[@]} -eq 2 ] && [ ${#ACCESSION_FILES[@]} -eq 1 ]; then
    # Run FastP for RNA reads (two files together) only on array job 0
    if [ $SLURM_ARRAY_TASK_ID -eq 0 ]; then
        echo "Running FastP on RNA files: ${RNA_FILES[0]} and ${RNA_FILES[1]}"
        apptainer exec --bind $WORKDIR,$ORIGINAL_DATA_DIR $CONTAINER fastp \
        -i ${RNA_FILES[0]} -I ${RNA_FILES[1]} \
        -o $OUTPUT_DIR/rna1_cleaned.fastq.gz -O $OUTPUT_DIR/rna2_cleaned.fastq.gz \
        -h $OUTPUT_DIR/fastp_report_rna.html \
        -j $OUTPUT_DIR/fastp_report_rna.json
        echo "FastP processing completed for RNA files."

    # Run FastP for DNA read (one file) only on array job 1
    elif [ $SLURM_ARRAY_TASK_ID -eq 1 ]; then
        FILE=${ACCESSION_FILES[0]}  # Get the DNA file
        echo "Running FastP on DNA file with filtering disabled: $FILE"
        apptainer exec --bind $WORKDIR,$ORIGINAL_DATA_DIR $CONTAINER fastp \
        -i $FILE \
        -o $OUTPUT_DIR/${ACCESSION}_dna_cleaned.fastq.gz \
        -h $OUTPUT_DIR/fastp_report_dna_${ACCESSION}.html \
        -j $OUTPUT_DIR/fastp_report_dna_${ACCESSION}.json -Q -L
        echo "FastP processing completed for DNA file."
    fi
else
    echo "Error: Expected 2 RNA files and 1 DNA file, but found ${#RNA_FILES[@]} RNA files and ${#ACCESSION_FILES[@]} DNA files."
    exit 1
fi
