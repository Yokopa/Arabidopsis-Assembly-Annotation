#!/usr/bin/env bash

#================================================================
# SCRIPT NAME:
#   13_generate_control_files_maker.sh
#
# DESCRIPTION:
#   This script generates the necessary control files for the MAKER genome annotation pipeline.
#   The MAKER pipeline is used for eukaryotic genome annotation and integrates ab initio gene prediction, 
#   RNA-Seq data, and protein homology to generate high-quality gene models. The control files generated
#   are required to run MAKER on the genome, which includes specifying genome sequence, transcript evidence, 
#   protein homology evidence, and repeat masking options. The script runs the MAKER container to generate 
#   the control files.
#
# USAGE:
#   sbatch 13_generate_control_files_maker.sh
#
# DEPENDENCIES:
#   - Apptainer: For running the MAKER tool inside a container.
#   - MAKER: For generating the control files necessary to run genome annotation.
#
# OUTPUT:
#   - MAKER control files will be generated in the specified `$WORKDIR`.
#   - These control files are required for running the full MAKER pipeline to annotate the genome.
#
# NOTE:
#   - Modify the `$WORKDIR` variable to point to the correct working directory for your project.
#   - Ensure that the necessary genome assembly, transcript files, and protein sequences are available in the 
#     specified paths in the `maker_opts.ctl` file.
#   - MAKER must be executed using the container located in `$CONTAINER`.
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=05:00:00
#SBATCH --job-name=control_files_maker
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/13_control_files_maker_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/13_control_files_maker_error_%j.e
#SBATCH --partition=pibu_el8

# Define the working directory where all annotation-related files will be stored
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/13_control_files_maker"
# Define the location of the MAKER container image
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"
# Create the working directory if it does not exist
mkdir -p $WORKDIR
# Change to the working directory
cd $WORKDIR

# Run the MAKER pipeline with the '-CTL' flag to generate the control files for annotation
# The 'apptainer' command is used to run the MAKER container, binding the current working directory 
# to the container environment to ensure all necessary files are accessible.

# Explanation of the command:
# - apptainer exec: Executes a command inside the container.
# - --bind $WORKDIR: Binds the current working directory ($WORKDIR) to the container.
# - $CONTAINER: The container image that contains the MAKER pipeline (MAKER_3.01.03.sif).
# - maker -CTL: The MAKER command to generate the control files needed for genome annotation.
apptainer exec --bind $WORKDIR \
$CONTAINER maker -CTL