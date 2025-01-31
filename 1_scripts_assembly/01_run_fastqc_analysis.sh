#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   01_run_fastqc_analysis.sh
#
# DESCRIPTION: 
#   This script runs FastQC on the RNA and DNA reads for a specified accession.
#   The RNA reads are the same for every accession and are located in the RNAseq_Sha directory, 
#   while DNA reads are located in their respective accession directories.
#   The script uses SLURM array jobs to process multiple files in parallel.
#
# PARAMETERS:
#   ACCESSION: The unique identifier for the dataset to be processed. 
#              This corresponds to a folder in the raw_data directory that contains the 
#              symbolic link to the DNA reads for that specific accession. The RNA reads 
#              are shared across accessions and are located in the RNAseq_Sha folder.
#
# USAGE:
#   sbatch 01_run_fastqc_analysis.sh <accession>
#
# EXAMPLE:
#   sbatch 01_run_fastqc_analysis.sh Qar-8a
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
#SBATCH --time=01:00:00
#SBATCH --job-name=fastqc_array
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/01_fastqc_output_%A_%a.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/01_fastqc_output_%A_%a.e
#SBATCH --partition=pibu_el8
#SBATCH --array=0-2

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
RAW_DATA_DIR=$WORKDIR/raw_data # Directory where raw data soft links are stored
ORIGINAL_DATA_DIR=/data/courses/assembly-annotation-course/raw_data  # Original data location
OUTPUT_DIR=$WORKDIR/outputs/01_fastqc # Output directory
CONTAINER=/containers/apptainer/fastqc-0.12.1.sif # Container path

# Get the accession from the command line argument
ACCESSION=${1}

# Check if an accession was provided
if [ -z "$ACCESSION" ]; then
    echo "Error: No accession specified. Usage: sbatch 01_run_fastqc_analysis.sh <accession>"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Define file paths
RNA_FILES=($RAW_DATA_DIR/RNAseq_Sha/*.fastq.gz)
DNA_FILES=($RAW_DATA_DIR/$ACCESSION/*.fastq.gz)  # DNA file for the specified accession

# Run FastQC for RNA files (common for all accessions)
if [ $SLURM_ARRAY_TASK_ID -eq 0 ] || [ $SLURM_ARRAY_TASK_ID -eq 1 ]; then
    RNA_FILE=${RNA_FILES[$SLURM_ARRAY_TASK_ID]}
    echo "Running FastQC on RNA file: $RNA_FILE"
    apptainer exec --bind $WORKDIR,$ORIGINAL_DATA_DIR $CONTAINER fastqc \
    $RNA_FILE \
    -o $OUTPUT_DIR
    echo "FastQC processing completed for RNA file: $RNA_FILE"

    # Rename FastQC output files for RNA to include task ID
    BASE_NAME=$(basename "$RNA_FILE" .fastq.gz)
    mv $OUTPUT_DIR/${BASE_NAME}_fastqc.zip $OUTPUT_DIR/rna_${SLURM_ARRAY_TASK_ID}_fastqc.zip
    mv $OUTPUT_DIR/${BASE_NAME}_fastqc.html $OUTPUT_DIR/rna_${SLURM_ARRAY_TASK_ID}_fastqc.html

# Run FastQC for the DNA file (with accession name and "dna" suffix)
elif [ $SLURM_ARRAY_TASK_ID -eq 2 ]; then
    # Use the first DNA file to avoid issues with wildcard expansion in the filename,
    # which would otherwise result in a base name containing the '*' character.
    DNA_FILE=${DNA_FILES[0]} 
    echo "Running FastQC on DNA file: $DNA_FILE for accession $ACCESSION"
    apptainer exec --bind $WORKDIR,$ORIGINAL_DATA_DIR $CONTAINER fastqc \
    $DNA_FILE \
    -o $OUTPUT_DIR
    echo "FastQC processing completed for DNA file: $DNA_FILE"

    # Rename FastQC output files for DNA
    DNA_BASE_NAME=$(basename "$DNA_FILE" .fastq.gz)
    mv "$OUTPUT_DIR/${DNA_BASE_NAME}_fastqc.zip" "$OUTPUT_DIR/${ACCESSION}_dna_fastqc.zip"
    mv "$OUTPUT_DIR/${DNA_BASE_NAME}_fastqc.html" "$OUTPUT_DIR/${ACCESSION}_dna_fastqc.html"
fi
