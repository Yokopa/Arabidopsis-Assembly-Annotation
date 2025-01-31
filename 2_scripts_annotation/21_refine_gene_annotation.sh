#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   21_refine_gene_annotation.sh
#
# DESCRIPTION:
#   This script refines gene annotations by leveraging Hierarchical Orthologous 
#   Groups (HOGs) to identify and correct fragmented or missing gene models. 
#   It performs the following tasks:
#   1. Extracts sequences of conserved HOGs for fragmented gene models.
#   2. Extracts sequences of conserved HOGs for missing gene models.
#   3. Maps the HOG sequences to the genome using MiniProt for annotation refinement.
#   4. Outputs two separate GFF files for visualization and comparison of gene models.
#
# USAGE:
#   sbatch 21_refine_gene_annotation.sh
#
#   IMPORTANT!
#   Ensure you submit this script while in the OMArk conda environment that you created to run OMArk.
#   If you haven't set up the environment yet, refer to the previous script (20_omark.sh) for guidance.
#   If you have already created it, make sure it is activated before running the script.
#   To activate the environment, run the following commands in the terminal:
#
#       module load Anaconda3/2022.05  # Load Anaconda module
#       eval "$(conda shell.bash hook)"  # Initialize conda
#       conda activate OMArk  # Activate OMArk conda environment
#
#   Ensure the script omark_contextualize.py is located in your "scripts" directory. 
#   If it isn't, you can find it at: 
#   /data/courses/assembly-annotation-course/CDS_annotation/softwares/OMArk-0.3.0/utils
#
# INPUT:
#   - Genome FASTA file
#   - Conserved HOG sequences files for fragmented and missing models (produced by omark_contextualize.py)
#
# OUTPUT:
#   - GFF files containing MiniProt mappings for fragmented and missing gene models
#   - Log file for MiniProt output
#
# NOTES:
#   - Update all file paths (e.g., OMAMER_FILE, GENOMIC_FASTA, MINIPROT_OUTPUT...) 
#     to match your specific file system and input data locations.
#================================================================

#SBATCH --time=04:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=refine_annotation
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/21_refine_annotation_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/21_refine_annotation_error_%j.e
#SBATCH --partition=pibu_el8

# Set paths and directories
WORKDIR="/data/users/ascarpellini/assembly_annotation_course"
GENOMIC_FASTA="$WORKDIR/genome_transcriptome_assembly/outputs/05_flye/assembly.fasta" 
OMAMER_FILE="$WORKDIR/genome_annotation/outputs/20_omark/assembly.all.maker.proteins.fasta.renamed.filtered.fasta.omamer"
OUTPUT_DIR="$WORKDIR/genome_annotation/outputs/21_miniprot"
FRAGMENTED_HOGS="$OUTPUT_DIR/fragment_HOGs"
MISSING_HOGS="$OUTPUT_DIR/missing_HOGs"

MINIPROT_PATH="/data/courses/assembly-annotation-course/CDS_annotation/containers/miniprot_conda/bin"
MINIPROT_OUTPUT="$OUTPUT_DIR/miniprot_output.gff"


# Create output directory
mkdir -p $OUTPUT_DIR


# Extract HOGs for fragmented gene models
echo "Extracting fragmented HOG sequences..."
python omark_contextualize.py fragment -m $OMAMER_FILE -o $WORKDIR/genome_annotation/outputs/20_omark -f $FRAGMENTED_HOGS
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract fragmented HOG sequences."
    exit 1
fi

# Extract HOGs for missing gene models
echo "Extracting missing HOG sequences..."
python omark_contextualize.py missing -m $OMAMER_FILE -o $WORKDIR/genome_annotation/outputs/20_omark -f $MISSING_HOGS
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract missing HOG sequences."
    exit 1
fi

# Run MiniProt for fragmented HOGs
echo "Running MiniProt for fragmented HOGs..."
MINIPROT_OUTPUT_FRAG="$OUTPUT_DIR/miniprot_fragmented.gff"
$MINIPROT_PATH/miniprot -I --gff --outs=0.95 "${GENOMIC_FASTA}" "${FRAGMENTED_HOGS}" > "${MINIPROT_OUTPUT_FRAG}"
if [ $? -ne 0 ]; then
    echo "Error: MiniProt mapping for fragmented HOGs failed."
    exit 1
fi
echo "MiniProt mapping for fragmented HOGs completed. Output saved to ${MINIPROT_OUTPUT_FRAG}"

# Run MiniProt for missing HOGs
echo "Running MiniProt for missing HOGs..."
MINIPROT_OUTPUT_MISS="$OUTPUT_DIR/miniprot_missing.gff"
$MINIPROT_PATH/miniprot -I --gff --outs=0.95 "${GENOMIC_FASTA}" $OUTPUT_DIR/missing_HOGs.fa > "${MINIPROT_OUTPUT_MISS}"
if [ $? -ne 0 ]; then
    echo "Error: MiniProt mapping for missing HOGs failed."
    exit 1
fi
echo "MiniProt mapping for missing HOGs completed. Output saved to ${MINIPROT_OUTPUT_MISS}"


echo "Gene annotation refinement completed. Use genome visualization tools like JBrowse 2 or Geneious to view the GFF file and compare the mappings."
exit 0
