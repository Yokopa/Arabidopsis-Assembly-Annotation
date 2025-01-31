#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   07_classify_copia_gypsy_tesorter.sh
#
# DESCRIPTION:
#   This script extracts Copia and Gypsy sequences from the EDTA-generated TE library
#   and classifies them using the TEsorter tool (version 1.3.0). 
#   The process involves the following steps:
#   1. Extract Copia and Gypsy sequences from the TE library.
#   2. Run TEsorter on each sequence file to classify the transposable elements (TEs)
#      using a specified plant database (rexdb-plant).
#   3. The results, including annotated protein sequences and classifications, are saved
#      in the corresponding output directories for Copia and Gypsy.
#
# USAGE:
#   sbatch 07_classify_copia_gypsy_tesorter.sh
#
# DEPENDENCIES:
#   - SeqKit: For extracting specific sequences (Copia and Gypsy) from the TE library.
#   - Apptainer: For executing the TEsorter tool inside a container.
#   - TEsorter: For classifying transposable elements based on protein domains.
#
# OUTPUT:
#   - Copia sequences are classified and saved in `$WORKDIR/07_tesorter_copia/`.
#   - Gypsy sequences are classified and saved in `$WORKDIR/07_tesorter_gypsy/`.
#
# NOTE:
#   - Modify the `$WORKDIR` variable to point to the correct working directory.
#   - Ensure that the EDTA-generated TE library (`assembly.fasta.mod.EDTA.TElib.fa`)
#     is located in `$WORKDIR/01_edta_TE/`.
#   - TEsorter must be executed using the container located in `$CONTAINER`.
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --job-name=copia_gypsy_tesorter
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/07_copia_gypsy_tesorter_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/07_te_copia_gypsy_tesorter_error_%j.e
#SBATCH --partition=pibu_el8

# Load the SeqKit module (for sequence manipulation)
module load SeqKit/2.6.1

# Set up working directories for input files and output results
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs"
OUTDIR_COPIA="$WORKDIR/07_tesorter_copia"
OUTDIR_GYPSY="$WORKDIR/07_tesorter_gypsy"
CONTAINER="/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif"
INPUT_FILE="$WORKDIR/01_edta_TE/assembly.fasta.mod.EDTA.TElib.fa"

# Create directory to save outputs
mkdir -p $OUTDIR_COPIA $OUTDIR_GYPSY
cd $WORKDIR

# Extract Copia sequences from the EDTA TE library using SeqKit
seqkit grep -r -p "Copia" $INPUT_FILE > $OUTDIR_COPIA/copia_sequences.fa
# Extract Gypsy sequences from the EDTA TE library using SeqKit
seqkit grep -r -p "Gypsy" $INPUT_FILE > $OUTDIR_GYPSY/gypsy_sequences.fa

# Run TEsorter for Copia sequences using the Apptainer container
apptainer exec -C -H $WORKDIR \
  --writable-tmpfs -u $CONTAINER  \
  TEsorter $OUTDIR_COPIA/copia_sequences.fa -db rexdb-plant
# Move the classified Copia output files to the appropriate directory
mv copia_sequences.fa.rexdb-plant.* $OUTDIR_COPIA

# Run TEsorter for Gypsy sequences using the Apptainer container
apptainer exec -C -H $WORKDIR \
  --writable-tmpfs -u $CONTAINER  \
  TEsorter $OUTDIR_GYPSY/gypsy_sequences.fa -db rexdb-plant
# Move the classified Gypsy output files to the appropriate directory
mv gypsy_sequences.fa.rexdb-plant.* $OUTDIR_GYPSY
