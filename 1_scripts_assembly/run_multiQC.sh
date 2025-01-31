#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   run_multiqc.sh
#
# DESCRIPTION: 
#   This script runs MultiQC to aggregate and visualize FastQC output 
#   from multiple users.
#
# USAGE:
#   sbatch run_multiqc.sh
#
# NOTES:
#   - Modify the FASTQC_OUTPUTS variable to include all necessary paths.
#================================================================

#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=multiqc_analysis
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/multiqc_output_%A.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/multiqc_error_%A.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly
OUTPUT_DIR="$WORKDIR/outputs/multiqc"

# Set paths for FastQC output directories
FASTQC_OUTPUTS_DNA=(
    "/data/users/ascarpellini/assembly_annotation_course24/read_QC/fastqc/ERR11437323_fastqc.zip" # Abd-0 Michaela

    #"/data/users/harribas/assembly_course/fastQC/ERR11437324_fastqc.zip" # Altai-5 Hector
    
    "$WORKDIR/outputs/01_fastqc/Qar-8a_dna_fastqc.zip" # Qar-8a Anna

    #"/data/users/lwuetschert/assembly-annotation-course/read_QC/ERR11437341_fastqc.zip" # St-0 Léo

    "/data/users/mjopiti/assembly-course/read_QC/FastQC_results/genomic/ERR11437319_fastqc.zip" # Ishikawa Michael
)

# FASTQC_OUTPUTS_RNA_1=(
#     "$WORKDIR/read_QC/FastQC/rna_ERR754081_1_fastqc.zip" # 1 - Anna

#     "/data/users/ascarpellini/assembly_annotation_course24/read_QC/fastqc/ERR754081_1_fastqc.zip" # 1 - Michaela

#     "/path/to/user3/fastqc_output"

#     "/path/to/user3/fastqc_output"

#     "/path/to/user3/fastqc_output"

#     "/path/to/user3/fastqc_output"
# )

# FASTQC_OUTPUTS_RNA_2=(
#     "$WORKDIR/read_QC/FastQC/rna_ERR754081_2_fastqc.zip" # 2 - Anna

#     "/data/users/ascarpellini/assembly_annotation_course24/read_QC/fastqc/ERR754081_2_fastqc.zip" # 2 - Michaela

#     "/path/to/user3/fastqc_output"

#     "/path/to/user3/fastqc_output"

#     "/path/to/user3/fastqc_output"

#     "/path/to/user3/fastqc_output"
# )

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Load MultiQC module
module load MultiQC

# Run MultiQC on the specified FastQC output directories
multiqc "${FASTQC_OUTPUTS_DNA[@]}" -o $OUTPUT_DIR
# multiqc "${FASTQC_OUTPUTS_RNA_1[@]}" -o $OUTPUT_DIR
# multiqc "${FASTQC_OUTPUTS_RNA_2[@]}" -o $OUTPUT_DIR

echo "MultiQC report generated in $OUTPUT_DIR."
