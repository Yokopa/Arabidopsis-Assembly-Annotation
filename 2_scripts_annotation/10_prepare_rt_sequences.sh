#!/usr/bin/env bash

#================================================================
# SCRIPT NAME:
#   10_prepare_rt_sequences.sh
#
# DESCRIPTION:
#   This script extracts reverse transcriptase (RT) sequences from Copia and Gypsy 
#   transposable elements (TEs) in Arabidopsis thaliana and the Brassicaceae family. 
#   The process involves the following steps:
#   1. Extract Copia and Gypsy sequences from Brassicaceae RepBase file.
#   2. Run TEsorter on Brassicaceae sequences to classify Gypsy and Copia families.
#   3. Extract RT sequences for Arabidopsis from pre-classified TE files.
#   4. Extract RT sequences for Brassicaceae using TEsorter classification results (from step 2).
#
# USAGE:
#   sbatch 10_prepare_rt_sequences.sh
#
# DEPENDENCIES:
#   - SeqKit: For extracting RT sequences.
#   - Apptainer: For executing the TEsorter tool inside a container.
#   - TEsorter: For classifying transposable elements based on protein domains.
#
# INPUTS:
#   - Arabidopsis: Pre-classified TE files located in:
#     `$WORKDIR/outputs/07_tesorter_<FAMILY>/<FAMILY>_sequences.fa.rexdb-plant.dom.faa`
#   - Brassicaceae: RepBase sequence file located at:
#     `/data/courses/assembly-annotation-course/CDS_annotation/data/Brassicaceae_repbase_all_march2019.fasta`
#
# OUTPUT:
#   - Arabidopsis RT sequences are saved in `$OUTDIR/<FAMILY>_RT_arabidopsis.fasta`.
#   - Brassicaceae RT sequences are saved in `$OUTDIR/<FAMILY>_RT_brassicaceae.fasta`.
#
# NOTES:
#   - Ensure that the paths to input files and containers are correctly defined.
#   - Modify `$WORKDIR` if working in a different directory.
#   - TEsorter Brassicaceae output files are organized under `$OUTDIR/tesorter`.
#================================================================

#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=prepare_rt_sequences
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/10_prepare_rt_sequences_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/10_prepare_rt_sequences_error_%j.e
#SBATCH --partition=pibu_el8

# Load necessary modules
module load SeqKit/2.6.1

# Set paths
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"
OUTDIR="$WORKDIR/outputs/10_rt_sequences"

# Create output directories
mkdir -p $OUTDIR
echo "Output directories created: $OUTDIR"

# -- Step 1: Extract Copia and Gypsy sequences from Brassicaceae --
# Paths for RepBase file and output directories
INPUT_FILE="/data/courses/assembly-annotation-course/CDS_annotation/data/Brassicaceae_repbase_all_march2019.fasta"
OUTDIR_COPIA_BRAS="$OUTDIR/tesorter_copia_brassicaceae"
OUTDIR_GYPSY_BRAS="$OUTDIR/tesorter_gypsy_brassicaceae"
CONTAINER="/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif"

# Create directories for TEsorter output
mkdir -p $OUTDIR_COPIA_BRAS $OUTDIR_GYPSY_BRAS
echo "Created directories for Copia and Gypsy sequences: $OUTDIR_COPIA_BRAS, $OUTDIR_GYPSY_BRAS"

# Extract Copia and Gypsy sequences using SeqKit
echo "Extracting Copia sequences from RepBase file..."
seqkit grep -r -p "Copia" $INPUT_FILE > $OUTDIR_COPIA_BRAS/copia_sequences_brassicaceae.fa
echo "Extracting Gypsy sequences from RepBase file..."
seqkit grep -r -p "Gypsy" $INPUT_FILE > $OUTDIR_GYPSY_BRAS/gypsy_sequences_brassicaceae.fa

# Run TEsorter for Copia sequences
apptainer exec -C -H $WORKDIR --writable-tmpfs -u $CONTAINER \
  TEsorter $OUTDIR_COPIA_BRAS/copia_sequences_brassicaceae.fa -db rexdb-plant
mv $WORKDIR/copia_sequences_brassicaceae.fa.rexdb-plant.* $OUTDIR_COPIA_BRAS
if [ $? -eq 0 ]; then
    echo "TEsorter successfully completed for Copia sequences."
    mv copia_sequences_brassicaceae.fa.rexdb-plant.* $OUTDIR_COPIA_BRAS
else
    echo "Error running TEsorter for Copia sequences." >&2
    exit 1
fi

