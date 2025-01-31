#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   04_count_kmer_dna.sh
#
# DESCRIPTION: 
#   This script runs Jellyfish to count kmers in a specified 
#   DNA FASTQ file or the files in the directory Qar-8a if no 
#   specific accession is provided. It generates a histogram
#   from the k-mer counts.
#
# USAGE:
#   sbatch 04_count_kmer_dna.sh [ACCESSION]
#
# PARAMETERS:
#   ACCESSION (optional): Specific accession to process. If not provided,
#                         the script defaults to using the FASTQ file 
#                         in the directory "/raw_data/Qar-8a".
#
# EXAMPLES:
#   - To run with the default DNA reads:
#     sbatch 04_count_kmer_dna.sh
#
#   - To run with a specific accession:
#     sbatch 04_count_kmer_dna.sh Qar-8a
#
# NOTES:
#   - Ensure that the input directory contains the necessary DNA 
#     reads before running this script.
#================================================================

#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=01:00:00
#SBATCH --job-name=count_kmer_dna
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/04_kmer_counts_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/04_kmer_counts_error_%j.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
RAW_DATA_DIR=$WORKDIR/raw_data # Input directory
OUTPUT_DIR=$WORKDIR/outputs/04_jellyfish  # Output directory
CONTAINER=/containers/apptainer/jellyfish:2.2.6--0  # Container path

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Check if an accession argument is provided
if [ "$#" -eq 1 ]; then
    ACCESSION=$1
    INPUT_FILE="$RAW_DATA_DIR/${ACCESSION}/*.fastq.gz"
else
    INPUT_FILE="$RAW_DATA_DIR/Qar-8a/*.fastq.gz"
fi

# Check if the input file exists for the specified accession
if [ ! -e $INPUT_FILE ]; then
    echo "Error: Input file(s) $INPUT_FILE does not exist."
    exit 1
fi

# Loop through input files to count k-mers
for file in $INPUT_FILE; do
    # Count k-mers using Jellyfish within Apptainer
    apptainer exec --bind $WORKDIR $CONTAINER jellyfish count -C -m 25 -s 5G -t 4 -o $OUTPUT_DIR/$(basename "$file" .fastq.gz).jf <(zcat "$file")

    echo "K-mer counting completed for $file."

    # Generate histogram from the k-mer counts
    HISTO_OUTPUT=$OUTPUT_DIR/$(basename "$file" .fastq.gz).histo
    apptainer exec --bind $WORKDIR $CONTAINER jellyfish histo $OUTPUT_DIR/$(basename "$file" .fastq.gz).jf -o $HISTO_OUTPUT

    echo "Histogram generation completed for $file."
done