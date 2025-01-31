#!/bin/bash

#SBATCH --time=10:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=omark
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/20_omark_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/20_omark_error_%j.e
#SBATCH --partition=pibu_el8

# ------------------------------------------------------------
# IMPORTANT! BEFORE SUBMITTING THIS SCRIPT, FOLLOW THESE STEPS
# TO SET UP THE NECESSARY CONDA ENVIRONMENT.

# NOTE: These steps are one-time setup steps to create the required 
# environment for running the script. Once the environment is created,
# you only need to activate it before running the script again.
# ------------------------------------------------------------
# Run these commands directly in the terminal at the prompt:

# 1) Start an interactive session on the cluster with:
# srun --time=02:00:00 --mem=4G --ntasks=1 --cpus-per-task=1 --partition=pibu_el8 --pty bash

# 2) Load the Conda module with:
# module load Anaconda3/2022.05 

# 3) Initialize Conda for use in the current shell with:
# eval "$(conda shell.bash hook)"

# 4) Create the necessary Conda environment with:
# conda env create -f /data/courses/assembly-annotation-course/CDS_annotation/containers/OMArk.yaml

# 5) Activate the environment:
# conda activate OMArk

# 6) Install additional packages inside the environment
# pip install omadb
# pip install gffutils

# ------------------------------------------------------------
# NOW YOU CAN SUBMIT THIS SCRIPT!:) 
# sbatch 20_omark.sh

# NOTE:
# - In future runs, you only need to activate the environment with:
#       module load Anaconda3/2022.05 
#       eval "$(conda shell.bash hook)"
#       conda activate OMArk
#
# - Stay in this environment to run the next script: 21_refine_gene_annotation.sh!
#
# - When finished, deactivate your environment with:
#       conda deactivate
# ------------------------------------------------------------

module add Anaconda3/2022.05

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/16_final_GENE"
OUTDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs/20_omark"

protein="$WORKDIR/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
isoform_list="$OUTDIR/isoform_list.txt"

mkdir -p $OUTDIR
cd $OUTDIR

# Download OMA database if necessary
if [ ! -f LUCA.h5 ]; then
    wget https://omabrowser.org/All/LUCA.h5
fi

# This command uses the omamer tool to perform a search in the LUCA.h5 database with the provided protein FASTA file ($protein)
omamer search --db "LUCA.h5" --query "$protein" --out "$OUTDIR/$(basename "$protein").omamer"

# Prepare isoform list
awk '/^>/ { 
    gene = gensub(/-[A-Z]+.*/, "", "g", substr($1, 2));
    isoform = substr($1, 2);
    genes[gene] = (genes[gene] ? genes[gene] ";" : "") isoform;
} END {
    for (g in genes) print genes[g];
}' "$protein" > "$isoform_list"

# Run OMArk
omark -f "$OUTDIR/$(basename "$protein").omamer" \
      -of "$protein" \
      -i "$isoform_list" \
      -d "LUCA.h5" \
      -o "$OUTDIR"



