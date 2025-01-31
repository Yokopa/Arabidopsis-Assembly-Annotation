#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   18_run_busco_GENE.sh
#
# DESCRIPTION: 
#   This script performs quality assessment of gene annotations using 
#   BUSCO (Benchmarking Universal Single-Copy Orthologs). It evaluates 
#   the completeness of MAKER annotations by identifying conserved 
#   single-copy orthologs within a specified taxonomic lineage.
#
#   The script supports both protein and transcript annotations produced 
#   by MAKER, allowing the user to run BUSCO in either `proteins` or 
#   `transcriptome` mode.
#
# USAGE:
#   sbatch 18_run_busco_GENE.sh
#
#   Modify the input file paths (`PROTEIN_FILE` and `TRANSCRIPT_FILE`) and 
#   lineage dataset (`LINEAGE`) variables as needed. Submit the script via 
#   SLURM to run BUSCO and generate the output results.
#
# BUSCO OUTPUT METRICS:
#   - Complete: Fully present orthologs in the annotation.
#   - Duplicated: Duplicated orthologs (could indicate assembly issues 
#     or polyploidy).
#   - Fragmented: Partial orthologs in the annotation.
#   - Missing: Orthologs not detected in the annotation.
#
# REQUIREMENTS:
#   - BUSCO version 5.4.2 or compatible.
#   - Appropriate lineage dataset for your organism (e.g., `brassicales_odb10`).
#
#================================================================

#SBATCH --cpus-per-task=50
#SBATCH --mem=20G
#SBATCH --time=4:00:00
#SBATCH --job-name=busco_annotation
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=END
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/18_busco_annotation_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/18_busco_annotation_error_%j.e
#SBATCH --partition=pibu_el8

module load BUSCO/5.4.2-foss-2021a

# User-defined variables
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
OUTDIR="$WORKDIR/18_busco_GENE"
PROTEIN_FILE="$WORKDIR/17_longest_isoforms/assembly_longest_protein_isoforms.fasta"
TRANSCRIPT_FILE="$WORKDIR/17_longest_isoforms/assembly_longest_transcript_isoforms.fasta"
LINEAGE="brassicales_odb10"  # Specify lineage dataset (e.g., embryophyta_odb10)

mkdir -p $OUTDIR
cd $OUTDIR

# Remember to get the longest isoform from the maker annotation

busco \
    -i $PROTEIN_FILE \
    -l $LINEAGE \
    -o maker_proteins \
    -m proteins \
    --cpu 50 \
    --download_path $OUTDIR \
    --force

busco \
    -i $TRANSCRIPT_FILE \
    -l $LINEAGE \
    -o maker_transcripts \
    -m transcriptome \
    --cpu 50 \
    --download_path $OUTDIR \
    --force

# ------------------------
# Interpretation Notes
# ------------------------
# The BUSCO results are located in the output directories:
#   - `maker_proteins/short_summary.txt` and `maker_transcripts/short_summary.txt`.
#
# Key Files:
#   - `short_summary.txt`: High-level summary of BUSCO metrics.
#   - `full_table.tsv`: Detailed list of each BUSCO ortholog and its status.
#
# Common Issues:
#   - High Duplicated BUSCOs: Could indicate assembly redundancy, polyploidy,
#     or incorrect input sequences (e.g., non-longest transcripts or proteins).
#   - High Fragmented or Missing BUSCOs: Could suggest incomplete annotations
#     or gaps in the assembly.
#
# A high percentage of Complete BUSCOs indicates a high-quality annotation.



