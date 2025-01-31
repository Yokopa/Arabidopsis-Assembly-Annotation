#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   05_run_flye_genome_assembly.sh
#
# DESCRIPTION: 
#   This script performs whole genome assembly using Flye 
#   from PacBio HiFi reads. 
#
# USAGE:
#   sbatch 05_run_flye_genome_assembly.sh [PACBIO_READS]
#
# PARAMETERS:
#   PACBIO_READS (optional): Path to the PacBio HiFi reads file. If not provided,
#                            the script defaults to using "ERR11437336.fastq.gz"
#                            located in the "raw_data/Qar-8a/" directory 
#                            within the working directory.
#
# EXAMPLES:
#   - To run with the default reads file:
#     sbatch 05_run_flye_genome_assembly.sh
#
#   - To run with a custom reads file:
#     sbatch 05_run_flye_genome_assembly.sh /path/to/your/reads.fastq.gz
#
# NOTES:
#   - Ensure that the input directory contains the necessary HiFi 
#     reads before running this script.
#   - Assemblies can take several hours and require sufficient memory.
#================================================================

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=flye_assembly
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/05_flye_assembly_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/05_flye_assembly_error_%j.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
OUTPUT_DIR=$WORKDIR/outputs/05_flye # Output directory
CONTAINER=/containers/apptainer/flye_2.9.5.sif # Container path
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

# Run Flye within container
apptainer exec --bind $WORKDIR,$ORIGINAL_DATA_DIR $CONTAINER flye \
    --pacbio-hifi $PACBIO_READS \
    --out-dir $OUTPUT_DIR \
    --threads 16

# Notify when assembly is complete and check if Flye ran successfully
if [ $? -eq 0 ]; then
    echo "Flye assembly completed successfully. Output is located in $OUTPUT_DIR."
else
    echo "Flye assembly failed. Check the error log for more details."
fi
