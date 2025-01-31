#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   00_link_reads.sh
#
# DESCRIPTION: 
#   This script creates symbolic links to the raw data files for a specified accession.
#   The RNA reads are the same for every accession and are located in the RNAseq_Sha directory.
#
# PARAMETERS:
#   ACCESSION: The unique identifier for the dataset you want to link. 
#              This corresponds to a folder in the raw data directory 
#              that contains the specific reads for that accession.
# 
# USAGE:
#   sbatch 00_link_reads.sh <accession>
#
# EXAMPLE:
#   sbatch 00_link_reads.sh Qar-8a
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:10:00
#SBATCH --job-name=link_reads
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/00_link_reads_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/00_link_reads_error_%j.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
GIVEN_READS_DIR=/data/courses/assembly-annotation-course/raw_data

# Get the accession from the command line argument
ACCESSION=${1}

# Check if an accession was provided
if [ -z "$ACCESSION" ]; then
    echo "Error: No accession specified. Usage: sbatch 00_download_reads.sh <accession>"
    exit 1
fi

# Create the raw_data and logs directories if they don't already exist
mkdir -p $WORKDIR/raw_data $WORKDIR/logs

# Change to the raw_data directory
cd $WORKDIR/raw_data

# Create symbolic links for the specified accession and the RNA reads
echo "Creating symbolic links for accession: $ACCESSION"
ln -s $GIVEN_READS_DIR/$ACCESSION ./
ln -s $GIVEN_READS_DIR/RNAseq_Sha ./
echo "Symbolic links created successfully."
