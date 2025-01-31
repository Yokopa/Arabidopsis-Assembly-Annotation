#!/usr/bin/env bash

#================================================================
# SCRIPT NAME:
#   11_run_phylogenetic_analysis.sh
#
# DESCRIPTION:
#   This script performs a phylogenetic analysis for Copia and Gypsy 
#   reverse transcriptase (RT) sequences from Arabidopsis and Brassicaceae. 
#   The process involves:
#   1. Concatenating RT sequences from both Brassicaceae and Arabidopsis.
#   2. Aligning sequences using Clustal Omega.
#   3. Constructing a phylogenetic tree using FastTree.
#
# USAGE:
#   sbatch 11_run_phylogenetic_analysis.sh
#
# DEPENDENCIES:
#   - Clustal Omega: For multiple sequence alignment.
#   - FastTree: For phylogenetic tree construction.
#
# INPUTS:
#   - RT sequences in FASTA format for Copia and Gypsy from Arabidopsis and Brassicaceae.
#     These files are located in:
#     `$WORKDIR/outputs/10_rt_sequences/<family>_RT.fasta`
#     `$WORKDIR/outputs/10_rt_sequences/<family>_RT_brassicaceae.fasta`
#
# OUTPUT:
#   - Aligned sequences in FASTA format.
#   - Phylogenetic tree files in Newick format.
#     These will be saved in:
#     `$WORKDIR/11_clustal_omega/<family>_aligned_RT.fasta`
#     `$WORKDIR/11_fast_tree/<family>_phylogenetic_tree.tree`
#
# NOTES:
#   - Ensure that Clustal Omega and FastTree modules are available.
#   - Modify `$WORKDIR` and paths to the input files if necessary.
#================================================================

#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=phylogenetic_analysis
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/11_phylogenetic_analysis_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/11_phylogenetic_analysis_error_%j.e
#SBATCH --partition=pibu_el8

module load Clustal-Omega/1.2.4-GCC-10.3.0
module load FastTree/2.1.11-GCCcore-10.3.0

# Set paths
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"
INPUT_DIR="$WORKDIR/outputs/10_rt_sequences"
OUTDIR="$WORKDIR/outputs/11_phylogenetic_analysis"
OUTDIR_CLUSTALO="$OUTDIR/clustal_omega"
OUTDIR_FAST_TREE="$OUTDIR/fast_tree"

mkdir -p $OUTDIR $OUTDIR_CLUSTALO $OUTDIR_FAST_TREE

# For Copia and Gypsy RT sequences
for FAMILY in "copia" "gypsy"; do
    # Concatenate RT sequences
    cat "$INPUT_DIR/${FAMILY}_RT_arabidopsis.fasta" "$INPUT_DIR/${FAMILY}_RT_brassicaceae.fasta" > "$OUTDIR/${FAMILY}_concatenated_RT.fasta"
    
    # Clean identifiers
    # This line is from the tutorial
    sed -i 's/#.\+//' "$OUTDIR/${FAMILY}_concatenated_RT.fasta"
    # Remove everything after the "|" character to shorten the header
    sed -i 's/|.\+//' "$OUTDIR/${FAMILY}_concatenated_RT.fasta"
    # This line is from the tutorial: replace ":" with "_" to avoid issues with special characters (like ":" or "|") in downstream tools
    sed -i 's/:/_/g' "$OUTDIR/${FAMILY}_concatenated_RT.fasta"
    
    # Extract headers from the FASTA file and check for duplicates
    DUPLICATES=$(grep "^>" "$OUTDIR/${FAMILY}_concatenated_RT.fasta" | sort | uniq -d)
    if [ -n "$DUPLICATES" ]; then
        echo "Duplicate headers found for $FAMILY:"
        echo "$DUPLICATES"
    else
        echo "No duplicate headers found for $FAMILY."
    fi

    # Align sequences
    clustalo -i "$OUTDIR/${FAMILY}_concatenated_RT.fasta" -o "$OUTDIR_CLUSTALO/${FAMILY}_aligned_RT.fasta" --outfmt fasta
    # Check if clustalo succeeded
    if [ $? -eq 0 ]; then
        echo "Clustal-Omega alignment successful for $FAMILY."
    else
        echo "Error: Clustal-Omega alignment failed for $FAMILY."
        break
    fi

    # Infer phylogenetic tree
    FastTree -out "$OUTDIR_FAST_TREE/${FAMILY}_phylogenetic_tree.tree" "$OUTDIR_CLUSTALO/${FAMILY}_aligned_RT.fasta"
    # Check if FastTree construction was successful
    if [ $? -eq 0 ]; then
        echo "FastTree phylogenetic tree construction successful for $FAMILY."
    else
        echo "Error: FastTree phylogenetic tree construction failed for $FAMILY."
        break
    fi
    
done

echo "Phylogenetic analysis completed."
