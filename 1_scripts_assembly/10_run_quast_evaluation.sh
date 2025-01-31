#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   10_run_quast_evaluation.sh
#
# DESCRIPTION: 
#   This script runs QUAST on multiple genome assemblies both 
#   with a reference genome and without a reference. It supports 
#   processing all assemblies in one go, creating separate output 
#   directories for each run.
#
# USAGE:
#   sbatch 10_run_quast_evaluation.sh [REFERENCE]
#
# PARAMETERS:
#   REFERENCE (optional): The reference genome to use (e.g., 
#                         /path/to/reference.fasta). If not provided, 
#                         QUAST will be run with the default reference genome: 
#                         /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.
#
# EXAMPLES:
#   - To run QUAST with the default reference and without a reference on all assemblies:
#     sbatch 10_run_quast_evaluation.sh
#
#   - To run QUAST with a specific reference and without a reference on all assemblies:
#     sbatch 10_run_quast_evaluation.sh /path/to/specific/reference.fasta
#
# NOTES:
#   - Ensure that the input assembly files and reference genome exist before running this script.
#   - Two output directories will be created: one for the run with the reference genome 
#     and one for the run without it.
#================================================================

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=quast_analysis
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/10_quast_output_%A.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/10_quast_error_%A.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
CONTAINER=/containers/apptainer/quast_5.2.0.sif # Container path

REFERENCE_DIR=/data/courses/assembly-annotation-course/references
REFERENCE_GENOME=$REFERENCE_DIR/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
REFERENCE_FEATURES=$REFERENCE_DIR/TAIR10_GFF3_genes.gff

# Define output directory
OUTPUT_DIR=$WORKDIR/outputs/10_quast
mkdir -p $OUTPUT_DIR

# Define assembly paths
ASSEMBLIES=(
    "$WORKDIR/outputs/05_flye/assembly.fasta"
    "$WORKDIR/outputs/06_hifiasm/hifiasm.bp.p_ctg.fa"
    "$WORKDIR/outputs/07_lja/assembly.fasta"
)

# Check for optional reference genome
REFERENCE=${1:-$REFERENCE_GENOME} 

# Create output directories if they don't exist
mkdir -p $OUTPUT_DIR/quast_with_ref
mkdir -p $OUTPUT_DIR/quast_no_ref

# Run QUAST with reference genome
echo "Running QUAST with reference genome..."
apptainer exec --bind $WORKDIR,$REFERENCE_DIR,$ORIGINAL_DATA_DIR $CONTAINER quast.py \
    "${ASSEMBLIES[@]}" \
    -o "$OUTPUT_DIR/quast_with_ref" \
    -r "$REFERENCE_GENOME" \
    --features $REFERENCE_FEATURES \
    --eukaryote \
    --large \
    --threads $SLURM_CPUS_PER_TASK \
    --labels flye,hifiasm,lja

# Check if the QUAST run with reference was successful
if [ $? -eq 0 ]; then
    echo "QUAST with reference genome completed successfully!"
else
    echo "QUAST with reference genome encountered an error."
    exit 1
fi

# Run QUAST without reference genome
echo "Running QUAST without reference genome..."
apptainer exec --bind $WORKDIR,$REFERENCE_DIR $CONTAINER quast.py \
    "${ASSEMBLIES[@]}" \
    -o "$OUTPUT_DIR/quast_no_ref" \
    --eukaryote \
    --large \
    --threads $SLURM_CPUS_PER_TASK \
    --labels flye,hifiasm,lja

# Check if the QUAST run without reference was successful
if [ $? -eq 0 ]; then
    echo "QUAST without reference genome completed successfully!"
else
    echo "QUAST without reference genome encountered an error."
    exit 1
fi

echo "All QUAST evaluations are complete!"