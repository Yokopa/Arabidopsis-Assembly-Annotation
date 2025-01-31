#!/bin/bash

#================================================================
# SCRIPT NAME: 
#   24_extract_numbers.sh
#
# DESCRIPTION:
#   This script extracts key statistics from genome annotation files, including 
#   the number of genes in raw and filtered GFF files, the number of genes with and without BLAST hits. 
#================================================================

#SBATCH --time=00:10:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --job-name=extract_numbers
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/extract_number__final_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/extract_number_final_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs"

# Input files
RAW_GENE_GFF="$WORKDIR/15_prepared_maker_output/assembly.all.maker.gff"
MAKER_GFF="$WORKDIR/16_final_GENE/filtered.genes.renamed.final.gff3"
BLAST_GFF="$WORKDIR/19_blast/filtered.genes.renamed.final.gff3.Uniprot.gff3"
BLAST_TXT="$WORKDIR/19_blast/blastp_output.txt"
OMARK_OUTPUT="$WORKDIR/20_omark/assembly.all.maker.proteins.fasta.renamed.filtered.fasta.omamer"

# Output summary file
SUMMARY_FILE="$WORKDIR/final_genome_annotation_notes.txt"

# Initialize summary file
echo "Genome Annotation Notes" > $SUMMARY_FILE

# Number of Genes (from raw GFF file)
raw_num_genes=$(grep -c -P '\tmaker\tgene\t' $RAW_GENE_GFF)
echo "Number of Genes (Raw): $raw_num_genes" >> $SUMMARY_FILE

# Number of Filtered Genes (from final GFF file)
filtered_num_genes=$(grep -c -P '\tmaker\tgene\t' $MAKER_GFF)
echo "Number of Filtered Genes: $filtered_num_genes" >> $SUMMARY_FILE

# Genes with meaningful BLAST hits 
blast_hit_genes=$(cut -f1 $BLAST_TXT | sort | uniq | wc -l)
echo "Genes with BLAST Hits: $blast_hit_genes" >> $SUMMARY_FILE

# Genes without BLAST Hits
genes_without_hits=$((filtered_num_genes - blast_hit_genes))
echo "Genes without BLAST Hits: $genes_without_hits" >> $SUMMARY_FILE
