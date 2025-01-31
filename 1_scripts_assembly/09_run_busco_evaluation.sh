#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   09_run_busco_evaluation.sh
#
# DESCRIPTION: 
#   This script runs BUSCO on multiple genome and transcriptome 
#   assemblies (Flye, Hifiasm, LJA, and Trinity) to assess assembly 
#   completeness using the appropriate lineage database for the Arabidopsis 
#   thaliana dataset (brassicales_odb10).
#   Assembly files are located in specific subdirectories under:
#     /data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/outputs
#
# USAGE:
#   sbatch 09_run_busco_evaluation.sh
#
# NOTES:
#   - Modify the `ASSEMBLIES` array to add or remove specific assemblies. 
#     Each path in the list should point to an assembly file for BUSCO to analyze. 
#   - Modify the `get_tool_name` function if you want to add or remove specific 
#     tools (e.g., Flye, Hifiasm, LJA, or Trinity).
#   - To run BUSCO with a different lineage, edit the LINEAGE variable in the script.
#================================================================

#SBATCH --time=05:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=busco_analysis_module
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/09_busco_output_%A_%a.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/09_busco_error_%A_%a.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory

# Define assembly paths
ASSEMBLIES=(
    "$WORKDIR/outputs/05_flye/assembly.fasta"
    "$WORKDIR/outputs/06_hifiasm/"*.bp.p_ctg.fa
    "$WORKDIR/outputs/07_lja/assembly.fasta"
    "$WORKDIR/outputs/08_trinity/"*.Trinity.fasta
)

module load BUSCO/5.4.2-foss-2021a
LINEAGE="brassicales_odb10"

# Function to determine tool name from assembly path
get_tool_name() {
    case "$1" in
        *"flye"*)
            echo "flye"
            ;;
        *"hifiasm"*)
            echo "hifiasm"
            ;;
        *"lja"*)
            echo "lja"
            ;;
        *"transcriptome"*)
            echo "trinity"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Define output directory
OUTPUT_DIR=$WORKDIR/outputs/09_busco
# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR
# Create directory for BUSCO databases
mkdir -p $OUTPUT_DIR/busco_downloads

for assembly in "${ASSEMBLIES[@]}"; do
    # Get tool name
    TOOL_NAME=$(get_tool_name "$assembly")

    # Set MODE based on the assembly being used (genome for genome assemblies, transcriptome for Trinity)
    if [[ $assembly == *"Trinity.fasta"* ]]; then
        MODE="transcriptome"
    else
        MODE="genome"
    fi

    # Define output directory
    OUTPUT_FOLDER=$OUTPUT_DIR/${MODE}_busco/${TOOL_NAME}_busco
    # Create output directory if it doesn't exist
    mkdir -p $OUTPUT_FOLDER
    pushd $OUTPUT_FOLDER || exit 1  # Change directory, and exit if changing directory fails

    # Run busco
    busco \
    -i $assembly  \
    --mode $MODE \
    --lineage $LINEAGE \
    --cpu 16 \
    -o $OUTPUT_DIR/$TOOL_NAME \
    --download_path $OUTPUT_DIR/busco_downloads \
    --force

    popd
done
