#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   22_run_genespace.sh
#
# DESCRIPTION:
#   This script runs the GENESPACE pipeline for synteny and orthology-constrained 
#   comparative genomics analysis. It performs the following tasks:
#   1. Initializes the GENESPACE pipeline with the specified input directory.
#   2. Executes the pipeline using the R script `22_genespace.R` to generate synteny 
#      and orthology analyses.
#   3. Logs the output and error messages for tracking and debugging.
#
# USAGE:
#   sbatch 22_run_genespace.sh
#
# REQUIREMENTS:
#   - GENESPACE installed in the container specified.
#   - MCScanX installed and accessible in the container.
#   - Properly formatted GENESPACE input files located in the input directory.
#   - R script `22_genespace.R` located in the `scripts` directory of the working directory.
#
# INPUT:
#   - GENESPACE input directory containing genome annotations, peptide FASTA files, 
#     and configuration files (specified in `GENESPACE_FILES_DIR`).
#
# OUTPUT:
#   - All outputs generated by the GENESPACE pipeline will be saved in the same directory
#     as the input files.
#
# NOTES:
#   - Update file paths (e.g., `COURSEDIR`, `WORKDIR`, `GENESPACE_FILES_DIR`) to match your 
#     environment and input data locations.
#   - Ensure that the container file path (`genespace_latest.sif`) points to the correct container.
#   - This script relies on the R script `22_genespace.R`, which processes the input data 
#     located in `GENESPACE_FILES_DIR`.
#================================================================

#SBATCH --time=1-0
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=genespace
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/22_genespace_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/22_genespace_error_%j.e
#SBATCH --partition=pibu_el8

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"
GENESPACE_FILES_DIR="$WORKDIR/outputs/22_genespace"

apptainer exec \
    --bind $COURSEDIR \
    --bind $WORKDIR \
    --bind $SCRATCH:/temp \
    $COURSEDIR/containers/genespace_latest.sif Rscript $WORKDIR/scripts/22_genespace.R $GENESPACE_FILES_DIR

# apptainer shell \
#     --bind $COURSEDIR \
#     --bind $WORKDIR \
#     --bind $SCRATCH:/temp \
#     $COURSEDIR/containers/genespace_latest.sif