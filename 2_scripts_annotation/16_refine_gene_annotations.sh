#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   16_refine_gene_annotations.sh
#
# DESCRIPTION:
# This script finalizes the annotation process by performing several steps:
# 1. Runs InterProScan on the provided protein file.
# 2. Uses Maker tools to map IDs and update GFF and FASTA files with the new, clean IDs.
# 3. Updates the GFF file with InterProScan results and filters it for quality.
# 4. Extracts mRNA entries from the filtered GFF file and generates a list of IDs.
# 5. Uses the list of IDs to filter the transcript and protein FASTA files, creating new filtered FASTA files.
#
# USAGE:
#   sbatch 16_refine_gene_annotations.sh
#
# DEPENDENCIES:
#   - MAKER tools: `maker_map_ids`, `map_gff_ids`, `map_fasta_ids`, and `ipr_update_gff`.
#   - InterProScan: For functional domain annotations.
#   - UCSC-Utils: For filtering FASTA files.
#   - Perl: For AED calculation script.
#
# INPUT:
#   - GFF3, transcript FASTA, and protein FASTA from MAKER output.
#
# OUTPUT:
#   - Refined GFF3 and FASTA files with consistent IDs and quality filtering.
#
# NOTE:
#   - Update paths for `$WORKDIR`, `$COURSEDIR`, and other variables to match your setup.
#================================================================

#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --time=24:00:00
#SBATCH --job-name=refine_annotations
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/16_refine_annotations_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/16_refine_annotations_error_%j.e
#SBATCH --partition=pibu_el8

module load UCSC-Utils/448-foss-2021a
module load BioPerl/1.7.8-GCCcore-10.3.0
module load MariaDB/10.6.4-GCC-10.3.0

# Define variables
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation/outputs"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
CPU=8 # Number of CPUs for InterProScan
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

cd $WORKDIR/15_prepared_maker_output

# Input files
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta" 
gff="assembly.all.maker.noseq.gff" 
prefix="Qar-8a" # 3-4 letter prefix for your accession.

# Create output directory
FINALDIR="${WORKDIR}/16_final_GENE"
mkdir -p $FINALDIR

# Create a directory to store the final files after filtering them based on AED values and InterProScan annotations
cp $gff $FINALDIR/${gff}.renamed.gff
cp $protein $FINALDIR/${protein}.renamed.fasta 
cp $transcript $FINALDIR/${transcript}.renamed.fasta

cd $FINALDIR

# Give clean gene names, update the gff and fasta files
$MAKERBIN/maker_map_ids --prefix $prefix --justify 7 $gff.renamed.gff > id.map
$MAKERBIN/map_gff_ids id.map $gff.renamed.gff
$MAKERBIN/map_fasta_ids id.map ${protein}.renamed.fasta
$MAKERBIN/map_fasta_ids id.map ${transcript}.renamed.fasta

# Run InterProScan using the container
apptainer exec \
    --bind $COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data \
    --bind $WORKDIR \
    --bind $COURSEDIR \
    --bind $SCRATCH:/temp \
    $COURSEDIR/containers/interproscan_latest.sif \
    /opt/interproscan/interproscan.sh \
    -appl pfam --disable-precalc -f TSV \
    --goterms --iprlookup --seqtype p \
    -i ${protein}.renamed.fasta -o output.iprscan

# here we are using interproscan on only pfam analysis, you can use other analysis as well
# example: -appl CDD,COILS,Gene3D,HAMAP,MobiDBLite,PANTHER,Pfam,PIRSF,PRINTS,PROSITEPATTERNS,PROSITEPROFILES,SFLD,SMART,SUPERFAMILY,TIGRFAM 
# a list of all analyses can be found here: https://interproscan-docs.readthedocs.io/en/latest/HowToRun.html#included-analyses

# Update the gff file with InterProScan results and filter it for quality
$MAKERBIN/ipr_update_gff ${gff}.renamed.gff output.iprscan > ${gff}.renamed.iprscan.gff

# Get the AED values for the genes
perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 ${gff}.renamed.gff > assembly.all.maker.renamed.gff.AED.txt
# plot the AED values. 
# Question: Are most of your genes in the range 0-0.5 AED?

# Filter the gff file based on AED values and Pfam domains
#perl $MAKERBIN/quality_filter.pl -s ${gff}.renamed.iprscan.gff > ${gff}_iprscan_quality_filtered.gff
# In the above command: -s  Prints transcripts with an AED <1 and/or Pfam domain if in gff3 
## Note: When you do QC of your gene models, you will see that AED <1 is not sufficient. We should rather have a script with AED <0.5
# From quality_filter.pl :
#       USAGE: quality_filter.pl -[options]<gff3_file>\n                                                                               
#       OPTIONS: -d  Prints transcripts with an AED <1 (MAKER default)         
#               -s  Prints transcripts with an AED <1 and/or Pfam domain 
#                    if in gff3 (MAKER Standard)
#               -a  <number between 0 and 1> Prints transcripts with an 
#                    AED < the given value\n\n"

perl $MAKERBIN/quality_filter.pl -a 0.5 ${gff}.renamed.iprscan.gff > ${gff}_iprscan_quality_filtered.gff

# The gff also contains other features like Repeats, and match hints from different sources of evidence
# Let's see what are the different types of features in the gff file
cut -f3 ${gff}_iprscan_quality_filtered.gff | sort | uniq

# We only want to keep gene features in the third column of the gff file
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" ${gff}_iprscan_quality_filtered.gff > filtered.genes.renamed.gff3
cut -f3 filtered.genes.renamed.gff3 | sort | uniq

# We need to add back the gff3 header to the filtered gff file so that it can be used by other tools
grep "^#" ${gff}_iprscan_quality_filtered.gff > header.txt
cat header.txt filtered.genes.renamed.gff3 > filtered.genes.renamed.final.gff3

# Get the names of remaining mRNAs and extract them from the transcript and and their proteins from the protein files
grep -P "\tmRNA\t" filtered.genes.renamed.final.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' >mRNA_list.txt
faSomeRecords ${transcript}.renamed.fasta mRNA_list.txt ${transcript}.renamed.filtered.fasta
faSomeRecords ${protein}.renamed.fasta mRNA_list.txt ${protein}.renamed.filtered.fasta




