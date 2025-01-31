#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   08_run_trinity_transcriptome_assembly.sh
#
# DESCRIPTION: 
#   This script performs whole transcriptome assembly using Trinity
#   from paired-end RNA-seq reads.
#
# USAGE:
#   sbatch 08_run_trinity_transcriptome_assembly.sh [RNA_READ1] [RNA_READ2]
#
# PARAMETERS:
#   RNA_READ1 (optional): Path to the first paired-end RNA read file (R1).
#   RNA_READ2 (optional): Path to the second paired-end RNA read file (R2).
#                         If not provided, the script defaults to using
#                         "rna1_cleaned.fastq.gz" and "rna2_cleaned.fastq.gz"
#                         from the fastp output located in the 
#                         "outputs/02_fastp/" directory within the working directory.
#
# EXAMPLES:
#   - To run with the default RNA-seq reads:
#     sbatch 08_run_trinity_transcriptome_assembly.sh
#
#   - To run with custom RNA-seq reads:
#     sbatch 08_run_trinity_transcriptome_assembly.sh /path/to/your/rna1.fastq.gz /path/to/your/rna2.fastq.gz
#
# NOTES:
#   - Ensure that the input directory contains the necessary RNA-seq 
#     reads before running this script.
#   - Transcriptome assemblies can take several hours and require sufficient memory.
#================================================================

#SBATCH --time=1-00:00:00
#SBATCH --mem=128G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=trinity_assembly
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/08_trinity_assembly_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/08_trinity_assembly_error_%j.e
#SBATCH --partition=pibu_el8

# Load Trinity module
module load Trinity/2.15.1-foss-2021a

# Set paths

WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
RNA_READ1=${1:-$WORKDIR/outputs/02_fastp/rna1_cleaned.fastq.gz}
RNA_READ2=${2:-$WORKDIR/outputs/02_fastp/rna2_cleaned.fastq.gz}
OUTDIR=$WORKDIR/outputs/08_trinity # Output directory

# Check if input files exist
if [ ! -f "$RNA_READ1" ] || [ ! -f "$RNA_READ2" ]; then
    echo "Error: RNA read files do not exist: $RNA_READ1 or $RNA_READ2"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p $OUTDIR

# Run Trinity
Trinity \
    --seqType fq \
    --left $RNA_READ1 \
    --right $RNA_READ2 \
    --CPU 16 \
    --max_memory 128G \
    --output $OUTDIR

# Notify when assembly is complete and check if Trinity ran successfully
if [ $? -eq 0 ]; then
    echo "Trinity assembly completed successfully. Output is located in $OUTDIR."
else
    echo "Trinity assembly failed. Check the error log for more details."
fi

# Move assembly fasta file and .gene_trans_map into 08_trinity folder
mv $WORKDIR/outputs/08_trinity.Trinity.* $OUTDIR