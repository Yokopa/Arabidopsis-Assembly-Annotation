#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   11-3_run_merqury_evaluation.sh
#
# DESCRIPTION: 
#   This script runs Merqury for multiple genome assemblies 
#   (Flye, Hifiasm, and LJA) in an array job.
#
# USAGE:
#   sbatch 11-3_run_merqury_evaluation.sh
#
# NOTES:
#   - Ensure that the pre-prepared Meryl database is available 
#     at the specified path.
#   - The script processes assemblies generated from different 
#     genome assemblers.
#================================================================

#SBATCH --time=05:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=merqury_array
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/11-3_merqury_output_%A_%a.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/11-3_merqury_error_%A_%a.e
#SBATCH --array=0-2  # Specify array job for 3 assemblies

# Directories for the input and output files
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly
OUTDIR=$WORKDIR/outputs/11_merqury
ORIGINAL_DATA_DIR=/data/courses/assembly-annotation-course/raw_data  # Original data location
MERYL_DB=$OUTDIR/raw_reads.meryl

# Define assembly paths
ASSEMBLIES=(
    "$WORKDIR/outputs/05_flye/assembly.fasta"
    "$WORKDIR/outputs/06_hifiasm/"*.bp.p_ctg.fa
    "$WORKDIR/outputs/07_lja/assembly.fasta"
)

# Function to determine tool name from input path
get_tool_name() {
    case "$1" in
        *"flye"*)
            echo "flye_assembly"
            ;;
        *"hifiasm"*)
            echo "hifiasm_assembly"
            ;;
        *"lja"*)
            echo "lja_assembly"
            ;;
    esac
}

# Create output directory for each assembly and temporarily switch to it
assembly=${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}  # Get the assembly for this task
TOOL_NAME=$(get_tool_name "$assembly")

OUTDIR_ASM=$OUTDIR/${TOOL_NAME}_${SLURM_ARRAY_TASK_ID}

# Create output directory and temporarily switch to it
mkdir -p $OUTDIR_ASM/logs
cd $OUTDIR_ASM

CONTAINER=/containers/apptainer/merqury_1.3.sif
# Set the Merqury path variable 
export MERQURY="/usr/local/share/merqury"

# Run Merqury with the pre-prepared meryl database and the assembly
apptainer exec --bind $WORKDIR,$ORIGINAL_DATA_DIR $CONTAINER \
merqury.sh $MERYL_DB $assembly merq
