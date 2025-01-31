#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   12_generate_color_strip_template.sh
#
# DESCRIPTION: 
#   This script generates a color strip dataset template for use in 
#   iTOL (Interactive Tree Of Life) visualization. The template 
#   contains color-coded strips representing transposable element (TE) 
#   families (COPIA and GYPSY) across different species (Arabidopsis 
#   and Brassicaceae). The color coding is based on the clade information 
#   provided in the input TSV files.
#
#   The script processes the following input '$.rexdb-plant.cls.tsv' files:
#   - COPIA (Arabidopsis): $COPIA_ARA
#   - COPIA (Brassicaceae): $COPIA_BRA
#   - GYPSY (Arabidopsis): $GYPSY_ARA
#   - GYPSY (Brassicaceae): $GYPSY_BRA
#
#   The output is a color strip template file that can be used for visual 
#   representation in phylogenetic trees. The dataset includes options for 
#   customizing the strip labels, legend, and visual style.
#
#   The script also generates a simple bar template, which includes counts of 
#   TEs for each family, useful for summarizing the abundance of each family 
#   across the species. The count data is extracted from the EDTA TE annotation 
#   summary file ($SUMMARY_DIR), and the counts are appended to the dataset.
#
#   The script works with the following steps:
#   1. Downloads default templates for color strips and simple bar representations.
#   2. Processes the COPIA and GYPSY families using their respective TSV files.
#   3. Appends custom color coding for each family based on their clades.
#   4. Extracts counts from the TE annotation summary and appends them to the simple bar template.
#
# USAGE:
#   12_generate_color_strip_template.sh
#
# NOTES:
#   - Modify the input file paths (e.g., `$COPIA_ARA`, `$COPIA_BRA`, etc.) 
#     in the script to point to the correct files on your system. Then, 
#     submit the script via SLURM to generate the color strip template.
#
#   - To check the unique clades in your input files, you can run the following 
#     `awk` commands interactively:
#
#     For COPIA (Arabidopsis):
#     awk -F'\t' '{print $4}' $COPIA_ARA | sort | uniq
#
#     For COPIA (Brassicaceae):
#     awk -F'\t' '{print $4}' $COPIA_BRA | sort | uniq
#
#     For GYPSY (Arabidopsis):
#     awk -F'\t' '{print $4}' $GYPSY_ARA | sort | uniq
#
#     For GYPSY (Brassicaceae):
#     awk -F'\t' '{print $4}' $GYPSY_BRA | sort | uniq
#================================================================

#SBATCH --job-name=color_strip_template
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/12_color_strip_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/12_color_strip_error_%j.e
#SBATCH --partition=pibu_el8

# Directories
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/"
COLOR_DIR="$WORKDIR/outputs/12_color_strip"
OUTPUT_FILE_COLOR="$COLOR_DIR/dataset_color_strip_template.txt"
OUTPUT_FILE_SIMPLEBAR="$COLOR_DIR/dataset_simplebar_template.txt"

GYPSY_ARA="$WORKDIR/outputs/07_tesorter_gypsy/gypsy_sequences.fa.rexdb-plant.cls.tsv"
COPIA_ARA="$WORKDIR/outputs/07_tesorter_copia/copia_sequences.fa.rexdb-plant.cls.tsv"

GYPSY_BRA="$WORKDIR/outputs/10_rt_sequences/tesorter_gypsy_brassicaceae/gypsy_sequences_brassicaceae.fa.rexdb-plant.cls.tsv"
COPIA_BRA="$WORKDIR/outputs/10_rt_sequences/tesorter_copia_brassicaceae/copia_sequences_brassicaceae.fa.rexdb-plant.cls.tsv"

SUMMARY_DIR="$WORKDIR/outputs/01_edta_TE/assembly.fasta.mod.EDTA.TEanno.sum"

# Create output directory if it doesn't exist
mkdir -p $COLOR_DIR
cd $COLOR_DIR

# Download the templates
curl -o "$OUTPUT_FILE_COLOR" https://itol.embl.de/help/dataset_color_strip_template.txt
curl -o "$OUTPUT_FILE_SIMPLEBAR" https://itol.embl.de/help/dataset_simplebar_template.txt

# Append custom content
cat <<EOF >> $OUTPUT_FILE_COLOR
DATA

# Process COPIA families
EOF

declare -A COPIA_CLASSES=(
    ["Ale"]="#1f77b4"       # Blue
    ["Alesia"]="#ff7f0e"    # Orange
    ["Angela"]="#2ca02c"    # Green
    ["Bianca"]="#d62728 "    # Red
    ["Clade"]="#9467bd"     # Purple
    ["Ikeros"]="#8c564b"    # Brown
    ["Ivana"]="#e377c2"     # Pink
    ["SIRE"]="#7f7f7f "      # Gray
    ["TAR"]="#bcbd22"       # Olive
    ["Tork"]="#17becf"      # Teal
)

for CLASS in "${!COPIA_CLASSES[@]}"; do
    grep -h -e "$CLASS" $COPIA_ARA $COPIA_BRA | \
        cut -f 1 | sed -e 's/:/_/' -e 's/#.*//' -e "s/$/ ${COPIA_CLASSES[$CLASS]} $CLASS/" >> $OUTPUT_FILE_COLOR
done

cat <<EOF >> $OUTPUT_FILE_COLOR
# Process GYPSY families
EOF

declare -A GYPSY_CLASSES=(
    ["Athila"]="#1f77b4"    # Blue
    ["Clade"]="#ff7f0e"     # Orange
    ["CRM"]="#2ca02c"       # Green
    ["Galadriel"]="#d62728" # Red
    ["Reina"]="#9467bd"     # Purple
    ["Retand"]="#8c564b"    # Brown
    ["Tekay"]="#e377c2"     # Pink
    ["unknown"]="#7f7f7f"   # Gray
)

for CLASS in "${!GYPSY_CLASSES[@]}"; do
    grep -h -e "$CLASS" $GYPSY_ARA $GYPSY_BRA | \
        cut -f 1 | sed -e 's/:/_/' -e 's/#.*//' -e "s/$/ ${GYPSY_CLASSES[$CLASS]} $CLASS/" >> $OUTPUT_FILE_COLOR
done

# Create the counts file
tail -n +31 "$SUMMARY_DIR" | head -n -49 | awk '{print $1 "," $2}' > counts.txt

cat counts.txt >> $OUTPUT_FILE_SIMPLEBAR