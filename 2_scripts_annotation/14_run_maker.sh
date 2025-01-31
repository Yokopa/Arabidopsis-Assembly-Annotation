#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   14_run_maker.sh
#
# DESCRIPTION:
#   This script executes the MAKER genome annotation pipeline
#   using MPI for parallel execution. It leverages control files
#   to specify the necessary parameters for the annotation process.
#   The script uses the MAKER container image for execution, and 
#   various tools like Augustus and RepeatMasker for gene prediction
#   and repeat masking. The steps involve the following:
#   1. Setup directories for output and control files.
#   2. Load necessary modules for running the MAKER pipeline.
#   3. Bind required directories to the container using Apptainer.
#   4. Run MAKER with MPI parallelism for improved performance.
#   5. Direct the output of MAKER to the specified output directory.
#
# USAGE:
#   sbatch 14_run_maker.sh
#
# DEPENDENCIES:
#   - Apptainer: For containerized execution of MAKER.
#   - MAKER (inside the container): Genome annotation pipeline.
#   - OpenMPI: For parallel execution of MAKER using multiple tasks.
#   - Augustus: For ab initio gene prediction.
#   - RepeatMasker: For repeat masking.
#
# OUTPUT:
#   The annotated genome and other intermediate results will be
#   stored in the directory specified by $OUTDIR.
#
# NOTE:
#   - Ensure that the control files (maker_opts.ctl, maker_bopts.ctl, etc.)
#     are correctly configured with the necessary file paths (e.g., genome,
#     transcript data, protein homology evidence).
#   - Adjust $WORKDIR and other variables to reflect the correct paths 
#     for your data.
#================================================================

#SBATCH --time=4-0
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --job-name=maker
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/14_maker_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/14_maker_error_%j.e
#SBATCH --partition=pibu_el8

# Define directories
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation" # Path to course directory with resources
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/" # Path to working directory
CONTROL_FILES_DIR="$WORKDIR/genome_annotation/outputs/13_control_files_maker" # Path to the directory containing MAKER control files
OUTDIR="$WORKDIR/genome_annotation/outputs/14_maker_GENE" # Path where output files will be saved

REPEATMASKER_DIR="/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker" # Path to RepeatMasker
export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker" # Add RepeatMasker to PATH

# Load necessary modules
module load OpenMPI/4.1.1-GCC-10.3.0 # Load OpenMPI for parallel execution
module load AUGUSTUS/3.4.0-foss-2021a # Load Augustus for gene prediction

# Create output directory if it doesn't exist
mkdir -p $OUTDIR # Make output directory
cd $OUTDIR # Navigate to output directory

# Run MAKER with MPI for parallel execution
mpiexec --oversubscribe -n 50 apptainer exec \
    --bind $SCRATCH:/TMP --bind $COURSEDIR --bind $AUGUSTUS_CONFIG_PATH --bind $REPEATMASKER_DIR --bind $WORKDIR \
    ${COURSEDIR}/containers/MAKER_3.01.03.sif \
    maker -mpi --ignore_nfs_tmp -TMP /TMP \
    $CONTROL_FILES_DIR/maker_opts.ctl \
    $CONTROL_FILES_DIR/maker_bopts.ctl \
    $CONTROL_FILES_DIR/maker_evm.ctl \
    $CONTROL_FILES_DIR/maker_exe.ctl