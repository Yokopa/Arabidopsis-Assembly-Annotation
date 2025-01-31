#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   07_run_lja_genome_assembly.sh
#
# DESCRIPTION: 
#   This script performs whole genome assembly using LJA 
#   from PacBio HiFi reads. 
#
# USAGE:
#   sbatch 07_run_lja_G_assembly.sh [PACBIO_READS]
#
# PARAMETERS:
#   PACBIO_READS (optional): Path to the PacBio HiFi reads file. If not provided,
#                            the script defaults to using "ERR11437336.fastq.gz"
#                            located in the "raw_data/Qar-8a/" directory 
#                            within the working directory.
#
# EXAMPLES:
#   - To run with the default reads file:
#     sbatch 07_run_lja_genome_assembly.sh
#
#   - To run with a custom reads file:
#     sbatch 07_run_lja_genome_assembly.sh /path/to/your/reads.fastq.gz
#
# NOTES:
#   - Ensure that the input directory contains the necessary HiFi 
#     reads ("dna_cleaned.fastq.gz" from fastp output) before running this script.
#   - Assemblies can take several hours and require sufficient memory.
#================================================================

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=lja_assembly
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/06_lja_assembly_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/06_lja_assembly_output_%j.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
OUTPUT_DIR=$WORKDIR/outputs/07_lja # Output directory
CONTAINER=/containers/apptainer/lja-0.2.sif  # Container path
DNA_READS=$WORKDIR/raw_data/Qar-8a/ERR11437336.fastq.gz
ORIGINAL_DATA_DIR=/data/courses/assembly-annotation-course/raw_data  # Original data location

# Get PacBio reads file or default to files matching the pattern
if [ -n "$1" ]; then
    PACBIO_READS="$1"
else
    PACBIO_READS=($DNA_READS)
fi

# Check if input file exists
if [ ! -f "$PACBIO_READS" ]; then
    echo "Error: Input PacBio reads file does not exist: $PACBIO_READS"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Run LJA within container
apptainer exec --bind $WORKDIR,$ORIGINAL_DATA_DIR $CONTAINER lja \
    -o $OUTPUT_DIR \
    -t 16 \
    --reads $PACBIO_READS

# Notify when assembly is complete and check if LJA ran successfully
if [ $? -eq 0 ]; then
    echo "LJA assembly completed successfully. Output is located in $OUTPUT_DIR."
else
    echo "LJA assembly failed. Check the error log for more details."
fi
