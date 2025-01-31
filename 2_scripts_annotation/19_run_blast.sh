#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   19_blast.sh
#
# DESCRIPTION:
#   This script performs functional annotation of protein sequences 
#   using BLAST+ against the UniProt database and integrates results 
#   into the MAKER GFF and FASTA files. It automates the following:
#   1. Runs `blastp` to align protein sequences against the UniProt 
#      Viridiplantae reviewed database.
#   2. Updates MAKER annotation files with functional annotations 
#      from BLAST results.
#
# USAGE:
#   sbatch 19_blast.sh
#
# REQUIREMENTS:
#   - BLAST+ (2.15.0 or compatible).
#   - MAKER tools: `maker_functional_fasta` and `maker_functional_gff`.
#   - UniProt database (`uniprot_viridiplantae_reviewed.fa`) properly formatted 
#     as a BLAST database (use `makeblastdb` if not already done).
#
# INPUT:
#   - Protein FASTA file: MAKER output renamed and filtered proteins.
#   - GFF3 file: MAKER filtered GFF file.
#   - BLAST database: UniProt Viridiplantae reviewed sequences.
#
# OUTPUT:
#   - Updated FASTA file with functional annotations.
#   - Updated GFF3 file with functional annotations.
#================================================================

#SBATCH --time=1-0
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=blast
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/19_blast_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/19_blast_error_%j.e
#SBATCH --partition=pibu_el8

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs"
OUTDIR="$WORKDIR/19_blast"

protein="$WORKDIR/16_final_GENE/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
gff="$WORKDIR/16_final_GENE/filtered.genes.renamed.final.gff3"
# Extract filenames for proper output naming
protein_basename=$(basename "$protein")
gff_basename=$(basename "$gff")

MAKERBIN="/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin/"
uniprot_fasta="/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa"

mkdir -p $OUTDIR
cd $OUTDIR

module load BLAST+/2.15.0-gompi-2021a
# makeblastb -in <uniprot_fasta> -dbtype prot # this step is already done

blastp -query $protein -db $uniprot_fasta -num_threads 10 -outfmt 6 -evalue 1e-10 -out blastp_output.txt
cp "$protein" "$OUTDIR/${protein_basename}.Uniprot"
cp "$gff" "$OUTDIR/${gff_basename}.Uniprot"


# Update FASTA file with functional annotations
$MAKERBIN/maker_functional_fasta "$uniprot_fasta" blastp_output.txt "$protein" > "$OUTDIR/${protein_basename}.Uniprot"
# Update GFF3 file with functional annotations
$MAKERBIN/maker_functional_gff "$uniprot_fasta" blastp_output.txt "$gff" > "$OUTDIR/${gff_basename}.Uniprot.gff3"
