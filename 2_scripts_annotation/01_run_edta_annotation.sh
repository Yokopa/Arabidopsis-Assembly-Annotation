#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   01_edta_annotation.sh
#
# DESCRIPTION: 
#   This script runs EDTA (TE detection tool) on a genome assembly to identify 
#   transposable elements (TEs) in the genome. It uses an Apptainer container 
#   to execute the EDTA pipeline. The output will be stored in the path set to 
#   the `OUTDIR` variable.
#
# USAGE:
#   sbatch 01_edta_annotation.sh
#
#   Modify the `ASSEMBLY` variable in the script to change the input genome assembly file.
#   No command-line arguments are needed. Simply edit the path to your genome assembly
#   in the script and run the script.
#================================================================

#SBATCH --time=24:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=20
#SBATCH --job-name=EDTA_annotation
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/01_edta_annotation_output_%A.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/01_edta_annotation_error_%A.e
#SBATCH --partition=pibu_el8

# Set the working directory
WORKDIR="/data/users/ascarpellini/assembly_annotation_course"

# The path to the genome assembly file in FASTA format that will be annotated for transposable elements.
# Modify this variable to change the path to your input genome assembly file.
# You can update this path manually depending on the genome you want to analyze.
ASSEMBLY="$WORKDIR/genome_transcriptome_assembly/outputs/05_flye/assembly.fasta" 
# The directory where the EDTA output files will be stored.
OUTDIR="$WORKDIR/genome_annotation/outputs/01_edta_TE"
LOGDIR="$WORKDIR/genome_annotation/logs"

# Path to the CDS (Coding Sequence) annotation file used in EDTA for gene identification.
# This annotation helps EDTA detect genes for TE prediction.
CDS="/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated"
# The path to the Apptainer container that includes the EDTA software and its dependencies.
CONTAINER="/data/courses/assembly-annotation-course/containers2/EDTA_v1.9.6.sif EDTA.pl"

# Create the output and logs directories if they do not exist
mkdir -p $OUTDIR $LOGDIR

# Change to the output directory before running the pipeline
cd $OUTDIR

# Run EDTA using Apptainer
# - The --bind /data option ensures that the /data directory is accessible inside the container
# - -H ${pwd}:/work binds the current directory to /work inside the container
# - --writable-tmpfs allows the container to write temporary data to memory
# - --genome specifies the genome assembly file to analyze
# - --species specifies the species; "others" is used here for species not in the default list
# - --step all specifies that all steps of EDTA should be executed
# - --cds specifies the CDS annotation file to be used for gene prediction
# - --anno 1 enables annotation of the TEs
# - --threads specifies the number of threads to be used by the pipeline (20 in this case)
apptainer exec -C --bind /data -H ${pwd}:/work \
    --writable-tmpfs -u $CONTAINER \
    --genome $ASSEMBLY \
    --species others \
    --step all \
    --cds $CDS \
    --anno 1 \
    --threads 20
