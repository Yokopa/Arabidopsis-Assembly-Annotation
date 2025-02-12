#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   02_get_clades_tesorter.sh
#
# DESCRIPTION: 
#   This script runs TEsorter to classify transposable elements (TEs) 
#   into their respective clades based on the input genome assembly. 
#   The input file is a filtered sequence of transposable elements 
#   identified by the EDTA pipeline. TEsorter assigns TE sequences to 
#   known clades using a pre-built plant database (rexdb-plant).
#
# USAGE:
#   sbatch 02_get_clades_tesorter.sh
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --job-name=get_clades_tesorter
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/02_get_clades_tesorter_output_%A.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/02_get_clades_tesorter_error_%A.e
#SBATCH --partition=pibu_el8

# Working directory
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"

# The path to the input file, which is a FASTA file containing transposable element sequences 
# identified by the EDTA pipeline. This file will be used by TEsorter to assign each TE to its clade.
INPUT="$WORKDIR/outputs/01_edta_TE/assembly.fasta.mod.EDTA.raw/LTR/assembly.fasta.mod.LTR.intact.fa"
# The output directory where the classified TE sequences will be stored.
# The output will contain files generated by TEsorter after clade assignment.
OUTDIR="$WORKDIR/outputs/02_tesorter_TE"

# The path to the Apptainer container that includes the TEsorter software and its dependencies.
CONTAINER="/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif"

# Go to working directory and create output directory
mkdir -p $OUTDIR
# Change to the working directory before executing the pipeline
cd $WORKDIR

# Run TEsorter using Apptainer to classify transposable elements.
# The command runs inside the container with the following options:
# - -C: Clear the container's cache (useful for fresh execution).
# - -H: Bind the working directory to the container, allowing access to the input files and output directories.
# - --writable-tmpfs: Use temporary writable storage to improve performance.
# - -u $CONTAINER: Specify the container image to be used (TEsorter).
# - TEsorter $INPUT -db rexdb-plant: The TEsorter command, specifying the input file and the database (rexdb-plant).
apptainer exec -C -H $WORKDIR \
  --writable-tmpfs -u $CONTAINER \
  TEsorter $INPUT -db rexdb-plant

mv assembly.fasta.mod.LTR.intact.fa.rexdb-plant.* $OUTDIR