# Run TEsorter for Gypsy sequences
apptainer exec -C -H $WORKDIR --writable-tmpfs -u $CONTAINER \
  TEsorter $OUTDIR_GYPSY_BRAS/gypsy_sequences_brassicaceae.fa -db rexdb-plant
mv $WORKDIR/gypsy_sequences_brassicaceae.fa.rexdb-plant.* $OUTDIR_GYPSY_BRAS
if [ $? -eq 0 ]; then
    echo "TEsorter successfully completed for Gypsy sequences."
    mv gypsy_sequences_brassicaceae.fa.rexdb-plant.* $OUTDIR_GYPSY_BRAS
else
    echo "Error running TEsorter for Gypsy sequences." >&2
    exit 1
fi

# -- Step 2: Extract RT sequences for Arabidopsis --
# Arabidopsis RT sequences are already available, so we directly extract them
echo "Extracting RT sequences for Arabidopsis..."
for FAMILY in "gypsy" "copia"; do
    INPUT_FILE="$WORKDIR/outputs/07_tesorter_${FAMILY}/${FAMILY}_sequences.fa.rexdb-plant.dom.faa"
    OUTPUT_LIST="$OUTDIR/${FAMILY}_list_arabidopsis.txt"
    OUTPUT_FASTA="$OUTDIR/${FAMILY}_RT_arabidopsis.fasta"
    
    # Check which family we're processing and set the RT type accordingly
    if [ "$FAMILY" == "gypsy" ]; then
        RT_TYPE="Ty3-RT"  # Gypsy uses Ty3-RT
    elif [ "$FAMILY" == "copia" ]; then
        RT_TYPE="Ty1-RT"  # Copia uses Ty1-RT
    fi

    # Extract RT sequences for Arabidopsis (Ty1-RT for Copia, Ty3-RT for Gypsy)
    echo "Extracting RT sequences for Arabidopsis $FAMILY..."
    grep "$RT_TYPE" $INPUT_FILE > $OUTPUT_LIST
    sed -i 's/>//' $OUTPUT_LIST #remove ">" from the header
    sed -i 's/ .\+//' $OUTPUT_LIST #remove all characters following "empty space" from the header
    seqkit grep -f $OUTPUT_LIST $INPUT_FILE -o $OUTPUT_FASTA
    if [ $? -eq 0 ]; then
        echo "Successfully extracted RT sequences for Arabidopsis $FAMILY."
    else
        echo "Error extracting RT sequences for Arabidopsis $FAMILY." >&2
        exit 1
    fi
done

# -- Step 3: Extract RT sequences for Brassicaceae --
# Extract RT sequences for Gypsy and Copia in Brassicaceae using TEsorter output
echo "Extracting RT sequences for Brassicaceae..."
for FAMILY in "gypsy" "copia"; do
    # Correct the path based on TEsorter output for Brassicaceae
    if [ "$FAMILY" == "gypsy" ]; then
        INPUT_FILE="$OUTDIR/tesorter_gypsy_brassicaceae/gypsy_sequences_brassicaceae.fa.rexdb-plant.dom.faa"
    elif [ "$FAMILY" == "copia" ]; then
        INPUT_FILE="$OUTDIR/tesorter_copia_brassicaceae/copia_sequences_brassicaceae.fa.rexdb-plant.dom.faa"
    fi
    
    OUTPUT_LIST="$OUTDIR/${FAMILY}_list_brassicaceae.txt"
    OUTPUT_FASTA="$OUTDIR/${FAMILY}_RT_brassicaceae.fasta"
    
    # Check which family we're processing and set the RT type accordingly
    if [ "$FAMILY" == "gypsy" ]; then
        RT_TYPE="Ty3-RT"  # Gypsy uses Ty3-RT
    elif [ "$FAMILY" == "copia" ]; then
        RT_TYPE="Ty1-RT"  # Copia uses Ty1-RT
    fi

    # Extract RT sequences for Brassicaceae (Ty3-RT for Gypsy, Ty1-RT for Copia)
    echo "Extracting RT sequences for Brassicaceae $FAMILY..."
    grep "$RT_TYPE" $INPUT_FILE > $OUTPUT_LIST
    sed -i 's/>//' $OUTPUT_LIST
    sed -i 's/ .\+//' $OUTPUT_LIST
    seqkit grep -f $OUTPUT_LIST $INPUT_FILE -o $OUTPUT_FASTA
    if [ $? -eq 0 ]; then
        echo "Successfully extracted RT sequences for Brassicaceae $FAMILY."
    else
        echo "Error extracting RT sequences for Brassicaceae $FAMILY." >&2
        exit 1
    fi
done

echo "RT sequence preparation completed for both Arabidopsis and Brassicaceae!"