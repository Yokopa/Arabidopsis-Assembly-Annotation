#!/usr/bin/env bash

#================================================================
# SCRIPT NAME:
#   12_generate_nucmer_mummerplots.sh
#
# DESCRIPTION:
#   This script compares assembled genomes (Flye, Hifiasm, LJA) among each other
#   and against the Arabidopsis thaliana reference genome using nucmer.
#   It generates delta files for alignments and corresponding mummerplots.
#
# USAGE:
#   sbatch 12_generate_nucmer_mummerplots.sh
#
# INPUTS:
#   - Arabidopsis thaliana reference genome:  
#       /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
#   - Assembly files:
#       Flye:      $WORKDIR/outputs/05_flye/assembly.fasta
#       Hifiasm:   $WORKDIR/outputs/06_hifiasm/hifiasm.bp.p_ctg.fa
#       LJA:       $WORKDIR/outputs/07_lja/assembly.fasta
#
# OUTPUTS:
#   - Delta files: $WORKDIR/12_nucmer/
#   - Mummerplots: $WORKDIR/12_mummerplots/
#
# REQUIREMENTS:
#   - Apptainer/Singularity container: mummer4_gnuplot.sif
#   - Tools: nucmer, mummerplot
#
# NOTES:
#   - This script assumes input assemblies are available in the specified directories.
#   - Pairwise and reference comparisons are generated under respective subdirectories.
#================================================================

#SBATCH --time=05:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=nucmer_mummerplots
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/12_nucmer_mummerplots_output_%A.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/12_nucmer_mummerplots_error_%A.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory
CONTAINER_DIR=/containers/apptainer/mummer4_gnuplot.sif # Container path
REFERENCE_DIR=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
INPUT_DIR=$WORKDIR/outputs
OUTPUT_NUCMER=$INPUT_DIR/12_nucmer
OUTPUT_MUMMERPLOTS=$INPUT_DIR/12_mummerplots

mkdir -p $OUTPUT_NUCMER/pairwise $OUTPUT_MUMMERPLOTS/pairwise $OUTPUT_NUCMER/reference $OUTPUT_MUMMERPLOTS/reference

# compare each assembly to the REFERENCE and plot

#----------------- FLYE vs REF -----------------
# nucmer
apptainer exec --bind /data $CONTAINER_DIR nucmer \
    --mincluster 1000 \
    --breaklen 1000 \
    --delta $OUTPUT_NUCMER/reference/flye_vs_ref.delta \
    $REFERENCE_DIR $INPUT_DIR/05_flye/assembly.fasta
# mummerplot
apptainer exec --bind /data $CONTAINER_DIR mummerplot \
    -R $REFERENCE_DIR \
    -Q $INPUT_DIR/05_flye/assembly.fasta \
    --fat --layout --filter --breaklen 1000 -t png --large -p \
    $OUTPUT_MUMMERPLOTS/reference/flye_vs_ref $OUTPUT_NUCMER/reference/flye_vs_ref.delta

#----------------- HIFIASM vs REF -----------------
# nucmer
apptainer exec --bind /data $CONTAINER_DIR nucmer \
    --mincluster 1000 \
    --breaklen 1000 \
    --delta $OUTPUT_NUCMER/reference/hifiasm_vs_ref.delta \
    $REFERENCE_DIR $INPUT_DIR/06_hifiasm/hifiasm.bp.p_ctg.fa
# mummerplot
apptainer exec --bind /data $CONTAINER_DIR mummerplot \
    -R $REFERENCE_DIR \
    -Q $INPUT_DIR/06_hifiasm/hifiasm.bp.p_ctg.fa \
    --fat --layout --filter --breaklen 1000 -t png --large -p \
    $OUTPUT_MUMMERPLOTS/reference/hifiasm_vs_ref $OUTPUT_NUCMER/reference/hifiasm_vs_ref.delta

#----------------- LJA vs REF -----------------
# nucmer
apptainer exec --bind /data $CONTAINER_DIR nucmer \
    --mincluster 1000 \
    --breaklen 1000 \
    --delta $OUTPUT_NUCMER/reference/lja_vs_ref.delta \
    $REFERENCE_DIR $INPUT_DIR/07_lja/assembly.fasta
# mummerplot
apptainer exec --bind /data $CONTAINER_DIR mummerplot \
    -R $REFERENCE_DIR \
    -Q $INPUT_DIR/07_lja/assembly.fasta \
    --fat --layout --filter --breaklen 1000 -t png --large -p \
    $OUTPUT_MUMMERPLOTS/reference/lja_vs_ref $OUTPUT_NUCMER/reference/lja_vs_ref.delta

##################################################################

# compare the assemblies against EACH OTHER and plot

#----------------- FLYE vs HIFIASM -----------------
# nucmer
apptainer exec --bind $WORKDIR $CONTAINER_DIR nucmer \
    --mincluster 1000 \
    --breaklen 1000 \
    --delta $OUTPUT_NUCMER/pairwise/flye_vs_hifiasm.delta \
    $INPUT_DIR/05_flye/assembly.fasta $INPUT_DIR/06_hifiasm/hifiasm.bp.p_ctg.fa
# mummerplot
apptainer exec --bind $WORKDIR $CONTAINER_DIR mummerplot \
    -R $INPUT_DIR/05_flye/assembly.fasta \
    -Q $INPUT_DIR/06_hifiasm/hifiasm.bp.p_ctg.fa \
    --fat --layout --filter --breaklen 1000 -t png --large -p \
    $OUTPUT_MUMMERPLOTS/pairwise/flye_vs_hifiasm $OUTPUT_NUCMER/pairwise/flye_vs_hifiasm.delta

#----------------- FLYE vs LJA -----------------
# nucmer
apptainer exec --bind $WORKDIR $CONTAINER_DIR nucmer \
    --mincluster 1000 \
    --breaklen 1000 \
    --delta $OUTPUT_NUCMER/pairwise/flye_vs_lja.delta \
    $INPUT_DIR/05_flye/assembly.fasta $INPUT_DIR/07_lja/assembly.fasta
# mummerplot
apptainer exec --bind $WORKDIR $CONTAINER_DIR mummerplot \
    -R $INPUT_DIR/05_flye/assembly.fasta \
    -Q $INPUT_DIR/07_lja/assembly.fasta \
    --fat --layout --filter --breaklen 1000 -t png --large -p \
    $OUTPUT_MUMMERPLOTS/pairwise/flye_vs_lja $OUTPUT_NUCMER/pairwise/flye_vs_lja.delta

#----------------- HIFIASM vs LJA -----------------
# nucmer
apptainer exec --bind $WORKDIR $CONTAINER_DIR nucmer \
    --mincluster 1000 \
    --breaklen 1000 \
    --delta $OUTPUT_NUCMER/pairwise/hifiasm_vs_lja.delta \
    $INPUT_DIR/06_hifiasm/hifiasm.bp.p_ctg.fa $INPUT_DIR/07_lja/assembly.fasta
# mummerplot
apptainer exec --bind $WORKDIR $CONTAINER_DIR mummerplot \
    -R $INPUT_DIR/06_hifiasm/hifiasm.bp.p_ctg.fa \
    -Q $INPUT_DIR/07_lja/assembly.fasta \
    --fat --layout --filter --breaklen 1000 -t png --large -p \
    $OUTPUT_MUMMERPLOTS/pairwise/hifiasm_vs_lja $OUTPUT_NUCMER/pairwise/hifiasm_vs_lja.delta